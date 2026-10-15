local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Redd", "Weapon", 1, 2)
local duration = timing.GetValue("Redd", "Weapon", 3, 2) - delayTime
local plasmaInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo0 = TweenInfo.new(duration * 0.64, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo1 = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function healthCurve(health: number, maxHealth: number, stat: number)
	local a = maxHealth
	local b = (stat^(1/2))/a
	return (b*health)^2 + stat
end

local RM2 = {}

function RM2:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	local rightArm: Part = char:WaitForChild("Right Arm")
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local deltaHealth = maxHealth - currentHealth
	
	--for glowing arm
	local glow = Instance.new("ParticleEmitter")
	glow.Parent = rightArm:FindFirstChildWhichIsA("Attachment")

	--appearance
	glow.Brightness = 8
	glow.Color = ColorSequence.new(Color3.new(1, 0, 0.2))
	glow.Size = NumberSequence.new(2.5, 1)
	glow.Texture = "rbxassetid://7902140311"
	glow.Transparency = NumberSequence.new(0.65)

	--emission
	glow.Lifetime = NumberRange.new(1)
	glow.Rate = 40
	glow.Rotation = NumberRange.new(0, 180)
	glow.RotSpeed = NumberRange.new(-100, 100)
	glow.Speed = NumberRange.new(8)

	--emittershape
	glow.Shape = Enum.ParticleEmitterShape.Disc
	glow.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface

	--particles
	glow.Drag = 1
	glow.LockedToPart = true
	
	local attackData = { --for the shockwave
		atkdur = duration * 0.3, --0.375s
		atkrad = 30,
		atktype = "light",
		dmg = healthCurve(deltaHealth, maxHealth, 20),
		ID = 2,
		noKB = true,
		noSound = true,
		origin = root,
		style = "Weapon"
	}
	
	damager:Damage(player, attackData)
	
	local attackData2 = { --for the slash itself
		atkdur = duration * 0.1, --0.125s
		atkrad = 8,
		atktype = "heavy",
		customSound = script.KnifeHit,
		dmg = healthCurve(deltaHealth, maxHealth, 50),
		ID = 2,
		origin = root,
		style = "Weapon"
	}
	
	local supernova = RS.AttackVFX.SupernovaRed:Clone()
	supernova.Parent = workspace
	supernova:PivotTo(root.CFrame)
	
	local alpha = Instance.new("NumberValue")
	alpha.Value = 0.01
	alpha.Changed:Connect(function(value)
		supernova:ScaleTo(value)
	end)
	
	local tweenAlpha = TS:Create(alpha, tweenInfo0, {Value = 1})
	
	tweenAlpha:Play()
	tweenAlpha.Completed:Connect(function()
		tweenAlpha:Destroy()
		alpha:Destroy()
	end)
	
	for i, obj: Instance in ipairs(supernova:GetDescendants()) do
		if obj:IsA("MeshPart") then
			local tweenTp = TS:Create(obj, tweenInfo1, {Transparency = 1})

			tweenTp:Play()
			tweenTp.Completed:Connect(function()
				tweenTp:Destroy()
				supernova:Destroy()
			end)
		end
	end
	
	task.delay(duration * 0.1, function()
		damager:Damage(player, attackData2)
		
		local tweenGlow = TS:Create(glow, plasmaInfo, {Brightness = 0})
		tweenGlow:Play()
		tweenGlow.Completed:Connect(function()
			tweenGlow:Destroy()
			glow:Destroy()
		end)
		
		local explosion = script.Explosion:Clone()
		explosion.Parent = root
		explosion:Play()
		explosion.Ended:Connect(function()
			explosion:Destroy()
		end)
	end)
end

return RM2