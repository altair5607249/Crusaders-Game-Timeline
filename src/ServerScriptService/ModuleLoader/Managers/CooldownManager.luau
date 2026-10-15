local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local cdRegistry = {}
local loadGUI = RS.Remotes.LoadCooldown
local cdChange = RS.Remotes.ChangeCooldown

Players.PlayerAdded:Connect(function(player)
	cdRegistry[player] = {}
	
	player.CharacterAdded:Connect(function(char) --indexes by player and character now
		cdRegistry[player][char] = {}
	end)
	
	player.CharacterRemoving:Connect(function(char)
		if player.Parent ~= Players then return end --this signal is faster than CharacterRemoving
		cdRegistry[player][char] = nil
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	cdRegistry[player] = nil
end)

local cooldown = {}

function cooldown:Register(player: Player, move: string, style: string, ID: number)
	local char = player.Character or player.CharacterAdded:Wait()
	
	if not (cdRegistry[player] and cdRegistry[player][char]) then return end --check in parts before directly indexing
	
	cdRegistry[player][char][move] = {os.clock(), ID} --char instances are distinct, regardless of shared template
	
	local crusader: string = player:GetAttribute("Crusader")
	local moveCooldown: number = timing.GetValue(crusader, style, 2, ID)
	
	loadGUI:FireClient(player, move, ID, moveCooldown)
end

function cooldown:IsReady(player: Player, move: string, style: string)
	local char = player.Character or player.CharacterAdded:Wait()
	local charEntries = cdRegistry[player] and cdRegistry[player][char]
	local entry = charEntries and charEntries[move]
	
	if entry == nil then return true end
	
	local prevInput = entry[1] --returns the specified previous input time/tick
	local ID = entry[2] --returns the specified previous input action
	
	local crusader: string = player:GetAttribute("Crusader")
	local constraint: number = timing.GetValue(crusader, style, 2, ID) --cooldown used as the constraint
	
	return not timing.CheckConstraint(prevInput, constraint)
end

function cooldown.Manipulate(player: Player, move: string, style: string, magnitude: number) --WIP
	local char = player.Character or player.CharacterAdded:Wait()
	local charEntries = cdRegistry[player] and cdRegistry[player][char]
	local entry = charEntries and charEntries[move]

	if entry == nil then return true end

	entry[1] += magnitude --can technically reduce wait time, add wait time, or eliminate it entirely by lying about the previous input
	
	local crusader: string = player:GetAttribute("Crusader")
	local difference: number = entry[1] - os.clock()
	local ID: number = entry[2]
	
	local newCooldown: number = timing.GetValue(crusader, style, 2, ID) + difference
	
	cdChange:FireClient(player, style, ID, entry[1])
	loadGUI:FireClient(player, move, ID, newCooldown)
end

return cooldown