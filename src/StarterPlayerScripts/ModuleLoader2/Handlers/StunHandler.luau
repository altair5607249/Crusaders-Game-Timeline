local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")

local IAS = require(RS.UniversalModules.Energy)

local stun = {}

function stun:Toggle(atktype: string, switch: boolean) --play an animation with atktype whenever ready to integrate
	if switch then
		IAS:Disconnect(IAS:GetActiveContexts())
	else
		IAS:Init(IAS:GetInputModules())
	end
end

return stun