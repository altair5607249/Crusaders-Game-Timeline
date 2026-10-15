local InputManager = {}

local RS = game:GetService("ReplicatedStorage")
local contexts = RS:WaitForChild("InputContexts")

local connections = {}

function InputManager.ActReg(context: InputContext, specs: {any}) --my hail mary
	for i, spec in ipairs(specs) do
		local action = context:FindFirstChild(spec.name)
		
		if action and action:IsA("InputAction") then
			local connection = action.Pressed:Connect(function()
				if spec.callback then
					spec.callback(true) --arguing a boolean optional in the rare case that it is needed; usually for held actions
				end
			end)
			table.insert(connections, connection)
			--only used in the case that the boolean is necessary
			if action:HasTag("hold") then
				local connectionR = action.Released:Connect(function()
					spec.callback(false)
				end)
				table.insert(connections, connectionR)
			end
		else
			warn(spec.name .. " does not exist within " .. context.Name)
		end
	end
end

function InputManager:DisconnectAll()
	for i, connection in ipairs(connections) do
		if connection then connection:Disconnect() end
	end
	table.clear(connections)
end

return InputManager