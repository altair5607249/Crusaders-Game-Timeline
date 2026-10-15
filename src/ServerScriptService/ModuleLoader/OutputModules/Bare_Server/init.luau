local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local managers = script.Parent.Parent.Managers

local cooldown = require(managers.CooldownManager)
local stun = require(managers.StunManager)

local timing = require(RS.UniversalModules.Time)

local stunManager = require(script.Parent.Parent.Managers.StunManager)
local charModules = script.CharModules:GetChildren()
local characters = {}

for i, character in ipairs(charModules) do
	for j, move in ipairs(character:GetChildren()) do
		local class = require(move)
		characters[character.Name] = characters[character.Name] or {}
		table.insert(characters[character.Name], class)
	end
end

local bareManager = {}

function bareManager.Action(player: Player, move: number)
	local moveName = "BM" .. tostring(move)
	
	if not cooldown:IsReady(player, moveName, "Bare") or stun:GetStunState(player) then return end
	cooldown:Register(player, moveName, move)
	
	print("Server reaction")
	
	local char  = player.Character or player.CharacterAdded:Wait()
	local ID = char:GetAttribute("Name")
		
	local delayTime = timing.GetValue(ID, "Bare", 1, move)
	local duration = timing.GetValue(ID, "Bare", 3, move)
		
	task.delay(delayTime, function()
		stunManager.Eval(player, nil, duration) --recovery frames/anim commitment
		characters[ID][move]:Trigger(player)
	end)
end

return bareManager