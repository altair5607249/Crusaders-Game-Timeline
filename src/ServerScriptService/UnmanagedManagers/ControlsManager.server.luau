local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local controllerClient = remotes.ControlsClient
local controllerServer = remotes.ControlsServer

controllerServer.OnServerEvent:Connect(function(plr, switch)
	controllerClient:FireClient(plr, switch)
end)