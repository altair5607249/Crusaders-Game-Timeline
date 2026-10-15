local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local managers = script.Parent.Parent.Managers

local cooldown = require(managers.CooldownManager)
local damager = require(managers.DamageManager)
local stun = require(managers.StunManager)

local UniMods = RS.UniversalModules
local spacing = require(UniMods.Space)
local timing = require(UniMods.Time)

local m1Registry = {}

Players.PlayerAdded:Connect(function(player)
	m1Registry[player] = {0, 0} --1 is the count, 2 is the previous input
end)

Players.PlayerRemoving:Connect(function(player)
	m1Registry[player] = nil
end)

local m1Manager = {}

function m1Manager.Action(player: Player, index: number)
	local char = nil
	local comboExtension, cheating = 1, false
			
	if player:IsA("Player") then char = player.Character or player.CharacterAdded:Wait()
	else char = player end --for dummies (remove after testing phase)
	
	if index > 4 then return end --just incase a modified client tries to pass their strike index as 4 when it isnt actually 4
	if not cooldown:IsReady(player, "M1", "M1") or stun:GetStunState(player) then return end
	
	m1Registry[player][1] = timing.M1Timing(m1Registry[player][1], m1Registry[player][2], comboExtension)
	
	if index == 4 then
		if m1Registry[player][1] == 4 then 
			index = 4
		else
			warn("Index and Registry do not match!")
			cheating = true
		end
	end
	
	m1Registry[player][2] = tick()
	cooldown:Register(player, "M1", index)
	
	if cheating then return end
		
	local attributes = char:GetAttributes()
	local delayTime = timing.GetValue(attributes["Name"], "M1", 1, index)
	local dmg = attributes["dmg"]
	
	local hum = char:WaitForChild("Humanoid")
	local speed, jump = attributes["bspd"], attributes["jump"]
	hum.WalkSpeed /= 3
	hum.JumpPower /= 3
	
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
		damager:Damage(player, attackData)	
		--maybe add a lil' extra delay here for insurance on the commitment
		hum.WalkSpeed, hum.JumpPower = speed, jump
	end)
end

return m1Manager