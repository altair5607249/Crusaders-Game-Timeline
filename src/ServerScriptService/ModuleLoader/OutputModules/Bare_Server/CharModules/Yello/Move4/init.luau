local RS = game:GetService("ReplicatedStorage")

local YM4 = {}

function YM4:Trigger(player)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	RS.Remotes.ToggleDash:FireClient(player, 7, root.CFrame.LookVector, script.DashForward, true)
end

return YM4