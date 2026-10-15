local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)
local movement = require(SSS.ModuleLoader.Managers.MovementManager)

local delayTime = timing.GetValue("Gleen", "Weapon", 1, 4)
local duration = timing.GetValue("Gleen", "Weapon", 3, 4) - delayTime
local endlag = 0.5

local jumpDistance = 40
local jumpInfo = TweenInfo.new(duration - endlag, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local GM4 = {}

function GM4:Trigger(player: Player)
	print("weapon gm4")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	local torso: Part = char:WaitForChild("Torso")

	local cost = 10
	local stamina = hum:GetAttribute("Stamina")

	local attackData = {
		atkdur = endlag,
		atkrad = 8,
		atktype = "heavy",
		bypassParry = true,
		dmg = 60,
		ID = 4,
		style = "Weapon",
		noSound = true,
		origin = root 
	}

	if stamina > cost then
		hum:SetAttribute("Stamina", stamina - cost)
	else --debuffs based on how much stamina debt there is
		if stamina == cost then
			attackData.dmg *= 4/5
		else
			attackData.atkrad /= 2
			attackData.dmg *= 3/5
		end
		hum:SetAttribute("Stamina", 0)
	end

	char:AddTag("Running")
	hum:AddTag("Immortal") --i-frames so i dont have to deal with stun ordeals in the air
	
	local magnitude: number = (jumpDistance / (duration - endlag)) * 3
	movement.ChangeTolerance(player, magnitude)

	local endCFrame = root.CFrame * CFrame.new(0, 0, -jumpDistance)
	local tween = TS:Create(root, jumpInfo, {CFrame = endCFrame})
	
	local characters = CS:GetTagged("Character")
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = characters
	
	local loop: RBXScriptConnection? = nil
	loop = RNS.PreSimulation:Connect(function(dt)
		local direction = root.CFrame.LookVector
		local step = direction * magnitude * dt
		
		local result = workspace:Raycast(root.Position, step, raycastParams)

		if result then 
			attackData.origin = CFrame.new(root.Position.X, torso.Position.Y, root.Position.Z)
			
			loop:Disconnect()
			tween:Cancel()
		end
	end)
	
	tween:Play()
	
	tween.Completed:Connect(function()
		tween:Destroy()

		if hum.Health <= 0 or not hum or player.Parent ~= Players then return end

		local shockwave = RS.AttackVFX.SlamShockwave:Clone()
		shockwave.Parent = workspace
		shockwave:PivotTo(root.CFrame * CFrame.Angles(3.142, 0, 0) * CFrame.new(0, -12.5, 0))

		for i, mesh: MeshPart in ipairs(shockwave:GetChildren()) do
			if not mesh:IsA("MeshPart") then continue end
			local tweenShockwave = TS:Create(mesh, jumpInfo, {Transparency = 1})
			tweenShockwave:Play()
			tweenShockwave.Completed:Connect(function()
				tweenShockwave:Destroy()
				mesh:Destroy()
				if not shockwave:FindFirstChildWhichIsA("MeshPart") then
					shockwave:Destroy()
				end
			end)
		end

		local slam = script.Sound:Clone()
		slam.Parent = root
		slam:Play()
		slam.Ended:Connect(function()
			slam:Destroy()
		end)

		if char:HasTag("Running") then char:RemoveTag("Running") end
		if hum:HasTag("Immortal") then hum:RemoveTag("Immortal") end

		damager:Damage(player, attackData)
		movement.ChangeTolerance(player, spacing.GetValue("Gleen", 2))
	end)
end

return GM4