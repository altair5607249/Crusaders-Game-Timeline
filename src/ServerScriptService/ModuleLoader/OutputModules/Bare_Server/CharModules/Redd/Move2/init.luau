local SSS = game:GetService("ServerScriptService")
local managers = SSS.ModuleLoader.Managers
local damager = require(managers.DamageManager)

local RM2 = {}

function RM2:Trigger(player: Player)
	print("rm2")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	local rightArm = char:WaitForChild("Right Arm")
	
	local dmg = 25
	local shockwaveDmg = 10
	local delayTime = 0.2
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = 0.5,
		atkrad = 4,
		atktype = "heavy",
		bdmg = dmg,
		dmg = dmg + health^2/(8*maxHealth),
		ID = 2,
		style = "Bare"
	}
	
	--calibrate effects
	local hitPart = char:WaitForChild("hitPart")
	
	local vfx = Instance.new("Explosion")
	vfx.ExplosionType = Enum.ExplosionType.NoCraters
	vfx.BlastPressure = 0 --this is purely cosmetic
	vfx.BlastRadius = 50
	vfx.Position = (hitPart.CFrame * CFrame.new(0, 0, -attackData.atkrad*2)).Position
	
	--for glowing arm
	local glow = Instance.new("PointLight")
	glow.Brightness = 8
	glow.Color = Color3.new(1, 0, 0)
	glow.Range = 10
	glow.Shadows = false
	glow.Parent = rightArm
	
	--copy and pastable move sfx code
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
		bdmg = shockwaveDmg,
		dmg = shockwaveDmg + health^2/(20*maxHealth),
		ID = 2,
		shockwave = 0.5
	}
	
	task.delay(delayTime, function()
		vfx.Parent = workspace --ekkuSPLOOOSION
		damager:Damage(player, attackData2) --shockwave
		glow:Destroy()
		vfx.AncestryChanged:Connect(function()
			vfx:Destroy()
		end)
	end)
end

return RM2