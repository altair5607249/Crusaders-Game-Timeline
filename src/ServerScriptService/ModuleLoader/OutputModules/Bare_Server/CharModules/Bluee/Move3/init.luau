local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local duration = timing.GetValue("Bluee", "Bare", 3, 3) - timing.GetValue("Bluee", "Bare", 1, 3)
local tornadoInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local BM3 = {}

function BM3:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	local leftArm: Part = char:WaitForChild("Left Arm")
	local rightArm: Part = char:WaitForChild("Right Arm")
	local torso: Part = char:WaitForChild("Torso")

	local attackData = {
		atkdur = duration,
		atkrad = 9,
		atktype = "reverse",
		dmg = 6,
		ID = 3,
		origin = root,
		DOT = 0.3,
		style = "Bare"
	}
	damager:Damage(player, attackData)
	char:AddTag("Running")
	char:AddTag("Resistance")

	local att0 = Instance.new("Attachment")
	local att1 = Instance.new("Attachment")
	att0.Parent = leftArm
	att1.Parent = leftArm
	att1.Position = Vector3.new(0, 0, 1)

	local att2 = Instance.new("Attachment")
	local att3 = Instance.new("Attachment")
	att2.Parent = rightArm
	att3.Parent = rightArm
	att3.Position = Vector3.new(0, 0, 1)

	local leftTrail = Instance.new("Trail")
	leftTrail.Attachment0 = att0
	leftTrail.Attachment1 = att1
	leftTrail.Texture = "rbxassetid://18163753701"

	local rightTrail = Instance.new("Trail")
	rightTrail.Attachment0 = att2
	rightTrail.Attachment1 = att3
	rightTrail.Texture = "rbxassetid://18163753701"

	leftTrail.Brightness = 20
	leftTrail.Color = ColorSequence.new(Color3.new(0, 0, 1))
	leftTrail.FaceCamera = true
	leftTrail.Lifetime = 1
	leftTrail.LightEmission = 0.7
	leftTrail.LightInfluence = 0
	leftTrail.Transparency = NumberSequence.new(0.8, 0)
	leftTrail.Parent = leftArm

	rightTrail.Brightness = 20
	rightTrail.Color = ColorSequence.new(Color3.new(0, 0, 1))
	rightTrail.FaceCamera = true
	rightTrail.Lifetime = 1
	rightTrail.LightEmission = 0.7
	rightTrail.LightInfluence = 0
	rightTrail.Transparency = NumberSequence.new(0.8, 0)
	rightTrail.Parent = rightArm
	
	--tornado vfx
	local tornado = RS.AttackVFX.Tornado:Clone()
	tornado.Parent = workspace
	tornado.CFrame = root.CFrame
	
	local tornadoAngle = 0
	local rotSpeed = math.tau
	
	local tweenTornadoIn = TS:Create(tornado, tornadoInfo, {Transparency = 0.5})
	tweenTornadoIn:Play()
	tweenTornadoIn.Completed:Connect(function()
		tweenTornadoIn:Destroy()
	end)

	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {char}

	local elapsed = 0
	local loop
	loop = RNS.PreSimulation:Connect(function(dt)
		elapsed += dt
		
		tornadoAngle += rotSpeed * dt
		tornado.CFrame = root.CFrame * CFrame.Angles(0, -tornadoAngle, 0)
		
		if elapsed >= attackData.atkdur or player.Parent ~= Players or not hum or char:HasTag("Parried") then
			loop:Disconnect()
			char:RemoveTag("Running")
			char:RemoveTag("Resistance")

			leftTrail:Destroy()
			rightTrail:Destroy()
			att0:Destroy()
			att1:Destroy()
			att2:Destroy()
			att3:Destroy()
			
			local tweenTornadoOut = TS:Create(tornado, tornadoInfo, {Transparency = 1})
			local tweenSize = TS:Create(tornado, tornadoInfo, {Size = Vector3.new(tornado.Size.X * 5, tornado.Size.Y, tornado.Size.Z * 5)})
			tweenTornadoOut:Play()
			tweenSize:Play()
			tweenTornadoOut.Completed:Connect(function()
				tweenTornadoOut:Destroy()
				tweenSize:Destroy()
				
				tornado:Destroy()
			end)
		end
		
		local direction = hum.MoveDirection --steering relies on WASD input unfortunately
		if direction.Magnitude < 0.1 then
			direction = root.CFrame.LookVector.Unit --this needs to be normalized
		else
			direction = direction.Unit
		end
		local magnitude = spacing.GetValue("Bluee", 2) * 1.5
		local step = direction * magnitude * dt

		--check the path BEFORE committing to it, instead of blindly teleporting through geometry
		local result = workspace:Raycast(root.Position, step, raycastParams)
		local newPosition
		if result then
			newPosition = result.Position - (direction * 0.1) --stop just short of the wall, not inside/past it
		else
			newPosition = root.Position + step
		end
		local target = newPosition + direction
		root.CFrame = CFrame.lookAt(newPosition, target) --must use lookAt for the rotation to matter and prevent gliding
	end)
end
return BM3