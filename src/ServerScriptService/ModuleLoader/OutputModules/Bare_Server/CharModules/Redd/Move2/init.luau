local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Redd", "Bare", 1, 2)
local duration = timing.GetValue("Redd", "Bare", 3, 2) - delayTime
local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local plasmaInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function modifyDescendants(container: Model | Folder, modifier: number)
	for i, obj: BasePart in ipairs(container:GetDescendants()) do
		local tween = TS:Create(obj, tweenInfo, {Transparency = modifier})
		tween:Play()
		tween.Completed:Connect(function()
			tween:Destroy()
			container:Destroy()
		end)
	end
end

local RM2 = {}

function RM2:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	local rightArm: Part = char:WaitForChild("Right Arm")
	
	local dmg = 40
	local shockwaveDmg = 10
	local delayTime = 0.2
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = 0.5,
		atkrad = 5,
		atktype = "heavy",
		bypassParry = (health > maxHealth * 0.8 and true) or false,
		customSound = script.Kapow,
		dmg = dmg + health^2/(8*maxHealth),
		ID = 2,
		style = "Bare"
	}
	
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
	
	local vfx = RS.AttackVFX.PunchShockwave:Clone()
	vfx.Parent = workspace
	
	--modify the shockwave
	local dest = (root.CFrame * CFrame.Angles(0, math.rad(270), math.rad(90))) * CFrame.new(0, 2.5, 0)
	vfx:PivotTo(dest)
	modifyDescendants(vfx, 1)
	
	local alpha = Instance.new("NumberValue")
	alpha.Value = 0.1
	local tweenAlpha = TS:Create(alpha, tweenInfo, {Value = 30})
	tweenAlpha:Play()
	
	tweenAlpha.Completed:Connect(function()
		tweenAlpha:Destroy()
		alpha:Destroy()
	end)
	
	alpha.Changed:Connect(function(value)
		vfx:ScaleTo(value)
		vfx:PivotTo(dest * CFrame.new(0, value/1.5, 0))
	end)
	
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	damager:Damage(player, attackData) --main hit
	
	local attackData2 = {
		atkdur = 0.3,
		atkrad = 40,
		atktype = "light",
		dmg = shockwaveDmg + health^2/(20*maxHealth),
		ID = 2,
		noStun = true,
		shockwave = 0.5
	}
	
	task.delay(delayTime, function()
		damager:Damage(player, attackData2) --shockwave
		
		local tweenGlow = TS:Create(glow, plasmaInfo, {Brightness = 0})
		tweenGlow:Play()
		
		tweenGlow.Completed:Connect(function()
			tweenGlow:Destroy()
			glow:Destroy()
		end)
	end)
end

return RM2