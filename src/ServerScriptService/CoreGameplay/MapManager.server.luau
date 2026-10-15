--manages map and spawn location rotation
local Players = game:GetService("Players")
local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local CMS = require(script.Parent.Parent.ModuleLoader.Matter)

local bufferTime = 60 --time spent in the default map
local changePeriod = 480 --test time, official will be 8 minutes :)
local starting = true

local spawns = workspace.Spawns
local defaultSpawns = spawns.Winterness
local maps = SS.Maps:GetChildren()
local defaultMap = workspace.Winterness

local notify = RS.Remotes.MapChange
local countdown = RS.Remotes.MapCountdown

local mapCreators = {
	Cyberpunk = "Animateria",
	Woodlands = "Infexornn & CorruptTypes",
	Winterness = "InstantlyBread"
}

local displayedMap: Model = defaultMap
local elapsed: number? = nil
local newMap: Model? = nil

local function immortalizePlayers(delayTime: number)
	for i, player: Player in ipairs(Players:GetChildren()) do
		task.spawn(function()
			local char = player.CharacterAdded:Wait()
			local hum = char:WaitForChild("Humanoid")
			hum:AddTag("Immortal")
			print("Lobby immortality added to player!")
			task.delay(delayTime, function()
				print("Lobby immortality rescinded from player!")
				hum:RemoveTag("Immortal")
			end)
		end)
	end
end

local function reloadPlayers()
	for i, player: Player in ipairs(Players:GetChildren()) do
		task.spawn(function() 
			repeat task.wait() until player:GetAttribute("Crusader")
			CMS.Death(player, player:GetAttribute("Crusader")) 
		end)
	end
end

local function controlSpawns(spawns: Folder, enabled: boolean)
	for i, location: SpawnLocation in ipairs(spawns:GetChildren()) do
		location.Enabled = enabled
	end
	CMS.ManageSpawns(spawns, enabled)
end

local function timer(timing: number)
	elapsed = timing
	repeat
		task.wait(1)
		elapsed -= 1
	until elapsed <= 0
end

local function updateGUI(player: Player, map: Model, timing: number)
	if player == "All" then
		notify:FireAllClients(map.Name, mapCreators[map.Name])
		countdown:FireAllClients(timing)
	else
		notify:FireClient(player, map.Name, mapCreators[map.Name])
		countdown:FireClient(player, timing)
	end
end

Players.PlayerAdded:Connect(function(player)
	if starting then return end --prevents early data leaks 
	updateGUI(player, displayedMap, elapsed)
end)

controlSpawns(defaultSpawns, true)

while true do
	if starting == false then 
		timer(changePeriod)
		controlSpawns(defaultSpawns, true)
		reloadPlayers()
		
		immortalizePlayers(bufferTime)
		updateGUI("All", defaultMap, bufferTime)
		displayedMap = defaultMap
	else --skips the wait and confirms the end of the initial, start-of-server cycle
		starting = false
		
		--wait for an available player
		if not Players:GetChildren()[1] then repeat task.wait() until Players:GetChildren()[1] end
		
		immortalizePlayers(bufferTime)
		updateGUI("All", defaultMap, bufferTime)
		displayedMap = defaultMap
	end

	local activeMaps: {Instance}?, currentMap: Model? = nil, nil

	activeMaps = CS:GetTagged("ActiveMap") --there's only one at a time to be fair (no the default map doesn't count)
	currentMap = activeMaps[1] --and this is how i'll get the map folder directly

	newMap = maps[math.random(1, #maps)]

	if currentMap and currentMap.Name == newMap.Name then --guards against nil
		repeat
			newMap = maps[math.random(1, #maps)]
		until currentMap.Name ~= newMap.Name
	end

	if currentMap then 
		local currentSpawns = spawns[currentMap.Name] 
		currentMap:Destroy()
		controlSpawns(currentSpawns, false)
	end

	local newSpawns: Folder = spawns[newMap.Name]
	local newClone: Model = newMap:Clone()
	newClone.Parent = workspace --because the maps are cached in server storage, their positions are saved from wherever i made or added the template!

	timer(bufferTime)

	newClone:AddTag("ActiveMap")
	controlSpawns(defaultSpawns, false)
	controlSpawns(newSpawns, true)
	reloadPlayers()
	
	immortalizePlayers(2.25) --tween time :)
	updateGUI("All", newMap, changePeriod)
	displayedMap = newMap
end