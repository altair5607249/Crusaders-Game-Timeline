local RS = game:GetService("ReplicatedStorage")
local knockback = RS.Remotes.Knockback
local toggleAnim = RS.Remotes.KnockbackAnim

local knockbackManager = {}

function knockbackManager.Eval(player: Player, targetPlr: Player, targetRoot: Part, attributes: {Instance})
	knockback:FireClient(player, attributes, targetRoot)
	if targetPlr then toggleAnim:FireClient(targetPlr, attributes) end
	
	--[[local frames = 0
	repeat 
		task.wait() 
		frames += 1

		if not (targetRoot and targetRoot.Parent) then break end
		if frames > 90 then break end
		
	until Vector3.new(targetRoot.AssemblyLinearVelocity.X, 0, targetRoot.AssemblyLinearVelocity.Z).Magnitude < 2 and frames > 10]]
end

return knockbackManager