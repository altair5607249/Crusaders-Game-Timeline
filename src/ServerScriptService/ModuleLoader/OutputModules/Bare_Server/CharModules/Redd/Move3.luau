local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")
local managers = SSS.ModuleLoader.Managers

local damager = require(managers.DamageManager)

local timing = require(RS.UniversalModules.Time)

local delayTime = timing.GetValue("Redd", "Bare", 3, 3) - timing.GetValue("Redd", "Bare", 1, 3)
local tweenInfo = TweenInfo.new(delayTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

local RM3 = {}

function RM3:Trigger(player: Player)
	print("rm3")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local duration = 3.5
	local dmg = 5
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration + health^2/(85.7142*maxHealth),
		atkrad = 10,
		atktype = "light",
		bdmg = dmg,
		dmg = dmg + health^2/(80*maxHealth),
		DOT = 0.35,
		expanding = 1.48599,
		ID = 3,
		origin = char:FindFirstChild("HumanoidRootPart"),
		style = "Bare"
	}
	
	local handle = Instance.new("Part")
	handle.Position = Vector3.new(root.Position.X, 0, root.Position.Z)
	handle.Size = Vector3.new(attackData.atkrad, 1, attackData.atkrad)
	handle.Anchored = true
	handle.CanCollide = false
	handle.CanQuery = false
	handle.CanTouch = false
	handle.Transparency = 0.99
	handle.Parent = workspace
	
	local vfx = Instance.new("ParticleEmitter")
	vfx.Texture = "rbxassetid://4977919056"
	vfx.Brightness = 1
	vfx.Drag = 1.25
	vfx.Rate = 75
	vfx.Shape = Enum.ParticleEmitterShape.Sphere
	vfx.Size = NumberSequence.new(2, 1)
	vfx.Speed = NumberRange.new(10, 20)
	vfx.WindAffectsDrag = true
	vfx.Parent = handle
	
	local sfoth = Instance.new("Decal")
	sfoth.Texture = "rbxassetid://11464629646"
	sfoth.Face = Enum.NormalId.Top
	sfoth.Parent = handle
	
	local tweenSize = TS:Create(handle, tweenInfo, {Size = Vector3.new(69, 1, 69)})
	
	tweenSize:Play()
	damager:Damage(player, attackData)
	
	tweenSize.Completed:Connect(function()
		if handle then handle:Destroy() end
		tweenSize:Destroy()
	end)
end

return RM3