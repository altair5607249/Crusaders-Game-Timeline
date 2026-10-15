local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local player = game:GetService("Players").LocalPlayer

remotes.ClientReadiness:FireServer(true)

local IAS = require(player.PlayerScripts.Energy)
--fix architecture later
local handlers = script.Handlers
local stun = require(handlers.StunHandler)
local kb = require(handlers.KnockbackHandler)

local modules = script.InputModules

local movement = nil

local inputMods = {}

for i, module in ipairs(modules:GetChildren()) do
	local class = require(module)
	if module == modules.Weapon_Client then continue end
	table.insert(inputMods, module)
	
	--fix architecture later
	if module == modules.Movement then movement = class end
end

IAS:Init(inputMods)

--fix architecture later
remotes.ToggleStun.OnClientEvent:Connect(function(atktype: string, duration: number)
	stun:Toggle(atktype, duration)
end)

remotes.Knockback.OnClientEvent:Connect(function(atktype: string, momentum: Vector3, targetRoot: Part)
	kb.Casing(atktype, momentum, targetRoot)
end)

--[[reserved for the rpg :)
local CS = game:GetService("CollectionService")

CS:GetInstanceAddedSignal("Weapon"):Connect(Weapon.new)

for i, object in CS:GetTagged("Weapon") do
	if object:FindFirstAncestorOfClass("ReplicatedStorage") then continue end
	Weapon.new(object)
end]]