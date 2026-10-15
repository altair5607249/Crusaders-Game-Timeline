--[[

> TopbarPlus was developed by ForeverHD and is actively maintained
thanks to HD Admin.

> You can get in touch with me on Discord via the social link here:
https://create.roblox.com/store/asset/92368439343389/TopbarPlus

> READ_ME is Script with RunContext set to 'Client' meaning you can
store it in ReplicatedStorage and Workspace and it will still run 
like a normal LocalScript. DO NOT PLACE place in StarterPlayerScripts
(because this is a Script with RunContext). You need to create a separate
LocalScript for anything under StarterPlayerScripts. 

> You're welcome to move `Icon` and require it yourself. You can
then delete this folder and READ_ME.

> Icon is a Package for when Roblox (hopefully soon) release
public packages. This for example will enable you to receive
automatic updates, and to compare code easily between changes

> Have feedback? Post it to devforum.roblox.com/t/topbarplus/1017485
which I actively monitor. Enjoy! ~ForeverHD June 2025

--]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PG = player:WaitForChild("PlayerGui")

local selectionGui: ScreenGui, settingsGui: ScreenGui, creditsGui: ScreenGui

local function onCharacterAdded()
	selectionGui = PG:WaitForChild("SelectionGui")
	settingsGui = PG:WaitForChild("Settings")
	creditsGui = PG:WaitForChild("Credits")
end

if player.Character then onCharacterAdded(player.Character) end
player.CharacterAdded:Connect(onCharacterAdded)

local container  = script.Parent
local Icon = require(container.Icon)

local function openSwitch()
	if player:HasTag("StartingScreenActive") then return end
	selectionGui.Enabled = true
end

local function openSettings()
	if player:HasTag("StartingScreenActive") then return end
	settingsGui.Enabled = true
end

local function openCredits()
	if player:HasTag("StartingScreenActive") then return end
	creditsGui.Enabled = true
end

local menu = Icon.new()
	:setName("Menu")
	:setLabel("Menu")
	:modifyTheme({"Dropdown", "MaxIcons", 3})
	:modifyChildTheme({"Widget", "MinimumWidth", 100})
	:setDropdown({
		Icon.new()
			:setName("Crusaders")
			:setLabel("Crusaders")
			:bindEvent("selected", openSwitch)
			:oneClick(),
		Icon.new()
			:setName("Settings")
			:setLabel("Settings")
			:bindEvent("selected", openSettings)
			:oneClick(),
		Icon.new()
			:setName("Credits")
			:setLabel("Credits")
			:bindEvent("selected", openCredits)
			:oneClick()
	})