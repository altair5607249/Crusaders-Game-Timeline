local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Redd", "Weapon", 1, 2)
local duration = timing.GetValue("Redd", "Weapon", 3, 2) - delayTime
local tweenInfo0 = TweenInfo.new(duration * 0.0625, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo1 = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function healthCurve(health: number, maxHealth: number, stat: number)
	local a = maxHealth
	local b = (stat^(1/2))/a
	return (b*health)^2 + stat
end

local RM2 = {}

function RM2:Trigger(player: Player)
	print("weapon rm2")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local deltaHealth = maxHealth - currentHealth
	
	local attackData = { --for the shockwave
		atkdur = duration * 0.3, --0.375s
		atkrad = 30,
		atktype = "light",
		dmg = healthCurve(deltaHealth, maxHealth, 20),
		ID = 2,
		noKB = true,
		origin = root,
		style = "Weapon"
	}
	
	damager:Damage(player, attackData)
	
	local attackData2 = { --for the slash itself
		atkdur = duration * 0.1, --0.125s
		atkrad = 8,
		atktype = "heavy",
		dmg = healthCurve(deltaHealth, maxHealth, 50),
		ID = 2,
		origin = root,
		style = "Weapon"
	}
	
	local supernova = RS.AttackVFX.SupernovaRed:Clone()
	supernova.Parent = workspace
	supernova:PivotTo(root.CFrame)
	
	local alpha = Instance.new("NumberValue")
	alpha.Value = 0.01
	
	local connection: RBXScriptConnection? = nil
	connection = RNS.Heartbeat:Connect(function(dt)
		if not supernova.Parent then connection:Disconnect() return end
		supernova:ScaleTo(alpha.Value)
	end)
	
	local tweenAlpha = TS:Create(alpha, tweenInfo0, {Value = 1})
	
	tweenAlpha:Play()
	tweenAlpha.Completed:Connect(function()
		tweenAlpha:Destroy()
		connection:Disconnect()
		alpha:Destroy()
	end)
	
	for i, obj: Instance in ipairs(supernova:GetDescendants()) do
		if obj:IsA("MeshPart") then
			local tweenSNTransparency = TS:Create(obj, tweenInfo1, {Transparency = 1})

			tweenSNTransparency:Play()
			tweenSNTransparency.Completed:Connect(function()
				tweenSNTransparency:Destroy()
				supernova:Destroy()
			end)
		end
	end
	
	task.delay(duration * 0.1, function()
		damager:Damage(player, attackData2)
	end)
end

return RM2