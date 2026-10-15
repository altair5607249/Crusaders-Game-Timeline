local SSS = game:GetService("ServerScriptService")
local managers = SSS.ModuleLoader.Managers
local damager = require(managers.DamageManager)

local RM1 = {}

function RM1:Trigger(player: Player)
	print("rm1")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	
	local dmg = 35
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = 0.5,
		atkrad = 4,
		atktype = "medium",
		bdmg = dmg,
		dmg = dmg + health^2/(8*maxHealth)
	}
	
	print(attackData.dmg)
	
	damager:Damage(player, attackData) --main hit
end

return RM1
