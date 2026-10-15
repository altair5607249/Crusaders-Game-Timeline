--this manages the damage & timing

local dmgManager = require(script.Parent.Parent.Managers.DamageManager)

local m1Manager = {}

local db = false

function m1Manager.Action(player: Player, count: number)
	if not db then
		db = true
		
		local char = player.Character or player.CharacterAdded:Wait()
		local attributes = char:GetAttributes()
		local delayTime = 0.15 --anim wind-up time
		local direction = char.HumanoidRootPart.CFrame.LookVector
		local dmg = attributes["dmg"] --base dmg snapshot
		
		attributes["atktype"] = "light" --see stun manager for time references
		attributes["atkdur"] -= delayTime
		attributes["dmg"] += 0.5*(count-1)^2 --dmg calculations (parabolic curve)
		attributes["velocity"] = direction*(100^(100^(count-4))*(attributes["dmg"]/dmg)) + direction*35
		
		task.delay(delayTime, function()
			dmgManager:Damage(player, attributes)
			db = false
		end)
	end
end

return m1Manager