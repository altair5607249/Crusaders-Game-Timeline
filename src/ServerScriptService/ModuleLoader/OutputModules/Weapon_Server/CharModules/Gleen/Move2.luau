local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Gleen", "Weapon", 1, 2)
local duration = timing.GetValue("Gleen", "Weapon", 3, 2) - delayTime

local GM2 = {}

function GM2:Trigger(player: Player)
	print("weapon gm2")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	char:AddTag("SolDisabled")
	char:AddTag("TechsDisabled")
	
	local attackData = {
		atkdur = duration,
		atkrad = 10,
		atktype = "heavy",
		dmg = 10,
		DOT = 0.35,
		DOTchange = 1.357,
		drainStamina = 25,
		ID = 2,
		noStun = true,
		origin = root,
		style = "Weapon"
	}
	
	damager:Damage(player, attackData)
	
	task.delay(duration, function()
		if hum.Health <= 0 or not hum or player.Parent ~= Players then return end
		
		char:RemoveTag("SolDisabled")
		char:RemoveTag("TechsDisabled")
	end)
end

return GM2