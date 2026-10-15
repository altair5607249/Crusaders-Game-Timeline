local Players = game:GetService("Players")
local CS = game:GetService("CollectionService")
local debby = game:GetService("Debris")
local RNS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local attack = remotes.Attack
local playAnim = remotes.PlayAnimation

local spacing = require(RS.UniversalModules.Space)
local stun = require(script.Parent.StunManager)
local kb = require(script.Parent.KnockbackManager)

local vfxQuirks = {
	Redd = Color3.new(1, 0, 0),
	Yello = Color3.new(1, 1, 0),
	Gleen = Color3.new(0, 1, 0),
	Bluee = Color3.new(0, 0, 1)
}

local DamageManager = {}

function DamageManager:Damage(player: Player, attributes: {Instance})
	local char = nil 
	
	if player:IsA("Player") then char = player.Character or player.CharacterAdded:Wait()
	else char = player end --for dummies (remove after testing phase)
	
	local root = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")
	local origin: Part = attributes["origin"] or char:WaitForChild("hitPart", 2)

	if hum == nil or hum.Health <= 0 then return end

	local targets = {}
	
	local characterList = CS:GetTagged("Character")
	local filtered = {}
	for i, c in ipairs(characterList) do
		if c ~= char then
			table.insert(filtered, c)
		end
	end
	
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = filtered
	
	local center
	local oldOrigin
	
	--various sub-attack types
	if attributes["shockwave"] then
		oldOrigin = origin
		origin = oldOrigin:Clone()
		origin.CFrame = oldOrigin.CFrame * CFrame.new(0, 0, -attributes["atkrad"]/2)
	end
	
	local bind
	if attributes["getTargets"] then
		bind = Instance.new("BindableEvent")
	end
	
	local loop
	local duration = 0
	loop = RNS.Heartbeat:Connect(function(dt)
		if hum == nil or hum.Health <= 0 then --early end
			loop:Disconnect()
			table.clear(targets)
			if attributes["shockwave"] then origin:Destroy() end
			if attributes["getTargets"] then bind:Fire(nil) end
			return --ends current frame too
		end
		
		if attributes["expanding"] then attributes["atkrad"] *= attributes["expanding"]^dt end
		
		center = (typeof(origin) == "CFrame" and origin) or origin.CFrame
		
		local hits = workspace:GetPartBoundsInBox(center, Vector3.new(attributes["atkrad"], attributes["atkrad"], attributes["atkrad"]), params)
		for i, part in hits do
			local targetChar = part:FindFirstAncestorOfClass("Model")
			if not targetChar then continue end
			
			local targetPlr = Players:GetPlayerFromCharacter(targetChar)
			local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
			if not targetRoot then continue end
			
			local targetHum = targetChar:FindFirstChild("Humanoid")
			if not targetHum or targetHum.Health <= 0 or targetHum == hum then continue end
			
			if targetHum:HasTag("Immortal") then continue end --for i-frames
			
			if attributes["shockwave"] ~= nil then
				local direction = (targetRoot.Position - oldOrigin.Position).Unit
				local dotProduct = oldOrigin.CFrame.LookVector:Dot(direction)
				
				if dotProduct < attributes["shockwave"] then continue end
			end

			if not table.find(targets, targetHum) then
				if not attributes["DOT"] then table.insert(targets, targetHum) end --for damage-over-time attacks
				
				targetHum:TakeDamage(attributes["dmg"]) --most important line obviously
				
				if attributes["oneHit"] and targetPlr then
					duration = attributes["atkdur"]
					char:AddTag("HitFinished")
					task.delay(0.1, function()
						char:RemoveTag("HitFinished")
					end)
				end
				
				if attributes["DOT"] then 
					targetHum:AddTag("Immortal") --i-frames for DOT; we're not adding Sans-level mechanics here
					task.delay(attributes["DOT"], function()
						targetHum:RemoveTag("Immortal")
					end)
				end
				
				if not targetHum or targetHum.Health <= 0 then 
					if targetPlr then --adds a KO if it's a player
						player.leaderstats["KO's"].Value += 1
					end
					
					continue 
				end
				
				if targetChar:HasTag("Resistance") then continue end --available during rush-style and ult attacks
				
				if attributes["precedent"] ~= true then
					if not attributes["shockwave"] then 
						stun:DurReg(player, targetPlr, attributes["atktype"], attributes["style"], attributes["ID"], "Hit") --hitstun 
					end
					
					if not attributes["expanding"] then 
						kb.Eval(player, targetPlr, targetRoot, attributes["atktype"]) --knockback
					end
				end
			end
		end

		--debug visualization (make optional later)
		local testPart = Instance.new("Part")
		testPart.Shape = Enum.PartType.Block
		testPart.Anchored = true
		testPart.CastShadow = false
		testPart.Color = vfxQuirks[player:GetAttribute("Crusader")]
		testPart.CFrame = (typeof(origin) == "CFrame" and origin) or origin.CFrame
		local size = attributes["atkrad"]
		testPart.Size = Vector3.new(size, size, size)
		testPart.CanCollide = false
		testPart.CanQuery = false
		testPart.Transparency = 0.94
		testPart.Parent = workspace

		if testPart == nil then
			warn("Hitbox is nil!")
		end

		debby:AddItem(testPart, 0.3)

		duration += dt
		if duration >= attributes["atkdur"] then
			loop:Disconnect()
			if attributes["shockwave"] then origin:Destroy() end
			if attributes["getTargets"] then 
				local clonedTargets = table.clone(targets)
				bind:Fire(clonedTargets)
			end
			table.clear(targets)
		end
	end)
	
	if attributes["getTargets"] then
		local clonedTargets = bind.Event:Wait()
		bind:Destroy()
		return clonedTargets
	end
end

return DamageManager