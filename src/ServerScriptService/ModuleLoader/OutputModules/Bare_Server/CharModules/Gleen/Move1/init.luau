local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local tweenInfo1 = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local GM1 = {}

function GM1:Trigger(player: Player)
	print("gm1")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local duration = 2*(timing.GetValue("Gleen", "Bare", 3, 1) - timing.GetValue("Gleen", "Bare", 1, 1))
	
	local attackData = {
		atkdur = duration*0.5,
		atkrad = 5,
		atktype = "light",
		customSound = script.MissSound,
		dmg = 0,
		getTargets = true,
		ID = 1,
		precedent = true,
		style = "Bare"
	}
	
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

	if not targetRoots[1] or char:HasTag("Parried") then
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
	
	local startingCFrame = (root.CFrame * CFrame.new(0, 5, 0)) * CFrame.Angles(-math.rad(-90), 0, 0)
	local endingCFrame = (root.CFrame * CFrame.new(0, -0.5, 5)) * CFrame.Angles(-math.rad(-180), 0, 0)
	local tweenRoot1 = TS:Create(targetRoot, tweenInfo1, {CFrame = startingCFrame})
	local tweenRoot2 = TS:Create(targetRoot, tweenInfo2, {CFrame = endingCFrame})
	
	tweenRoot1:Play()
	tweenRoot1.Completed:Connect(function()
		tweenRoot1:Destroy()
		tweenRoot2:Play()
		tweenRoot2.Completed:Connect(function()
			tweenRoot2:Destroy()
			targetRoot.Anchored = true
			targetRoot.AssemblyLinearVelocity = Vector3.zero
			targetRoot.AssemblyAngularVelocity = Vector3.zero
			
			attackData = {
				atkdur = duration*0.5,
				atkrad = 4,
				atktype = "light",
				customSound = script.AuxSound,
				dmg = 25,
				ID = 1,
				oneHit = true,
				origin = targetRoot,
				soundTarget = targetRoot,
				style = "Bare"
			}
			
			damager:Damage(player, attackData)
			
			local targetChar: Model = targetRoot.Parent
			targetChar:AddTag("Immortal") --i-frames
			
			local hitstun = timing.GetValue("Gleen", "Bare", 4, 1)
			task.delay(hitstun, function()
				targetRoot.Anchored = false
				targetChar:RemoveTag("Immortal")
			end)
		end)
	end)
end

return GM1