local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local tweenInfo1 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function healthCurve(health: number, maxHealth: number, stat: number) --cubic curve
	local b = (stat^(1/3))/maxHealth
	return -(b*(health-maxHealth))^3 + stat
end

local GM1 = {}

function GM1:Trigger(player: Player)
	print("gm1")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local dmg = 0
	local duration = timing.GetValue("Gleen", "Bare", 3, 1) - timing.GetValue("Gleen", "Bare", 1, 1)
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration,
		atkrad = 6,
		atktype = "medium",
		bdmg = dmg,
		dmg = dmg,
		getTargets = true,
		ID = 1,
		style = "Bare"
	}
	
	local targets: {Instance} = damager:Damage(player, attackData)
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

	if not targetRoots[1] then return end
	
	char:AddTag("Continue")
	
	local startingCFrame = (root.CFrame * CFrame.new(0, 5, 0)) * CFrame.Angles(-math.rad(-90), 0, 0)
	local endingCFrame = (root.CFrame * CFrame.new(0, 1.25, 5)) * CFrame.Angles(-math.rad(-180), 0, 0)
	local tweenRoot1 = TS:Create(targetRoots[1], tweenInfo1, {CFrame = startingCFrame})
	local tweenRoot2 = TS:Create(targetRoots[1], tweenInfo2, {CFrame = endingCFrame})
	tweenRoot1:Play()
	tweenRoot1.Completed:Connect(function()
		tweenRoot1:Destroy()
		tweenRoot2:Play()
		tweenRoot2.Completed:Connect(function()
			tweenRoot2:Destroy()
			targetRoots[1].AssemblyLinearVelocity = Vector3.zero
			targetRoots[1].AssemblyAngularVelocity = Vector3.zero
			
			char:RemoveTag("Continue")
			dmg = 25
			
			attackData = {
				atkdur = duration,
				atkrad = 4,
				atktype = "light",
				bdmg = dmg,
				dmg = healthCurve(health, maxHealth, dmg),
				ID = 1,
				oneHit = true,
				origin = targetRoots[1],
				style = "Bare"
			}
			
			damager:Damage(player, attackData)
		end)
	end)
end

return GM1