--this manages the damage & timing

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local attack = remotes.Attack

local m1Manager = {}

local managers = script.Parent
local dmgManager = require(managers.DamageManager)

local db = false

function m1Manager.Action(player, origin, char, hum, atkdur, atkrad, cd, count, dmg)
	local newDmg = 0.5*(count-1)^2+dmg --dmg calculations (parabolic curve)
	
	local delayTime = 0.15 --intentional frame delay
	local newAtkdur = atkdur - delayTime
	
	local stun = 1
	local stunned = char:GetAttribute("Stunned")
	if stunned then return end
	
	local direction = char.HumanoidRootPart.CFrame.LookVector
	local velocity = direction*(100^(100^(count-4))*(newDmg/dmg)) + direction*35
	
	local dmgType = nil
	
	if count < 4 then
		dmgType = "light"
	else
		dmgType = "heavy"
	end
	
	task.delay(delayTime, function()
		dmgManager.Damage(origin, char, hum, newAtkdur, atkrad, cd, newDmg, velocity, stun, dmgType)
	end)
	
	db = false
end

attack.OnServerEvent:Connect(function(player, origin, char, hum, atkdur, atkrad, cd, count, dmg)
	if not db then
		db = true --server-side debounce check just in-case
		m1Manager.Action(player, origin, char, hum, atkdur, atkrad, cd, count, dmg)
	end
end)

return m1Manager