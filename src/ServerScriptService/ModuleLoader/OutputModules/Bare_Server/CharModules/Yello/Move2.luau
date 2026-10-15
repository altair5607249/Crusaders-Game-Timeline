local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local YM2 = {}

function YM2:Trigger(player: Player)
	print("ym2")
	
	local dmg = 20
	local duration = timing.GetValue("Yello", "Bare", 3, 2) - timing.GetValue("Yello", "Bare", 1, 2)
	
	local attackData = {
		atkdur = duration,
		atkrad = 4,
		atktype = "medium",
		bdmg = dmg,
		dmg = dmg * 1.5,
		ID = 2,
		style = "Bare"
	}
	
	damager:Damage(player, attackData)
end

return YM2