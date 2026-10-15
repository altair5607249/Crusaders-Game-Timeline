local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local duration: number = timing.GetValue("Redd", "Weapon", 3, 1) - timing.GetValue("Redd", "Weapon", 1, 1)

local function healthCurve(health: number, maxHealth: number, stat: number)
	local a = maxHealth
	local b = (stat^(1/2))/a
	return (b*health)^2 + stat
end

local RM1 = {}

function RM1:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local deltaHealth = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration,
		atkrad = 6.5,
		atktype = "light",
		customSound = script.Bonk,
		dmg = 25,
		ID = 1,
		style = "Weapon"
	}
	
	damager:Damage(player, attackData)
end

return RM1