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
local kb = require(script.Handlers.KnockbackHandler)
local bgm = require(script.Handlers.MusicHandler)

local modules = script.InputModules

local inputMods = {}

for i, module in ipairs(modules:GetChildren()) do
	local class = require(module)
	table.insert(inputMods, module)
end

repeat task.wait() until player:HasTag("StartingScreenActive")
repeat task.wait() until not player:HasTag("StartingScreenActive")

IAS:Init(inputMods) --initial spawn

remotes.Knockback.OnClientEvent:Connect(function(atktype: string, momentum: Vector3, targetRoot: Part)
	kb.Casing(atktype, momentum, targetRoot)
end)

remotes.BGMVolume.OnClientEvent:Connect(function(music: Sound, enabled: boolean)
	bgm.Volume(music, enabled)
end)