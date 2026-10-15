local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local sender = RS.Remotes.Admin

local adminRegistry = {
	Regulators = { --T2
		Magnitude = {8},
		Redeemer = {1147951417},
		Eudaimonic = {1686067617},
	},
	Principalities = { --T3
		Magnitude = {7},
		Crusader = {4881419387, 8780962510, 733050969, 7504271088, 5593365425, 2942231469},
		Transcendant = {2528328358, 306366365, 3570093153, 474688120, 2057014980, 1036700937},
	},
	Regalia = { --T4
		Magnitude = {6},
		Sovereign = {1631980288},
		Suzerain = {},
		Mediator = {},
		Visionary = {1198289487}
	},
}

--note: the category details the level of permission, while the subcategory details the aesthetics behind that permission

table.sort(adminRegistry, function(a, b)
	print(a["Magnitude"][1])
	print(b["Magnitude"][1])
	return a["Magnitude"][1] > b["Magnitude"][1]
end)

print(adminRegistry)

local adminPerms = {}

Players.PlayerAdded:Connect(function(player)
	local result: boolean, title1: string, title2: string = adminPerms:GetPerms(player)
	
	if result then
		print("One of the", title1, "has joined!", title2 .. ":", player.Name .. "!")
	else
		print(player.Name, "was not found in the administration registry.")
	end
end)

function adminPerms:GetPerms(player: Player)
	for title1: string, category1: {Instance} in pairs(adminRegistry) do
		for title2: string, category2: {Instance} in pairs(category1) do
			local index = table.find(category2, player.UserId)
			
			if index then 
				sender:FireClient(player, title1, title2)
				return true, title1, title2
			end
		end
	end
end

return adminPerms