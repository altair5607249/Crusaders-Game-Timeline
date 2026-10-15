local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Yello", "Weapon", 1, 2)
local duration = timing.GetValue("Yello", "Weapon", 3, 2) - delayTime

local YM2 = {}

function YM2:Trigger(player: Player)
	print("weapon ym2")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	
	char:AddTag("SolDisabled")
	
	local attackData = {
		atkdur = duration,
		atkrad = 4,
		atktype = "light",
		bypassParry = true,
		dmg = 0,
		getTargets = true,
		ID = 2,
		origin = root,
		style = "Weapon"
	}
	
	local light = Instance.new("PointLight")
	light.Parent = root

	--customizing the light
	light.Brightness = 10
	light.Color = Color3.new(1, 1, 0)

	task.delay(duration, function()
		light:Destroy()
		char:RemoveTag("SolDisabled")
	end)
	
	if char:HasTag("Godspeed") then
		attackData.atkrad += 0.5
		attackData.dmg = 10
	end
	
	local targets: {Humanoid} = damager:Damage(player, attackData)
	
	if targets[1] and char:HasTag("Godspeed") then
		local stamina = hum:GetAttribute("Stamina")
		hum:SetAttribute("Stamina", stamina + 30)
	end
end

return YM2