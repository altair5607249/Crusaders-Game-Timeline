local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local portal = RS.AttackVFX.Portal
local tweenInfo0 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo1 = TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local YM4 = {}

function YM4:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local duration = timing.GetValue("Yello", "Bare", 3, 4) - timing.GetValue("Yello", "Bare", 1, 4)
	local distance = 50
	
	local burst1 = Instance.new("Part")
	burst1.CFrame = root.CFrame
	burst1.Parent = workspace
	
	--customizing the burst
	burst1.Anchored = true
	burst1.CanCollide = false
	burst1.CanQuery = false
	burst1.Material = Enum.Material.Neon
	burst1.Shape = Enum.PartType.Ball
	burst1.Transparency = 0.4
	
	local burst2 = burst1:Clone()
	
	local tweenSize1 = TS:Create(burst1, tweenInfo1, {Size = burst1.Size * 10})
	local tweenTp1 = TS:Create(burst1, tweenInfo1, {Transparency = 1})
	
	tweenSize1:Play()
	tweenTp1:Play()
	
	tweenTp1.Completed:Connect(function()
		tweenSize1:Destroy()
		tweenTp1:Destroy()
		burst1:Destroy()
	end)
	
	local tweenSize2 = TS:Create(burst2, tweenInfo1, {Size = burst2.Size * 10})
	local tweenTp2 = TS:Create(burst2, tweenInfo1, {Transparency = 1})
	
	local attachment0 = Instance.new("Attachment")
	attachment0.Parent = root
	
	local attachment1 = Instance.new("Attachment")
	attachment1.Parent = root
	attachment1.Position += Vector3.new(0, 0, distance)
	
	local whoosh = Instance.new("Beam")
	whoosh.Attachment0 = attachment0
	whoosh.Attachment1 = attachment1
	whoosh.Texture = "rbxassetid://6091329339"
	whoosh.Brightness = 1
	whoosh.Color = ColorSequence.new(Color3.new(1, 1, 0), Color3.new(1, 0.5, 0))
	whoosh.FaceCamera = true
	whoosh.LightInfluence = 0.1
	whoosh.LightEmission = 0.8
	whoosh.Transparency = NumberSequence.new(0.2, 1)
	whoosh.Width0 = 2
	whoosh.Width1 = 0
	whoosh.Parent = root
	
	local tweenWhoosh = TS:Create(whoosh, tweenInfo0, {Width0 = 0})
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {char}

	local finalVector = root.CFrame * CFrame.new(0, 0, -distance)
	local direction = finalVector.Position - root.Position
	local result = workspace:Raycast(root.Position, direction, raycastParams)
	
	if not result then
		root.CFrame = finalVector --teleports the full distance
	else --prevents phasing
		root.CFrame = CFrame.new(result.Position) * CFrame.new(0, 0, 0.5) --skin buffer
	end
		
	player:SetAttribute("lastServerPos", root.Position)
	
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	task.delay(duration, function()
		if player.Parent ~= Players then return end
		
		tweenWhoosh:Play()
		
		local attackData = {
			atkdur = duration,
			atkrad = 10,
			atktype = "medium",
			dmg = 20,
			ID = 4,
			noKB = true,
			noSound = true,
			origin = root,
			style = "Bare"
		}
		
		damager:Damage(player, attackData)
		
		tweenWhoosh.Completed:Connect(function()
			tweenWhoosh:Destroy()
			whoosh:Destroy()
			attachment0:Destroy()
			attachment1:Destroy()
		end)
		
		burst2.CFrame = root.CFrame
		burst2.Parent = workspace
		
		tweenSize2:Play()
		tweenTp2:Play()
		
		tweenTp2.Completed:Connect(function()
			tweenSize2:Destroy()
			tweenTp2:Destroy()
			burst2:Destroy()
		end)
	end)
end

return YM4