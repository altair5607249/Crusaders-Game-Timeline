local RS = game:GetService("ReplicatedStorage")
local timing = require(RS.UniversalModules.Time)

local RM4 = {}

function RM4:Trigger(player: Player)
	print("rm4")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	
	local duration = timing.GetValue("Redd", "Bare", 3, 4) - timing.GetValue("Redd", "Bare", 1, 4)
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local delayTime = duration + health^2/(240*maxHealth)
	
	hum:AddTag("Immortal")
	task.delay(delayTime, function()
		hum:RemoveTag("Immortal")
	end)
end

return RM4