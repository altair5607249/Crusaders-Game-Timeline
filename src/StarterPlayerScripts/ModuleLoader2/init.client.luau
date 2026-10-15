local remotes = game:GetService("ReplicatedStorage").Remotes
local player = game:GetService("Players").LocalPlayer
local IAS = require(script.Handlers.IASHandler)
local stun = require(script.Handlers.StunHandler)
local inputMods = script.InputModules:GetChildren()

for i, module in ipairs(inputMods) do
	require(module)
end

IAS:Init(inputMods)

remotes.ToggleStun.OnClientEvent:Connect(function(duration: number)
	stun:Toggle(duration)
end)

--[[reserved for the rpg :)
local CS = game:GetService("CollectionService")

CS:GetInstanceAddedSignal("Weapon"):Connect(Weapon.new)

for i, object in CS:GetTagged("Weapon") do
	if object:FindFirstAncestorOfClass("ReplicatedStorage") then continue end
	Weapon.new(object)
end]]