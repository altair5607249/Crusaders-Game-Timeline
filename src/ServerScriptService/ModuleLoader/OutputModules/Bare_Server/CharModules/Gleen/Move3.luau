local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local duration = timing.GetValue("Gleen", "Bare", 3, 3) - timing.GetValue("Gleen", "Bare", 1, 3) 
local tweenInfo = TweenInfo.new(duration/2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local GM3 = {}

local function healthCurve(health: number, maxHealth: number, stat: number) --cubic curve
	local b = (stat^(1/3))/maxHealth
	return -(b*(health-maxHealth))^3 + stat
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
		atkdur = duration/2,
		atkrad = 15,
		atktype = "light",
		bdmg = dmg,
		dmg = dmg,
		getTargets = true,
		ID = 3,
		oneHit = true,
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
	
	hum.Health += healthCurve(health, maxHealth, dmg)
	
	local endingCFrame = targetRoots[1].CFrame * CFrame.new(0, 0, -5)
	local tweenGleen = TS:Create(root, tweenInfo, {CFrame = endingCFrame})
	tweenGleen:Play()
	tweenGleen.Completed:Connect(function()
		tweenGleen:Destroy()
	end)
end

return GM3