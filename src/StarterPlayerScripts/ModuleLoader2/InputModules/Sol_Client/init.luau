local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local IAS = require(player.PlayerScripts.Energy)
local timing = require(RS.UniversalModules.Time)

local animHandler = require(player.PlayerScripts.ModuleLoader2.Handlers.AnimationHandler)

local attack = RS.Remotes.Attack
local cdChange = RS.Remotes.ChangeCooldown
local equipEvent = RS.Remotes.EquipWeapon

local bareStyle = RS.InputContexts.BareContext
local weaponStyle = RS.InputContexts.WeaponContext

local defaultStyle = bareStyle --characters will not spawn in with their weapon equipped

local crusader, char, hum, animator
local bareAnimTracks, weaponAnimTracks
local bareRegistry, weaponRegistry, swapRegistry
local bareAnims = script.BareAnimations
local weaponAnims = script.WeaponAnimations

local Sol = {}

RS.Remotes.CopyMove.OnClientEvent:Connect(function(copiedCrusader: string, move: number, style: string)
	Sol.Input(move, style, copiedCrusader)
end)

local function onCharacterChanged()
	if defaultStyle == weaponStyle then 
		IAS:Disconnect({defaultStyle}) 
		defaultStyle = bareStyle
		Sol.IAS()
	end

	crusader = player:GetAttribute("Crusader")
	animHandler:ClearCache()
	char = player.Character or player.CharacterAdded:Wait()
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")

	bareAnimTracks = animHandler:LoadAnimations(animator, bareAnims, crusader, "Bare")
	weaponAnimTracks = animHandler:LoadAnimations(animator, weaponAnims, crusader, "Weapon")

	bareRegistry = {0, 0, 0, 0}
	weaponRegistry = {0, 0, 0, 0}

	swapRegistry = 0
end

if player.Character then onCharacterChanged() end --covers the case where the player's character already exists before this script runs
player.CharacterAdded:Connect(function()
	onCharacterChanged() --callback in case of respawn and/or character swap
end)

cdChange.OnClientEvent:Connect(function(style: string, ID: number, newTime: number)
	local registry = (style == "Weapon" and weaponRegistry) or bareRegistry
	registry[ID] = newTime
end)

function Sol.Input(move: number, style: string, copy: string)
	if hum == nil or hum.Health <= 0 then return end
	if char:HasTag("ActiveInput") or char:HasTag("RagdollActive") or char:HasTag("SolDisabled") then return end
	
	local confirmedCrusader = (copy ~= nil and copy) or crusader
	local constraint = timing.GetValue(confirmedCrusader, style, 2, move)
	local animTracks: {Animation}, registry: {number}
	
	if style == "Weapon" then
		animTracks = weaponAnimTracks
		registry = weaponRegistry
	else
		animTracks = bareAnimTracks
		registry = bareRegistry
	end
	
	if not copy then
		if timing.CheckConstraint(registry[move], constraint) or char:GetAttribute("Stunned") then return end
	end
	
	char:AddTag("ActiveInput")
	
	local delayTime: number = timing.GetValue(confirmedCrusader, style, 1, move)
	local duration: number = timing.GetValue(confirmedCrusader, style, 3, move) - delayTime
	
	local animTrack: AnimationTrack? = nil
	
	if not copy then
		animTrack = animTracks[move]
	else
		local animations = (style == "Weapon" and weaponAnims) or bareAnims
		local copiedAnimTracks = animHandler:LoadAnimations(animator, animations, copy, style)
		animTrack = copiedAnimTracks[move]
	end
	
	animTrack:Play()
	attack:FireServer(style .. "_Server", move, copy)
	
	if not copy then registry[move] = os.clock() end
	
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
		
		local continuation: boolean = timing.GetValue(confirmedCrusader, style, 5, move)
		
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

function Sol.SwitchStyle(style: InputContext)
	if hum == nil or hum.Health <= 0 then return end
	if char:HasTag("ActiveInput") or char:HasTag("RagdollActive") or char:HasTag("TechsDisabled") then return end
	
	local constraint = timing.GetValue(crusader, "Tech", 2, 4)
	
	if timing.CheckConstraint(swapRegistry, constraint) or char:GetAttribute("Stunned") then return end
	
	swapRegistry = os.clock()
	
	local animTracks: {Animation}, currentStyle: InputContext?, listener: RBXScriptSignal?
	
	if style == weaponStyle then
		animTracks = bareAnimTracks
		currentStyle = bareStyle
		listener = CS:GetInstanceAddedSignal("WeaponActive")
	else
		animTracks = weaponAnimTracks
		currentStyle = weaponStyle
		listener = CS:GetInstanceRemovedSignal("WeaponActive")
	end
	
	equipEvent:FireServer()
	
	animTracks[5]:Play()
	
	task.spawn(function()
		local connection: RBXScriptConnection?
		connection = listener:Connect(function(instance)
			if instance == char then
				IAS:Disconnect({currentStyle})
				defaultStyle = style
				Sol.IAS()
				connection:Disconnect()
			end
		end)
	end)
end

local bareSpecs = {
	{name = "BM1", callback = function() Sol.Input(1, "Bare") end},
	{name = "BM2", callback = function() Sol.Input(2, "Bare") end},
	{name = "BM3", callback = function() Sol.Input(3, "Bare") end},
	{name = "BM4", callback = function() Sol.Input(4, "Bare") end},
	{name = "STW", callback = function() Sol.SwitchStyle(weaponStyle) end}
}

local weaponSpecs = {
	{name = "WM1", callback = function() Sol.Input(1, "Weapon") end},
	{name = "WM2", callback = function() Sol.Input(2, "Weapon") end},
	{name = "WM3", callback = function() Sol.Input(3, "Weapon") end},
	{name = "WM4", callback = function() Sol.Input(4, "Weapon") end},
	{name = "STB", callback = function() Sol.SwitchStyle(bareStyle) end}
}

function Sol.IAS()
	local style = defaultStyle --defaults to bare (or weapon IF it was active beforehand) style

	local specs: {any}? = nil

	if style == weaponStyle then
		specs = weaponSpecs
	else
		specs = bareSpecs
	end

	IAS.ActReg(style, specs)
end

return Sol