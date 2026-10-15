local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local duration: number = timing.GetValue("Redd", "Weapon", 3, 3) - timing.GetValue("Redd", "Weapon", 1, 3)

local function healthCurve(health: number, maxHealth: number, stat: number)
	local a = maxHealth
	local b = (stat^(1/2))/a
	return (b*health)^2 + stat
end

local RM3 = {}

function RM3:Trigger(player: Player)
	print("weapon rm3")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local deltaHealth = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration - 0.5, --0.5s of endlag
		atkrad = 10,
		atktype = "medium",
		dmg = healthCurve(deltaHealth, maxHealth, 5),
		DOT = 0.1,
		expanding = 5,
		ID = 3,
		noKB = true,
		origin = root,
		style = "Weapon"
	}
	
	damager:Damage(player, attackData)
	
	hum:TakeDamage(hum.Health / 8)
end

return RM3