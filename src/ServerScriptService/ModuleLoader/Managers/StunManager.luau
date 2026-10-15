local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local toggle = RS.Remotes.ToggleStun

local CMS = require(SSS.ModuleLoader.Matter)
local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local stunManager = {}

function stunManager.Eval(player: Player, atktype: string, duration: number) --can be called instead of DurReg if caller already has a duration in mind
	if player == nil then return end
	
	if not CMS:GetAttribute(player, "Stunned") then
		CMS:SetAttribute(player, "Stunned", true)
		CMS:SetAttribute(player, "StunTime", duration)
		
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:FindFirstChild("Humanoid")
		hum.WalkSpeed = 0
		hum.JumpPower = 0
	else
		duration += CMS:GetAttribute(player, "StunTime")
		CMS:SetAttribute(player, "StunTime", duration)
	end
	
	CMS:SetAttribute(player, "StunType", atktype) --stores the most recent atktype
	
	if not CMS:GetAttribute(player, "StunExt") then
		toggle:FireClient(player, atktype, true)
		
		local initialStun = tick()
		task.spawn(function()
			CMS:SetAttribute(player, "StunExt", true)
			repeat task.wait() until (tick() - initialStun >= CMS:GetAttribute(player, "StunTime")) or player.Parent ~= Players --repeats until change in time outweighs the duration
			
			if player.Parent ~= Players then return end
			
			toggle:FireClient(player, CMS:GetAttribute(player, "StunType"), false)
			
			CMS:SetAttribute(player, "Stunned", false)
			CMS:SetAttribute(player, "StunTime", 0)
			CMS:SetAttribute(player, "StunExt", false)

			local crusader = CMS:GetAttribute(player, "Crusader")
			local char = player.Character
			local hum = char:WaitForChild("Humanoid")
			hum.WalkSpeed = spacing.GetValue(crusader, 1)
			hum.JumpPower = spacing.GetValue(crusader, 3)
		end)
	end
end

function stunManager:DurReg(player: Player, atktype: string, style: string, ID: number)
	if player == nil then return end
	local char = player.Character or player.CharacterAdded:Wait()
	local duration = timing.GetValue(CMS:GetAttribute(player, "Crusader"), style, 4, ID)
	stunManager.Eval(player, atktype, duration)
end

return stunManager