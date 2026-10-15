local debby = game:GetService("Debris")
local UIS = game:GetService("UserInputService")
local RNS = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local baseSpd = char:GetAttribute("bspd")
local runSpd = char:GetAttribute("sspd")
local hum = char:WaitForChild("Humanoid")
local animator = hum:WaitForChild("Animator")

local animations = script:WaitForChild("Animations")
local animsTable = animations:GetChildren()
local animDispatch = {}

for i, anim in pairs(animsTable) do
	local animTrack = animator:LoadAnimation(anim)
	animDispatch[anim] = animTrack
end

player:GetPropertyChangedSignal("Character"):Connect(function()
	char = player.Character or player.CharacterAdded:Wait()
	root = char:WaitForChild("HumanoidRootPart")
	baseSpd = char:GetAttribute("bspd")
	runSpd = char:GetAttribute("sspd")
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")
	
	table.clear(animDispatch)
	
	for i, anim in pairs(animsTable) do
		local animTrack = animator:LoadAnimation(anim)
		animDispatch[anim] = animTrack
	end
end)

local movement = {}

local dashing = false

function movement:Dash()
	local duration = 0.33
	if not dashing then
		dashing = true
		local lookVector = root.CFrame.LookVector
		local moveVector = hum.MoveDirection --had to search up new documentation for this one!
		local dotProduct = lookVector:Dot(moveVector) --this too
		if dotProduct > 0.5 then --forward
			movement.DashAction(duration*3, lookVector, animations.DashForward)
		elseif dotProduct < -0.5 or moveVector.Magnitude == 0 then --backward
			movement.DashAction(duration*2, -lookVector, animations.DashBackward)
		else --sideways 
			if UIS:IsKeyDown(Enum.KeyCode.A) then --leftward
				movement.DashAction(duration, lookVector * Vector3.new(1, 0, 0), animations.DashLeft)
			elseif UIS:IsKeyDown(Enum.KeyCode.D) then --rightward
				movement.DashAction(duration, lookVector * Vector3.new(-1, 0, 0), animations.DashRight)
			end
		end
	end
end

function movement.DashAction(dashDur, direction, anim)
	animDispatch[anim]:Play()
	
	local CD = 10
	local db = false
	local x, d = 0, 100 --x should probably start at 0, but modify incase diff starting point desired
	local b = math.sqrt(d)/dashDur
	
	local rootXZ = direction * Vector3.new(1, 0, 1)
	local currentXZ = root.CFrame.LookVector * Vector3.new(1, 0, 1)
		
	local loop = nil
	loop = RNS.RenderStepped:Connect(function(dt)
		print(root.Position)
		if rootXZ == currentXZ and not db then --updates dash direction if forward dash is executed
			db = true
		elseif db then
			direction = root.CFrame.LookVector
		end
		
		local magnitude = -(b*x)^2 + d --so proud of the evolution of this
			
		root.AssemblyLinearVelocity = direction * magnitude
		x += dt
		if x >= dashDur then
			animDispatch[anim]:Stop()
			loop:Disconnect()
		end
	end)
	
	local keyConnection = UIS.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Q then
			task.wait(CD)
			dashing = false
			db = false
		end
	end)
		
	repeat task.wait() until dashing == false
	keyConnection:Disconnect()
end

local running = false

function movement:Sprint()
	if not running then
		running = true
		local keyConnection = UIS.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
				running = false
			end
		end)
		for i = 1,5 do
			game.Workspace.CurrentCamera.FieldOfView = (70+(i*2))
			task.wait()
		end
		hum.WalkSpeed = runSpd
		repeat task.wait() until running == false
		keyConnection:Disconnect()
		hum.WalkSpeed = baseSpd
		for i = 1,5 do
			game.Workspace.CurrentCamera.FieldOfView = (80-(i*2))
			task.wait()
		end
	end
end

return movement