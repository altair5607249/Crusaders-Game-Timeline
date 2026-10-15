local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local duration = 2*(timing.GetValue("Gleen", "Bare", 3, 3) - timing.GetValue("Gleen", "Bare", 1, 3))
local tweenInfo0 = TweenInfo.new(duration*0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo1 = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function morph(char: Model, modifier: number)
	for i, obj in ipairs(char:GetDescendants()) do
		if (obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Name ~= "HumanoidRootPart" and obj.Name ~= "hitPart" then
			local tween = TS:Create(obj, tweenInfo0, {Transparency = modifier})
			tween:Play()
			tween.Completed:Connect(function()
				tween:Destroy()
				if modifier == 1 then
					char:Destroy()
				end
			end)
		end
	end
end

local positions = {
	CFrame.new(-7.5, 0, 0) * CFrame.Angles(0, -math.rad(90), 0), --west
	CFrame.new(7.5, 0, 0) * CFrame.Angles(0, math.rad(90), 0), --east
	CFrame.new(0, 0, 7.5), --south
	CFrame.new(0, 0, -7.5) * CFrame.Angles(0, math.rad(180), 0), --north
	CFrame.new(7, 0, 7) * CFrame.Angles(0, math.rad(45), 0), --northeast
	CFrame.new(-7, 0, -7) * CFrame.Angles(0, -math.rad(135), 0), --southwest
	CFrame.new(7, 0, -7) * CFrame.Angles(0, math.rad(135), 0), --southeast
	CFrame.new(-7, 0, 7) * CFrame.Angles(0, -math.rad(45), 0), --northwest
}

local GM3 = {}

local function healthCurve(health: number, maxHealth: number, stat: number) --cubic curve
	local b = (stat^(1/3))/maxHealth
	return (b*(health-maxHealth))^3 + stat --yes this is purposely inversed
end

function GM3:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration*0.5,
		atkrad = 15,
		atktype = "light",
		customSound = script.Heal,
		dmg = 20,
		getTargets = true,
		ID = 3,
		style = "Bare"
	}
	
	for i = 1, 8 do
		local clone: Model? = nil
		local crusader: string = player:GetAttribute("Crusader") --in case this move is being copied
		
		if crusader == "Bluee" then --for the copycat
			clone = char:Clone()
		else --for Gleen himself
			local skin = player:GetAttribute("Skin")
			if skin == "Sage" then
				clone = SS.Characters.Gleen.Suit:Clone()
			else
				clone = SS.Characters.Gleen.Sage:Clone()
			end
		end
		
		clone.Parent = workspace
		
		if clone.Humanoid then clone.Humanoid:AddTag("Immortal") end
		if clone.HumanoidRootPart then 
			clone.HumanoidRootPart.Anchored = true
			clone.HumanoidRootPart.CFrame = root.CFrame * positions[i] 
		end
		
		morph(clone, 1)
	end
	
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
	
	hum.Health += healthCurve(health, maxHealth, attackData.dmg)
	
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