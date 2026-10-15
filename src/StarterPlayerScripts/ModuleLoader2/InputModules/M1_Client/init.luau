local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local IAS = require(player.PlayerScripts.Energy)
local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local animHandler = require(player.PlayerScripts.ModuleLoader2.Handlers.AnimationHandler)

local attack = RS.Remotes.Attack

local crusader, options, prevInput, count, comboExtension, db, char, hum, animator, animTracks
local animations = script.Animations

local function onCharacterChanged()
	crusader = player:GetAttribute("Crusader")
	options = {1, 2, 3}
	prevInput, count, comboExtension, db = 0, 0, 1, false
	char = player.Character or player.CharacterAdded:Wait()
	hum = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
	animator = hum:WaitForChild("Animator")

	animTracks = animHandler:LoadAnimations(animator, animations, crusader, "M1")
end

player.CharacterAdded:Connect(function()
	onCharacterChanged()
end)

--[[player.CharacterAdded:Connect(function()
	table.clear(animTracks)
	repeat task.wait() until crusader ~= nil
	onCharacterChanged()
end)]]

local m1 = {}

function m1.Click()
	if not db then
		if hum == nil or hum.Health <= 0 then return end
		if char:GetAttribute("Stunned") then return end

		db = true

		count = timing.M1Timing(count, prevInput, comboExtension)

		local index = count
		m1:Attack(index)
		prevInput = os.clock()
	end
end

function m1:Attack(index: number)
	--blue's randomizer stuff
	if crusader == "Bluee" and count < 4 then
		if #options == 0 or count == 1 then options = {1, 2, 3} end
		local choice = math.random(1, #options)
		index = options[choice]
		table.remove(options, choice)
	end
	
	root.AssemblyLinearVelocity = root.CFrame.LookVector * 45

	local animTrack = animTracks[index]
	animTrack:Play()
	attack:FireServer("M1_Server", index)

	local currentChar = char
	local cooldown = timing.GetValue(crusader, "M1", 2, index)
	task.delay(cooldown, function()
		if currentChar == char then db = false end
	end)
end

local mouseSpecs = {
	{name = "Punch", callback = function() m1.Click() end}
}

function m1.IAS()
	local context = RS.InputContexts.MouseContext

	IAS.ActReg(context, mouseSpecs)
end

return m1