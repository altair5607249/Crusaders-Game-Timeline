local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local IAS = require(player.PlayerScripts.Energy)
local timing = require(RS.UniversalModules.Time)

local animHandler = require(player.PlayerScripts.ModuleLoader2.Handlers.AnimationHandler)

local attack = RS.Remotes.Attack
local context = RS.InputContexts.BareContext
local switch = false

local crusader, bareRegistry, char, hum, animator, animTracks
local animations = script.Animations

local function onCharacterChanged()
	crusader = player:GetAttribute("Crusader")
	bareRegistry = {0, 0, 0, 0}
	animHandler:ClearCache()
	char = player.Character or player.CharacterAdded:Wait()
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")
	
	animTracks = animHandler:LoadAnimations(animator, animations, crusader, "Bare")
end

if player.Character then onCharacterChanged() end --covers the case where the player's character already exists before this script runs
player.CharacterAdded:Connect(function()
	onCharacterChanged() --callback in case of respawn and/or character swap
end)

RS.Remotes.CopyAnimation.OnClientEvent:Connect(function(copiedCrusader: string, copiedMove: number)
	local copiedAnimTracks = animHandler:LoadAnimations(animator, animations, copiedCrusader, "Bare")
	copiedAnimTracks[copiedMove]:Play()
end)

local bareStyle = {}

function bareStyle.Input(move: number)
	if hum == nil or hum.Health <= 0 then return end
	if char:HasTag("ActiveInput") then return end
	
	local constraint = timing.GetValue(crusader, "Bare", 2, move)
	
	if timing.CheckConstraint(bareRegistry[move], constraint) or char:GetAttribute("Stunned") then return end
	
	char:AddTag("ActiveInput")
	
	local delayTime: number = timing.GetValue(crusader, "Bare", 1, move)
	local duration: number = timing.GetValue(crusader, "Bare", 3, move) - delayTime
	
	local animTrack = animTracks[move]
	animTrack:Play()
	attack:FireServer("Bare_Server", move)
	
	bareRegistry[move] = os.clock()
	
	task.spawn(function() --cancellation thread for certain conditions being met
		local thread = coroutine.running()
		local listeners = {}
		
		--using CS here for C++ conservation of CPU
		local function stopListening()
			for i, listener in ipairs(listeners) do 
				if listener then listener:Disconnect() end 
			end
			char:RemoveTag("ActiveInput")
		end

		table.insert(listeners, CS:GetInstanceAddedSignal("CancellingAttack"):Connect(function(instance)
			if instance == char then 
				animTrack:Stop() 
				stopListening() 
				task.cancel(thread)
			end
		end))

		task.wait(delayTime)
		if not char then stopListening() return end

		table.insert(listeners, CS:GetInstanceAddedSignal("Parried"):Connect(function(instance)
			if instance == char then 
				animTrack:Stop() 
				stopListening() 
				task.cancel(thread)
			end
		end))
		
		local continuation: boolean = timing.GetValue(crusader, "Bare", 5, move)
		
		if continuation then
			table.insert(listeners, CS:GetInstanceAddedSignal("Discontinue"):Connect(function(instance)
				if instance == char then
					animTrack:Stop()
					stopListening()
					task.cancel(thread)
				end
			end))
		elseif continuation == nil then
			table.insert(listeners, CS:GetInstanceAddedSignal("HitFinished"):Connect(function(instance)
				if instance == char then
					animTrack:Stop()
					stopListening()
					task.cancel(thread)
				end
			end))
		else
			task.wait(duration)
			stopListening()
		end
	end)
end

function bareStyle.SwitchToWeapon()
	print("SwitchToWeapon called! switch =", switch)
	if switch then
		switch = false
		print("Switching to Weapon in 1 second...")
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