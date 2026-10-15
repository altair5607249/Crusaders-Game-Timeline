local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local spacing = require(RS.UniversalModules.Space)

local knockback = RS.Remotes.Knockback

local knockbackManager = {}

local kbSpecs = {
	light = 0.2,
	medium = 0.3,
	heavy = 0.5,
	reverse = 0.25
}

function knockbackManager.Eval(player: Player, targetPlr: Player, targetRoot: Part, atktype: string)
	local root: Part = player.Character:WaitForChild("HumanoidRootPart")
	
	local attackerRoot = player.Character:FindFirstChild("HumanoidRootPart")

	local velocity = spacing.Knockback(attackerRoot, targetRoot, atktype)
	local mass = targetRoot.AssemblyMass
	local momentum = mass * velocity
	
	local targetChar = targetRoot.Parent
	
	if targetPlr then
		knockback:FireClient(targetPlr, atktype, momentum)
	end
	
	local duration = kbSpecs[atktype]
	
	if not targetChar:GetAttribute("RagdollTime") then 
		targetChar:SetAttribute("RagdollTime", duration) 
	else
		duration += targetChar:GetAttribute("RagdollTime")
		targetChar:SetAttribute("RagdollTime", duration)
	end
	
	if not targetChar:GetAttribute("RagdollExt") then
		knockback:FireClient(player, nil, momentum, targetRoot)
		
		local initialTime = os.clock()
		task.spawn(function()
			targetChar:SetAttribute("RagdollExt", true)
			
			targetChar:AddTag("RagdollActive")
			
			repeat task.wait() until (os.clock() - initialTime >= targetChar:GetAttribute("RagdollTime")) or player.Parent ~= Players or not targetRoot
			
			targetChar:SetAttribute("RagdollTime", nil)
			targetChar:SetAttribute("RagdollExt", nil)
			
			targetChar:RemoveTag("RagdollActive")
			
			if targetPlr then 
				targetPlr:SetAttribute("lastServerPos", targetRoot.Position)
			end
		end)
	end
end

return knockbackManager