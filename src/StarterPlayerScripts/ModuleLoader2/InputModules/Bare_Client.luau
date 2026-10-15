local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")

local bareStyle = {}

function bareStyle:UM1()
	print("Kaboom!")
end

function bareStyle.Placeholder()
	print("BareStyle Move 1")
end

local IASHandler = require(player.PlayerScripts.ModuleLoader2.Handlers.IASHandler)

local weaponSpecs = { --it's so peak... so clean..!
	{name = "Move1", callback = function() bareStyle.Placeholder() end}
}

function bareStyle.IAS()
	local context = RS.InputContexts.BareContext

	IASHandler.ActReg(context, weaponSpecs)
end

return bareStyle