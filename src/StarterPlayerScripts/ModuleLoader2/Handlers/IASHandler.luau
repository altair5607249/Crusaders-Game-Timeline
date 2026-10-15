local player = game:GetService("Players").LocalPlayer
local modules = player.PlayerScripts.ModuleLoader2.InputModules

local connections = {}

local InputManager = {}

function InputManager.ActReg(context: InputContext, specs: {any}) --my hail mary
	for i, spec in ipairs(specs) do
		local action = context:FindFirstChild(spec.name)
		
		if action and action:IsA("InputAction") then
			local connection = action.Pressed:Connect(function()
				if spec.callback then
					spec.callback(true) --arguing a boolean optional in the rare case that it is needed; usually for held actions
				end
			end)
			connections[context] = connections[context] or {}
			table.insert(connections[context], connection)
			--only used in the case that the boolean is necessary
			if action:HasTag("hold") then
				local connectionR = action.Released:Connect(function()
					spec.callback(false)
				end)
				table.insert(connections[context], connectionR)
			end
		else
			warn(spec.name .. " does not exist within " .. context.Name)
		end
	end
end

function InputManager:Init(mods: {Instance})
	for i, mod in ipairs(mods) do
		local class = require(modules:FindFirstChild(mod.Name))
		class.IAS()
	end
end

function InputManager:Disconnect(classes: {Instance})
	for i, class in ipairs(classes) do
		for j, connection in pairs(connections[class]) do
			if connection then connection:Disconnect() end
		end
		table.clear(connections[class])
	end
end

return InputManager