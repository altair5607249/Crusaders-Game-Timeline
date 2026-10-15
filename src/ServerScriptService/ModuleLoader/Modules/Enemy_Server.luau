local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponManager = require(ServerScriptService.Managers.WeaponManager)

local Enemy = {}
Enemy.__index = Enemy

local ATTACK_RANGE = 10
local SEARCH_RANGE = 25
local RESPAWN_TIME = 4

function Enemy.new(model)
	local self = setmetatable({}, Enemy)
	self.Name = model.Name
	self.Model = model
	self.Root = model.HumanoidRootPart
	self.Humanoid = model.Humanoid
	self.OriginalPosition = self.Root.CFrame
	self.Weapon = model:FindFirstChildOfClass("Tool")
	
	self.Root:SetNetworkOwner(nil)
	
	if not self.Weapon then
		warn("No weapon found for enemy: ", self.Name)
		return
	end
	
	self.Humanoid.Died:Connect(function()
		self:OnDeath()
	end)
	
	self:HuntTarget()
	
	return self
end

function Enemy:OnDeath()
	task.wait(3)
	self.Model:Destroy()
	task.wait(RESPAWN_TIME)
	self:Respawn()
end

function Enemy:Respawn()
	local newModel = ReplicatedStorage.Enemies[self.Name]:Clone()
	newModel:PivotTo(self.OriginalPosition)
	self.Model = newModel
	self.Root = newModel.HumanoidRootPart
	self.Humanoid = newModel.Humanoid
	self.Weapon = newModel:FindFirstChildOfClass("Tool")
	self.Model.Parent = workspace
	
	self:HuntTarget()
end

function Enemy:GetNearestVisiblePlayer()
	local nearestPlayer = nil
	local position = nil
	local maxDistance = SEARCH_RANGE
	
	for i, player in game.Players:GetPlayers() do
		local character = player.Character
		if not character then continue end
		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then
			continue
		end
		
		local direction = root.Position - self.Root.Position
		local distance = direction.Magnitude
		if distance > maxDistance then continue end
		
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {self.Model}
		
		local raycastResult = workspace:Raycast(self.Root.Position, direction * SEARCH_RANGE, params)
		if not raycastResult or not raycastResult.Instance then continue end
		
		if raycastResult.Instance == root or raycastResult.Instance.Parent == root.Parent then
			maxDistance = distance
			nearestPlayer = player
			position = root.Position
		end
	end
	
	return position
end

function Enemy:HuntTarget()
	task.spawn(function()
		while self.Model.Parent == workspace and self.Humanoid.Health > 0 do
			local targetPosition = self:GetNearestVisiblePlayer()
			self.Humanoid:SetAttribute("Target", targetPosition)
			
			if not targetPosition then
				task.wait(1)
				continue
			end
			
			local distance = (self.Root.Position - targetPosition).Magnitude
			if distance < ATTACK_RANGE then
				WeaponManager.Attack(self.Weapon, self.Humanoid)
				task.wait(0.5)
			else
				self.Humanoid:MoveTo(targetPosition)
				task.wait()
			end
		end
	end)
end

return Enemy