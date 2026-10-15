local SSS = game:GetService("ServerScriptService")
local managers = SSS.ModuleLoader.Managers
local damager = require(managers.DamageManager)

local RM2 = {}

function RM2:Trigger(player: Player)
	print("RM2")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	
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
		dmg = dmg + health^2/(8*maxHealth)
	}
	
	damager:Damage(player, attackData) --main hit
	
	local attackData2 = {
		atkdur = 0.3,
		atkrad = 40,
		atktype = "light",
		bdmg = shockwaveDmg,
		dmg = shockwaveDmg + health^2/(20*maxHealth),
		shockwave = 0.5
	}
	
	task.delay(delayTime, function()
		damager:Damage(player, attackData2) --shockwave
	end)
end

return RM2