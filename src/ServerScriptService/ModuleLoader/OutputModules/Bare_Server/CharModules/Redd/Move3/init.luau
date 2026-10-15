local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")
local managers = SSS.ModuleLoader.Managers

local damager = require(managers.DamageManager)

local timing = require(RS.UniversalModules.Time)

local delayTime = timing.GetValue("Redd", "Bare", 3, 3) - timing.GetValue("Redd", "Bare", 1, 3)
local tweenInfo = TweenInfo.new(delayTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
local fireInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local RM3 = {}

function RM3:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local duration = 3.5
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration,
		atkrad = 10,
		atktype = "light",
		dmg = 6,
		DOT = 0.35,
		expanding = 1.48599,
		ID = 3,
		noKB = true,
		noSound = true,
		origin = root,
		style = "Bare"
	}
	
	local handle = Instance.new("Part")
	handle.Position = Vector3.new(root.Position.X, root.Position.Y - 3, root.Position.Z)
	handle.Size = Vector3.new(attackData.atkrad, 1, attackData.atkrad)
	handle.Anchored = true
	handle.CanCollide = false
	handle.CanQuery = false
	handle.CanTouch = false
	handle.Transparency = 0.99
	handle.Parent = workspace
	
	--fireeeee
	local holder = RS.AttackVFX.Fire:Clone()
	local fire: ParticleEmitter?, smoke: ParticleEmitter?
	
	for _, obj in ipairs(holder:GetChildren()) do
		obj.Parent = handle
		
		if obj.Name == "Particles" then
			fire = obj
		elseif obj.Name == "Smoke" then
			smoke = obj
		end
	end
	
	holder:Destroy()
	
	local sfoth = Instance.new("Decal")
	sfoth.Texture = "rbxassetid://11464629646"
	sfoth.Face = Enum.NormalId.Top
	sfoth.Parent = handle
	
	local sfx = script.AuxSound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	local tweenSize = TS:Create(handle, tweenInfo, {Size = Vector3.new(69, 1, 69)})
	
	tweenSize:Play()
	damager:Damage(player, attackData)
	
	hum:TakeDamage(currentHealth/8)
	
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	tweenSize.Completed:Connect(function()
		tweenSize:Destroy()
	end)
	
	local alpha = Instance.new("NumberValue")
	alpha.Parent = fire
	alpha.Changed:Connect(function(value)
		fire.Size = NumberSequence.new(value)
	end)

	local beta = Instance.new("NumberValue")
	beta.Parent = fire
	beta.Changed:Connect(function(value)
		fire.Transparency = NumberSequence.new(value)
		smoke.Transparency = NumberSequence.new(value)
		sfoth.Transparency = value
	end)

	local tweenAlpha = TS:Create(alpha, tweenInfo, {Value = 5})
	tweenAlpha:Play()

	tweenAlpha.Completed:Connect(function()
		tweenAlpha:Destroy()

		local tweenBeta = TS:Create(beta, fireInfo, {Value = 1})
		tweenBeta:Play()

		tweenBeta.Completed:Connect(function()
			tweenBeta:Destroy()
			handle:Destroy()
		end)
	end)
end

return RM3