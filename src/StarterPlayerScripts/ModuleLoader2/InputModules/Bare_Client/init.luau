local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local attack = RS.Remotes.Attack

local IAS = require(player.PlayerScripts.Energy)
local timing = require(RS.UniversalModules.Time)

local animHandler = require(player.PlayerScripts.ModuleLoader2.Handlers.AnimationHandler)

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

player.CharacterAdded:Connect(function()
	onCharacterChanged()
end)

RS.Remotes.CopyAnimation.OnClientEvent:Connect(function(copiedCrusader: string, copiedMove: number)
	local copiedAnimTracks = animHandler:LoadAnimations(animator, animations, copiedCrusader, "Bare")
	copiedAnimTracks[copiedMove]:Play()
end)

local bareStyle = {}

function bareStyle.Input(move: number)
	if hum == nil or hum.Health <= 0 then return end
	
	local constraint = timing.GetValue(crusader, "Bare", 2, move)
	
	if timing.CheckConstraint(bareRegistry[move], constraint) or char:GetAttribute("Stunned") then return end
	
	local delayTime = timing.GetValue(crusader, "Bare", 1, move)
	local animTrack = animTracks[move]
	animTrack:Play()
	attack:FireServer("Bare_Server", move)
	
	bareRegistry[move] = os.clock()
	
	task.delay(delayTime, function()
		if char:HasTag("CancellingAttack") then animTrack:Stop() end
	end)
	
	local fullAnim = timing.GetValue(crusader, "Bare", 3, move)
	local continuation: boolean = timing.GetValue(crusader, "Bare", 5, move)
	
	if continuation then
		task.spawn(function()
			repeat task.wait() until char:HasTag("Continue") or char:HasTag("Discontinue")
			if char:HasTag("Discontinue") then animTrack:Stop() end
		end)
	elseif continuation == nil then
		local initialTime = os.clock()
		task.spawn(function()
			repeat task.wait() until char:HasTag("HitFinished") or os.clock() - initialTime >= fullAnim
			animTrack:Stop()
		end)
	end
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