local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local vfx = RS.AttackVFX.Lightning

local YM3 = {}

function YM3:Trigger(player: Player)
	print("ym3")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	
	local duration = timing.GetValue("Yello", "Bare", 3, 3) - timing.GetValue("Yello", "Bare", 1, 3)
	
	local attackData = {
		atkdur = duration,
		atkrad = 20,
		atktype = "heavy", --supposed to be custom, change after MVP phase
		bypassParry = true,
		dmg = 50,
		ID = 3,
		origin = root,
		style = "Bare"
	}
	
	--copy and pastable move sfx code
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	damager:Damage(player, attackData)
	
	local clone = vfx:Clone()
	local base = clone:FindFirstChild("Base")
	local top = clone:FindFirstChild("Part")
	base.Position = Vector3.new(root.Position.X, root.Position.Y - 3, root.Position.Z)
	top.Position = Vector3.new(root.Position.X, root.Position.Y + 256, root.Position.Z)
	local lightning = base:FindFirstChild("Attachment"):FindFirstChild("Beam")
	
	clone.Parent = workspace
	
	local tweenLightningBottom = TS:Create(lightning, tweenInfo, {Width0 = 0})
	local tweenLightningTop = TS:Create(lightning, tweenInfo, {Width1 = 0})
	tweenLightningBottom:Play()
	tweenLightningTop:Play()
	
	tweenLightningBottom.Completed:Connect(function()
		tweenLightningBottom:Destroy()
		tweenLightningTop:Destroy()
		clone:Destroy()
	end)
end

return YM3