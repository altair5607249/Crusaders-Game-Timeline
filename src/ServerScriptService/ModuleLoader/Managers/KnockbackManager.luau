local RS = game:GetService("ReplicatedStorage")

local spacing = require(RS.UniversalModules.Space)

local knockback = RS.Remotes.Knockback

local knockbackManager = {}

function knockbackManager.Eval(player: Player, targetPlr: Player, targetRoot: Part, atktype: string)
	local root: Part = player.Character:WaitForChild("HumanoidRootPart")
	
	local attackerRoot = player.Character:FindFirstChild("HumanoidRootPart")

	local velocity = spacing.Knockback(attackerRoot, targetRoot, atktype)
	local mass = targetRoot.AssemblyMass
	local momentum = mass * velocity

	print(momentum)
	
	targetRoot.Parent:AddTag("RagdollActive")
	
	knockback:FireClient(player, nil, momentum, targetRoot)
	if targetPlr then
		knockback:FireClient(targetPlr, atktype, momentum)
	end
	
	local frames = 0
	
	task.spawn(function()
		repeat 
			task.wait() 
			frames += 1
			if not (targetRoot and targetRoot.Parent) then break end
			if frames > 90 then break end
		until (Vector3.new(targetRoot.AssemblyLinearVelocity.X, 0, targetRoot.AssemblyLinearVelocity.Z).Magnitude < 1 and frames > 10) or not targetRoot
		
		targetRoot.Parent:RemoveTag("RagdollActive")
		if targetPlr then 
			targetPlr:SetAttribute("lastServerPos", targetRoot.Position)
		end
	end)
end

return knockbackManager