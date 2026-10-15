local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local managers = script.Parent.Parent.Managers

local cooldown = require(managers.CooldownManager)
local damager = require(managers.DamageManager)

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local m1Registry = {}

Players.PlayerAdded:Connect(function(player)
	m1Registry[player] = {
		prevCount = 0,
		prevTick = 0
	}
end)

Players.PlayerRemoving:Connect(function(player)
	m1Registry[player] = nil
end)

local m1Manager = {}

function m1Manager.Action(player: Player, index: number)
	local char = player.Character or player.CharacterAdded:Wait()
	local comboExtension, cheating = 1, false
	
	if index > 4 then return end --just incase a modified client tries to pass their strike index as 4 when it isnt actually 4
	if not cooldown:IsReady(player, "M1", "M1") or player:GetAttribute("Stunned") then return end
	
	local count = timing.M1Timing(m1Registry[player].prevCount, m1Registry[player].prevTick, comboExtension)
	
	if index == 4 then
		if count == 4 then 
			index = 4
		else
			warn("Index and Registry do not match!")
			return
		end
	end

	m1Registry[player].prevCount = count
	m1Registry[player].prevTick = tick()
	cooldown:Register(player, "M1", index)
	
	local crusader = player:GetAttribute("Crusader")
		
	local delayTime = timing.GetValue(crusader, "M1", 1, index)
	local dmg = spacing.GetValue(crusader, 4)
	
	local hum = char:WaitForChild("Humanoid")
	local speed, jump = spacing.GetValue(crusader, 1), spacing.GetValue(crusader, 3)
	hum.WalkSpeed, hum.JumpPower = speed/3, jump/3 
	
	local attackData = {
		atkdur = 0.2,
		atkrad = 3.5,
		atktype = (index == 4 and "medium") or "light", --see stun manager for time references
		bdmg = dmg,
		dmg = dmg + 0.5*(index-1)^2, --dmg calculations (parabolic curve)
		ID = index,
		style = "M1"
	}
	
	task.delay(delayTime, function()
		if player:GetAttribute("Stunned") then return end
		damager:Damage(player, attackData)	
		--maybe add a lil' extra delay here for insurance on the commitment
		hum.WalkSpeed, hum.JumpPower = speed, jump
	end)
end

return m1Manager