local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PG = player:WaitForChild("PlayerGui")
local loadingManager = require(PG:WaitForChild("LoadingScreen").ModuleLoader3.Manager)

player:AddTag("StartingScreenActive")

local hum = nil
local function onCharacterAdded(char: Model)
	hum = char:WaitForChild("Humanoid")
end

if player.Character then --in case the character model already exists (race condition for initial player entry)
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(function(char) --in case the character model doesn't already exist
	onCharacterAdded(char)
end)

repeat task.wait() until hum ~= nil

loadingManager.StartScreen()

script:Destroy()