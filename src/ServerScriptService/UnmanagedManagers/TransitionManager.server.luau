local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local transClient = remotes.TransitionClient
local transServer = remotes.TransitionServer
local loadingServer = remotes.LoadingServer
local loadingClient = remotes.LoadingClient

transServer.OnServerEvent:Connect(function(plr)
	transClient:FireClient(plr)
end)

loadingServer.OnServerEvent:Connect(function(plr)
	loadingClient:FireClient(plr)
end)