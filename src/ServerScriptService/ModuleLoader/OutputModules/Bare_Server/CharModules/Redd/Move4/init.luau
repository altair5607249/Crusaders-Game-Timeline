local RS = game:GetService("ReplicatedStorage")

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local RM4 = {}

function RM4:Trigger(player: Player)
	print("rm4")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	
	char:AddTag("SolDisabled")
	
	if char:HasTag("HitFinished") then char:RemoveTag("HitFinished") end
	
	local duration = timing.GetValue("Redd", "Bare", 3, 4) - timing.GetValue("Redd", "Bare", 1, 4)
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	hum.WalkSpeed = 0
	
	local highlight = Instance.new("Highlight")
	highlight.Parent = char
	
	local delayTime = duration + health^2/(240*maxHealth)
	
	hum:AddTag("Immortal")
	task.delay(delayTime, function()
		char:RemoveTag("SolDisabled")
		
		hum.WalkSpeed = spacing.GetValue("Redd", 1)
		
		hum:RemoveTag("Immortal")
		highlight:Destroy()
		
		char:AddTag("HitFinished")
		
		task.delay(0.1, function()
			char:RemoveTag("HitFinished")
		end)
	end)
	
	--copy and pastable move sfx code
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
end

return RM4