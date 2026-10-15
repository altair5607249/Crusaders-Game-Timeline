local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Yello", "Weapon", 1, 1)
local duration = timing.GetValue("Yello", "Weapon", 3, 1) - timing.GetValue("Yello", "Weapon", 1, 1)
local retraction = 0.25

local tweenInfo = TweenInfo.new(retraction, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local YM1 = {}

function YM1:Trigger(player: Player)
	print("weapon ym1")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local rootFrame = root.CFrame
	local extendedHitbox = rootFrame * CFrame.new(0, 0, -25)
	
	local attackData = {
		atkdur = duration - retraction,
		atkrad = 3,
		atktype = "light",
		dmg = 20,
		getTargets = true,
		ID = 1,
		origin = extendedHitbox,
		style = "Weapon"
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
		--[[local sfx = script.MissSound:Clone()
		sfx.Parent = root
		sfx:Play()
		sfx.Ended:Connect(function()
			sfx:Destroy()
		end)]]

		return 
	else
		if char:HasTag("Godspeed") then
			local stamina = hum:GetAttribute("Stamina")
			hum:SetAttribute("Stamina", stamina + 15)
		end
		
		--[[local sfx = script.Sound:Clone()
		sfx.Parent = root
		sfx:Play()
		sfx.Ended:Connect(function()
			sfx:Destroy()
		end)]]
	end

	local targetRoot: Part = targetRoots[1]
	local rootDest: CFrame = root.CFrame * CFrame.new(0, 0, -3)
	
	local tweenRoot = TS:Create(targetRoot, tweenInfo, {CFrame = rootDest})
	
	tweenRoot:Play()
	tweenRoot.Completed:Connect(function()
		tweenRoot:Destroy()
		targetRoot.AssemblyLinearVelocity = Vector3.zero
		targetRoot.AssemblyAngularVelocity = Vector3.zero
	end)
end

return YM1