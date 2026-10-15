local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local cooldown = require(SSS.ModuleLoader.Managers.CooldownManager)
local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local delayTime = timing.GetValue("Bluee", "Weapon", 1, 2)
local duration = timing.GetValue("Bluee", "Weapon", 3, 2) - delayTime

local BM2 = {}

function BM2:Trigger(player: Player)
	print("weapon bm2")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local validMoves = {"Rend", "Oumuamua", "Sword Trick", "Proteus"}
	local candidates = {}
	
	for i, move: string in ipairs(validMoves) do
		if not cooldown:IsReady(player, move, "Weapon") and move ~= "Oumuamua" then
			table.insert(candidates, move)
		end
	end
	
	local secretMove = "Azurewrath"
	local randomIndex = (#candidates ~= 0 and math.random(#candidates)) or secretMove
	
	if randomIndex ~= secretMove then
		local randomChoice = candidates[randomIndex]
		local actualIndex = table.find(validMoves, randomChoice)
		local cd: number = timing.GetValue("Bluee", "Weapon", 2, actualIndex)
		
		cooldown.Manipulate(player, randomChoice, "Weapon", -cd)
	else
		print(secretMove)
		
		local attackData = {
			atkdur = duration,
			atkrad = 5,
			atktype = "medium",
			dmg = 0,
			getTargets = true,
			ID = 2,
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
				local doomedMove = moveset[math.random(1, #moveset)]
				
				cooldown.Manipulate(targetPlayer, doomedMove, style, 8)
			end
		end
	end
	
	local vfx = Instance.new("Sparkles")
	vfx.Color = Color3.new(0, 0, 1)
	vfx.TimeScale = 1.5
	vfx.Parent = root
	
	task.delay(1, function()
		vfx:Destroy()
	end)
end

return BM2