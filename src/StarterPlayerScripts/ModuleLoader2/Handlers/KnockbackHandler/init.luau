local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")

local player = Players.LocalPlayer

local spacing = require(RS.UniversalModules.Space)
local animHandler = require(script.Parent.AnimationHandler)

local crusader, char, root: Part, hum, animator 
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
	reverse = 4
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
	knockbackHandler:Affect(atktype, momentum, targetRoot)
	if not targetRoot then
		knockbackHandler:Effect(atktype, momentum) --not really momentum in this case, but still a Vector3 value
	end
end

function knockbackHandler:Affect(atktype: string, momentum: Vector3, targetRoot: Part)
	if targetRoot then --physical illusion!
		local targetChar = targetRoot.Parent
		
		local targetClone: Model = targetChar:Clone()
		targetClone.Parent = workspace
		
		for i, object in ipairs(targetClone:GetDescendants()) do
			if object:IsA("LuaSourceContainer") then object:Destroy() end
		end
		
		toggleCharacterModel(targetChar, "Transparency", 1) --hides the real enemy model
		
		local cloneRoot: Part = targetClone:WaitForChild("HumanoidRootPart")
		cloneRoot.CFrame = CFrame.lookAt(cloneRoot.Position, root.Position)
		cloneRoot:ApplyImpulse(momentum)
		
		--applying the animation to the dummy if there is an attack type
		local animTrack: AnimationTrack? = nil
		if atktype then
			local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
			local targetCrusader: string = (targetPlayer and targetPlayer:GetAttribute("Crusader")) or player:GetAttribute("Crusader")
			
			local targetHum: Humanoid = targetClone:WaitForChild("Humanoid")
			local cloneAnimator: Animator = targetHum:WaitForChild("Animator")
			animTrack = cloneAnimator:LoadAnimation(animations[targetCrusader][atktype])
			
			animTrack:Play()
		end
		
		local loop: RBXScriptConnection? = nil
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
			
			if targetClone then
				if animTrack then
					animTrack:Stop()
					animTrack:Destroy()
				end
				
				targetClone:Destroy() 
			end

			if targetChar.Parent then
				toggleCharacterModel(targetChar, "Transparency", 0) --brings back the real enemy model
			end
		end)
	else
		root:ApplyImpulse(momentum)
	end
end

function knockbackHandler:Effect(atktype: string, whereToLook: Vector3)
	if atktype then
		local index = animSpecs[atktype]
		animTracks[index]:Play()
	end
end

return knockbackHandler