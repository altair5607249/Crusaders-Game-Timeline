local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local mapManager = require(SSS.ModuleLoader.Managers.MapManager)
local registry = require(script.Parent.Permissions)

local receiver = RS.Remotes.Admin

local function findPlayer(playerName: string)
	for i, player: Player in ipairs(Players:GetChildren()) do
		if player.Name == playerName then return true, player end
	end
end

local adminCmds = {}

local function findModel(modelName: string)
	for i, model: Model in ipairs(workspace:GetDescendants()) do
		if model.Name == modelName then return true, model end
	end
end

receiver.OnServerEvent:Connect(function(admin, protocol: string, subject: string)
	local result: boolean, title1: string, title2: string = registry:GetPerms(admin)
	local command = adminCmds[protocol]
	
	if not result then warn(admin.Name, "is attempting to access restricted protocols!") return end
	if not command then warn("Protocol:", protocol, "does not exist.") return end
	
	command(subject, admin, title1) --elite syntax right here; luau's vm stack approach ignores extra/unnecessary argumetns
end)

function adminCmds.Collapse(playerName: string, admin: Player, title1: string)
	print("Protocol: Collapse")
	
	if title1 ~= "Principalities" or title1 ~= "Regulators" then return end
	
	local result: boolean, player: Player = findPlayer(playerName)
	
	if not result then warn(playerName, "not found") return end
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	
	hum.Health = 0
end

function adminCmds.Preserve(playerName: string, admin: Player, title1: string)
	print("Protocol: Preserve")
	
	local result: boolean, player: Player = findPlayer(playerName)

	if not result then warn(playerName, "not found") return end

	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")

	hum:AddTag("Blessed") --id rather not clash with the Immortal tag's dynamism with certain attacks that manipulate i-frames
end

function adminCmds.Transfer(mapName: string)
	print("Protocol: Transfer")
	
	mapManager.SetMap(mapName)
end

function adminCmds.Teleport(modelName: string, admin: Player)
	print("Protocol: Teleport")
	
	local result: boolean, model: Model = findModel(modelName)
	
	if not result then warn(modelName, "not found") return end
	
	local char: Model = admin.Character or admin.CharacterAdded:Wait()
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	root.Position = model:FindFirstChildWhichIsA("Part").Position
	
	admin:SetAttribute("lastServerPos", root.Position) --prevents rubberbanding
end

return adminCmds