local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")

local spacing = require(RS.UniversalModules.Space)

local crusader
RS.Remotes.ReturnAttribute.OnClientEvent:Connect(function(name: string)
	crusader = name
end)

local char, root, hum, animator 
local animations = script.Animations:GetChildren()
local animTracks = {}

local function onCharacterChanged()
	char = player.Character or player.CharacterAdded:Wait()
	root = char:WaitForChild("HumanoidRootPart")
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")

	table.sort(animations, function(a, b)
		return a:GetAttribute("Order") < b:GetAttribute("Order")
	end)

	for i, anim in ipairs(animations) do
		local animTrack = animator:LoadAnimation(anim)
		table.insert(animTracks, animTrack)
	end
end

player:GetPropertyChangedSignal("Character"):Connect(function()
	table.clear(animTracks)
	repeat task.wait() until crusader ~= nil
	onCharacterChanged()
end)

local animSpecs = {
	light = 1,
	medium = 2,
	heavy = 3
}

local knockbackHandler = {}

function knockbackHandler.Casing(attackData: {Instance}, targetRoot: Part)
	if targetRoot then
		knockbackHandler:Affect(attackData, targetRoot)
	else
		knockbackHandler:Effect(attackData)
	end
end

function knockbackHandler:Affect(attackData: {Instance}, targetRoot: Part)
	local velocity = spacing.Knockback(root, attackData)
	targetRoot.AssemblyLinearVelocity = velocity
end

function knockbackHandler:Effect(attackData: {Instance})
	local index = animSpecs[attackData["atktype"]]
	animTracks[index]:Play()
end

return knockbackHandler