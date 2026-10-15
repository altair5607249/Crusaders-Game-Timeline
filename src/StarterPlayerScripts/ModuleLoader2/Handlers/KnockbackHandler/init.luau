local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")

local spacing = require(RS.UniversalModules.Space)
local animHandler = require(script.Parent.AnimationHandler)

local crusader, char, root, hum, animator 
local animations = script.Animations
local animTracks = {}

local function onCharacterChanged()
	crusader = player:GetAttribute("Crusader")
	char = player.Character or player.CharacterAdded:Wait()
	root = char:WaitForChild("HumanoidRootPart")
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")

	animTracks = animHandler:LoadAnimations(animator, animations, crusader, "Knockback")
end

player.CharacterAdded:Connect(function()
	onCharacterChanged()
end)

local animSpecs = {
	light = 1,
	medium = 2,
	heavy = 3,
	reverse = 4 --give this a custom animation post-MVP
}

local function toggleCharacterModel(character: Model, property: string, modifier: any)
	for i, object in ipairs(character:GetDescendants()) do
		if object.Name == "HumanoidRootPart" or object.Name == "hitPart" then continue end
		if object:IsA("BasePart") or object:IsA("Decal") then
			local hasProperty, _ = pcall(function() local test = object[property] end)
			if hasProperty and not object:FindFirstChild(property) then 
				object[property] = modifier 
			end
		end
	end
end

local knockbackHandler = {}

function knockbackHandler.Casing(atktype: string, momentum: Vector3, targetRoot: Part)
	knockbackHandler:Affect(momentum, targetRoot)
	if atktype then
		knockbackHandler:Effect(atktype)
	end
end

function knockbackHandler:Affect(momentum: Vector3, targetRoot: Part)
	if targetRoot then --this physics illusion method was inspired by TSB :)
		local targetChar = targetRoot.Parent
		
		targetChar.Archivable = true
		local targetClone = targetChar:Clone()
		targetClone.Parent = workspace
		targetChar.Archivable = false
		
		for i, object in ipairs(targetClone:GetDescendants()) do
			if object:IsA("LuaSourceContainer") then object:Destroy() end
		end
		
		toggleCharacterModel(targetClone, "CanCollide", false)
		toggleCharacterModel(targetChar, "Transparency", 1) --hides the real enemy model
		
		local cloneRoot: Part = targetClone:WaitForChild("HumanoidRootPart")
		cloneRoot:ApplyImpulse(momentum)
		
		local loop
		loop = RNS.RenderStepped:Connect(function()
			if targetRoot and cloneRoot and targetChar:HasTag("RagdollActive") then
				targetRoot.CFrame = targetRoot.CFrame:Lerp(cloneRoot.CFrame, 0.7)
			else
				loop:Disconnect()
			end
		end)
		
		task.spawn(function()
			repeat 
				task.wait() 
			until not targetChar.Parent or not targetChar:HasTag("RagdollActive")

			if loop then loop:Disconnect() end
			if targetClone then targetClone:Destroy() end

			if targetChar.Parent then
				toggleCharacterModel(targetChar, "Transparency", 0) --brings back the real enemy model
			end
		end)
	else
		root:ApplyImpulse(momentum)
	end
end

function knockbackHandler:Effect(atktype: string)
	local index = animSpecs[atktype]
	animTracks[index]:Play()
end

return knockbackHandler