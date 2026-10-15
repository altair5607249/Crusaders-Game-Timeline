local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local delayTime = timing.GetValue("Redd", "Weapon", 1, 4)
local duration = timing.GetValue("Redd", "Weapon", 3, 4) - timing.GetValue("Redd", "Weapon", 1, 4)
local tweenInfo = TweenInfo.new(delayTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function healthCurve(health: number, maxHealth: number, stat: number)
	local a = maxHealth + 50 --offsets values for the reflection divisor that are TOO SMALL
	local b = (stat^(1/2))/a
	return -(b*health)^2 + stat
end

local function toggleCharacterModel(character: Model, property: string, modifier: any)
	for i, object in ipairs(character:GetDescendants()) do
		if object.Name == "HumanoidRootPart" or object.Name == "hitPart" then continue end
		if object:IsA("BasePart") or object:IsA("Decal") then
			local hasProperty, _ = pcall(function() local test = object[property] end)
			if hasProperty and not object:FindFirstChild(property) then
				local tween = TS:Create(object, tweenInfo, {[property] = modifier})
				tween:Play()
				tween.Completed:Connect(function()
					tween:Destroy()
				end)
			end
		end
	end
end

local RM4 = {}

function RM4:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local deltaHealth = maxHealth - currentHealth
	
	local reflectDivisor = healthCurve(deltaHealth, maxHealth, 8)

	hum:SetAttribute("Reflect", reflectDivisor)
	local rooster = SS.TestRigs.Rooster:Clone()
	rooster.Parent = workspace

	local initialPosition = root.Position + Vector3.new(0, 20, 0)
	local finalPosition = root.Position + Vector3.new(0, -1.3, 0)
	local finalRotation = root.CFrame.Rotation * CFrame.Angles(0, 3.1452, 0)

	rooster.CFrame = CFrame.new(initialPosition) * root.CFrame.Rotation

	local tweenPosDown = TS:Create(rooster, tweenInfo, {CFrame = CFrame.new(finalPosition) * finalRotation})

	local loadRoosterIn = TS:Create(rooster, tweenInfo, {Transparency = 0})
	local loadRoosterOut = TS:Create(rooster, tweenInfo, {Transparency = 1})

	loadRoosterIn:Play()
	tweenPosDown:Play()

	loadRoosterIn.Completed:Connect(function() 
		loadRoosterIn:Destroy()
		
		local initSfx = script.Appear:Clone() --note: make a module that i can call to do all of this in one go
		initSfx.Parent = root
		initSfx:Play()
		initSfx.Ended:Connect(function()
			initSfx:Destroy()
		end)
	end)

	local weld
	tweenPosDown.Completed:Connect(function()
		tweenPosDown:Destroy()

		--attach only once landed, so it tracks root from here on
		weld = Instance.new("Weld")
		weld.Part0 = root
		weld.Part1 = rooster
		weld.C0 = CFrame.new(0, -1.3, 0) * CFrame.Angles(0, 3.1452, 0)
		weld.Parent = rooster
	end)
	
	toggleCharacterModel(char, "Transparency", 1)

	task.delay(duration - delayTime, function()
		loadRoosterOut:Play()
		if weld then
			local tweenPosUp = TS:Create(weld, tweenInfo, {C0 = CFrame.new(0, 20, 0)})
			tweenPosUp:Play()
		end

		loadRoosterOut.Completed:Connect(function()
			hum:SetAttribute("Reflect", nil)
			loadRoosterOut:Destroy()
			if weld then weld:Destroy() end
			rooster:Destroy()
			toggleCharacterModel(char, "Transparency", 0)
		end)
	end)
end

return RM4