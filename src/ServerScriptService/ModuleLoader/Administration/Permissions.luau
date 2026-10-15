local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local announce = RS.Remotes.Announcement
local sender = RS.Remotes.Admin

local adminRegistry = {
	Regulators = {
		Magnitude = 8, --this indicates the level of authority one possesses
		Eudaimonic = {1686067617, 1147951417},
	},
	Principalities = {
		Magnitude = 7,
		Crusader = {4881419387, 8780962510, 733050969, 7504271088, 5593365425, 2942231469},
		Transcendant = {2528328358, 306366365, 3570093153, 474688120, 2057014980, 1036700937},
	},
	Redeemers = {
		Magnitude = 6,
		Wonder = {},
		Reverend = {},
		Vindicator = {},
		Agonist = {}
		
	},
	["Greater Regalia"] = {
		Magnitude = 5,
		Regent = {},
		Sovereign = {1631980288},
	},
	["Lesser Regalia"] = {
		Magnitude = 4,
		Suzerain = {},
		Mediator = {},
		Visionary = {1198289487}
	},
	
}

local titleQuirks = {
	Crusader = {
		[4881419387] = "<font color ='#FF0000'>%s</font>",
		[8780962510] = "<font color ='#FF8000'>%s</font>",
		[733050969] = "<font color ='#FFFF00'>%s</font>",
		[7504271088] = "<font color ='#00FF00'>%s</font>",
		[5593365425] = "<font color ='#0000FF'>%s</font>",
		[2942231469] = "<font color ='#FF00FF'>%s</font>",
	}
}

--note: the category details the level of permission, while the subcategory details the aesthetics behind that permission

local tiers = {}

for tierName, tierData in pairs(adminRegistry) do
	table.insert(tiers, tierName)
end

table.sort(tiers, function(a, b)
	return adminRegistry[a]["Magnitude"] > adminRegistry[b]["Magnitude"]
end)

local adminPerms = {}

Players.PlayerAdded:Connect(function(player)
	local result: boolean, title: string, clearance: number = adminPerms:GetPerms(player, true)
	
	if result then
		local message: string = title .. " " .. player.Name .. " has entered the Headspace!"
		local quirk: string | string = titleQuirks[title][player.UserId] or "<font color ='#FF0000'>%s</font>"
		announce:FireAllClients(message, quirk)
	else
		print(player.Name, "was not found in the administration registry.")
	end
end)

function adminPerms:GetPerms(player: Player, init: boolean)
	for rank: string, category1: {Instance} in pairs(adminRegistry) do
		for title: string, category2: {Instance} in pairs(category1) do
			if title == "Magnitude" then continue end --not for storing IDs
			
			local index = table.find(category2, player.UserId)
			
			if index then 
				if init then sender:FireClient(player, title, category1.Magnitude) end
				return true, title, category1.Magnitude
			end
		end
	end
end

return adminPerms