local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Yello", "Weapon", 1, 3)
local duration = timing.GetValue("Yello", "Weapon", 3, 3) - delayTime

local YM3 = {}

function YM3:Trigger(player: Player)
	print("weapon ym3")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local rootFrame = root.CFrame
	local extendedHitbox = rootFrame * CFrame.new(1.5, 0, -42.5)
	
	local attackData = {
		atkdur = duration,
		atkrad = 5,
		atktype = "medium",
		dmg = 30,
		getTargets = true,
		ID = 3,
		origin = extendedHitbox,
		style = "Weapon"
	}
	
	local targets: {Humanoid}? = damager:Damage(player, attackData)
	
	if targets[1] and char:HasTag("Godspeed") then
		if char:HasTag("Parried") then return end
		
		local stamina = hum:GetAttribute("Stamina")
		hum:SetAttribute("Stamina", stamina + 15)
	end
end

return YM3