local Players = game:GetService("Players")
local debby = game:GetService("Debris")
local RNS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local attack = remotes.Attack
local playAnim = remotes.PlayAnimation
local knockback = remotes.Knockback

local stun = require(script.Parent.StunManager)

local DamageManager = {}

function DamageManager:Damage(player: Player, attributes: {Instance})
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local origin = char:WaitForChild("hitPart")
	
	if player and char then
		if attributes["LastAttack"] and tick() - attributes["LastAttack"] < attributes["cd"] then return end
		char:SetAttribute("LastAttack", tick())
	end

	if hum == nil or hum.Health <= 0 then return end

	local targets = {}
	local loop = nil
	local duration = 0
	loop = RNS.Heartbeat:Connect(function(dt)
		local hits = workspace:GetPartBoundsInBox(origin.CFrame, Vector3.new(attributes["atkrad"], attributes["atkrad"], attributes["atkrad"]))
		for i, part in hits do
			local targetChar = part.Parent
			local targetPlr = Players:GetPlayerFromCharacter(targetChar)
			local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
			local targetHum = targetChar:FindFirstChild("Humanoid")
			
			if not targetHum or targetHum == hum then continue end

			if targetHum:GetAttribute("Immortal") then continue end

			if not table.find(targets, targetHum) then
				table.insert(targets, targetHum)
				
				targetHum:TakeDamage(attributes["dmg"]) --most important line obviously
				
				if targetHum == nil or targetHum.Health <= 0 then continue end
				
				stun:DurReg(targetPlr, attributes["atktype"]) --hitstun
				
				--knockback
				if targetPlr ~= nil then --for players
					knockback:FireClient(targetPlr, attributes["velocity"])
				else --for dummies
					targetRoot.AssemblyLinearVelocity = attributes["velocity"]
				end
			end
		end

		--debug visualization (make optional later)
		local testPart = Instance.new("Part")
		testPart.Shape = Enum.PartType.Block
		testPart.Color = Color3.new(1, 0, 0)
		testPart.Transparency = 0.92
		testPart.Anchored = true
		testPart.Position = origin.Position
		local size = attributes["atkrad"]
		testPart.Size = Vector3.new(size, size, size)
		testPart.CanCollide = false
		testPart.Parent = workspace

		if testPart == nil then
			warn("test part is nil")
		end

		game.Debris:AddItem(testPart, 0.3)

		duration += dt
		if duration >= attributes["atkdur"] then
			loop:Disconnect()
			table.clear(targets)
		end
	end)
end

return DamageManager