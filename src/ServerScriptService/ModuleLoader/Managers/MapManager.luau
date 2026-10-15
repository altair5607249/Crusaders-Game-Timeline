-- manages map and spawn location rotation
local CS = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SNS = game:GetService("SoundService")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local CMS = require(SSS.ModuleLoader.Matter)

local bufferTime = 60 -- time spent in the default map
local changePeriod = 480 -- 8 minutes
local starting = true

local spawns = workspace.Spawns
local defaultSpawns = spawns.Winterness
local maps = SS.Maps:GetChildren()
local defaultMap = workspace.Winterness

defaultMap:AddTag("ActiveLobby") --tracks the whether the lobby is in play

local countdown = RS.Remotes.MapCountdown
local notify = RS.Remotes.MapChange
local volume = RS.Remotes.BGMVolume

local mapInfo = {
	["Cyberpunk City"] = "Animateria & InstantlyBread",
	Woodlands = "Infexornn & CorruptTypes",
	Winterness = "InstantlyBread",
	["City 17"] = "Valve Software",
	Station = "MasonEpicBuilder2008",
	Opalia = "GreenHoldinItDown",
	["Parking Lot"] = "Nicholas3285 & MinecraftPro97k",
	["Floating Castle"] = "J4milion & InstantlyBread",
	Backrooms = "InstantlyBread & GreenHoldinItDown",
	["Former School"] = "Brendan & RedManta LLC",
	Town = "CorruptTypes"
}

local skyboxes = {
	["Cyberpunk City"] = {
		Bk = "rbxassetid://17124357467",
		Dn = "rbxassetid://17124359797",
		Ft = "rbxassetid://17124362093",
		Lf = "rbxassetid://17124365127",
		Rt = "rbxassetid://17124367200",
		Up = "rbxassetid://17124369657",
	},

	Woodlands = {
		Bk = "rbxasset://sky/null_plainsky512_bk.jpg",
		Dn = "rbxasset://sky/null_plainsky512_dn.jpg",
		Ft = "rbxasset://sky/null_plainsky512_ft.jpg",
		Lf = "rbxasset://sky/null_plainsky512_lf.jpg",
		Rt = "rbxasset://sky/null_plainsky512_rt.jpg",
		Up = "rbxasset://sky/null_plainsky512_up.jpg",
	},

	Winterness = {
		Bk = "rbxassetid://1327358",
		Dn = "rbxassetid://1327359",
		Ft = "rbxassetid://1327355",
		Lf = "rbxassetid://1327357",
		Rt = "rbxassetid://1327356",
		Up = "rbxassetid://1327360",
	},

	["City 17"] = {
		Bk = "rbxassetid://88447992114024",
		Dn = "rbxassetid://107600007706708",
		Ft = "rbxassetid://105779212301234",
		Lf = "rbxassetid://104874552107093",
		Rt = "rbxassetid://97440827307564",
		Up = "rbxassetid://114054184472252",
	},

	Station = {
		Bk = "rbxassetid://70846814891440",
		Dn = "rbxassetid://70846814891440",
		Ft = "rbxassetid://70846814891440",
		Lf = "rbxassetid://70846814891440",
		Rt = "rbxassetid://70846814891440",
		Up = "rbxassetid://70846814891440",
	},

	Opalia = {
		Bk = "rbxassetid://93706034661058",
		Dn = "rbxassetid://93734219887902",
		Ft = "rbxassetid://112463714577591",
		Lf = "rbxassetid://80149133716752",
		Rt = "rbxassetid://81838491736518",
		Up = "rbxassetid://76186424846211",
	},

	["Parking Lot"] = {
		Bk = "rbxassetid://93706034661058",
		Dn = "rbxassetid://93734219887902",
		Ft = "rbxassetid://112463714577591",
		Lf = "rbxassetid://80149133716752",
		Rt = "rbxassetid://81838491736518",
		Up = "rbxassetid://76186424846211",
	},

	["Floating Castle"] = {
		Bk = "rbxassetid://246894245",
		Dn = "rbxassetid://246893155",
		Ft = "rbxassetid://246894274",
		Lf = "rbxassetid://246894229",
		Rt = "rbxassetid://246892987",
		Up = "rbxassetid://246894296",
	},
	
	Backrooms = {
		Bk = "rbxassetid://72669936335562",
		Dn = "rbxassetid://72669936335562",
		Ft = "rbxassetid://72669936335562",
		Lf = "rbxassetid://72669936335562",
		Rt = "rbxassetid://72669936335562",
		Up = "rbxassetid://72669936335562",
	},
	
	["Former School"] = {
		Bk = "rbxasset://sky/null_plainsky512_bk.jpg",
		Dn = "rbxasset://sky/null_plainsky512_dn.jpg",
		Ft = "rbxasset://sky/null_plainsky512_ft.jpg",
		Lf = "rbxasset://sky/null_plainsky512_lf.jpg",
		Rt = "rbxasset://sky/null_plainsky512_rt.jpg",
		Up = "rbxasset://sky/null_plainsky512_up.jpg",
	},
	
	Town = {
		Bk = "rbxasset://sky/null_plainsky512_bk.jpg",
		Dn = "rbxasset://sky/null_plainsky512_dn.jpg",
		Ft = "rbxasset://sky/null_plainsky512_ft.jpg",
		Lf = "rbxasset://sky/null_plainsky512_lf.jpg",
		Rt = "rbxasset://sky/null_plainsky512_rt.jpg",
		Up = "rbxasset://sky/null_plainsky512_up.jpg",
	}
}

local function setSkybox(mapName: string)
	local data = skyboxes[mapName]

	if not data then
		warn("No skybox configured for map:", mapName)
		return
	end

	local sky = Lighting:FindFirstChildOfClass("Sky")

	if not sky then
		sky = Instance.new("Sky")
		sky.Parent = Lighting
	end

	sky.SkyboxBk = data.Bk
	sky.SkyboxDn = data.Dn
	sky.SkyboxFt = data.Ft
	sky.SkyboxLf = data.Lf
	sky.SkyboxRt = data.Rt
	sky.SkyboxUp = data.Up
end

local displayedMap: Model = defaultMap
local timeNecessity = true
local elapsed: number? = nil
local newMap: Model? = nil
local mapIndex: number? = nil

local tweenTime = 5
local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function playSoundtrack(map: string, enabled: boolean)
	local music: Sound = SNS[map].Sound

	if enabled then --to enable
		volume:FireAllClients(music, enabled)
	else --to disable
		volume:FireAllClients(music, enabled)
	end
end

local function immortalizePlayers(players: {Player}, delayTime: number)
	for i, player in ipairs(players) do
		task.spawn(function()
			local char = player.Character or player.CharacterAdded:Wait()
			local hum = char:WaitForChild("Humanoid")

			hum:AddTag("Immortal")

			--same shape as the StunManager's main code/shared expiry
			local expiresAt = os.clock() + delayTime
			local current = player:GetAttribute("ImmortalUntil") or 0
			if expiresAt > current then
				player:SetAttribute("ImmortalUntil", expiresAt)
			end

			print(("Lobby immortality added to %s (delay=%d, t=%.3f, until=%.3f)"):format(player.Name, delayTime, os.clock(), expiresAt))

			task.delay(delayTime, function()
				if os.clock() >= (player:GetAttribute("ImmortalUntil") or 0) then
					print(("Lobby immortality rescinded from %s (delay=%d, t=%.3f)"):format(player.Name, delayTime, os.clock()))
					hum:RemoveTag("Immortal")
				end
			end)
		end)
	end
end

local function reloadPlayers(immortalDuration: number)
	local playerList = Players:GetChildren()

	for i, player in ipairs(playerList) do
		task.spawn(function()
			repeat task.wait() until player:GetAttribute("Crusader")
			CMS.Death(player, player:GetAttribute("Crusader"), immortalDuration)
		end)
	end
end

local function controlSpawns(spawns: Folder, enabled: boolean)
	for i, location: SpawnLocation in ipairs(spawns:GetChildren()) do
		location.Enabled = enabled
	end

	CMS.ManageSpawns(spawns, enabled)
end

local function updateGUI(player: Player, map: Model, timing: number)
	if player == "All" then
		notify:FireAllClients(map.Name, mapInfo[map.Name])
		countdown:FireAllClients(timing)
	else
		notify:FireClient(player, map.Name, mapInfo[map.Name])
		countdown:FireClient(player, timing)
	end
end

Players.PlayerAdded:Connect(function(player)
	if starting then return end

	updateGUI(player, displayedMap, elapsed)
	
	if defaultMap:HasTag("ActiveLobby") then --prevents the attribution of inaccurate immortality timing to new players
		immortalizePlayers({player}, elapsed or bufferTime) --for when the player joins during a lobby phase
	else
		immortalizePlayers({player}, 10) --for when the player joins during an active round
	end
end)

controlSpawns(defaultSpawns, true)
setSkybox(defaultMap.Name)

local mapManager = {}

function mapManager.Timer(timing: number, necessary: boolean)
	elapsed = timing
	timeNecessity = necessary --differentiates between lobby's buffer timing and chosen map's rotation

	repeat
		task.wait(1)
		elapsed -= 1
	until elapsed <= 0
end

function mapManager.MapSelector()
	if mapIndex then
		local index = mapIndex --snapshots the mapIndex before setting it back to nil
		mapIndex = nil
		return maps[index]
	else
		return maps[math.random(1, #maps)] 
	end
end

function mapManager.SetMap(mapName: string) --for manually selecting the map
	local index: number? = nil
	
	for i, map: Model in ipairs(maps) do --glorified table.find(), due to the actual maps table being filled with instances
		if map.Name == mapName then
			index = i
			break
		end
	end
	
	if index then
		mapIndex = index
		
		if not timeNecessity then elapsed = 0 end
	else
		warn(mapName, "not found!")
	end
end

--main rotation/loop block
task.spawn(function()
	while true do
		if starting == false then
			mapManager.Timer(changePeriod, false) --pauses the thread
			
			defaultMap:AddTag("ActiveLobby")
			
			controlSpawns(defaultSpawns, true)
			reloadPlayers(60)

			updateGUI("All", defaultMap, bufferTime)

			displayedMap = defaultMap

			playSoundtrack(defaultMap.Name, true)
			setSkybox(defaultMap.Name)
		else --skips the wait and confirms the end of the initial, start-of-server cycle
			if not Players:GetChildren()[1] then --waits for an available player
				repeat task.wait() until Players:GetChildren()[1]
			end

			starting = false

			immortalizePlayers(Players:GetChildren(), bufferTime)
			updateGUI("All", defaultMap, bufferTime)

			displayedMap = defaultMap
		end

		local activeMaps: {Instance}?, currentMap: Model? = nil, nil

		activeMaps = CS:GetTagged("ActiveMap")
		currentMap = activeMaps[1]

		newMap = mapManager.MapSelector()

		if currentMap and currentMap.Name == newMap.Name then
			repeat newMap = maps[math.random(1, #maps)] until currentMap.Name ~= newMap.Name
		end

		if currentMap then
			local currentSpawns = spawns[currentMap.Name]

			controlSpawns(currentSpawns, false)
			playSoundtrack(currentMap.Name, false) --disables the last active map's song

			currentMap:Destroy()
		end

		local newSpawns: Folder = spawns[newMap.Name]
		local newClone: Model = newMap:Clone()

		newClone.Parent = workspace

		mapManager.Timer(bufferTime, true) --allows players 60 seconds in the lobby
		newClone:AddTag("ActiveMap")
		defaultMap:RemoveTag("ActiveLobby")

		setSkybox(newMap.Name)

		controlSpawns(defaultSpawns, false)
		controlSpawns(newSpawns, true)

		playSoundtrack(newMap.Name, true)
		playSoundtrack(defaultMap.Name, false)

		reloadPlayers(2) --amount of time for limbo be broken through

		updateGUI("All", newMap, changePeriod)

		displayedMap = newMap
	end
end)

return mapManager