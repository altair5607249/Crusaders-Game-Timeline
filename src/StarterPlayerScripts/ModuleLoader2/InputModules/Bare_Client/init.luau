local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local attack = RS.Remotes.Attack

local IAS = require(RS.UniversalModules.Energy)
local timing = require(RS.UniversalModules.Time)

local context = RS.InputContexts.BareContext
local switch = false

local char, hum, animator 
local animations = script.Animations
local animTracks = {}

local function onCharacterChanged()
	char = player.Character or player.CharacterAdded:Wait()
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")
	
	local charAnims = animations[char:GetAttribute("Name")]:GetChildren()
	
	table.sort(charAnims, function(a, b)
		return a:GetAttribute("Order") < b:GetAttribute("Order")
	end)
	
	for i, anim in ipairs(charAnims) do
		local animTrack = animator:LoadAnimation(anim)
		table.insert(animTracks, animTrack)
	end
end

onCharacterChanged()

player:GetPropertyChangedSignal("Character"):Connect(function()
	table.clear(animTracks)
	onCharacterChanged()
end)

local bareRegistry = {0, 0, 0, 0}

local bareStyle = {}

function bareStyle.Input(move: number)
	local constraint = timing.GetValue(char:GetAttribute("Name"), "Bare", 2, move)
	if timing.CheckConstraint(bareRegistry[move], constraint) then return end
	
	print("Client reaction")
	local animTrack = animTracks[move]
	animTrack:Play()
	attack:FireServer("Bare_Server", move)
	
	bareRegistry[move] = tick()
end

function bareStyle.SwitchToWeapon()
	if switch then
		switch = false
		task.delay(1, function()
			IAS:Disconnect({context})
			IAS:Init({script.Parent.Weapon_Client})
		end)
	end
end

local bareSpecs = {
	{name = "Move1", callback = function() bareStyle.Input(1) end},
	{name = "Move2", callback = function() bareStyle.Input(2) end},
	{name = "Move3", callback = function() bareStyle.Input(3) end},
	{name = "Move4", callback = function() bareStyle.Input(4) end},
	{name = "Switch", callback = function() bareStyle.SwitchToWeapon() end}
}

function bareStyle.IAS()
	switch = true
	IAS.ActReg(context, bareSpecs)
end

return bareStyle