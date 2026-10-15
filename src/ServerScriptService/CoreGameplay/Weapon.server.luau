local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local cooldown = require(SSS.ModuleLoader.Managers.CooldownManager)
local stunManager = require(SSS.ModuleLoader.Managers.StunManager)

local receiver = RS.Remotes.EquipWeapon

local weaponRegistry = {} --dictates whether a player's character is eligible to equip a weapon

Players.PlayerAdded:Connect(function(player)
	weaponRegistry[player] = {}
	
	player.CharacterAdded:Connect(function(char)
		weaponRegistry[player][char] = {true, nil, nil} --1 indicates whether the style is bare, 2 is the idle quirk, 3 is the debuff
	end)
	
	player.CharacterRemoving:Connect(function(char)
		if player.Parent ~= Players then return end
		weaponRegistry[player][char] = nil
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	weaponRegistry[player] = nil
end)

local weaponCoords = {
	Redd = CFrame.new(0, -1, 1) * CFrame.Angles(math.rad(90), 0, 0),
	Yello = CFrame.new(0, 2.5, 0) * CFrame.Angles(0, 0, 0),
	Gleen = CFrame.new(0, 2.75, 1) * CFrame.Angles(math.rad(65), 0, 0),
	Bluee = CFrame.new(0.65, 2, 0) * CFrame.Angles(math.rad(-90), math.rad(45), math.rad(90)),
}

local function sway(joint: Motor6D, active: boolean)
	local char = joint:FindFirstAncestorOfClass("Model")
	local player = Players:GetPlayerFromCharacter(char)
	
	if active then
		joint.MaxVelocity = 0.01
		
		local initialTime = os.clock()
		
		weaponRegistry[player][char][2] = RNS.Heartbeat:Connect(function()
			local elapsed = os.clock() - initialTime
			joint.DesiredAngle = math.rad(8) * math.sin(elapsed * 1.2)
		end)
	else
		weaponRegistry[player][char][2]:Disconnect()
		joint.MaxVelocity = 0
	end
end

local function addMotor6dJoints(crusader: string, object: Accessory, part0: Part, part1: Part)
	local joint = Instance.new("Motor6D")
	
	local handle: Part = object.Handle
	local weld: WeldConstraint = handle:FindFirstChild("WeaponWeld")
	local autoWeld: Weld = handle:FindFirstChild("AccessoryWeld")
	
	if weld then weld.Enabled = false end --we only want this weld to remain
	if autoWeld then autoWeld:Destroy() end --deletes roblox's auto-generated accessory weld to prevent interference with the weapon joint
	
	joint.Name = "WeaponJoint"
	joint.Parent = object
	joint.Part0 = part0
	joint.Part1 = part1
	
	--customizing the position of the weapon
	joint.C1 = weaponCoords[crusader]
	
	local rope = handle:FindFirstChildWhichIsA("RopeConstraint")
	if rope then 
		rope.Attachment1 = object.Parent:FindFirstChild("Right Arm"):FindFirstChild("RightHandAttachment") 
		sway(joint, true)
	end
end

receiver.OnServerEvent:Connect(function(player)
	local currentChar = player.Character --snapshot of player's current character
	
	if currentChar:HasTag("RagdollActive") then return end
	
	if not cooldown:IsReady(player, "Switch", "Tech") or currentChar:GetAttribute("Stunned") then return end
	
	local crusader: string = player:GetAttribute("Crusader")
	local swapTime: number = timing.GetValue(crusader, "Tech", 2, 4) --returns 0.8 seconds
	
	cooldown:Register(player, "Switch", "Tech", 4)
	stunManager.Eval(player, nil, swapTime + 0.05, "Recovery")
	
	currentChar:AddTag("Resistance")
	
	task.delay(swapTime, function()
		if player.Parent ~= Players then return end
		
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:WaitForChild("Humanoid")
		
		if currentChar ~= char or hum.Health <= 0 then return end
		
		char:RemoveTag("Resistance")
		
		local main: Accessory = char:FindFirstChild("Main")
		
		if weaponRegistry[player][char][1] == true then
			weaponRegistry[player][char][1] = false
			
			char:AddTag("WeaponActive")
			
			local crusader: string = player:GetAttribute("Crusader")
			local domArm = (char["Left Arm"]:HasTag("Dominant") and char["Left Arm"]) or char["Right Arm"]
			
			addMotor6dJoints(crusader, main, domArm, main.Handle)
		else
			weaponRegistry[player][char][1] = true

			char:RemoveTag("WeaponActive")

			local handle: Part = main.Handle
			local torso: Part = char:WaitForChild("Torso")
			
			local att: Attachment = handle:FindFirstChildWhichIsA("Attachment")
			local weld: WeldConstraint = handle:FindFirstChild("WeaponWeld")
			
			local weaponJoint: Motor6D = main:FindFirstChild("WeaponJoint")
			
			if weld then
				weld.Part1 = torso
				weld.Enabled = true 
			end
			
			local rope = handle:FindFirstChildWhichIsA("RopeConstraint")
			if rope and rope.Attachment1 then
				sway(weaponJoint, false)
				rope.Attachment1 = nil 
			end
			
			weaponJoint:Destroy()
		end
	end)
end)