local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local announce = RS.Remotes.Announcement
local sender = RS.Remotes.Admin

local adminRegistry = {
	Regulators = {
		Magnitude = 8, --this indicates the level of authority one possesses
		Eudaimonic = {
			[7486368182] = {"Avyā B. Elyssium L., the Last Human,", "<font color ='#000000'>%s</font>"},
			[1147951417] = {"Veryn, the Wonder,", "<font color ='#888888'>%s</font>"}
		},
	},
	Principalities = {
		Magnitude = 7,
		Crusader = { --crude, contemporary aliases
			[4881419387] = {"Aidalon, the Most Incompetent God,", "<font color ='#FF0000'>%s</font>"}, 
			[8780962510] = {"Xæon, the Knight of Twilight,", "<font color ='#FF8000'>%s</font>"}, 
			[733050969] = {"Ethandros, the First Drifter,", "<font color ='#FFFF00'>%s</font>"}, 
			[7504271088] = {"Zakyros, the Fractal Fabricator,", "<font color ='#00FF00'>%s</font>"}, 
			[5593365425] = {"Gabrius, the Stellar Liberator,", "<font color ='#0000FF'>%s</font>"}, 
			[2942231469] = {"Koleon, the Lord of the Federation,", "<font color ='#FF00FF'>%s</font>"}
		},
		Transcendant = {
			[2528328358] = {"Krimson, the Hidden Menace,", "<font color ='#FF000F'>%s</font>"}, --Aidalon's isolated rage
			[306366365] = {"Knox, the Alter Ego,", "<font color ='#00FF00'>%s</font>"}, --Zakyros's alter ego
			[3570093153] = {"Sage, the Earth Standing,", "<font color ='#B2AC88'>%s</font>"}, --Zakyros's wife (Askafroa)
			[474688120] = {"Jazz, the Jewel,", "<font color ='#FF0000'>%s</font>"}, --ancient creature of the Abyss, friend of Avyā
			[2057014980] = {"Yochanan, the Merry Minstrel,", "<font color ='#825825'>%s</font>"}, --Sigiward's old aide
			[1036700937] = {"Lord F-150, the Symphony of Syzygy,", "<font color ='#0088FF'>%s</font>"}, --rival of Sigiward on the racetrack
			[1686067617] = {"Dinosaur, not Dinosuar,", "<font color ='#FFC0CB'>%s</font>"}, --ancient creature of the Abyss, friend of Avyā
		},
	},
	Redeemers = {
		Magnitude = 6,
		Wonder = {
			[1631980288] = {"Ryushi Akuseru, the Wonder of What Matters,", "<font color ='#FF69B4'>%s</font>"} --former Sovereign
		},
		Reverend = {},
		Vindicator = {},
		Agonist = {}
		
	},
	["Greater Regalia"] = {
		Magnitude = 5,
		Regent = {},
		Sovereign = {},
	},
	["Lesser Regalia"] = {
		Magnitude = 4,
		Suzerain = {},
		Mediator = {},
		Visionary = {
			[1198289487] = {"Adelheid", "<font color ='#FF00FF'>%s</font>"} --previous visionary of Earth
		}
	},
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

type adminInfo = {epithet: string, ink: string}

Players.PlayerAdded:Connect(function(player)
	local rank: string, title: string, clearance: number = adminPerms:GetPerms(player, true)
	
	if rank then
		local specs: adminInfo = adminRegistry[rank][title][player.UserId]
		specs.epithet = specs[1]
		specs.ink = specs[2]
		
		local message: string = title .. " " .. specs.epithet .. " has entered the Headspace!"
		local quirk: string | string = specs.ink or "<font color ='#FF0000'>%s</font>"
		announce:FireAllClients(message, quirk)
	else
		print(player.Name, "was not found in the administration registry.")
	end
end)

function adminPerms:GetPerms(player: Player, init: boolean)
	for rank: string, category1: {Instance} in pairs(adminRegistry) do
		for title: string, category2: {Instance} in pairs(category1) do
			if title == "Magnitude" then continue end --not for storing IDs
			
			local key = category2[player.UserId]
			
			if key then 
				if init then sender:FireClient(player, title, category1.Magnitude) end
				return rank, title, category1.Magnitude::number
			end
		end
	end
end

return adminPerms