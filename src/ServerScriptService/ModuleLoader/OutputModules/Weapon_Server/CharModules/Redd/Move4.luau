local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local delayTime = timing.GetValue("Redd", "Weapon", 1, 4)
local duration = timing.GetValue("Redd", "Weapon", 3, 4) - timing.GetValue("Redd", "Weapon", 1, 4)
local tweenInfo = TweenInfo.new(delayTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function hideCharacter(char: Model)
	for i, obj: Instance in ipairs(char:GetDescendants()) do
		if obj.Name == "HumanoidRootPart" then continue end
		obj.Transparency = 1
	end
end

local RM4 = {}

function RM4:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")

	hum:AddTag("Immortal")
	local rooster = SS.TestRigs.Rooster:Clone()
	rooster.Parent = workspace

	local initialPosition = root.Position + Vector3.new(0, 24, 0)
	local finalPosition = root.Position + Vector3.new(0, 4, 0)
	local finalRotation = root.CFrame.Rotation * CFrame.Angles(0, 3.1452, 0)

	rooster.CFrame = CFrame.new(initialPosition) * root.CFrame.Rotation

	local tweenPosDown = TS:Create(rooster, tweenInfo, {CFrame = CFrame.new(finalPosition) * finalRotation})

	local loadRoosterIn = TS:Create(rooster, tweenInfo, {Transparency = 0})
	local loadRoosterOut = TS:Create(rooster, tweenInfo, {Transparency = 1})

	loadRoosterIn:Play()
	tweenPosDown:Play()

	loadRoosterIn.Completed:Connect(function()
		loadRoosterIn:Destroy()
	end)

	local weld
	tweenPosDown.Completed:Connect(function()
		tweenPosDown:Destroy()

		-- attach only once landed, so it tracks root from here on
		weld = Instance.new("Weld")
		weld.Part0 = root
		weld.Part1 = rooster
		weld.C0 = CFrame.new(0, 4, 0) * CFrame.Angles(0, 3.1452, 0)
		weld.Parent = rooster
	end)

	task.delay(duration - delayTime, function()
		loadRoosterOut:Play()
		if weld then
			local tweenPosUp = TS:Create(weld, tweenInfo, {C0 = CFrame.new(0, 24, 0)})
			tweenPosUp:Play()
		end

		loadRoosterOut.Completed:Connect(function()
			hum:RemoveTag("Immortal")
			loadRoosterOut:Destroy()
			if weld then weld:Destroy() end
			rooster:Destroy()
		end)
	end)
end

return RM4