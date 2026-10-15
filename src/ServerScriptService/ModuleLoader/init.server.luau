local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local managers = ServerScriptService.Managers

local WeaponManager = require(managers.WeaponManager)
local ClickManager = require(managers.M1Manager)
local DamageManager = require(managers.DamageManager)

for i, module in script.Modules:GetChildren() do
	local class = require(module)
	
	local suffix = RunService:IsServer() and "_Server" or "_Client"
	local tagName = string.sub(module.Name, 1, -#suffix - 1)
	
	CollectionService:GetInstanceAddedSignal(tagName):Connect(class.new)
	
	for i, object in CollectionService:GetTagged(tagName) do
		if object:FindFirstAncestorOfClass("ReplicatedStorage") then continue end
		class.new(object)
	end
end

--player coll group
game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAppearanceLoaded:Connect(function(character)
		for i, v in character:GetDescendants() do
			if v:IsA("BasePart") then
				v.CollisionGroup = "Player"
			end
		end
	end)
end)