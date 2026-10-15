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

local DamageManager = {}

function DamageManager:Damage(player: Player, attributes: {Instance})
	local char = nil 
	
	if player:IsA("Player") then char = player.Character or player.CharacterAdded:Wait()
	else char = player end --for dummies (remove after testing phase)
	
	local root = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")
	local origin = attributes["origin"] or char:WaitForChild("hitPart", 2)

	if hum == nil or hum.Health <= 0 then return end

	local targets = {}
	
	local characterList = CS:GetTagged("Character")
	local filtered = {}
	for i, c in characterList do
		if c ~= char then
			table.insert(filtered, c)
		end
	end
	
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = filtered
	
	local center
	local oldOrigin
	
	if attributes["shockwave"] then
		oldOrigin = origin
		origin = oldOrigin:Clone()
		origin.CFrame = oldOrigin.CFrame * CFrame.new(0, 0, -attributes["atkrad"]/2)
	end
	
	local loop
	local duration = 0
	loop = RNS.Heartbeat:Connect(function(dt)
		if hum == nil or hum.Health <= 0 then --early end
			loop:Disconnect()
			table.clear(targets)
			if attributes["shockwave"] then origin:Destroy() end
			return
		end
		
		if attributes["expanding"] then attributes["atkrad"] *= attributes["expanding"]^dt end
		
		center = origin.CFrame
		local hits = workspace:GetPartBoundsInBox(center, Vector3.new(attributes["atkrad"], attributes["atkrad"], attributes["atkrad"]), params)
		for i, part in hits do
			local targetChar = part:FindFirstAncestorOfClass("Model")
			if not targetChar then continue end
			
			local targetPlr = Players:GetPlayerFromCharacter(targetChar)
			local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
			if not targetRoot then continue end
			
			local targetHum = targetChar:FindFirstChild("Humanoid")
			if not targetHum or targetHum.Health <= 0 or targetHum == hum then continue end
			
			if targetHum:GetAttribute("Immortal") then continue end
			
			if attributes["shockwave"] ~= nil then
				local direction = (targetRoot.Position - oldOrigin.Position).Unit
				local dotProduct = oldOrigin.CFrame.LookVector:Dot(direction)
				
				if dotProduct < attributes["shockwave"] then continue end
			end

			if not table.find(targets, targetHum) then
				if not attributes["DOT"] then table.insert(targets, targetHum) end --for damage-over-time attacks
				
				targetHum:TakeDamage(attributes["dmg"]) --most important line obviously
				print("Damage frame!")
				
				if attributes["DOT"] then 
					targetHum:SetAttribute("Immortal", true) --i-frames for DOT; we're not adding Sans-level mechanics here
					task.delay(attributes["DOT"], function()
						targetHum:SetAttribute("Immortal", nil)
					end)
				end
				
				if targetHum == nil or targetHum.Health <= 0 then continue end
				if targetChar:HasTag("Resistance") then continue end --available during rush-style and ult attacks
				
				if attributes["shockwave"] == nil then stun:DurReg(targetPlr, attributes["atktype"], attributes["style"], attributes["ID"], "Hit") end --hitstun
				if not attributes["expanding"] then 
					kb.Eval(player, targetPlr, targetRoot, attributes) 
				end --knockback
			end
		end

		--debug visualization (make optional later)
		local testPart = Instance.new("Part")
		testPart.Shape = Enum.PartType.Block
		testPart.Color = Color3.new(1, 0, 0)
		testPart.Transparency = 0.92
		testPart.Anchored = true
		testPart.CFrame = origin.CFrame
		local size = attributes["atkrad"]
		testPart.Size = Vector3.new(size, size, size)
		testPart.CanCollide = false
		testPart.CanQuery = false
		testPart.Parent = workspace

		if testPart == nil then
			warn("test part is nil")
		end

		game.Debris:AddItem(testPart, 0.3)

		duration += dt
		if duration >= attributes["atkdur"] then
			loop:Disconnect()
			table.clear(targets)
			if attributes["shockwave"] then origin:Destroy() end
		end
	end)
end

return DamageManager