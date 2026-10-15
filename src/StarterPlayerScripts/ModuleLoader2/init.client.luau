local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

for i, module in script.Modules:GetChildren() do
	local class = require(module)
	local name = module.Name

	local suffix = RunService:IsServer() and "_Server" or "_Client"
	local tagName = string.sub(module.Name, 1, -#suffix - 1)

	CollectionService:GetInstanceAddedSignal(tagName):Connect(class.new)

	for i, object in CollectionService:GetTagged(tagName) do
		if object:FindFirstAncestorOfClass("ReplicatedStorage") then continue end
		class.new(object)
	end
	
	if name == "M1_Client" then
		print("Success")
		UIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				class.ClickEvent()
			end
		end)
	end
end