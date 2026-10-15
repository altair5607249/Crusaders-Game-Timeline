--meant to be kind to/tolerant of laggy players

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local cooldownManager = require(SSS.ModuleLoader.Managers.CooldownManager)
local stunManager = require(SSS.ModuleLoader.Managers.StunManager)

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local dashChecks = 8
local minPeriod = 0.05
local period = 0.1 --how often the anticheat checks movement (in seconds)
local paddingFreq = 60 --to be scaled with the periodic cycle, since padding adds flat rates
local padding = paddingFreq * period --for network jitter, packet burstiness, physics interpolation, etc.

local movementSpecs = {
	dashSpecs = {
		DashForward = {"FrontDash", 1, "DashActive"},
		DashBackward = {"AuxDash", 2, "DashActive"},
		DashRight = {"AuxDash", 2, "DashActive"},
		DashLeft = {"AuxDash", 2, "DashActive"}
	},
	runSpecs = {
		Sprint = {nil, nil, "SprintActive"},
		Walk = {nil, nil, nil}
	}
}

--crude token bucket scheme that i learned as i built it for this anticheat's tolerance
local tokenRegistry = {}
type TokenStructure = {timeCredit: number, maxCredit: number}

local function maxWalkDistance(player: Player, elapsed: number, latency: number, tokenData: TokenStructure)
	local crusader = player:GetAttribute("Crusader")
	local char = player.Character or player.CharacterAdded:Wait()
	local walkSpeed: number = (char:HasTag("Running") and spacing.GetValue(crusader, 2)) or spacing.GetValue(crusader, 1)
	
	tokenData.timeCredit = math.min(tokenData.maxCredit, tokenData.timeCredit + elapsed)
	
	local distance = (walkSpeed * tokenData.timeCredit) + padding/4
	
	return distance, walkSpeed
end

local function dashDisplacement(b: number, d: number, x: number)
	return -(b^2 * x^3)/3 + d*x
end

local function maxDashDistance(player: Player, elapsed: number, latency: number)
	local lastFrontDash, lastAuxDash = player:GetAttribute("LastFrontDash"), player:GetAttribute("LastAuxDash")
	local lastFDCheck, lastADCheck = player:GetAttribute("LastFrontDashCheck"), player:GetAttribute("LastAuxDashCheck")
	
	local initialTime = ((lastFrontDash or -1) > (lastAuxDash or -1) and lastFrontDash) or lastAuxDash --high-brow ternary operator shortcut
	local check = ((lastFDCheck or -1) > (lastADCheck or -1) and lastFDCheck) or lastADCheck
	
	local dashDur = player:GetAttribute("DashActive")
	local d = 95
	local b = math.sqrt(d)/dashDur
	
	local finalTime = os.clock()
	
	local maxServerWindow = dashDur + latency
	
	local xPrev = math.clamp((check or initialTime) - initialTime, 0, maxServerWindow)
	local xNow = math.clamp(finalTime - initialTime, 0, maxServerWindow)
	local curveXPrev = math.clamp(xPrev, 0, dashDur)
	local curveXNow = math.clamp(xNow, 0, dashDur)
	
	if initialTime == lastFrontDash then 
		player:SetAttribute("LastFrontDashCheck", finalTime)
	else
		player:SetAttribute("LastAuxDashCheck", finalTime)
	end
	
	local curveDisplacement = dashDisplacement(b, d, curveXNow) - dashDisplacement(b, d, curveXPrev)
	
	--allow overflowing walk-induced displacement, just in case the server timeline overextends
	local overflowTime = math.max(0, xNow - curveXNow) - math.max(0, xPrev - curveXPrev)
	local overflowDisplacement = 0
	if overflowTime > 0 then
		local crusader = player:GetAttribute("Crusader")
		local char = player.Character or player.CharacterAdded:Wait()
		local walkSpeed = (char:HasTag("Running") and spacing.GetValue(crusader, 2)) or spacing.GetValue(crusader, 1)
		overflowDisplacement = (walkSpeed * overflowTime) + padding
	end
	
	return curveDisplacement + overflowDisplacement + padding
end

local function validateMovement(player: Player, char: Model, tokenData: TokenStructure)
	local maxSpeed = 0
	local root: Part = char:WaitForChild("HumanoidRootPart")
	player:SetAttribute("lastServerPos", root.Position)

	local duration = 0
	local loop
	loop = RNS.PreSimulation:Connect(function(dt)
		if char:HasTag("RagdollActive") then return end
		
		local currentPeriod = period
		if player:GetAttribute("DashActive") then currentPeriod = math.max(player:GetAttribute("DashActive") / dashChecks, minPeriod) end
		
		duration += dt
		if duration < currentPeriod then return end

		local elapsed = duration
		duration = 0

		if not char or not char:IsDescendantOf(workspace) then loop:Disconnect() return end --sanity check #1
		if not root then loop:Disconnect() return end --sanity check #2
		
		local lastServerPos = player:GetAttribute("lastServerPos")
		local currentPosXZ = Vector3.new(root.Position.X, 0, root.Position.Z)
		local lastServerPosXZ = Vector3.new(lastServerPos.X, 0, lastServerPos.Z)
		local distance = (currentPosXZ - lastServerPosXZ).Magnitude
		
		local latency = math.clamp(player:GetNetworkPing()/2, 0, 0.5) --ping cap at a 1000ms round-trip, and it cannot be negative
		local maxDistance = 0
		
		--basic selection tree for movement mode
		if player:GetAttribute("DashActive") then
			maxDistance = maxDashDistance(player, elapsed, latency)
			
			if char:HasTag("LoadingAttack") and not char:HasTag("CancellingAttack") then
				char:AddTag("CancellingAttack")
			end
		else --which is calculated with, by default, walking
			maxDistance, maxSpeed = maxWalkDistance(player, elapsed, latency, tokenData)
		end
		
		if distance > maxDistance then --illegal movement
			warn("Movement anticheat triggered by", player.Name .. "! Distance:", distance, "Max Distance:", maxDistance)
			root.CFrame = CFrame.new(lastServerPos.X, root.Position.Y, lastServerPos.Z) * (root.CFrame - root.Position)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		else --legal movement
			if not player:GetAttribute("DashActive") and elapsed > 0 then
				local actualSpeed = (elapsed > 0 and distance / elapsed) or 0
				local timeConsumed = elapsed
				if actualSpeed > maxSpeed then timeConsumed = distance / maxSpeed end
				tokenData.timeCredit = math.max(0, tokenData.timeCredit - timeConsumed)
			end
			
			player:SetAttribute("lastServerPos", root.Position) --reassign to validated position
		end
	end)
end

local function registerMovement(player: Player, scope: string, mechanic: string, switch: boolean)
	local move, ID, duration = nil, nil, nil
	local movementState = movementSpecs[scope][mechanic][3]
	local crusader = player:GetAttribute("Crusader")
	local char = player.Character or player.CharacterAdded:Wait()
	
	if movementState ~= "SprintActive" then
		move = movementSpecs[scope][mechanic][1]
		ID = movementSpecs[scope][mechanic][2]
		
		if not cooldownManager:IsReady(player, move, "Tech") or player:GetAttribute("Stunned") then return end
		
		if movementState == "DashActive" then 
			if move == "FrontDash" then 
				char:AddTag("Dashing")
				player:SetAttribute("LastFrontDash", os.clock())
			elseif move == "AuxDash" then
				char:AddTag("Dashing")
				player:SetAttribute("LastAuxDash", os.clock())
			else
				warn("Invalid dash type from", player.Name .. "!")
			end
		end
		
		duration = timing.GetValue(crusader, "Tech", 3, ID)
		stunManager.Eval(player, nil, duration, "Recovery")
		cooldownManager:Register(player, move, ID)
		player:SetAttribute(movementState, duration)
		
		local gracePeriod = 4*(if player:GetAttribute("DashActive") then player:GetAttribute("DashActive") else 0)/ dashChecks
		task.delay(duration + gracePeriod, function()
			if player.Parent ~= Players then return end
			if char:HasTag("Dashing") then char:RemoveTag("Dashing") end
			player:SetAttribute(movementState, nil)
		end)
	else
		if switch then
			char:AddTag("Running")
		else
			char:RemoveTag("Running")
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		tokenRegistry[player] = {
			timeCredit = 0.15, --maximum "burst buffer" to absorb lag spikes
			maxCredit = 0.5, --prevents hoarding credits for malicious intent/exploitation thereof
		}
		validateMovement(player, char, tokenRegistry[player])
	end)
	player.CharacterRemoving:Connect(function(char) --change these to character-level attributes
		player:SetAttribute("DashActive", nil)
		player:SetAttribute("LastFrontDash", nil)
		player:SetAttribute("LastAuxDash", nil)
		player:SetAttribute("LastFrontDashCheck", nil)
		player:SetAttribute("LastAuxDashCheck", nil)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	tokenRegistry[player] = nil
end)

RS.Remotes.MovementTrigger.OnServerEvent:Connect(function(player, scope: string, mechanic: string, switch: boolean)
	registerMovement(player, scope, mechanic, switch)
end)