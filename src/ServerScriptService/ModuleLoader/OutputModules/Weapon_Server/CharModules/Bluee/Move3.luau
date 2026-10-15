local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)
local stunManager = require(SSS.ModuleLoader.Managers.StunManager)

local delayTime = timing.GetValue("Bluee", "Weapon", 1, 3)
local endlag = 0.25
local duration = timing.GetValue("Bluee", "Weapon", 3, 3) - delayTime - endlag

local BM3 = {}

function BM3:Trigger(player: Player)
	print("weapon bm3")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	
	char:AddTag("SolDisabled")
	char:AddTag("TechsDisabled")
	
	local attackData = {
		atkdur = duration - (duration/5),
		atkrad = 5,
		atktype = "light",
		dmg = 12,
		DOT = duration / 5,
		ID = 3,
		style = "Weapon"
	}
		
	damager:Damage(player, attackData)
	
	task.delay(duration - (duration/5), function()
		local attackData2 = {
			atkdur = duration / 5,
			atkrad = 5,
			atktype = "heavy",
			dmg = 17,
			ID = 3,
			style = "Weapon"
		}

		damager:Damage(player, attackData2)
	end)
	
	hum.WalkSpeed /= 3
	
	local initialTime = os.clock()
	
	repeat 
		task.wait()
		
		if char:HasTag("Parried") then break end --very unlikely, but still possible (~0.1s window)
		
	until os.clock() - initialTime >= duration
	
	char:RemoveTag("SolDisabled")
	char:RemoveTag("TechsDisabled")
	
	stunManager.Eval(player, nil, endlag, "Recovery")
end

return BM3