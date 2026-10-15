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
	
	local crusader = player:GetAttribute("Crusader")
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	
	if not player:GetAttribute("Stunned") or player:GetAttribute("Stunned") == 0 then
		if char:HasTag("LoadingAttack") and atktype == "heavy" then char:AddTag("CancellingAttack") end
		
		player:SetAttribute("Stunned", true)
		player:SetAttribute("StunTime", duration)

		local hum: Humanoid = char:FindFirstChild("Humanoid")
		hum.WalkSpeed = 0
		hum.JumpPower = 0
	else
		duration += player:GetAttribute("StunTime")
		player:SetAttribute("StunTime", duration)
	end
	
	if player:GetAttribute("StunType") then player:SetAttribute("StunType", atktype) end --stores the most recent valid atktype
	
	local previousSource = player:GetAttribute("StunSource")
	if not previousSource or stunPriority[source] > stunPriority[previousSource] then player:SetAttribute("StunSource", source) end
	
	if not player:GetAttribute("StunExt") then
		if atktype then toggle:FireClient(player, atktype, true) end
		
		local initialStun = os.clock()
		task.spawn(function()
			player:SetAttribute("StunExt", true)
			
			if not char:HasTag("Dashing") then hum.AutoRotate = false end
			
			repeat task.wait() until (os.clock() - initialStun >= player:GetAttribute("StunTime")) or player.Parent ~= Players --repeats until change in time outweighs the duration
			
			if player.Parent ~= Players then return end
			
			if player:GetAttribute("StunType") then toggle:FireClient(player, player:GetAttribute("StunType"), false) end
			
			player:SetAttribute("Stunned", false)
			player:SetAttribute("StunTime", 0)
			player:SetAttribute("StunExt", false)
			player:SetAttribute("StunSource", nil)

			hum.WalkSpeed = spacing.GetValue(crusader, 1)
			hum.JumpPower = spacing.GetValue(crusader, 3)
			hum.AutoRotate = true
		end)
	end
end

function stunManager:DurReg(player: Player, targetPlayer: Player, atktype: string, style: string, ID: number, source: string)
	if player == nil then return end
	local duration = timing.GetValue(player:GetAttribute("Crusader"), style, 4, ID)
	stunManager.Eval(targetPlayer, atktype, duration, source)
end

return stunManager