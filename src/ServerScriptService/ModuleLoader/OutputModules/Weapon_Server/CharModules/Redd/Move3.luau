local debby = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Redd", "Weapon", 1, 3)
local duration: number = timing.GetValue("Redd", "Weapon", 3, 3) - delayTime

local RM3 = {}

function RM3:Trigger(player: Player)
	print("weapon rm3")

	local char: Model = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local deltaHealth = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration - 0.5, --0.5s of endlag
		atkrad = 10,
		atktype = "medium",
		dmg = 5,
		DOT = 0.1,
		expanding = 5,
		ID = 3,
		noKB = true,
		origin = root,
		style = "Weapon"
	}
	
	damager:Damage(player, attackData)
	
	hum:TakeDamage(hum.Health / 8)
	
	local weapon: Accessory = char:FindFirstChild("Main")
	local handle: Part = weapon:FindFirstChild("Handle")
	
	local highlight = Instance.new("Highlight")
	highlight.Parent = handle
	
	local trail = Instance.new("Trail")
	trail.Attachment0 = handle:FindFirstChildWhichIsA("Attachment")
	trail.Attachment1 = root:FindFirstChildWhichIsA("Attachment")
	trail.Parent = handle
	
	--customizing the trail
	trail.Color = ColorSequence.new(Color3.new(1, 0, 0))
	trail.Lifetime = 0.2
	
	debby:AddItem(highlight, attackData.atkdur)
	debby:AddItem(trail, attackData.atkdur)
end

return RM3