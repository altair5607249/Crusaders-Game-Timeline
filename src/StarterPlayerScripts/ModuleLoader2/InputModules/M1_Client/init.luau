local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local player = Players.LocalPlayer

local IAS = require(player.PlayerScripts.Energy)
local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local animHandler = require(player.PlayerScripts.ModuleLoader2.Handlers.AnimationHandler)

local attack = RS.Remotes.Attack

local crusader: string?, prevInput, count, comboExtension: number?, db, char, hum, animator 
local bareOptions: {number}?, weaponOptions: {number}?
local bareAnimTracks: {Animation}?, weaponAnimTracks: {Animation}?
local bareAnims, weaponAnims = script.BareAnimations, script.WeaponAnimations

local function resetOptions()
	bareOptions = {1, 2, 3}
	weaponOptions = {1, 2, 3}
end

local m1 = {}

local function onCharacterChanged()
	crusader = player:GetAttribute("Crusader")

	resetOptions()

	prevInput, count, db = 0, 0, false
	comboExtension = timing.GetValue(crusader, "M1", 3, 1) + 0.5

	char = player.Character or player.CharacterAdded:Wait()
	hum = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
	animator = hum:WaitForChild("Animator")

	bareAnimTracks = animHandler:LoadAnimations(animator, bareAnims, crusader, "M1_Bare")
	weaponAnimTracks = animHandler:LoadAnimations(animator, weaponAnims, crusader, "M1_Weapon")
end

if player.Character then onCharacterChanged() end --covers the case where the player's character already exists before this script runs
player.CharacterAdded:Connect(function()
	onCharacterChanged() --callback in case of respawn and/or character swap
end)

function m1.Click()
	if not db then
		if hum == nil or hum.Health <= 0 then return end
		if char:GetAttribute("Stunned") then return end
		if char:HasTag("ActiveInput") or char:HasTag("SolDisabled") then return end
		
		if char:HasTag("WeaponActive") then
			local stamina = hum:GetAttribute("Stamina")
			if stamina < 5 then return end
		end
		
		char:AddTag("ActiveInput")

		db = true

		count = timing.M1Timing(count, prevInput, comboExtension)

		local index = count
		m1:Attack(index)
		prevInput = os.clock()
	end
end

function m1:Attack(index: number)
	--blue's randomizer stuff
	local animTracks: {Animation} = char:HasTag("WeaponActive") and weaponAnimTracks or bareAnimTracks
	local options: {number} = char:HasTag("WeaponActive") and weaponOptions or bareOptions
	
	if crusader == "Bluee" and count < 4 then
		if #options == 0 or count == 1 then 
			table.clear(options)
			table.insert(options, 1)
			table.insert(options, 2)
			table.insert(options, 3)
		end
		local choice = math.random(1, #options)
		index = options[choice]
		table.remove(options, choice)
	end
	
	root.AssemblyLinearVelocity = root.CFrame.LookVector * 45

	local animTrack = animTracks[index]
	animTrack:Play()
	attack:FireServer("M1_Server", index)

	local currentChar = char
	local cooldown: number = timing.GetValue(crusader, "M1", 2, index)
	local duration: number = timing.GetValue(crusader, "M1", 3, index)
	
	task.delay(cooldown, function()
		if currentChar == char then db = false  end
	end)
	
	task.delay(duration, function()
		char:RemoveTag("ActiveInput")
	end)
end

CS:GetInstanceAddedSignal("WeaponActive"):Connect(resetOptions)
CS:GetInstanceRemovedSignal("WeaponActive"):Connect(resetOptions)

local mouseSpecs = {
	{name = "Punch", callback = function() m1.Click() end}
}

function m1.IAS()
	local context = RS.InputContexts.MouseContext

	IAS.ActReg(context, mouseSpecs)
end

return m1