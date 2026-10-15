local CP = game:GetService("ContentProvider")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local player = game:GetService("Players").LocalPlayer

local function preloadAllVFX()
	local assetsToLoad = {}
	
	for _, desc in ipairs(RS.AttackVFX:GetDescendants()) do
		if desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("ParticleEmitter") or desc:IsA("Sound") or desc:IsA("Texture") or desc:IsA("Beam") then
			table.insert(assetsToLoad, desc)
		end
	end
	
	for _, desc in ipairs(script:GetDescendants()) do
		if desc:IsA("Animation") then
			table.insert(assetsToLoad, desc)
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
	table.insert(inputMods, module)
end

repeat task.wait() until player:HasTag("StartingScreenActive")
repeat task.wait() until not player:HasTag("StartingScreenActive")

print(inputMods)

IAS:Init(inputMods) --initial spawn

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