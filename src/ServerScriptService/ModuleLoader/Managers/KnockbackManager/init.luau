local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local spacing = require(RS.UniversalModules.Space)

local knockback = RS.Remotes.Knockback

local knockbackManager = {}

local kbSpecs = {
	light = 0.1,
	medium = 0.3,
	heavy = 0.5,
	reverse = 0.25
}

function knockbackManager.Eval(player: Player, targetPlr: Player, targetRoot: Part, atktype: string)
	local root: Part = player.Character:WaitForChild("HumanoidRootPart")
	
	local attackerRoot: Part = player.Character:FindFirstChild("HumanoidRootPart")

	local mass = targetRoot.AssemblyMass
	local velocity = spacing.Knockback(attackerRoot, targetRoot, atktype)
	local momentum = mass * velocity --p = m*v
	
	local targetChar = targetRoot.Parent
	
	if targetPlr then
		knockback:FireClient(targetPlr, atktype, momentum)
	else --for dummies
		if atktype then
			local targetHum: Humanoid = targetChar:WaitForChild("Humanoid")
			local animator: Animator = targetHum:WaitForChild("Animator")
			
			local animTrack = animator:LoadAnimation(script.Animations[atktype])
			
			animTrack:Play()
			animTrack.Ended:Connect(function()
				animTrack:Destroy()
			end)
		end
	end
	
	local duration = kbSpecs[atktype]
	
	if not targetChar:GetAttribute("RagdollTime") then 
		targetChar:SetAttribute("RagdollTime", duration) 
	else
		duration += targetChar:GetAttribute("RagdollTime")
		targetChar:SetAttribute("RagdollTime", duration)
	end
	
	if not targetChar:GetAttribute("RagdollExt") then
		knockback:FireClient(player, atktype, momentum, targetRoot)
		
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