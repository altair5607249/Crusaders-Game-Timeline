local CS = game:GetService("CollectionService")
local UIS = game:GetService("UserInputService")

local modules = script:WaitForChild("Modules"):GetChildren()
for i, module in ipairs(modules) do
	require(module)
end

--[[for Weapon_Client
CS:GetInstanceAddedSignal("Weapon"):Connect(Weapon.new)

for i, object in CS:GetTagged("Weapon") do
	if object:FindFirstAncestorOfClass("ReplicatedStorage") then continue end
	Weapon.new(object)
end]]