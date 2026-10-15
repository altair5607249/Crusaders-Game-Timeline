local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Gleen", "Bare", 1, 2)
local duration = 2 * (timing.GetValue("Gleen", "Bare", 3, 2) - delayTime)
local waveInfo = TweenInfo.new(duration * 0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut)

local function healthCurve(health: number, maxHealth: number, stat: number) --cubic curve
	local b = (stat^(1/3))/maxHealth
	return -(b*(health-maxHealth))^3 + stat
end

local GM2 = {}

function GM2:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration*0.5,
		atkrad = 20,
		atktype = "light",
		bypassParry = true,
		dmg = 0,
		getTargets = true,
		ID = 2,
		noSound = true,
		precedent = true,
		style = "Bare"
	}
	
	local sfx = script.AuxSound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	local aura = RS.AttackVFX.EnergyWave:Clone()
	aura.Parent = workspace
	aura.CFrame = root.CFrame * CFrame.new(0, -2.5, 0)
	
	local tweenTp = TS:Create(aura, waveInfo, {Transparency = 1})
	local tweenSize = TS:Create(aura, waveInfo, {Size = aura.Size * 8})
	local tweenPos = TS:Create(aura, waveInfo, {CFrame = aura.CFrame * CFrame.new(0, 5, 0)})
	
	tweenTp:Play()
	tweenSize:Play()
	tweenPos:Play()
	
	tweenSize.Completed:Connect(function()
		tweenSize:Destroy()
		tweenTp:Destroy()
		tweenPos:Destroy()
		aura:Destroy()
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
	end
	
	attackData = {
		atkdur = duration*0.5,
		atkrad = 8,
		atktype = "medium",
		bypassParry = true,
		dmg = healthCurve(health, maxHealth, 13.333),
		DOT = 0.5,
		ID = 2,
		noSound = true,
		style = "Bare"
	}
	
	damager:Damage(player, attackData)
	char:AddTag("Running")
	char:AddTag("Resistance")
	
	local clone = RS.AttackVFX.Slashes:Clone()
	clone.Position = root.Position
	clone.Parent = workspace
	
	--copy and pastable move sfx code
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	task.delay(attackData.atkdur, function()
		sfx:Destroy()
	end)
	
	local elapsed = 0
	local loop
	loop = RNS.PreSimulation:Connect(function(dt)
		elapsed += dt
		if elapsed >= attackData.atkdur or not targetRoots then
			loop:Disconnect()
			char:RemoveTag("Running")
			char:RemoveTag("Resistance")
			clone:Destroy()
		end
		
		local direction = -(root.Position - targetRoots[1].Position).Unit
		
		local magnitude = spacing.GetValue("Gleen", 2) * 2
		local newPosition = root.Position + (direction * magnitude * dt)
		local target = newPosition + direction
		
		root.CFrame = CFrame.lookAt(newPosition, target) --gotta use lookAt for the rotation to matter and prevent gliding
		clone.Position = newPosition
	end)
end

return GM2