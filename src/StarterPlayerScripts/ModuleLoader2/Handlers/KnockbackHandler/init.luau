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
	heavy = 3
}

local function toggleCharacterModel(character: Model, property: string, modifier: any)
	for i, object in ipairs(character:GetDescendants()) do
		if object.Name == "HumanoidRootPart" then continue end
		if object:IsA("Part") or object:IsA("Decal") or object:IsA("MeshPart") then
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
	if targetRoot then
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
		targetRoot:ApplyImpulse(momentum)
		cloneRoot:ApplyImpulse(momentum)
		
		task.spawn(function()
			local elapsed = 0
			local initialTime = os.clock()
			repeat task.wait() until not targetChar:HasTag("RagdollActive")
			
			targetClone:Destroy()
			toggleCharacterModel(targetChar, "Transparency", 0) --brings back the real enemy model
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