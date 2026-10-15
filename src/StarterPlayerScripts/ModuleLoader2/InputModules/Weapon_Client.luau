local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local attack = RS.Remotes.Attack

local IAS = require(player.PlayerScripts.Energy)

local crusader
RS.Remotes.ReturnAttribute.OnClientEvent:Connect(function(name: string)
	crusader = name
end)

local context = RS.InputContexts.WeaponContext
local switch = false

local Weapon = {}

function Weapon.MoveOne()
	print("W1")
end

function Weapon.MoveTwo()
	print("W2")
end

function Weapon.MoveThree()
	print("W3")
end

function Weapon.MoveFour()
	print("W4")
end

function Weapon.SwitchToBare()
	if switch then
		switch = false
		task.delay(1, function()
			IAS:Disconnect({context})
			IAS:Init({script.Parent.Bare_Client})
		end)
	end
end

local weaponSpecs = {
	{name = "Move1", callback = function() Weapon.MoveOne() end},
	{name = "Move2", callback = function() Weapon.MoveTwo() end},
	{name = "Move3", callback = function() Weapon.MoveThree() end},
	{name = "Move4", callback = function() Weapon.MoveFour() end},
	{name = "Switch", callback = function() Weapon.SwitchToBare() end}
}

function Weapon.IAS()
	switch = true
	IAS.ActReg(context, weaponSpecs)
end

return Weapon