local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local mapManager = require(SSS.ModuleLoader.Managers.MapManager)
local registry = require(script.Parent.Permissions)

local receiver = RS.Remotes.Admin

local function findPlayer(playerName: string)
	for i, player: Player in ipairs(Players:GetPlayers()) do
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
	local rank: string, title: number, clearance: number = registry:GetPerms(admin, false)
	local command = adminCmds[protocol]
	
	if not rank then warn(admin.Name, "is attempting to access restricted protocols!") return end
	if not command then warn("Protocol:", protocol, "does not exist.") return end
	
	command(subject, admin, clearance) --elite syntax right here; luau's vm stack approach ignores extra/unnecessary argumetns
end)

function adminCmds.Collapse(playerName: string, admin: Player, clearance: number)
	print("Protocol: Collapse")
	
	if clearance < 8 then return end --only Regulators can manipulate something so sacred as death
	
	local result: boolean, player: Player = findPlayer(playerName)
	
	if not result then warn(playerName, "not found") return end
	
	local _, _, targetClearance: number = registry:GetPerms(player, false)
	if targetClearance > clearance then return end --cannot insta-kill players with more authority than you
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	
	hum.Health = 0
end

function adminCmds.Preserve(playerName: string, admin: Player, clearance: number)
	print("Protocol: Preserve")
	
	if clearance < 8 then return end --only Regulators can manipulate something so sacred as life
	
	local result: boolean, player: Player = findPlayer(playerName)

	if not result then warn(playerName, "not found") return end

	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")

	hum:AddTag("Blessed") --id rather not clash with the Immortal tag's dynamism with certain attacks that manipulate i-frames
end

function adminCmds.Transfer(mapName: string, admin: Player, clearance: number)
	print("Protocol: Transfer")
	
	if clearance < 6 then return end --Regalia and above can forcibly change the map selection
	
	mapManager.SetMap(mapName)
end

function adminCmds.Teleport(modelName: string, admin: Player, clearance: number)
	print("Protocol: Teleport")
	
	if clearance < 4 then return end
	
	local result: boolean, model: Model = findModel(modelName)
	
	if not result then warn(modelName, "not found") return end
	
	local char: Model = admin.Character or admin.CharacterAdded:Wait()
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	root:PivotTo(model:FindFirstChildWhichIsA("Part").CFrame)
	
	admin:SetAttribute("lastServerPos", root.Position) --prevents rubberbanding
end

return adminCmds