local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local managers = script.Parent.Parent.Managers

local cooldown = require(managers.CooldownManager)
local stun = require(managers.StunManager)

local CMS = require(SSS.ModuleLoader.Matter)
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
	
	if not cooldown:IsReady(player, moveName, "Bare") or CMS:GetAttribute(player, "Stunned") then return end
	cooldown:Register(player, moveName, move)
	
	local char  = player.Character or player.CharacterAdded:Wait()
	local crusader = CMS:GetAttribute(player, "Crusader")
		
	local delayTime = timing.GetValue(crusader, "Bare", 1, move)
	local duration = timing.GetValue(crusader, "Bare", 3, move)
		
	task.delay(delayTime, function()
		stunManager.Eval(player, nil, duration) --recovery frames/anim commitment
		characters[crusader][move]:Trigger(player)
	end)
end

return bareManager