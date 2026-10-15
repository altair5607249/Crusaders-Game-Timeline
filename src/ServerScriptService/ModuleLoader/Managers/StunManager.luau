local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local toggle = RS.Remotes.ToggleStun
local mouselock = RS.Remotes.Mouselock

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local stunPriority = {
	Recovery = 1,
	Hit = 2
}

local stunManager = {}

function stunManager.Eval(player: Player, atktype: string, duration: number, source: string) --can be called instead of DurReg if caller already has a duration in mind
	if player == nil then return end
	
	local crusader = player:GetAttribute("Crusader")
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	
	if not char:GetAttribute("Stunned") then
		if char:HasTag("LoadingAttack") and atktype == "heavy" then char:AddTag("CancellingAttack") end
		
		char:SetAttribute("Stunned", true)
		char:SetAttribute("StunTime", duration)

		local hum: Humanoid = char:FindFirstChild("Humanoid")
		hum.WalkSpeed = 0
	else
		if char:GetAttribute("StunTime") > 4 then return end --stun time is capped :)
		duration += char:GetAttribute("StunTime")
		char:SetAttribute("StunTime", duration)
	end
	
	if atktype then char:SetAttribute("StunType", atktype) end --stores the most recent valid atktype
	
	local previousSource = char:GetAttribute("StunSource")
	if not previousSource or stunPriority[source] > stunPriority[previousSource] then char:SetAttribute("StunSource", source) end
	
	if not char:GetAttribute("StunExt") then
		if atktype then toggle:FireClient(player, atktype, true) end
		
		local initialStun = os.clock()
		task.spawn(function()
			char:SetAttribute("StunExt", true)
			
			repeat task.wait() until (os.clock() - initialStun >= char:GetAttribute("StunTime")) or player.Parent ~= Players or not hum
			
			if player.Parent ~= Players then return end
			
			if char:GetAttribute("StunType") then toggle:FireClient(player, char:GetAttribute("StunType"), false) end
			
			char:SetAttribute("Stunned", false)
			char:SetAttribute("StunTime", nil)
			char:SetAttribute("StunExt", nil)
			char:SetAttribute("StunSource", nil)
			char:SetAttribute("StunType", nil)

			hum.WalkSpeed = spacing.GetValue(crusader, 1)
		end)
	end
end

function stunManager:DurReg(player: Player, targetPlayer: Player, atktype: string, style: string, ID: number, source: string)
	if player == nil then return end
	local duration = timing.GetValue(player:GetAttribute("Crusader"), style, 4, ID)
	stunManager.Eval(targetPlayer, atktype, duration, source)
end

return stunManager