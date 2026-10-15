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
	print("ym4")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local duration = timing.GetValue("Yello", "Bare", 3, 4) - timing.GetValue("Yello", "Bare", 1, 4)
	
	local clone = portal:Clone()
	
	clone.Position = root.Position
	clone.Parent = workspace
	
	task.wait(duration - 0.01) --oh my, extra-secret delay?? how scandalous!!!
	
	char:AddTag("RagdollActive")
	
	local dmg = 20
	local distance = 50
	
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
	
	local rift = clone:FindFirstChild("Images/4x4 ripple")
	
	local proxy = Instance.new("NumberValue") --cant directly tween a particle's transparency
	proxy.Value = 0
	
	proxy.Changed:Connect(function(alpha)
		rift.Transparency = NumberSequence.new(alpha)
	end)
	
	local tweenWhoosh = TS:Create(whoosh, tweenInfo0, {Width0 = 0})
	local tweenValue = TS:Create(proxy, tweenInfo1, {Value = 1})
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {char}

	local finalVector = root.CFrame * CFrame.new(0, 0, -distance)
	local direction = finalVector.Position - root.Position
	local result = workspace:Raycast(root.Position, direction, raycastParams)
	
	if not result then
		root.CFrame = finalVector
	else --hopefully prevents phasing
		root.CFrame = CFrame.new(result.Position)
	end
		
	player:SetAttribute("lastServerPos", root.Position)
	
	--copy and pastable move sfx code
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	task.delay(duration, function()
		if player.Parent ~= Players then return end
		char:RemoveTag("RagdollActive")
		
		tweenWhoosh:Play()
		tweenValue:Play()
		
		local attackData = {
			atkdur = duration,
			atkrad = 10,
			atktype = "light",
			bdmg = dmg,
			dmg = dmg,
			ID = 4,
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
		
		tweenValue.Completed:Connect(function()
			tweenValue:Destroy()
			proxy:Destroy()
			clone:Destroy()
		end)
	end)
end

return YM4