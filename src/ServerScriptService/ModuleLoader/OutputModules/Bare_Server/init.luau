local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local managers = script.Parent.Parent.Managers

local cooldown = require(managers.CooldownManager)
local stunManager = require(managers.StunManager)

local timing = require(RS.UniversalModules.Time)

local charModules = script.CharModules:GetChildren()
local characters = {}

for i, character in ipairs(charModules) do
	for j, move in ipairs(character:GetChildren()) do
		local class = require(move)
		characters[character.Name] = characters[character.Name] or {}
		table.insert(characters[character.Name], class)
	end
end

local namespace = {
	Redd = "RM",
	Yello = "YM",
	Gleen = "GM",
	Bluee = "BM"
}

local bareManager = {}

function bareManager.Action(player: Player, move: number, copiedCrusader: string)
	local crusader = player:GetAttribute("Crusader")
	local copycat = false
	
	if copiedCrusader then
		crusader = copiedCrusader
		copycat = true
	end
	
	local moveName = namespace[crusader] .. tostring(move)
	
	if player:GetAttribute("Stunned") then --first stun check
		if not copycat or player:GetAttribute("StunSource") ~= "Recovery" then
			return
		end
	end
	
	if not copycat then
		if not cooldown:IsReady(player, moveName, "Bare") then return end
		cooldown:Register(player, moveName, move)
	end
	
	print("Server-side confirmation")
		
	local delayTime = timing.GetValue(crusader, "Bare", 1, move)
	local duration = timing.GetValue(crusader, "Bare", 3, move)
	
	player:AddTag("LoadingAttack")
	print(player:HasTag("CancellingMove"))
	task.delay(delayTime, function()
		print(player:HasTag("CancellingMove"))
		player:RemoveTag("LoadingAttack")
		print(player:HasTag("CancellingMove"))
		stunManager.Eval(player, nil, duration, "Recovery") --recovery frames/anim commitment
		characters[crusader][move]:Trigger(player)
	end)
end

return bareManager