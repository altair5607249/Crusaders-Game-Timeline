--meant to be kind to/tolerant of laggy players
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local cooldownManager = require(SSS.ModuleLoader.Managers.CooldownManager)
local stunManager = require(SSS.ModuleLoader.Managers.StunManager)

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local dashChecks = 8
local minPeriod = 0.05
local period = 0.08 --how often the anticheat checks movement (in seconds)
local paddingFreq = 80 --to be scaled with the periodic cycle, since padding adds flat rates
local padding = paddingFreq * period --for network jitter, packet burstiness, physics interpolation, etc.
local maxStamina: number? --adjust to match the real cap across diff players
local vfxInfo = TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

local techSpecs = {
	dashSpecs = {
		FrontDash = {"FrontDash", 1, "DashActive"},
		AuxDash = {"AuxDash", 2, "DashActive"}
	},
	runSpecs = {
		Sprint = {nil, nil, "SprintActive"},
		Walk = {nil, nil, nil}
	},
	parrySpecs = {
		Parry = {"Parry", 3, "ParryActive"}
	}
}

--crude token bucket scheme that i learned as i built it for this anticheat's tolerance 
local tokenRegistry = {}
type TokenStructure = {timeCredit: number, maxCredit: number}

local toleranceRegistry = {}
type ToleranceStructure = {toleranceFactor: number}

local function maxWalkDistance(player: Player, elapsed: number, latency: number, tokenData: TokenStructure, toleranceData: ToleranceStructure)
	local crusader = player:GetAttribute("Crusader")
	local char = player.Character or player.CharacterAdded:Wait()
	local walkSpeed: number = (char:HasTag("Running") and spacing.GetValue(crusader, 2)) or spacing.GetValue(crusader, 1)

	tokenData.timeCredit = math.min(tokenData.maxCredit, tokenData.timeCredit + elapsed)
	
	local distance = ((walkSpeed * tokenData.timeCredit) + padding) * toleranceData.toleranceFactor

	return distance, walkSpeed
end

local function dashDisplacement(b: number, d: number, x: number)
	return -(b^2 * x^3)/3 + d*x
end

local function maxDashDistance(player: Player, elapsed: number, latency: number)
	local char = player.Character or player.CharacterAdded:Wait()
	
	local lastFrontDash, lastAuxDash = char:GetAttribute("LastFrontDash"), char:GetAttribute("LastAuxDash")
	local lastFDCheck, lastADCheck = char:GetAttribute("LastFrontDashCheck"), char:GetAttribute("LastAuxDashCheck")

	local initialTime = ((lastFrontDash or -1) > (lastAuxDash or -1) and lastFrontDash) or lastAuxDash --high-brow ternary operator shortcut
	local check = ((lastFDCheck or -1) > (lastADCheck or -1) and lastFDCheck) or lastADCheck

	local dashDur = char:GetAttribute("DashActive")
	local d = 95
	local b = math.sqrt(d)/dashDur

	local finalTime = os.clock()

	local maxServerWindow = dashDur + latency

	local xPrev = math.clamp((check or initialTime) - initialTime, 0, maxServerWindow)
	local xNow = math.clamp(finalTime - initialTime, 0, maxServerWindow)
	local curveXPrev = math.clamp(xPrev, 0, dashDur)
	local curveXNow = math.clamp(xNow, 0, dashDur)

	if initialTime == lastFrontDash then 
		char:SetAttribute("LastFrontDashCheck", finalTime)
	else
		char:SetAttribute("LastAuxDashCheck", finalTime)
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

local function validateMovement(player: Player, char: Model, tokenData: TokenStructure, toleranceData: ToleranceStructure)
	local maxSpeed = 0
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	player:SetAttribute("lastServerPos", root.Position)

	local duration = 0
	local loop
	loop = RNS.PreSimulation:Connect(function(dt)
		if char:HasTag("RagdollActive") then return end

		local currentPeriod = period
		if char:GetAttribute("DashActive") then currentPeriod = math.max(char:GetAttribute("DashActive") / dashChecks, minPeriod) end

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
		if char:GetAttribute("DashActive") then
			maxDistance = maxDashDistance(player, elapsed, latency)
		else --which is calculated with, by default, walking
			maxDistance, maxSpeed = maxWalkDistance(player, elapsed, latency, tokenData, toleranceData)
		end

		if distance > maxDistance then --illegal movement = rubberbanding; make this bannable later
			if hum:HasTag("Sitting") and hum.Sit then player:SetAttribute("lastServerPos", root.Position) return end
			
			warn("Movement anticheat triggered by", player.Name .. "! Distance:", distance, "Max Distance:", maxDistance)
			
			if hum.Sit then hum.Sit = false end --stops the seats from being dragged with the player
			
			root.CFrame = CFrame.new(lastServerPos.X, root.Position.Y, lastServerPos.Z) * (root.CFrame - root.Position)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		else --legal movement
			if not char:GetAttribute("DashActive") and elapsed > 0 then
				local actualSpeed = (elapsed > 0 and distance / elapsed) or 0
				local timeConsumed = elapsed
				if actualSpeed > maxSpeed then timeConsumed = distance / maxSpeed end
				tokenData.timeCredit = math.max(0, tokenData.timeCredit - timeConsumed)

				local stamina: number = hum:GetAttribute("Stamina")

				if char:HasTag("Running") then
					local newStamina = math.max(0, stamina - 1) --10 in 1 second
					hum:SetAttribute("Stamina", newStamina)

					if newStamina <= 0 and not char:GetAttribute("StaminaDepleted") then
						char:SetAttribute("StaminaDepleted", true)
						task.delay(5, function()
							if char:HasTag("Running") then char:RemoveTag("Running") end
							char:SetAttribute("StaminaDepleted", nil)
						end)
					end
				else
					local maxStamina = hum:GetAttribute("MaxStamina")

					local newStamina = math.min(maxStamina, stamina + 0.2) --2 in 1 second
					hum:SetAttribute("Stamina", newStamina)
				end
			end
			
			player:SetAttribute("lastServerPos", root.Position) --reassign to validated position
		end
	end)
end

local function registerMovement(player: Player, scope: string, mechanic: string, switch: boolean)
	local move, ID, duration = nil, nil, nil
	local movementState = techSpecs[scope][mechanic][3]

	local crusader = player:GetAttribute("Crusader")
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")

	if hum:GetAttribute("Stamina") <= 0 then return end --frankly, there's no situation where you can tech without stamina (sanity check)

	if movementState ~= "SprintActive" then
		move = techSpecs[scope][mechanic][1]
		ID = techSpecs[scope][mechanic][2]

		if not cooldownManager:IsReady(player, move, "Tech") or char:GetAttribute("Stunned") then return end

		--situational stamina check (sanity check pt 2)
		local stamina: number = hum:GetAttribute("Stamina")

		if movementState == "DashActive" then 
			if move == "FrontDash" then 
				if stamina < 5 then return end

				char:AddTag("Dashing")
				char:SetAttribute("LastFrontDash", os.clock())

				hum:SetAttribute("Stamina", stamina - 5)

				local sfx = script.AuxSound:Clone()
				sfx.Parent = root
				sfx:Play()
				sfx.Ended:Connect(function()
					sfx:Destroy()
				end)
				
				local pressure = RS.AttackVFX["All-Purpose Ring"]:Clone()
				pressure.Parent = workspace
				pressure.CFrame = root.CFrame
				
				local tweenSize = TS:Create(pressure, vfxInfo, {Size = pressure.Size * 8})
				local tweenTp = TS:Create(pressure, vfxInfo, {Transparency = 1})
				
				tweenSize:Play()
				tweenTp:Play()
				tweenTp.Completed:Connect(function()
					tweenSize:Destroy()
					tweenTp:Destroy()
					pressure:Destroy()
				end)
			elseif move == "AuxDash" then
				if stamina < 2.5 then return end

				char:AddTag("Dashing")
				char:SetAttribute("LastAuxDash", os.clock())

				hum:SetAttribute("Stamina", stamina - 2.5)

				local sfx = script.Sound:Clone()
				sfx.Parent = root
				sfx:Play()
				sfx.Ended:Connect(function()
					sfx:Destroy()
				end)
			else
				warn("Invalid dash type from", player.Name .. "!")
			end
		elseif movementState == "ParryActive" and move == "Parry" then
			if stamina < 15 then return end
			
			local delayTime: number = timing.GetValue(crusader, "Tech", 1, ID)
			local effectiveDuration: number = timing.GetValue(crusader, "Tech", 3, ID) - delayTime
			
			task.delay(delayTime, function() --being attacked during parry startup frames shouldnt cancel out the parry entirely like with special moves
				char:AddTag("Parrying")
				
				local toleranceData: ToleranceStructure = toleranceRegistry[player]
				local savedTolerance = toleranceData.toleranceFactor
				toleranceData.toleranceFactor /= 4
				
				task.spawn(function()
					local initialTime = os.clock() --maybe make another function in Time that manages these sorts of timers; this is getting repetitive
					repeat
						task.wait()
						
						if not char or player.Parent ~= Players then return end
						
						if char:HasTag("SuccessfulParry") then 
							char:RemoveTag("Parrying")
							
							local sfx = script.Parry:Clone() --cool parry sound
							sfx.Parent = root
							sfx:Play()
							sfx.Ended:Connect(function()
								sfx:Destroy()
							end)
							
							char:RemoveTag("SuccessfulParry")
							char:SetAttribute("StunTime", 0) --removes recovery frames
							
							break 
						end
					until os.clock() - initialTime >= effectiveDuration
					
					toleranceData.toleranceFactor = savedTolerance
				end)
			end)
			
			hum:SetAttribute("Stamina", stamina - 15)
		end

		duration = timing.GetValue(crusader, "Tech", 3, ID)
		stunManager.Eval(player, nil, duration, "Recovery")
		cooldownManager:Register(player, move, "Tech", ID)
		char:SetAttribute(movementState, duration)

		local gracePeriod = 4 * (if char:GetAttribute("DashActive") then char:GetAttribute("DashActive") else 0) / dashChecks
		task.delay(duration + gracePeriod, function()
			if player.Parent ~= Players then return end
			
			--create a namespace module in the future for this to be more elegant
			if char:HasTag("Dashing") then char:RemoveTag("Dashing") end
			if char:HasTag("Parrying") then char:RemoveTag("Parrying") end
			
			char:SetAttribute(movementState, nil)
		end)
	else
		if switch then
			char:AddTag("Running")
		else
			char:RemoveTag("Running")
		end
	end
end

local function playerIsSwimming(player: Player, hum: Humanoid, root: Part)
	local position = root.Position
	local region = Region3.new(position - Vector3.new(0.5, 0.5, 0.5), position + Vector3.new(0.5, 0.5, 0.5)) --one-stud region
	region = region:ExpandToGrid(4)

	local materials = workspace.Terrain:ReadVoxels(region, 4)

	local material = materials[1][1][1]

	if material == Enum.Material.Water then
		hum:AddTag("Swimming")
		hum.JumpPower = 50
	else
		hum:RemoveTag("Swimming")
		hum.JumpPower = 0
	end
end

local seats = {}

for i, desc in ipairs(workspace:GetDescendants()) do
	if desc:IsA("Seat") then table.insert(seats, desc) end
end

for i, desc in ipairs(SS:GetDescendants()) do
	if desc:IsA("Seat") then table.insert(seats, desc) end
end

local function playerIsSitting(player: Player, hum: Humanoid, root: Part)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = seats
	
	local result = workspace:Raycast(root.Position, Vector3.new(0, -4, 0), params)
	
	if result and result.Instance:IsA("Seat") then
		local seat = result.Instance
		if seat.Occupant == hum then
			hum:AddTag("Sitting")
			hum.JumpPower = 50
		else
			hum:RemoveTag("Sitting")
			hum.JumpPower = 0
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		
		tokenRegistry[player] = {
			timeCredit = 0.15, --maximum "burst buffer" to absorb lag spikes
			maxCredit = 0.5, --prevents hoarding credits for malicious intent/exploitation thereof
		}
		
		toleranceRegistry[player] = {
			toleranceFactor = 1 --multiplied against the max displacement, mostly used for special moves
		}
		
		validateMovement(player, char, tokenRegistry[player], toleranceRegistry[player])
		
		local hum: Humanoid = char:WaitForChild("Humanoid")
		local root: Part = char:WaitForChild("HumanoidRootPart")
		
		hum.StateChanged:Connect(function()
			if hum.Sit then 
				playerIsSitting(player, hum, root) --verifies whether the player is actually sitting
			else
				hum.JumpPower = 0
			end 
		end)
		
		hum.Swimming:Connect(function() playerIsSwimming(player, hum, root) end) --verifies whether the player is actually swimming
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	tokenRegistry[player] = nil
	toleranceRegistry[player] = nil
end)

RS.Remotes.MovementTrigger.OnServerEvent:Connect(function(player, scope: string, mechanic: string, switch: boolean)
	registerMovement(player, scope, mechanic, switch)
end)

local movement = {}

function movement.ChangeTolerance(player: Player, magnitude: number)
	local crusader = player:GetAttribute("Crusader")
	local toleranceData: ToleranceStructure = toleranceRegistry[player]
	
	if not toleranceData then return end
	
	local newFactor: number = magnitude / spacing.GetValue(crusader, 2)
	
	toleranceData.toleranceFactor = newFactor
end

return movement