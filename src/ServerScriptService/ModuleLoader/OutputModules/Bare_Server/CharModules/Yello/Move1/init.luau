local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local duration = timing.GetValue("Yello", "Bare", 3, 1) - timing.GetValue("Yello", "Bare", 1, 1)
local tweenInfo = TweenInfo.new(duration*4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local YM1 = {}

function YM1:Trigger(player: Player)
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
	
	local radius = 3
	local magnitude = 256
	local finalVector = magnitude * root.CFrame.LookVector
	local result = workspace:Spherecast(root.Position, radius, finalVector, params)
	
	local testPart = Instance.new("Part")
	testPart.Anchored = true
	testPart.CanCollide = false
	testPart.CanQuery = false
	testPart.CastShadow = false
	testPart.CFrame = CFrame.lookAt(root.Position, root.Position + finalVector) * CFrame.new(0, 0, -finalVector.Magnitude/2)
	testPart.Color = Color3.new(1, 1, 0)
	testPart.Material = Enum.Material.Neon
	testPart.Reflectance = 0.5
	testPart.Size = Vector3.new(radius, radius, finalVector.Magnitude)
	testPart.Transparency = 0.25
	testPart.Parent = workspace
	
	local tweenBlast = TS:Create(testPart, tweenInfo, {Transparency = 1})
	tweenBlast:Play()
	tweenBlast.Completed:Connect(function()
		tweenBlast:Destroy()
	end)
	
	local tweenSize = TS:Create(testPart, tweenInfo, {Size = Vector3.new(0, 0, finalVector.Magnitude)})
	tweenSize:Play()
	tweenSize.Completed:Connect(function()
		tweenSize:Destroy()
		testPart:Destroy()
	end)
	
	--copy and pastable move sfx code
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)

	if not result then return end
	
	local attackData = {
		atkdur = duration,
		atkrad = 2.5,
		atktype = "medium",
		dmg = 20,
		ID = 1,
		oneHit = true,
		origin = CFrame.new(result.Position),
		soundTarget = result.Instance,
		style = "Bare"
	}

	damager:Damage(player, attackData)
end

return YM1
