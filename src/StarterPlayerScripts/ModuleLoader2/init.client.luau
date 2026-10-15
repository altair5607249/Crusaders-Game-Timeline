local CS = game:GetService("CollectionService")
local UIS = game:GetService("UserInputService")

local modules = script:WaitForChild("Modules")
local M1 = require(modules:WaitForChild("M1_Client"))
local Movement = require(modules:WaitForChild("Movement_Client"))
local Weapon = require(modules:WaitForChild("Weapon_Client"))

--for Weapon_Client
CS:GetInstanceAddedSignal("Weapon"):Connect(Weapon.new)

for i, object in CS:GetTagged("Weapon") do
	if object:FindFirstAncestorOfClass("ReplicatedStorage") then continue end
	Weapon.new(object)
end

local dispatch = { --note to self: do not call the module functions immediately
	[Enum.UserInputType.MouseButton1] = function() M1:Click() end,
	[Enum.KeyCode.Q] = function() Movement:Dash() end,
	[Enum.KeyCode.LeftShift] = function() Movement:Sprint() end,
	[Enum.KeyCode.RightShift] = function() Movement:Sprint() end
}

UIS.InputBegan:Connect(function(input)
	local action = dispatch[input.KeyCode]
	if action then
		action()
	else
		local action2 = dispatch[input.UserInputType]
		if action2 then
			action2()
		end
	end
end)