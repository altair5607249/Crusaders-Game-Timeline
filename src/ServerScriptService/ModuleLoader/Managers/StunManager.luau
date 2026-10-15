local RS = game:GetService("ReplicatedStorage")
local toggle = RS.Remotes.ToggleStun

local stunSpecs = {
	light = 1,
	medium = 1.75,
	heavy = 2.5
}

local stunManager = {}

function stunManager.Eval(player: Player, duration: number)
	local char = player.Character or player.CharacterAdded:Wait()
	local stunned = char:GetAttribute("Stunned")
	if not stunned then char:SetAttribute("Stunned", true) end
	toggle:FireClient(player, duration)
end

function stunManager:DurReg(player: Player, atkType: string)
	if player == nil then return end
	local duration = stunSpecs[atkType]
	stunManager.Eval(player, duration)
end

return stunManager