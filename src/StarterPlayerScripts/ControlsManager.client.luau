local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PS = player:WaitForChild("PlayerScripts")
local PM = require(PS:WaitForChild("PlayerModule"))
local controls = PM:GetControls()
local RS = game:GetService("ReplicatedStorage")
local remotes = RS:WaitForChild("Remotes")
local controller = remotes:WaitForChild("ControlsClient")

controls:Disable()

controller.OnClientEvent:Connect(function(switch)
	if switch then
		controls:Enable()
	else
		controls:Disable()
	end
end)