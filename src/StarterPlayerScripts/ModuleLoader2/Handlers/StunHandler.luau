local player = game:GetService("Players").LocalPlayer
local IAS = require(player.PlayerScripts.Energy)

local stunned = false

local stun = {}

function stun:Toggle(atktype: string, switch: boolean) --play an animation with atktype whenever ready to integrate
	if switch then
		IAS:Disconnect(IAS:GetActiveContexts())
	else
		IAS:Init(IAS:GetInputModules())
	end
	stunned = switch
end

function stun:GetStunState() --not used by the server
	return stunned
end

return stun