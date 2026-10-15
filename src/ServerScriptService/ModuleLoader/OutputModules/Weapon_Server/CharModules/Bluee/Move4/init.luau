local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Bluee", "Weapon", 1, 4)
local duration = (timing.GetValue("Bluee", "Weapon", 3, 4) - delayTime) - 0.1
local tweenTime = 0.5
local effectInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function morph(char: Model, modifier: number)
	for i, obj in ipairs(char:GetDescendants()) do
		if (obj:IsA("Part") or obj:IsA("MeshPart")) and obj.Name ~= "HumanoidRootPart" and obj.Name ~= "hitPart" then
			local tween = TS:Create(obj, effectInfo, {Transparency = modifier})
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

local BM4 = {}

function BM4:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local maxHealth = hum.MaxHealth
	local health = hum.Health
	
	local attackData = {
		atkdur = duration,
		atkrad = 5,
		atktype = nil,
		dmg = 5,
		ID = 4,
		origin = root.CFrame * CFrame.new(0, 0, -8),
		style = "Weapon"
	}
	
	local water = RS.AttackVFX.Whirlpool:Clone()
	water.Parent = workspace
	water.CFrame = root.CFrame * CFrame.new(0, -1.5, 0)
	
	local waterVfx = water.VFX_Attachment["Images/4x4_ver"]
	local fadeWater = TS:Create(waterVfx, effectInfo, {Brightness = 0})
	
	fadeWater:Play()
	
	fadeWater.Completed:Connect(function()
		fadeWater:Destroy()
		water:Destroy()
	end)
	
	local clone = RS.AttackVFX["Proteus?"]:Clone()
	clone.Parent = workspace
	clone.HumanoidRootPart.CFrame = root.CFrame
	
	local cloneHum = clone.Humanoid
	local desc = cloneHum:GetAppliedDescription()
	cloneHum:ApplyDescriptionAsync(desc)
	
	morph(char, 0.6)
	morph(clone, 0.4)
	
	if health >= maxHealth * (2/3) then --solid
		attackData.atkrad *= 1
		attackData.atktype = "heavy"
		attackData.customSound = script.Ice
		attackData.dmg = 50
		
		damager:Damage(player, attackData)
		
		local crack = RS.AttackVFX.Break:Clone()
		crack.Parent = workspace
		crack.CFrame = root.CFrame * CFrame.new(0, 0, -8)
		
		local iceVfx = crack:FindFirstChild("VFX_Attachment"):FindFirstChildWhichIsA("ParticleEmitter")
		
		local tweenBreak = TS:Create(iceVfx, effectInfo, {Brightness = 0})
		tweenBreak:Play()
		
		tweenBreak.Completed:Connect(function()
			tweenBreak:Destroy()
			crack:Destroy()
		end)
		
		task.delay(tweenTime, function()
			if char and player.Parent == Players then 
				morph(char, 0) 
			end
			morph(clone, 1)
		end)
	elseif health <= maxHealth * (2/3) and health > maxHealth * (1/3) then --liquid
		attackData.atkrad *= 2
		attackData.atktype = "medium"
		attackData.getTargets = true
		attackData.precedent = true
		
		local targets: {Humanoid} = damager:Damage(player, attackData)
		
		if #targets == 0 then 
			if char and player.Parent == Players then 
				morph(char, 0) 
			end 
			morph(clone, 1)
			return 
		end
		
		local targetRoots = {}

		for i, targetHum in ipairs(targets) do
			local targetRoot: Part = targetHum.Parent:WaitForChild("HumanoidRootPart")
			table.insert(targetRoots, targetRoot)
			targetHum:TakeDamage(35)
		end
		
		for i, targetRoot: Part in ipairs(targetRoots) do
			local targetChar: Model = targetRoot.Parent
			local targetPlr = Players:GetPlayerFromCharacter(targetChar) or player
			local targetHum: Humanoid = targetChar:WaitForChild("Humanoid")
			
			if targetHum.Health <= 0 or not hum or targetPlr.Parent ~= Players then return end
			
			local geyser = Instance.new("Part")
			geyser.Parent = workspace
			geyser.CFrame = targetRoot.CFrame * CFrame.new(0, -1.5, 0)
			
			--customizing the geyser
			geyser.Anchored = true
			geyser.CanCollide = false
			geyser.CanQuery = false
			geyser.Color = Color3.new(0, 0, 1)
			geyser.Size = Vector3.new(3, 0.5, 3)
			geyser.Transparency = 0.45
			
			local sfx = script.Geyser:Clone()
			sfx.Parent = targetRoot
			sfx:Play()
			sfx.Ended:Connect(function()
				sfx:Destroy()
			end)
			
			local tweenHeight = TS:Create(geyser, effectInfo, {Size = Vector3.new(3, 100, 3)})
			local tweenTrans = TS:Create(geyser, effectInfo, {Transparency = 1})
			
			tweenHeight:Play()
			tweenTrans:Play()
			
			tweenHeight.Completed:Connect(function()
				tweenHeight:Destroy()
				tweenTrans:Destroy()
				geyser:Destroy()
			end)
			
			task.delay(tweenTime, function()
				if char and player.Parent == Players then 
					morph(char, 0) 
				end
				morph(clone, 1)
			end)
		end
	else --gas
		attackData.atkrad *= 2
		attackData.atktype = "light"
		attackData.customSound = script.Gas
		attackData.dmg = 25
		attackData.expanding = 5
		attackData.shockwave = 0.5
		
		damager:Damage(player, attackData)
		
		local pressure = RS.AttackVFX.ImpactSpeed2:Clone()
		pressure.Parent = workspace
		pressure.CFrame = attackData.origin
		
		local pressureVfx = pressure.VFX_Attachment:FindFirstChildWhichIsA("ParticleEmitter")
		local fadePressure = TS:Create(pressureVfx, effectInfo, {Brightness = 0})

		fadePressure:Play()

		fadePressure.Completed:Connect(function()
			fadePressure:Destroy()
			pressure:Destroy()
		end)
		
		task.delay(tweenTime, function()
			if char and player.Parent == Players then 
				morph(char, 0) 
			end
			morph(clone, 1)
		end)
	end
end

return BM4