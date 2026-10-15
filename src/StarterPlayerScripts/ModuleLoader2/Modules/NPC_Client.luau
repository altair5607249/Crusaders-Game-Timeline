local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPC = {}

function NPC.new(object)
	print("Client NPC:", object)
	
	local root = object:WaitForChild("HumanoidRootPart")
	local originalPosition = root.Position
	local myHumanoid = object:WaitForChild("Humanoid")
	
	local animationScript = ReplicatedStorage:WaitForChild("Animate"):Clone()
	animationScript.Parent = object
	animationScript.Enabled = true
	
	ReplicatedStorage.Remotes.PlayAnimation.OnClientEvent:Connect(function(humanoid, animationId)
		if humanoid ~= myHumanoid then return end
		
		local animObject = Instance.new("Animation")
		animObject.AnimationId = animationId
		local anim = humanoid.Animator:LoadAnimation(animObject)
		anim:Play()
	end)
end

return NPC