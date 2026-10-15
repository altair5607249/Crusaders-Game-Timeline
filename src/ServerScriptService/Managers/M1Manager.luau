--this manages the damage & timing

local Players = game:GetService("Players")
local RNS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local attack = remotes.Attack

local m1Manager = {}

local managers = script.Parent
local dmgManager = require(managers.DamageManager)

local char = nil
local atk_rad = nil
local atk_dur = nil
local CD = nil
local dmg = nil

function m1Manager.Attack(origin, hum)
	dmgManager.Damage(origin, origin.Parent, hum, atk_dur, atk_rad, CD, dmg)
end

attack.OnServerEvent:Connect(function(player)
	char = player.Character or player.CharacterAdded:Wait()
	atk_dur = char:GetAttribute("atkdur")
	atk_rad = char:GetAttribute("atkrad")
	CD = char:GetAttribute("cd")
	dmg = char:GetAttribute("dmg")
	local hitArea = char:WaitForChild("hitPart")
	local hum = char:WaitForChild("Humanoid")
	m1Manager.Attack(hitArea, hum)
end)

return m1Manager