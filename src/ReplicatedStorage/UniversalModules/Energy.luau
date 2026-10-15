local RS = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local modules = player.PlayerScripts.ModuleLoader2.InputModules
local connections = {}

local InputActionSystem = {}

function InputActionSystem.ActReg(context: InputContext, specs: {any}) --my hail mary
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
			context:AddTag("Active")
		else
			warn(spec.name .. " does not exist within " .. context.Name)
		end
	end
end

function InputActionSystem:Init(mods: {Instance})
	for i, mod in ipairs(mods) do
		local class = require(modules:FindFirstChild(mod.Name))
		class.IAS()
	end
end

function InputActionSystem:Disconnect(contexts: {Instance})
	for i, context in ipairs(contexts) do
		for j, connection in pairs(connections[context]) do
			if connection then connection:Disconnect() end
		end
		table.clear(connections[context])
		context:RemoveTag("Active")
	end
end

function InputActionSystem:GetActiveContexts()
	local activeContexts = {}
	
	for i, context in ipairs(RS.InputContexts:GetChildren()) do
		if context:HasTag("Active") then
			table.insert(activeContexts, context)
		end
	end
	
	return activeContexts
end

function InputActionSystem:GetInputModules()
	local inputModules = {}
	
	for i, mod in modules:GetChildren() do
		if mod ~= modules.Weapon_Client then
			table.insert(inputModules, mod)
		end
	end
	
	return inputModules
end

return InputActionSystem