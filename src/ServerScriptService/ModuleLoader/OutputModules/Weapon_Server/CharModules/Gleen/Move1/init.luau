local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Gleen", "Weapon", 1, 1)
local duration = timing.GetValue("Gleen", "Weapon", 3, 1) - delayTime
local retraction = 0.2

local GM1 = {}

function GM1:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local sfx = script.Throw:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	local rootFrame = root.CFrame
	local extendedHitbox = rootFrame * CFrame.new(0, 0.5, -35)
	
	local attackData = { --direct hit
		atkdur = duration - retraction * 2,
		atkrad = 1, --yes, the inner hitbox has to be THIS small
		atktype = "heavy",
		customSound = script.DirectHit,
		dmg = 75,
		getTargets = true,
		ID = 1,
		noStun = true,
		origin = extendedHitbox,
		style = "Weapon"
	}
	
	local targets: {Humanoid} = damager:Damage(player, attackData)
	
	if #targets ~= 0 then
		for i, targetHum: Humanoid in ipairs(targets) do
			targetHum:AddTag("Immortal") --if directly hit, they get i-frames
			task.delay(duration - retraction * 0.2, function()
				targetHum:RemoveTag("Immortal")
			end)
		end
	end
	
	local attackData2 = { --grazed by the anchor
		atkdur = duration - retraction * 2,
		atkrad = 5,
		atktype = "medium",
		customSound = script.IndirectHit,
		dmg = 25,
		ID = 1,
		noKB = true,
		origin = extendedHitbox,
		style = "Weapon"
	}
	
	damager:Damage(player, attackData2)
end

return GM1