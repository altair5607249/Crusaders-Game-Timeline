--handles all of the player input
local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local plrGui = player:WaitForChild("PlayerGui")
local modules = player.PlayerScripts.ModuleLoader2.InputModules

local connections = {}
local gates = {}

local IAS = {}

function IAS.ActReg(context: InputContext, specs: {any})
	for i, spec in ipairs(specs) do
		local action: InputAction? = context:FindFirstChild(spec.name)

		if action and action:IsA("InputAction") then

			local connection = action.Pressed:Connect(function()
				if spec.callback then
					spec.callback(true)
				end
			end)
			connections[context] = connections[context] or {}
			table.insert(connections[context], connection)

			if action:HasTag("hold") then
				local connectionR = action.Released:Connect(function()
					spec.callback(false)
				end)
				table.insert(connections[context], connectionR)
			end

			IAS.MapToGui(action, context, spec) --this should be rerun alongside the keyboard & mouse controls

			if not gates[action] then --prevents duping of listeners/sentinels
				gates[action] = true
				IAS.SetSentinels(action, context, spec)
			end

			context:AddTag("Active")
		else
			warn(spec.name .. " does not exist within " .. context.Name)
		end
	end
end

--yes, the long awaited mobile support is here
function IAS.MapToGui(action: InputAction, context: InputContext, spec: any)
	local gui: ScreenGui = plrGui:WaitForChild("Gameplay")
	local moveset: Frame = gui:WaitForChild("Moveset")

	for i, button: GuiButton in ipairs(CS:GetTagged(action.Name)) do
		IAS.Mapping(button, action, context, spec, moveset)
	end
end

function IAS.Mapping(button: GuiButton, action: InputAction, context: InputContext, spec: any, moveset: Frame)
	if not button:IsDescendantOf(moveset) then return end

	local mobileBinding: InputBinding = action:FindFirstChild("InputBinding")

	if not mobileBinding then warn("Input binding not found within " .. action.Name) return end

	button.Interactable = true
	button.Selectable = true
	mobileBinding.UIButton = button
	
	local touchConn = nil
	if not action:HasTag("hold") then --for normal, one-and-done input actions
		touchConn = button.Activated:Connect(function()
			spec.callback()
		end)
	else --for continuous input actions (e.g., sprinting)
		touchConn = button.InputBegan:Connect(function()
			spec.callback(true)
		end)
		local touchConnR = button.InputEnded:Connect(function()
			spec.callback(false)
		end)
		table.insert(connections[context], touchConnR)
	end
	table.insert(connections[context], touchConn)
end

--listeners for resetting input-to-gui mapping
function IAS.SetSentinels(action: InputAction, context: InputContext, spec: any)
	local gui: ScreenGui = plrGui:WaitForChild("Gameplay")
	local moveset: Frame = gui:WaitForChild("Moveset")

	CS:GetInstanceAddedSignal(action.Name):Connect(function(instance: Instance)
		if instance:IsA("GuiButton") then
			task.defer(function()
				gui = plrGui:FindFirstChild("Gameplay")
				moveset = gui and gui:FindFirstChild("Moveset")

				if moveset and instance:IsDescendantOf(moveset) and context:HasTag("Active") then
					IAS.Mapping(instance, action, context, spec, moveset)
				end
			end)
		end
	end)
end

function IAS:Init(mods: {Instance})
	for i, mod in ipairs(mods) do
		local class = require(modules:FindFirstChild(mod.Name))
		class.IAS()
	end
end

function IAS:Disconnect(contexts: {Instance})
	for i, context in ipairs(contexts) do
		for j, connection in pairs(connections[context]) do
			if connection then connection:Disconnect() end
		end
		table.clear(connections[context])
		context:RemoveTag("Active")
	end
end

function IAS:GetActiveContexts()
	local activeContexts = {}

	for i, context in ipairs(RS.InputContexts:GetChildren()) do
		if context:HasTag("Active") then
			table.insert(activeContexts, context)
		end
	end

	return activeContexts
end

function IAS:GetInputModules()
	local inputModules = {}

	for i, mod in ipairs(modules:GetChildren()) do
		table.insert(inputModules, mod)
	end

	return inputModules
end

return IAS