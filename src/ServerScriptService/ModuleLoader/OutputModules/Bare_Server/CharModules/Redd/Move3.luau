local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local managers = SSS.ModuleLoader.Managers

local damager = require(managers.DamageManager)

local timing = require(RS.UniversalModules.Time)

local RM3 = {}

function RM3:Trigger(player: Player)
	print("rm3")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local delayTime = timing.GetValue("Redd", "Bare", 3, 3) - timing.GetValue("Redd", "Bare", 1, 3)
	local duration = 3.5
	local dmg = 2.5
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration + health^2/(85.7142*maxHealth),
		atkrad = 10,
		atktype = "light",
		bdmg = dmg,
		dmg = dmg + health^2/(80*maxHealth),
		DOT = 0.35,
		expanding = 1.48599,
		origin = char:FindFirstChild("HumanoidRootPart")
	}
	
	local handle = Instance.new("Part")
	handle.Parent = workspace
	handle.Position = Vector3.new(root.Position.X, 0, root.Position.Z)
	handle.CanCollide = false
	handle.CanQuery = false
	handle.CanTouch = false
	handle.Transparency = 0.99
	
	local sfoth = Instance.new("Decal")
	sfoth.Texture = "11464629646"
	sfoth.Parent = handle
	sfoth.Face = Enum.NormalId.Top
	
	damager:Damage(player, attackData)
	
	task.delay(delayTime, function()
		handle:Destroy()
	end)
end

return RM3