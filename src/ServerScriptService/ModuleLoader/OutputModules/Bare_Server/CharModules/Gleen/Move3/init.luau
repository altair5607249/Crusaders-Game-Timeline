local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local duration = 2*(timing.GetValue("Gleen", "Bare", 3, 3) - timing.GetValue("Gleen", "Bare", 1, 3))
local tweenInfo0 = TweenInfo.new(duration*0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo1 = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local GM3 = {}

local function healthCurve(health: number, maxHealth: number, stat: number) --cubic curve
	local b = (stat^(1/3))/maxHealth
	return (b*(health-maxHealth))^3 + stat --yes this is purposely inversed
end

function GM3:Trigger(player: Player)
	print("gm3")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	
	local dmg = 20
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration*0.5,
		atkrad = 15,
		atktype = "light",
		bdmg = dmg,
		dmg = dmg,
		getTargets = true,
		ID = 3,
		style = "Bare"
	}
	
	--copy and pastable move sfx code
	local sfx = script.AuxSound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	local targets: {Humanoid} = damager:Damage(player, attackData)
	local targetRoots = {}

	for i, targetHum in ipairs(targets) do
		local targetRoot: Part = targetHum.Parent:WaitForChild("HumanoidRootPart")
		table.insert(targetRoots, targetRoot)
	end

	table.sort(targetRoots, function(a, b)
		local directionA = (root.Position - a.Position).Magnitude
		local directionB = (root.Position - b.Position).Magnitude
		return directionA < directionB
	end)

	if not targetRoots[1] then
		char:AddTag("Discontinue") 
		task.delay(0.1, function()
			char:RemoveTag("Discontinue")
		end)
		return 
	else
		char:AddTag("Continue")
		task.delay(0.1, function()
			char:RemoveTag("Continue")
		end)
		
		local sfx = script.Sound:Clone()
		sfx.Parent = root
		sfx:Play()
		sfx.Ended:Connect(function()
			sfx:Destroy()
		end)
	end
	
	local targetRoot: Part = targetRoots[1]
	
	local att0 = Instance.new("Attachment")
	local att1 = Instance.new("Attachment")
	att0.Parent = root
	att1.Parent = targetRoot

	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Texture = "rbxassetid://6091341618"

	--customizing it for the millionth time
	beam.Brightness = 5
	beam.Color = ColorSequence.new(Color3.new(0, 1, 0))
	beam.FaceCamera = true
	beam.LightInfluence = 0
	beam.LightEmission = 1
	beam.Transparency = NumberSequence.new(0, 0.6)
	beam.Width0 = 2
	beam.Width1 = 5
	
	beam.Parent = workspace
	
	local glow = Instance.new("PointLight")
	glow.Color = Color3.new(0, 1, 0)
	glow.Parent = root
	
	local tweenGlowUp = TS:Create(glow, tweenInfo1, {Brightness = 8})
	local tweenGlowDown = TS:Create(glow, tweenInfo1, {Brightness = 0})
	
	hum.Health += healthCurve(health, maxHealth, dmg)
	
	local endingCFrame = targetRoot.CFrame * CFrame.new(0, 0, 5)
	local tweenGleen = TS:Create(root, tweenInfo0, {CFrame = endingCFrame})
	tweenGleen:Play()
	tweenGlowUp:Play()
	
	tweenGleen.Completed:Connect(function()
		tweenGleen:Destroy()
		tweenGlowUp:Destroy()
		tweenGlowDown:Play()
		
		tweenGlowDown.Completed:Connect(function()
			tweenGlowDown:Destroy()
			glow:Destroy()
			beam:Destroy()
			att0:Destroy()
			att1:Destroy()
		end)
	end)
end

return GM3