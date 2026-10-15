local Players = game:GetService("Players")
local RNS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local attack = remotes.Attack
local playAnim = remotes.PlayAnimation

local DamageManager = {}

function DamageManager.Damage(origin1, origin2, hum, atk_dur, atk_rad, CD, dmg)
	local char = hum.Parent
	local player = Players:GetPlayerFromCharacter(char)

	if player then
		local lastAtk = origin2:GetAttribute("LastAttack")
		if lastAtk and tick() - lastAtk < CD then return end
		origin2:SetAttribute("LastAttack", tick())
	else
		playAnim:FireAllClients(hum,"rbxassetid://75594920461255")
	end

	if hum.Health <= 0 then return end

	local targets = {}
	local loop = nil
	local duration = 0
	loop = RNS.Heartbeat:Connect(function(dt)
		local hits = workspace:GetPartBoundsInRadius(origin1.Position, atk_rad)
		for i, part in hits do
			local targetHum = part.Parent:FindFirstChild("Humanoid")
			if not targetHum or targetHum == hum then continue end

			if targetHum:GetAttribute("Immortal") then continue end

			if not table.find(targets, targetHum) then
				table.insert(targets, targetHum)
				targetHum:TakeDamage(dmg)
			end
		end

		-- debug visualization
		local testPart = Instance.new("Part")
		testPart.Shape = Enum.PartType.Ball
		testPart.Color = Color3.new(1, 0, 0)
		testPart.Transparency = 0.99
		testPart.Anchored = true
		local size = atk_rad * 2
		testPart.Size = Vector3.new(size, size, size)
		testPart.Position = origin1.Position
		testPart.CanCollide = false
		testPart.Parent = workspace

		if testPart == nil then
			warn("test part is nil")
		end

		game.Debris:AddItem(testPart, 0.3)

		duration += dt
		if duration >= atk_dur then
			loop:Disconnect()
		end
	end)
end

return DamageManager
