local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local toggle = RS.Remotes.ToggleStun

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local stunPriority = {
	Recovery = 1,
	Hit = 2
}

local stunManager = {}

function stunManager.Eval(player: Player, atktype: string, duration: number, source: string) --can be called instead of DurReg if caller already has a duration in mind
	if player == nil then return end
	
	if not player:GetAttribute("Stunned") then
		player:SetAttribute("Stunned", true)
		player:SetAttribute("StunTime", duration)
		
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:FindFirstChild("Humanoid")
		hum.WalkSpeed = 0
		hum.JumpPower = 0
	else
		duration += player:GetAttribute("StunTime")
		player:SetAttribute("StunTime", duration)
	end
	
	player:SetAttribute("StunType", atktype) --stores the most recent atktype
	
	local previousSource = player:GetAttribute("StunSource")
	if not previousSource or stunPriority[source] > stunPriority[previousSource] then player:SetAttribute("StunSource", source) end
	
	if not player:GetAttribute("StunExt") then
		toggle:FireClient(player, atktype, true)
		
		local initialStun = tick()
		task.spawn(function()
			player:SetAttribute("StunExt", true)
			repeat task.wait() until (tick() - initialStun >= player:GetAttribute("StunTime")) or player.Parent ~= Players --repeats until change in time outweighs the duration
			
			if player.Parent ~= Players then return end
			
			toggle:FireClient(player, player:GetAttribute("StunType"), false)
			
			player:SetAttribute("Stunned", false)
			player:SetAttribute("StunTime", 0)
			player:SetAttribute("StunExt", false)
			player:SetAttribute("StunSource", nil)

			local crusader = player:GetAttribute("Crusader")
			local char = player.Character
			local hum = char:WaitForChild("Humanoid")
			hum.WalkSpeed = spacing.GetValue(crusader, 1)
			hum.JumpPower = spacing.GetValue(crusader, 3)
		end)
	end
end

function stunManager:DurReg(player: Player, atktype: string, style: string, ID: number, source: string)
	if player == nil then return end
	local char = player.Character or player.CharacterAdded:Wait()
	local duration = timing.GetValue(player:GetAttribute("Crusader"), style, 4, ID)
	stunManager.Eval(player, atktype, duration, source)
end

return stunManager