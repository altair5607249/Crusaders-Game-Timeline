local CP = game:GetService("ContentProvider") --dont make fun of me id just rather abbreviate
local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local player = game:GetService("Players").LocalPlayer

local function preloadAllVFX()
	local assetsToLoad = {}
	for _, descendant in ipairs(RS.AttackVFX:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("ParticleEmitter") or descendant:IsA("Sound") or descendant:IsA("Texture") or descendant:IsA("Beam") then
			table.insert(assetsToLoad, descendant)
		end
	end
	CP:PreloadAsync(assetsToLoad)
end

preloadAllVFX() --loads vfx before player is declared to be ready
remotes.ClientReadiness:FireServer(true)

local IAS = require(player.PlayerScripts.Energy)

--fix architecture later
local handlers = script.Handlers
local stun = require(handlers.StunHandler)
local kb = require(handlers.KnockbackHandler)

local modules = script.InputModules

local inputMods = {}

for i, module in ipairs(modules:GetChildren()) do
	local class = require(module)
	if module == modules.Weapon_Client then continue end
	table.insert(inputMods, module)
end

task.delay(1.5, function()
	IAS:Init(inputMods) --initial spawn
end)

--fix architecture later
remotes.ToggleStun.OnClientEvent:Connect(function(atktype: string, switch: boolean)
	stun:Toggle(atktype, switch)
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