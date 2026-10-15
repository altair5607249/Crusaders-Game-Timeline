local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local vfx = RS.AttackVFX.ImpactSpeed

local YM2 = {}

function YM2:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local leg: Part = char:FindFirstChild("Right Leg")
	
	local attachment0 = Instance.new("Attachment")
	attachment0.Parent = leg

	local attachment1 = Instance.new("Attachment")
	attachment1.Parent = leg
	attachment1.Position = Vector3.new(0, 0, 1.25)
	
	local whoosh = Instance.new("Trail")
	whoosh.Attachment0 = attachment0
	whoosh.Attachment1 = attachment1
	whoosh.Texture = "rbxassetid://6091329339"
	
	whoosh.Brightness = 25
	whoosh.Color = ColorSequence.new(Color3.new(1, 1, 0), Color3.new(1, 0.5, 0))
	whoosh.FaceCamera = true
	whoosh.Lifetime = 5
	whoosh.LightEmission = 1
	whoosh.LightInfluence = 0
	whoosh.Transparency = NumberSequence.new(0.2, 1)
	whoosh.Parent = leg
	
	local tweenWhoosh = TS:Create(whoosh, tweenInfo, {Brightness = 0})
	tweenWhoosh:Play()
	tweenWhoosh.Completed:Connect(function()
		tweenWhoosh:Destroy()
		whoosh:Destroy()
		attachment0:Destroy()
		attachment1:Destroy()
	end)
	
	local duration = timing.GetValue("Yello", "Bare", 3, 2) - timing.GetValue("Yello", "Bare", 1, 2)
	
	task.delay(duration, function()
		local attackData = {
			atkdur = duration,
			atkrad = 5,
			atktype = "light",
			customSound = script.Sound,
			dmg = 30,
			getTargets = true,
			ID = 2,
			style = "Bare"
		}

		local targets: {Humanoid} = damager:Damage(player, attackData)
		
		if not targets then return end
		
		for i, targetHum in ipairs(targets) do
			local targetRoot = targetHum.Parent:FindFirstChild("HumanoidRootPart")
			local clone = vfx:Clone()
			local vfx = clone:FindFirstChild("HIT EFFECTS 1")
			
			local tweenHit = TS:Create(vfx, tweenInfo, {Brightness = 0})
			
			clone.Position = targetRoot.Position
			clone.Parent = workspace
			
			task.delay(0.4, function()
				tweenHit:Play()
				tweenHit.Completed:Connect(function()
					tweenHit:Destroy()
					clone:Destroy()
				end)
			end)
		end
	end)
end

return YM2