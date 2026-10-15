local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local shockwaveInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local vfx = RS.AttackVFX.Lightning

local YM3 = {}

function YM3:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local duration = timing.GetValue("Yello", "Bare", 3, 3) - timing.GetValue("Yello", "Bare", 1, 3)
	
	local attackData = {
		atkdur = duration,
		atkrad = 10,
		atktype = "heavy", --supposed to be custom, change after MVP phase
		bypassParry = true,
		dmg = 50,
		ID = 3,
		noSound = true,
		origin = root,
		style = "Bare"
	}
	
	local cost = 35
	local stamina: number = hum:GetAttribute("Stamina")
	
	if stamina <= cost then
		hum:SetAttribute("Stamina", 0)
	else
		hum:SetAttribute("Stamina", stamina - cost)
	end
	
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
	local cloud = clone:FindFirstChild("Cloud")
	
	base.Position = Vector3.new(root.Position.X, root.Position.Y - 3, root.Position.Z)
	top.Position = Vector3.new(root.Position.X, root.Position.Y + 256, root.Position.Z)
	cloud.Position = top.Position
	
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
	
	local shockwave = RS.AttackVFX["All-Purpose Ring"]:Clone()
	shockwave.CFrame = root.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
	shockwave.Parent = workspace
	
	local tweenSize = TS:Create(shockwave, shockwaveInfo, {Size = Vector3.new(shockwave.Size.X * 25, shockwave.Size.Y * 25, shockwave.Size.Z * 15)})
	tweenSize:Play()
	tweenSize.Completed:Connect(function()
		tweenSize:Destroy()
	end)
	
	local tweenTp = TS:Create(shockwave, shockwaveInfo, {Transparency = 1})
	tweenTp:Play()
	tweenTp.Completed:Connect(function()
		tweenTp:Destroy()
		shockwave:Destroy()
	end)
end

return YM3