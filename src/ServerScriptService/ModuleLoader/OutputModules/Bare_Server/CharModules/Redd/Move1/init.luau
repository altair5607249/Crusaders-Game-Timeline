local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local RM1 = {}

function RM1:Trigger(player: Player)
	print("rm1")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	local duration = timing.GetValue("Redd", "Bare", 3, 1) - timing.GetValue("Redd", "Bare", 1, 1)
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration,
		atkrad = 4,
		atktype = "medium",
		bypassParry = (currentHealth < maxHealth/2 and true) or nil,
		dmg = 35,
		ID = 1,
		style = "Bare"
	}
	
	--copy and pastable move sfx code
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	damager:Damage(player, attackData) --main hit
end

return RM1
