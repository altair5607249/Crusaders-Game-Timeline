local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local cdRegistry = {} --too dynamic; will stay independent of the global registry in Matter

Players.PlayerAdded:Connect(function(player)
	cdRegistry[player] = {}
end)

Players.PlayerRemoving:Connect(function(player)
	cdRegistry[player] = nil
end)

local cooldown = {}

function cooldown:Register(player: Player, move: string, ID: number)
	cdRegistry[player][move] = {tick(), ID} 
end

function cooldown:IsReady(player: Player, move: string, style: string)
	local entry = cdRegistry[player][move]
	if entry == nil then return true end
	local ID = entry[2] --returns the specified previous input action
	local prevInput = entry[1] --returns the specified previous input time/tick
	local crusader = player:GetAttribute("Crusader")
	local constraint = timing.GetValue(crusader, style, 2, ID) --cooldown used as the constraint
	return not timing.CheckConstraint(prevInput, constraint)
end

return cooldown