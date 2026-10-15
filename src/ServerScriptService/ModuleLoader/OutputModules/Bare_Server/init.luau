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
	Redd = {"Headbutt", "Hero's Fist", "Sacred Circle", "Sixth Sense"},
	Yello = {"Beam", "Invisible Attack", "Fulmination", "Rift Rush"},
	Gleen = {"Suplex", "Animal Instinct", "Give Gifts", "Breach"},
	Bluee = {"Rend", "Copy", "Vortex", "Gamble"}
}

local bareManager = {}

function bareManager.Action(player: Player, move: number, copiedCrusader: string)
	local char = player.Character or player.CharacterAdded:Wait()
	
	if char:HasTag("RagdollActive") then return end
	
	local crusader = player:GetAttribute("Crusader")
	local copycat = false
	
	if copiedCrusader then
		crusader = copiedCrusader
		copycat = true
	end
	
	local moveName = namespace[crusader][move]
	
	if char:GetAttribute("Stunned") then --first stun check
		if not copycat or char:GetAttribute("StunSource") ~= "Recovery" then
			return
		end
	end
	
	if not copycat then
		if not cooldown:IsReady(player, moveName, "Bare") then return end
		cooldown:Register(player, moveName, "Bare", move)
	end
		
	local delayTime = timing.GetValue(crusader, "Bare", 1, move)
	local duration = timing.GetValue(crusader, "Bare", 3, move) - delayTime
	local earlyEnd = timing.GetValue(crusader, "Bare", 5, move) --no recovery frames/anim commitment
	
	char:AddTag("LoadingAttack")
	task.delay(delayTime, function()
		char:RemoveTag("LoadingAttack")
		if char:HasTag("CancellingAttack") then
			char:RemoveTag("CancellingAttack")
			return
		end
		if earlyEnd ~= nil then stunManager.Eval(player, nil, duration, "Recovery") end --recovery frames/anim commitment
		characters[crusader][move]:Trigger(player)
	end)
end

return bareManager