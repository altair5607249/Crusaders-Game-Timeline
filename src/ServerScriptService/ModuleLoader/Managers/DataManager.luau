--basic data saving code, and thanks BrawlDev for the tutorial!
local DSS = game:GetService("DataStoreService")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataManager = {}

local autoSave = 600 --period
local knockoutStats = DSS:GetDataStore("Knockouts") --will migrate all this data to a more appropriately named data store later on

local receivers = RS.Remotes
local updSettings = receivers.UpdateSettings

local defaultData = {
	knockouts = 0,
	preferences = {
		Hitboxes = false,
		Music = 50,
		Secret = false
	}
}

local playerData = {}

local function fullCopy(toCopy: {any})
	local uniqueCopy = {}

	for key, value in pairs(toCopy) do
		if typeof(value) == "table" then --for sub-tables, aka the only thing table.clone() doesn't account for
			uniqueCopy[key] = fullCopy(value)
		else
			uniqueCopy[key] = value
		end
	end

	return uniqueCopy
end

local function reconcileData(loaded: {any}, default: {any})
	for key, value in pairs(default) do
		if loaded[key] == nil then
			loaded[key] = value --fill in missing data slot with what the default data has it set as
		elseif typeof(value) == "table" then --e.g., preferences
			reconcileData(loaded[key], value) --recursively calls the function with the inner/sub loaded and default tables
		end
	end
	return loaded
end

local function saveData(player: Player, retry: boolean)
	local leaderstats: Folder = player:FindFirstChild("leaderstats")
	local currentKOs: number = leaderstats and leaderstats["KO's"].Value
	if not currentKOs then return end --guards against race conditions

	local data = playerData[player.UserId]
	if not data then return end
	data.knockouts = currentKOs

	local success, _ = pcall(function()
		knockoutStats:SetAsync(tostring(player.UserId), data)
	end)
	if not success then
		warn("Save failed for", tostring(player.UserId) .. "!")
		if retry then
			local success, _ = pcall(function()
				knockoutStats:UpdateAsync(tostring(player.UserId), function(oldValue)
					return data
				end)
			end)
			if not success then
				warn("Recursive save failed for", tostring(player.UserId) .. "!")
			end
		end
	end
end

--lets other scripts read a player's current data (e.g. DamageManager checking Hitboxes)
function DataManager.GetPlayerData(player: Player)
	return playerData[player.UserId]
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local KOs = Instance.new("IntValue")
	KOs.Name = "KO's"
	KOs.Parent = leaderstats

	local success, data = pcall(function()
		return knockoutStats:GetAsync(tostring(player.UserId))
	end)

	local loadedData
	if success and typeof(data) == "table" then
		loadedData = data --uses previously saved data if available
	elseif success and typeof(data) == "number" then --migrates the knockout data from previous versions
		loadedData = fullCopy(defaultData)
		loadedData.knockouts = data
	else
		loadedData = fullCopy(defaultData) --default data
	end

	loadedData = reconcileData(loadedData, defaultData)
	playerData[player.UserId] = loadedData

	KOs.Value = loadedData.knockouts

	task.spawn(function() --autosave, just in case
		while true do
			task.wait(autoSave)
			if player.Parent ~= Players then break end
			saveData(player, false)
		end
	end)
	
	repeat task.wait() until not player:HasTag("StartingScreenActive")
	
	updSettings:FireClient(player, playerData[player.UserId].preferences)
end)

Players.PlayerRemoving:Connect(function(player)
	saveData(player, true)
	playerData[player.UserId] = nil
end)

updSettings.OnServerEvent:Connect(function(player, preference: string, prefValue: string | number | boolean)
	local data = playerData[player.UserId]
	if not data then return end
	if typeof(data.preferences[preference]) ~= typeof(prefValue) then return end
	data.preferences[preference] = prefValue
end)

return DataManager