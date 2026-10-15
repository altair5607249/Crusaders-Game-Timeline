local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local managers = script.Parent.Parent.Managers

local cooldown = require(managers.CooldownManager)
local stunManager = require(managers.StunManager)

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local charModules = script.CharModules:GetChildren()
local characters = {}

for i, character: Folder in ipairs(charModules) do
	local moveScripts = character:GetChildren()
	table.sort(moveScripts, function(a, b)
		return a:GetAttribute("Order") < b:GetAttribute("Order")
	end)
	
	characters[character.Name] = {}
	for j, move: ModuleScript in ipairs(moveScripts) do
		table.insert(characters[character.Name], require(move))
	end
end

local namespace = {
	Redd = {"Headbutt", "Hero's Fist", "Sacred Circle", "Sixth Sense"},
	Yello = {"Beam", "Invisible Attack", "Fulmination", "Rift Rush"},
	Gleen = {"Suplex", "Animal Instinct", "Give Gifts", "Breach"},
	Bluee = {"Rip", "Copy", "Vortex", "Gamble"}
}

local bareManager = {}

function bareManager.Action(player: Player, move: number, copiedCrusader: string)
	local char = player.Character or player.CharacterAdded:Wait()
	
	if char:HasTag("RagdollActive") or char:HasTag("WeaponActive") or char:HasTag("SolDisabled") then return end
	
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
	
	local cancelMove = false
	local listener
	
	listener = CS:GetInstanceAddedSignal("CancellingAttack"):Connect(function(instance)
		if instance == char then
			char:RemoveTag("LoadingAttack")
			cancelMove = true
			if listener then listener:Disconnect() end
		end
	end)
	
	task.wait(delayTime)
	
	if listener then listener:Disconnect() end
	
	if not char then return end
	
	if char:HasTag("LoadingAttack") then char:RemoveTag("LoadingAttack") end
	
	if cancelMove then return end
	
	if earlyEnd ~= nil then stunManager.Eval(player, nil, duration, "Recovery") end --recovery frames/anim commitment
	
	characters[crusader][move]:Trigger(player)
end

function bareManager.GetMoves(crusader: string)
	return namespace[crusader]
end

return bareManager