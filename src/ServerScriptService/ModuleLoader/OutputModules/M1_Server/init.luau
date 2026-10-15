local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local managers = script.Parent.Parent.Managers

local cooldown = require(managers.CooldownManager)
local damager = require(managers.DamageManager)

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local vfxInfo = TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

local weaponQuirks = {
	Redd = {
		dmg = 1.25,
		range = 2
	},
	Yello = {
		dmg = 0.85,
		range = 3.5
	},
	Gleen = {
		dmg = 0.95,
		range = 2.75
	},
	Bluee = {
		dmg = 1,
		range = 2.5
	}
}

local m1Registry = {}

Players.PlayerAdded:Connect(function(player)
	m1Registry[player] = {
		prevCount = 0,
		prevTick = 0
	}
end)

Players.PlayerRemoving:Connect(function(player)
	m1Registry[player] = nil
end)

local m1Manager = {}

function m1Manager.Action(player: Player, index: number)
	local crusader: string = player:GetAttribute("Crusader")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local cheating = false
	local comboExtension = timing.GetValue(crusader, "M1", 3, 1) + 0.5
	
	if char:HasTag("SolDisabled") then return end
	
	if index > 4 then return end --just incase a modified client tries to pass their strike index as 4 when it isnt actually 4
	if not cooldown:IsReady(player, "M1", "M1") or char:GetAttribute("Stunned") then return end
	
	local count = timing.M1Timing(m1Registry[player].prevCount, m1Registry[player].prevTick, comboExtension)
	
	if index == 4 then
		if count == 4 then 
			index = 4
		else
			warn("Index and Registry do not match!")
			return
		end
	end

	m1Registry[player].prevCount = count
	m1Registry[player].prevTick = os.clock()
	cooldown:Register(player, "M1", "M1", index)
	
	if char:HasTag("WeaponActive") then
		local cost = 5
		local stamina = hum:GetAttribute("Stamina")

		if stamina < cost then
			return
		else
			hum:SetAttribute("Stamina", stamina - cost)
		end
	end
	
	local root: Part = char:FindFirstChild("HumanoidRootPart")
	local duration: number = timing.GetValue(crusader, "M1", 3, index) - timing.GetValue(crusader, "M1", 1, index)
		
	local delayTime = timing.GetValue(crusader, "M1", 1, index)
	local duration = timing.GetValue(crusader, "M1", 3, index) - delayTime
	local dmg = spacing.GetValue(crusader, 3)
	
	local hum = char:WaitForChild("Humanoid")
	local speed: number | number = (char:HasTag("ConserveSpeed") and hum.WalkSpeed) or spacing.GetValue(crusader, 1)
	hum.WalkSpeed = speed/3
	
	local addend: number | number = (char:HasTag("WeaponActive") and weaponQuirks[crusader].dmg) or 0
	
	local attackData = {
		atkdur = duration,
		atkrad = 3.5,
		atktype = (index == 4 and "heavy") or "light", --see stun manager for time references
		customSound = (index == 4 and script.Heavy) or nil,
		dmg = (dmg + 0.5*(index-1)^2) + addend, --dmg calculations (parabolic curve)
		getTargets = true,
		ID = index,
		style = "M1"
	}
	
	task.delay(delayTime, function()
		if char:GetAttribute("Stunned") then return end
		
		local normalRange: CFrame = char.hitPart.CFrame
		
		attackData.origin = (char:HasTag("WeaponActive") and normalRange * CFrame.new(0, 0, -weaponQuirks[crusader].range)) or nil
		
		task.spawn(function()
			local targets: {Instance} = damager:Damage(player, attackData)
			
			if targets and targets[1] and not char:HasTag("Parried") then
				if char:HasTag("Godspeed") then 
					local stamina = hum:GetAttribute("Stamina")
					hum:SetAttribute("Stamina", stamina + 6) 
				end
				
				if index == 4 then
					local impact = RS.AttackVFX["All-Purpose Ring"]:Clone()
					impact.Parent = workspace
					impact.CFrame = root.CFrame * CFrame.new(0, 0, -5)
					
					--customizing the impact
					impact.Material = Enum.Material.Neon
					
					local tweenSize = TS:Create(impact, vfxInfo, {Size = impact.Size * 8})
					local tweenTp = TS:Create(impact, vfxInfo, {Transparency = 1})
					
					tweenSize:Play()
					tweenTp:Play()
					tweenTp.Completed:Connect(function()
						tweenSize:Destroy()
						tweenTp:Destroy()
						impact:Destroy()
					end)
				end
			end
		end)	
		
		hum.WalkSpeed = speed
	end)
end

return m1Manager