local IAS = require(script.Parent.IASHandler)
local player = game:GetService("Players").LocalPlayer
local contexts = game:GetService("ReplicatedStorage").InputContexts:GetChildren()
local modules = player.PlayerScripts.ModuleLoader2.InputModules:GetChildren()

local stun = {}

function stun:Toggle(duration: number)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	
	local health = hum.Health --health snapshot
	
	hum.WalkSpeed = 0
	hum.JumpPower = 0
	IAS:Disconnect(contexts)
	
	task.delay(duration, function()
		if hum.Health < health then return end --if their health has decreased since the beginning of the stun, then a combo is inferred
		char:SetAttribute("Stunned", false)
		IAS:Init(modules)
		hum.WalkSpeed = char:GetAttribute("bspd")
		hum.JumpPower = char:GetAttribute("jump")
	end)
end

return stun