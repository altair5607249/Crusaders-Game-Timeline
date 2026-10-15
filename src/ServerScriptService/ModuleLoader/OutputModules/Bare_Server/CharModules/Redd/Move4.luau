local RM4 = {}

function RM4:Trigger(player: Player)
	print("rm4")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	
	local duration = 1.25
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local delayTime = duration + health^2/(240*maxHealth)
	
	hum:SetAttribute("Immortal", true)
	task.delay(delayTime, function()
		hum:SetAttribute("Immortal", nil)
	end)
end

return RM4