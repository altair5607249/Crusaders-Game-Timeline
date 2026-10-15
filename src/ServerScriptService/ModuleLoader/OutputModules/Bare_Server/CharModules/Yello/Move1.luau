local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local YM1 = {}

function YM1:Trigger(player: Player)
	print("ym1")
	
	local dmg = 10
	local duration = timing.GetValue("Yello", "Bare", 3, 1) - timing.GetValue("Yello", "Bare", 1, 1)
	
	local attackData = {
		atkdur = duration,
		atkrad = 80,
		atktype = "light",
		bdmg = dmg,
		dmg = dmg * 1.5,
		ID = 1,
		shockwave = 0.25,
		style = "Bare"
	}
	
	damager:Damage(player, attackData)
end

return YM1
