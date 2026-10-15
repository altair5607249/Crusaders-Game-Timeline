local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local timing = require(RS.UniversalModules.Time)

local cooldown = require(SSS.ModuleLoader.Managers.CooldownManager)
local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Bluee", "Weapon", 1, 2)
local duration = timing.GetValue("Bluee", "Weapon", 3, 2) - delayTime
local effectInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local BM2 = {}

function BM2:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local validMoves = {"Rend", "Oumuamua", "Sword Trick", "Protean Pace"}
	local candidates = {}
	
	for i, move: string in ipairs(validMoves) do
		if not cooldown:IsReady(player, move, "Weapon") and move ~= "Oumuamua" then
			table.insert(candidates, move)
		end
	end
	
	local secretMove = "Azurewrath"
	local actualMove = (#candidates ~= 0 and validMoves[2]) or secretMove
	
	if actualMove ~= secretMove then
		local randomIndex = math.random(#candidates)
		local randomChoice = candidates[randomIndex]
		local actualIndex = table.find(validMoves, randomChoice)
		local cd: number = timing.GetValue("Bluee", "Weapon", 2, actualIndex)
		
		cooldown.Manipulate(player, randomChoice, "Weapon", -cd)
	else
		local attackData = {
			atkdur = duration,
			atkrad = 5,
			atktype = "light",
			dmg = 0,
			getTargets = true,
			ID = 2,
			noSound = true,
			origin = root,
			style = "Weapon"
		}
		
		local targets: {Humanoid} = damager:Damage(player, attackData)
		
		if not targets[1] then return end
		
		for i, targetHum in ipairs(targets) do
			local targetChar: Model = targetHum.Parent
			local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
			
			if targetPlayer and targetPlayer.Parent == Players then
				local style = (targetChar:HasTag("WeaponActive") and "Weapon") or "Bare"
				local manager = (targetChar:HasTag("WeaponActive") and require(SSS.ModuleLoader.OutputModules.Weapon_Server)) or require(SSS.ModuleLoader.OutputModules.Bare_Server)
				
				local moveset = manager.GetMoves(targetPlayer:GetAttribute("Crusader"))
				local doomedMove = moveset[math.random(#moveset)]
				
				cooldown.Manipulate(targetPlayer, doomedMove, style, 8)
			end
		end
	end
	
	local sfx: Sound = script[actualMove]:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	local distortion: Part = RS.AttackVFX[actualMove]:Clone()
	distortion.Parent = root
	distortion.CFrame = root.CFrame
	
	local vfx = distortion:FindFirstChildWhichIsA("Attachment"):FindFirstChildWhichIsA("ParticleEmitter")
	local tween = TS:Create(vfx, effectInfo, {Brightness = 0.25})
	
	tween:Play()
	
	hum:AddTag("Immortal") --quick i-frames
	task.delay(0.35, function()
		hum:RemoveTag("Immortal")
	end)
	
	tween.Completed:Connect(function()
		tween:Destroy()
		distortion:Destroy()
	end)
end

return BM2