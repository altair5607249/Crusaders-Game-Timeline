--this manages the animations & counting

local RS = game:GetService("ReplicatedStorage")
local attack = RS.Remotes.Attack
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local char, hum, animator = nil, nil, nil
local CD, CD2, comboExtension = nil, nil, 1.25

local animations = script.SeqAnimations:GetChildren()
local animTracks = {}
table.sort(animations, function(a, b)
	return a:GetAttribute("Order") < b:GetAttribute("Order")
end)

local function onCharacterAdded()
	char = player.Character or player.CharacterAdded:Wait()
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")
	
	CD, CD2 = char:GetAttribute("cd"), char:GetAttribute("cd")
	
	for i, anim in ipairs(animations) do
		local animTrack = animator:LoadAnimation(anim)
		table.insert(animTracks, animTrack)
	end
end

onCharacterAdded()

player:GetPropertyChangedSignal("Character"):Connect(function()
	table.clear(animTracks)
	onCharacterAdded()
end)

local m1 = {}

local prevInput = 0
local count = 0
local db = false

function m1.Click()
	if not db then
		db = true
		
		--timing check
		if tick() - prevInput <= comboExtension or prevInput == 0 then
			count += 1
			m1:Attack()
			if count == 4 then
				CD += 1
				count = 0
			end
		else
			count = 1
			m1:Attack()
		end
		
		task.delay(CD, function()
			CD = CD2
			db = false
			prevInput = tick()
		end)
	end
end

function m1:Attack()
	local animTrack = animTracks[count]
	animTrack:Play()
	attack:FireServer("M1_Server", count)
end

local IASHandler = require(player.PlayerScripts.ModuleLoader2.Handlers.IASHandler)

local mouseSpecs = {
	{name = "Punch", callback = function() m1.Click() end}
}

function m1.IAS()
	local context = RS.InputContexts.MouseContext

	IASHandler.ActReg(context, mouseSpecs)
end

return m1