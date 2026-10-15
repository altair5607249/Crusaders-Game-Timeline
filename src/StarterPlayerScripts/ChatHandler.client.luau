local RS = game:GetService("ReplicatedStorage")
local TCS = game:GetService("TextChatService")

local receiver = RS.Remotes.Announcement

receiver.OnClientEvent:Connect(function(message: string, modifier: string)
	local channel: TextChannel = TCS.TextChannels:FindFirstChild("RBXSystem")
	
	if channel then 
		channel:DisplaySystemMessage(string.format(modifier, message))
	end
end)