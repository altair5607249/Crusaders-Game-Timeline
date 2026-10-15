--basic data saving code, and thanks BrawlDev for the tutorial!
local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local autoSave = 60 --period
local knockoutStats = DSS:GetDataStore("Knockouts")

local function saveData(player: Player, retry: boolean)
	local leaderstats: Folder = player:FindFirstChild("leaderstats")
	local currentKOs: number = leaderstats and leaderstats["KO's"].Value
	if not currentKOs then return end --guards against race conditions

	local success, _ = pcall(function()
		knockoutStats:SetAsync(tostring(player.UserId), currentKOs)
	end)
	if not success then
		warn("Save failed for", tostring(player.UserId) .. "!")
		if retry then
			local success, _ = pcall(function()
				knockoutStats:UpdateAsync(tostring(player.UserId), function(oldValue) 
					return currentKOs
				end)
			end)
			if not success then
				warn("Recursive save failed for", tostring(player.UserId) .. "!")
			end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local KOs = Instance.new("IntValue")
	KOs.Name = "KO's"
	KOs.Parent = leaderstats
	
	local success, currentKOs: number = pcall(function()
		return knockoutStats:GetAsync(tostring(player.UserId))
	end)
	if success and currentKOs ~= nil then
		KOs.Value = currentKOs --uses the last saved value
	else
		KOs.Value = 0 --default value
	end
	
	task.spawn(function() --autosave, just in case
		while true do
			task.wait(autoSave)
			if player.Parent ~= Players then break end
			saveData(player, false)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	saveData(player, true)
end)