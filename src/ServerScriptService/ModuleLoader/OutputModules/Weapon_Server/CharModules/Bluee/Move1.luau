local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)
local movement = require(SSS.ModuleLoader.Managers.MovementManager)
local stunManager = require(SSS.ModuleLoader.Managers.StunManager)

local delayTime = timing.GetValue("Bluee", "Weapon", 1, 1)
local duration = timing.GetValue("Bluee", "Weapon", 3, 1) - delayTime
local endlag = 0.3
local dashInfo = TweenInfo.new(duration - endlag, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut)

local BM1 = {}

function BM1:Trigger(player: Player)
	print("weapon bm1")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local attackData = {
		atkdur = endlag * (1/3),
		atkrad = 4,
		atktype = "heavy",
		bypassParry = true,
		dmg = 75,
		getTargets = true,
		ID = 1,
		style = "Weapon"
	}
	
	local distance = 30
	
	local magnitude: number = (distance / (duration - endlag)) * 3
	movement.ChangeTolerance(player, magnitude)
	
	char:AddTag("Running")
	hum:AddTag("Immortal")
	
	local dest = root.CFrame * CFrame.new(0, 0, -distance)
	local tween = TS:Create(root, dashInfo, {CFrame = dest})
	
	local characters = CS:GetTagged("Character")
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = characters
	
	local loop: RBXScriptConnection = nil
	loop = RNS.PreSimulation:Connect(function(dt)
		local direction = root.CFrame.LookVector
		local step = direction * magnitude * dt

		local result = workspace:Raycast(root.Position, step, raycastParams)

		if result then
			loop:Disconnect()
			tween:Cancel()
		end
	end)
	
	tween:Play()
	
	tween.Completed:Connect(function()
		tween:Destroy()
		
		if hum.Health <= 0 or not hum or player.Parent ~= Players then return end
		
		char:RemoveTag("Running")
		hum:RemoveTag("Immortal")
		
		local targets: {Humanoid} = damager:Damage(player, attackData)
		
		if not targets[1] then
			hum:TakeDamage(hum.Health / 10)
			stunManager.Eval(player, nil, 0.5, "Recovery")
		end
	end)
end

return BM1