local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local movement = require(SSS.ModuleLoader.Managers.MovementManager)

local delayTime: number = timing.GetValue("Yello", "Weapon", 1, 4)
local duration: number = timing.GetValue("Yello", "Weapon", 3, 4) - delayTime
local tweenTime = 0.35
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

local YM4 = {}

function YM4:Trigger(player: Player)
	print("weapon ym4")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	char:AddTag("Godspeed") --every successful weapon hit restores stamina
	
	char:AddTag("Running")
	char:AddTag("ConserveSpeed")
	char:AddTag("TechsDisabled")
	
	local speed: number = spacing.GetValue("Yello", 2) * 2
	movement.ChangeTolerance(player, speed)
	hum.WalkSpeed = speed
	
	local vfx = RS.AttackVFX.Electricity:Clone()
	vfx.Parent = workspace
	vfx.CFrame = CFrame.new(root.Position)
	
	local weld = Instance.new("Weld")
	weld.Part0 = root
	weld.Part1 = vfx
	weld.C0 = CFrame.new(Vector3.zero) * CFrame.Angles(0, 0, 0)
	weld.Parent = vfx
	
	local highlight = Instance.new("Highlight")
	highlight.Parent = char
	
	--customizing the highlight
	highlight.FillColor = Color3.new(1, 1, 0)
	highlight.FillTransparency = 0.8
	
	local initialTime = os.clock()
	
	task.spawn(function()
		repeat 
			task.wait(0.1) 
			
			local stamina = hum:GetAttribute("Stamina")
			if stamina <= 25 then break end
			
			local afterImage = char:Clone()
			afterImage.Parent = workspace
			if afterImage.Highlight then afterImage.Highlight:Destroy() end
			if afterImage.Humanoid then afterImage.Humanoid:AddTag("Immortal") end
			morph(afterImage, 1)
			
		until os.clock() - initialTime >= duration or hum.Health <= 0 or not hum
		
		if not char:GetAttribute("Stunned") then hum.WalkSpeed = spacing.GetValue("Yello", 1) end
		
		char:RemoveTag("Godspeed")

		char:RemoveTag("Running")
		char:RemoveTag("ConserveSpeed")
		char:RemoveTag("TechsDisabled")
		
		movement.ChangeTolerance(player, spacing.GetValue("Yello", 2))
		
		weld:Destroy()
		vfx:Destroy()
		highlight:Destroy()
	end)
end

return YM4