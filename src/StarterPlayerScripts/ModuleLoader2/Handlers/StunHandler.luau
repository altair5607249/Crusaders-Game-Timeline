local player = game:GetService("Players").LocalPlayer
local IAS = require(player.PlayerScripts.Energy)

local stun = {}

--this is idempotent due to the immediate client-side application of the character tag "ActiveInput" (remove this at your own risk)
function stun:Toggle(atktype: string, switch: boolean) --play an animation with atktype (unless atktype is nil)
	if switch then
		IAS:Disconnect(IAS:GetActiveContexts())
	else
		IAS:Init(IAS:GetInputModules())
	end
end

return stun