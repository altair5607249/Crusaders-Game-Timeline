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
local slashInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local extraInfo = TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

local BM1 = {}

function BM1:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local attackData = {
		atkdur = endlag * (1/3),
		atkrad = 5,
		atktype = "heavy",
		bypassParry = true,
		customSound = script.Rend,
		dmg = 75,
		getTargets = true,
		ID = 1,
		noSound = true,
		style = "Weapon"
	}
	
	local attackData2 = {
		atkdur = endlag * (1/3),
		atkrad = 15,
		atktype = "heavy",
		dmg = 5,
		ID = 1,
		noStun = true,
		shockwave = 0.2588, --75 degrees
		style = "Weapon"
	}
	
	local distance = 38
	
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
	
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	tween.Completed:Connect(function()
		tween:Destroy()
		
		if hum.Health <= 0 or not hum or player.Parent ~= Players then return end
		
		char:RemoveTag("Running")
		hum:RemoveTag("Immortal")
		
		local weapon: Accessory? = char:FindFirstChild("Main")
		
		if weapon then
			local vfx: ParticleEmitter = weapon.Handle:FindFirstChild("VFX_Att"):FindFirstChild("glow")
			
			local prevColor = vfx.Color
			vfx.Color = ColorSequence.new(Color3.new(0.4, 0.9, 1))
			
			task.delay(endlag, function()
				vfx.Color = prevColor
			end)
		end
		
		damager:Damage(player, attackData2)
		
		local shockwave = RS.AttackVFX.SlashShockwave:Clone()
		shockwave.Parent = workspace
		shockwave.CFrame = root.CFrame * CFrame.new(0, -2, -10) * CFrame.Angles(0, 0, math.rad(45))
		
		local dest = shockwave.CFrame * CFrame.new(5, 6, -5)
		
		local tweenTP = TS:Create(shockwave, extraInfo, {Transparency = 1})
		local tweenFrame = TS:Create(shockwave, extraInfo, {CFrame = dest})
		local tweenSize = TS:Create(shockwave, extraInfo, {Size = shockwave.Size * 10})
		
		tweenTP:Play()
		tweenFrame:Play()
		tweenSize:Play()
		
		tweenTP.Completed:Connect(function()
			tweenTP:Destroy()
			tweenFrame:Destroy()
			tweenSize:Destroy()
			
			shockwave:Destroy()
		end)
		
		local targets: {Humanoid} = damager:Damage(player, attackData)
		
		if #targets == 0 then
			hum:TakeDamage(hum.Health / 20)
			stunManager.Eval(player, nil, 0.2, "Recovery")
		else
			local vfx = RS.AttackVFX.BigSlash:Clone()
			vfx.Parent = workspace
			
			vfx.CFrame = root.CFrame * CFrame.new(-2, 0, -5) * CFrame.Angles(0, 0, math.rad(45))

			local tweenSlash = TS:Create(vfx, slashInfo, {Transparency = 1})
			tweenSlash:Play()
			
			tweenSlash.Completed:Connect(function()
				tweenSlash:Destroy()
				vfx:Destroy()
			end)
		end
	end)
end

return BM1