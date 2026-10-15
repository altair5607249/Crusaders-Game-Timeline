local CS = game:GetService("CollectionService")
local debby = game:GetService("Debris")
local Players = game:GetService("Players")
local RNS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local charDims = Vector3.new(2, 5, 1) --for r6 models, which this game exclusively uses
local directions = { --1.0 for the torso, and the extra 0.5 as a skin buffer
	Front = {vect = function(cf: CFrame) return cf.LookVector end, rad = 1.5, axis = function(pt: Part) return pt.AssemblyLinearVelocity.Z end}, 
	Back = {vect = function(cf: CFrame) return -cf.LookVector end, rad = 1.5, axis = function(pt: Part) return pt.AssemblyLinearVelocity.Z end},
	Right = {vect = function(cf: CFrame) return cf.RightVector end, rad = 1.5, axis = function(pt: Part) return pt.AssemblyLinearVelocity.X end},
	Left = {vect = function(cf: CFrame) return -cf.RightVector end, rad = 1.5, axis = function(pt: Part) return pt.AssemblyLinearVelocity.X end},
	Down = {vect = function(cf: CFrame) return -cf.UpVector end, rad = 3, axis = function(pt: Part) return pt.AssemblyLinearVelocity.Y end}, 
} --the down direction needs more grace than the cardinal directions
local rng = Random.new()
local vfxInfo = TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local peakMomentum = {} --only for individual player models, separate from simRegistry; utilized for kinetic continuity/determinstic impact velocity
local simRegistry = {} --works on a player-character basis

local function setCollision(character: Model)
	for i, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			object.CollisionGroup = "Player"
		end
	end
end

local function detectCollision(player: Player, char: Model, dt: number)
	local entry = simRegistry[player] and simRegistry[player][char]
	
	if entry and entry[2] == true then return end
	
	local hum: Humanoid = char:FindFirstChild("Humanoid")
	local root: Part = char:FindFirstChild("HumanoidRootPart")
	
	if not hum or not root or hum.Health <= 0 then return end --prevents old threads from throwing errors
	
	local velocity = root.AssemblyLinearVelocity
	local momentum = root.Mass * velocity.Magnitude
	local reqMomentum = root.Mass * 125 --evaluates to approximately 350
	
	peakMomentum[char] = math.max(peakMomentum[char] or 0, momentum) --prevents clashing between my physics and Roblox's physics
	
	if peakMomentum[char] < reqMomentum then return end --ends the thread early before too much allocation
	--note: do NOT use instantanteous momentum in the gate above, as it risks clashing with Roblox's physics engine
	--(this is the reason why i implemented kinetic continuity)
	
	local chars = CS:GetTagged("Character")
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = chars
		
	for direction: string, info: {any} in pairs(directions) do
		local result = workspace:Blockcast(root.CFrame, charDims, info.vect(root.CFrame), params)
		local speed = math.abs(info.axis(root))
		local radius = math.max(info.rad, speed * dt * info.rad)
		
		local verticalVel = velocity.Y
		local horizontalVel = math.sqrt(velocity.X^2 + velocity.Z^2) --applies the pythagorean theorem to evaluate the magnitude of the horizontal vectors
		
		if direction == "Down" and horizontalVel > verticalVel then continue end --prevents false positives for knockback scenarios
		
		if result and result.Distance <= radius then
			local recMomentum = peakMomentum[char] or 0
			peakMomentum[char] = 0 --resets recorded momentum for next moment of contact
			
			if recMomentum >= reqMomentum then
				entry[2] = true

				--debris flies into the air upon impact
				for i = 1, 8 do
					local debris = Instance.new("Part")
					local offset = (direction ~= "Down" and Vector3.new(math.random(-10, 10), math.random(-10, 10), 0)) or Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
					
					if offset.Magnitude < 0.1 then offset = Vector3.new(1, 0, 0) end
					
					debris.CFrame = CFrame.new(result.Position) * CFrame.new(offset)
					debris.Massless = true --looks visually better
					debris.Parent = workspace
					
					local relDir = offset.Unit --normalizes the offset to determine the relative direction, rather than normalizing the positional difference between the debris and the blockcast's result
					local side = rng:NextNumber(3, 4)
					
					--customizing the debris
					debris.CanCollide = false
					debris.CanQuery = false
					debris.Color = Color3.new()
					debris.Material = result.Material
					debris.Size = Vector3.new(side, side, side)
					
					local impulse = (direction ~= "Down" and Vector3.new(relDir.X * 1000, 3000, -relDir.Z * 4500)) or Vector3.new(relDir.X * 1500, 5000, relDir.Z * 2000)
					
					debris:ApplyImpulse(impulse)
					debris:ApplyAngularImpulse(Vector3.new(math.random(200, 400), math.random(200, 400), math.random(200, 400)))
					debby:AddItem(debris, 3) --3s is about enough time for all of the flying debris to be out of sight
				end
				
				--shockwave from the impact
				local shockwave = RS.AttackVFX.CollisionShockwave:Clone()
				shockwave.Parent = workspace
				
				local worldUp = Vector3.yAxis
				if math.abs(result.Normal:Dot(worldUp)) > 0.999 then
					worldUp = Vector3.xAxis --prevents up-vector singularity down the line
				end
				
				local relRight = result.Normal:Cross(worldUp).Unit
				local relUp = relRight:Cross(result.Normal).Unit
				
				--the magic of linear algebra saves me from coding 100+ lines of trigonometry
				local rot = CFrame.Angles(math.rad(-90), 0, 0) --will be relative to the new cframe, in which the vfx by default face upward
				local dest = CFrame.fromMatrix(result.Position, relRight, relUp, -result.Normal) * rot
				
				shockwave:PivotTo(dest)
				
				for i, mesh: MeshPart in ipairs(shockwave:GetChildren()) do
					local tweenTp = TS:Create(mesh, vfxInfo, {Transparency = 1})
					tweenTp:Play()
					tweenTp.Completed:Connect(function()
						tweenTp:Destroy()
						shockwave:Destroy()
					end)
				end
				
				local alpha = Instance.new("NumberValue")
				alpha.Value = shockwave:GetScale()
				alpha.Changed:Connect(function(value)
					if not shockwave then return end
					
					shockwave:ScaleTo(value)
					shockwave:PivotTo(dest * CFrame.new(0, 2.5 * value, 0))
				end)
				
				local tweenAlpha = TS:Create(alpha, vfxInfo, {Value = 1})
				tweenAlpha:Play()
				tweenAlpha.Completed:Connect(function()
					tweenAlpha:Destroy()
					alpha:Destroy()
				end)

				if not hum:HasTag("Immortal") then hum:TakeDamage(hum.MaxHealth / 15) end --collision damage

				task.delay(0.5, function() --delay time here is equivalent to heavy knockback's reset interval
					local currentEntry = simRegistry[player] and simRegistry[player][char]
					if currentEntry then currentEntry[2] = false end
				end)
			end
				
			return
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	simRegistry[player] = {}
	
	player.CharacterAdded:Connect(function(char)
		setCollision(char)
		
		local sim = RNS.PreSimulation:Connect(function(dt)
			detectCollision(player, char, dt)
		end)
		
		simRegistry[player][char] = {sim, false}
	end)
	
	player.CharacterRemoving:Connect(function(char)
		if player.Parent ~= Players then return end
		
		local entry = simRegistry[player] and simRegistry[player][char]
		local conn = entry and entry[1]
		if conn then 
			conn:Disconnect() 
			peakMomentum[char] = nil
			simRegistry[player][char] = nil
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local playerSims = simRegistry[player]
	
	if playerSims then
		for char, t: {any} in pairs(playerSims) do
			local conn = t[1]
			conn:Disconnect()
			peakMomentum[char] = nil
		end
	end
	
	simRegistry[player] = nil
end)