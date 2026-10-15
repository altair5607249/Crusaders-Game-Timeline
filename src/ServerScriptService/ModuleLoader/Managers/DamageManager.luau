local Players = game:GetService("Players")
local debby = game:GetService("Debris")
local RNS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local attack = remotes.Attack
local playAnim = remotes.PlayAnimation
local knockback = remotes.Knockback

local DamageManager = {}

function DamageManager.Damage(origin1, origin2, hum, atk_dur, atk_rad, CD, dmg, velocity, stun, dmgType)
	local char = hum.Parent --this is because origin2 may not always be origin1's parent, such as with the weapon module
	local player = Players:GetPlayerFromCharacter(char)

	if player then
		local lastAtk = origin2:GetAttribute("LastAttack")
		if lastAtk and tick() - lastAtk < CD then return end
		origin2:SetAttribute("LastAttack", tick())
	end

	if hum.Health <= 0 then return end

	local targets = {}
	local loop = nil
	local duration = 0
	loop = RNS.Heartbeat:Connect(function(dt)
		local hits = workspace:GetPartBoundsInRadius(origin1.Position, atk_rad)
		for i, part in hits do
			local targetChar = part.Parent
			local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
			local targetHum = targetChar:FindFirstChild("Humanoid")
			if not targetHum or targetHum == hum then continue end

			if targetHum:GetAttribute("Immortal") then continue end

			if not table.find(targets, targetHum) then
				table.insert(targets, targetHum)
				
				targetHum:TakeDamage(dmg) --most important line obviously
				
				if targetHum.Health <= 0 then continue end --if dead
				
				--aftereffects of getting clocked
				targetChar:SetAttribute("Stunned", true) --stun
				local speed = targetChar:GetAttribute("bspd")
				local jump = targetChar:GetAttribute("jump")
				targetHum.WalkSpeed = 0
				targetHum.JumpPower = 0
				
				--knockback
				if dmgType == "heavy" then
					targetHum:ChangeState(Enum.HumanoidStateType.Physics)
				end
				local targetPlr = Players:GetPlayerFromCharacter(targetChar)
				if targetPlr ~= nil then --for players
					knockback:FireClient(targetPlr, velocity)
				else --for dummies
					targetRoot.AssemblyLinearVelocity = velocity
				end
				
				local storedHealth = targetHum.Health --health snapshot
				
				task.delay(stun, function()
					if storedHealth > targetHum.Health then return end --prevents player from unstunning mid combo (inferred from health decreasing)
					targetChar:SetAttribute("Stunned", false)
					targetHum:ChangeState(Enum.HumanoidStateType.GettingUp)
					if speed ~= nil and jump ~= nil then
						targetHum.WalkSpeed = speed
						targetHum.JumpPower = jump
					end
				end)
			end
		end

		-- debug visualization (make optional later)
		local testPart = Instance.new("Part")
		testPart.Shape = Enum.PartType.Ball
		testPart.Color = Color3.new(1, 0, 0)
		testPart.Transparency = 0.92
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
			table.clear(targets)
		end
	end)
end

return DamageManager