local RS = game:GetService("ReplicatedStorage")
local attack = RS.Remotes.Attack
local player = game:GetService("Players").LocalPlayer

local IAS = require(RS.UniversalModules.Energy)
local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local options, prevInput, count, comboExtension, db, char, hum, animator
local animations = script.Animations
local animTracks = {}

local function onCharacterChanged()
	options = {1, 2, 3}
	prevInput, count, comboExtension, db = 0, 0, 1, false
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

local m1 = {}

function m1.Click()
	if not db then
		if hum == nil or hum.Health <= 0 then return end
		
		db = true
		
		count = timing.M1Timing(count, prevInput, comboExtension)
		
		local index = count
		m1:Attack(index)
		prevInput = tick()
	end
end

function m1:Attack(index: number)
	--blue's randomizer stuff
	if char:GetAttribute("Name") == "Bluee" and count < 4 then
		if #options == 0 or count == 1 then options = {1, 2, 3} end
		local choice = math.random(1, #options)
		index = options[choice]
		table.remove(options, choice)
	end
	
	local animTrack = animTracks[index]
	animTrack:Play()
	attack:FireServer("M1_Server", index)
	
	local cooldown = timing.GetValue(char:GetAttribute("Name"), "M1", 2, index)
	task.delay(cooldown, function()
		db = false
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