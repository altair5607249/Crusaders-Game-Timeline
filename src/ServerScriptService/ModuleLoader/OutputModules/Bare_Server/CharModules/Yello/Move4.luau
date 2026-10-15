local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local YM4 = {}

function YM4:Trigger(player: Player)
	print("ym4")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	char:AddTag("RagdollActive")
	
	local dmg = 20
	local duration = timing.GetValue("Yello", "Bare", 3, 4) - timing.GetValue("Yello", "Bare", 1, 4)
	
	local gracePeriod = 0.05
	local distance = 20
	
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
	
	local tweenWhoosh = TS:Create(whoosh, tweenInfo, {Width0 = 0})
	
	root.CFrame = root.CFrame * CFrame.new(0, 0, -distance) --yes this teleports you backwards
	player:SetAttribute("lastServerPos", root.Position)
	
	task.delay(gracePeriod, function()
		if player.Parent ~= Players then return end
		char:RemoveTag("RagdollActive")
		tweenWhoosh:Play()
		
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
	end)
end

return YM4