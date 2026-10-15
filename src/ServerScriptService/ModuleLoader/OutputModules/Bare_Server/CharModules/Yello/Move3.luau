local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local YM3 = {}

function YM3:Trigger(player: Player)
	print("ym3")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	
	local dmg = 25
	local duration = timing.GetValue("Yello", "Bare", 3, 3) - timing.GetValue("Yello", "Bare", 1, 3)
	
	local attackData = {
		atkdur = duration,
		atkrad = 20,
		atktype = "heavy", --supposed to be custom, change after MVP phase
		bdmg = dmg,
		dmg = dmg * 2,
		ID = 3,
		origin = root,
		style = "Bare"
	}
	
	damager:Damage(player, attackData)
end

return YM3