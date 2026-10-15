local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local duration = timing.GetValue("Bluee", "Bare", 3, 1) - timing.GetValue("Bluee", "Bare", 1, 1)
local tweenInfo1 = TweenInfo.new(duration*0.90, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo2 = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local BM1 = {}

function BM1:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local characterList = CS:GetTagged("Character")
	local filtered = {}
	for i, c in ipairs(characterList) do
		if c ~= char then
			table.insert(filtered, c)
		end
	end
	
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = filtered
	
	local size = Vector3.new(0.75, 64, 1)
	local magnitude = 256
	local finalVector = magnitude * root.CFrame.LookVector
	local result = workspace:Blockcast(root.CFrame, size, finalVector, params)
	
	local attachment0 = Instance.new("Attachment")
	attachment0.Parent = root

	local attachment1 = Instance.new("Attachment")
	attachment1.Parent = root
	attachment1.Position += Vector3.new(0, 0, -magnitude)

	local whoosh = Instance.new("Beam")
	whoosh.Attachment0 = attachment0
	whoosh.Attachment1 = attachment1
	whoosh.Texture = "rbxassetid://6091474388"
	whoosh.Brightness = 1
	whoosh.Color = ColorSequence.new(Color3.new(0, 0, 1), Color3.new(1, 1, 1))
	whoosh.FaceCamera = false
	whoosh.LightInfluence = 0.1
	whoosh.LightEmission = 0.8
	whoosh.Transparency = NumberSequence.new(0, 1)
	whoosh.Width0 = 2.5
	whoosh.Width1 = magnitude/2
	whoosh.Parent = root
	
	local tweenRend = TS:Create(whoosh, tweenInfo1, {Width0 = 0})
	local tweenRend2 = TS:Create(whoosh, tweenInfo2, {Width1 = 0})
	
	tweenRend:Play()
	tweenRend2:Play()
	
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	tweenRend2.Completed:Connect(function()
		whoosh:Destroy()
		attachment0:Destroy()
		attachment1:Destroy()
	end)
	
	if not result then return end
	
	local attackData = {
		atkdur = duration,
		atkrad = 2.5,
		atktype = "heavy",
		customSound = script.Rip,
		dmg = 60,
		ID = 1,
		oneHit = true,
		origin = CFrame.new(result.Position),
		soundTarget = result.Instance,
		style = "Bare"
	}
	
	damager:Damage(player, attackData)
end

return BM1