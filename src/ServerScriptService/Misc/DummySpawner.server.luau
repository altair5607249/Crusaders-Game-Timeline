local CS = game:GetService("CollectionService")
local SS = game:GetService("ServerStorage")

local dummies = {}
local templates = SS["Templates (DO NOT QUERY)"]:GetChildren()

for i, template in ipairs(templates) do
	local name = template.Name
	dummies[name] = template
end

local function cleanup(dummy: Model)
	local hum: Humanoid = dummy:WaitForChild("Humanoid")
	
	hum.Died:Connect(function()
		dummy:Destroy()
	end)
	
	for i, part in ipairs(dummy:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Player"
		end
	end
end


for i, object in ipairs(workspace:GetDescendants()) do --initial setup
	if object:HasTag("Dummy") then
		cleanup(object)
	end
end

workspace.DescendantAdded:Connect(function(object) --for future dummies
	if object:HasTag("Dummy") then
		cleanup(object)
	end
end)

workspace.DescendantRemoving:Connect(function(object)
	if object:HasTag("Dummy") then
		if not workspace.Winterness then repeat task.wait() until workspace.Winterness end
		
		local name = object.Name
		local clone = dummies[name]:Clone()
		clone.Parent = workspace.Winterness.Dummies
		clone:AddTag("Dummy")
	end
end)
