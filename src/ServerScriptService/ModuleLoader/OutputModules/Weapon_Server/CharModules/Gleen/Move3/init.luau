local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local movement = require(SSS.ModuleLoader.Managers.MovementManager)

local delayTime = timing.GetValue("Gleen", "Weapon", 1, 3)
local duration = timing.GetValue("Gleen", "Weapon", 3, 3) - delayTime

local function healthCurve(health: number, maxHealth: number, stat: number) --cubic curve
	local b = (stat^(1/3))/maxHealth
	return -(b*(health-maxHealth))^3 + stat
end

local GM3 = {}

function GM3:Trigger(player: Player)
	print("weapon gm3")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	char:AddTag("SolDisabled")
	char:AddTag("TechsDisabled")
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local deltaHealth = maxHealth - currentHealth
	
	local shieldHealth = healthCurve(deltaHealth, maxHealth, 40)
	
	hum:SetAttribute("Shield", shieldHealth)
	hum:SetAttribute("ShieldDirection", "Front")
	
	local runSpeed: number = spacing.GetValue("Gleen", 2)
	local speed = runSpeed / 2
	movement.ChangeTolerance(player, speed)
	
	hum.WalkSpeed = speed
	
	task.delay(duration, function()
		if hum.Health <= 0 or not hum or player.Parent ~= Players then return end
		
		char:RemoveTag("SolDisabled")
		char:RemoveTag("TechsDisabled")
		
		if hum:GetAttribute("Shield") then hum:SetAttribute("Shield", nil) end
		if hum:GetAttribute("ShieldDirection") then hum:SetAttribute("ShieldDirection", nil) end
		
		movement.ChangeTolerance(player, runSpeed)
		
		if not char:GetAttribute("Stunned") then hum.WalkSpeed = spacing.GetValue("Gleen", 1) end
	end)
	
	local connection: RBXScriptConnection? = nil
	connection = hum:GetAttributeChangedSignal("Shield"):Connect(function()
		if not hum:GetAttribute("Shield") then
			char:AddTag("HitFinished") --ends the move's animation
			task.delay(0.1, function()
				char:RemoveTag("HitFinished")
			end)
		end
	end)
	
	local sfx = script.Anchor:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
end

return GM3