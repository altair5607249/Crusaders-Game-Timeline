local outputMods = script.OutputModules
local remotes = game:GetService("ReplicatedStorage").Remotes
local attack = remotes.Attack

local atkRoutes = {}

for i, folder in ipairs(script:GetChildren()) do
	for i, module in ipairs(folder:GetChildren()) do
		local class = require(module)
		if module.Parent == outputMods then atkRoutes[module.Name] = class end
	end
end

attack.OnServerEvent:Connect(function(player, atkRoute: string, modifier: number)
	atkRoutes[atkRoute].Action(player, modifier)
end)

--[[ reserved for the rpg :)
local CollectionService = game:GetService("CollectionService")

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
--]]

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