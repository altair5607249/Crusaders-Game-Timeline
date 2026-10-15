local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

repeat task.wait() until player and camera

local char = player.Character or player.CharacterAdded:Wait()
local head = char:WaitForChild("Head")

camera.CameraSubject = head