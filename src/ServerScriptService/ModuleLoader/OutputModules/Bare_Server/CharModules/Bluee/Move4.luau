--this is the most complicated move in the game...
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local stunManager = require(SSS.ModuleLoader.Managers.StunManager)
local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local receiveParlay = RS.Remotes.GambleServer
local sendParlay = RS.Remotes.GambleClient

local pendingGambles = {}
local options = { --weighted random system
	{name = "Heads", chance = 3000}, 
	{name = "Tails", chance = 3000}, 
	{name = "Sides", chance = 1} --studies have shown this to be approximately 1/6000 (at least with american coins)
}

local function flipCoin(items: {Instance})
	local sum = 0
	for i, item in ipairs(items) do
		sum += item.chance
	end
	
	local value = math.random(1, sum)
	local accumulator = 0
	
	for i, item in ipairs(items) do
		accumulator += item.chance
		if value <= accumulator then
			return item.name
		end
	end
end

local function awaitingChoice(player: Player, timeout: number)
	local bind = Instance.new("BindableEvent")
	
	pendingGambles[player] = {
		choiceMade = false,
		bind = bind
	}
	
	local result
	task.spawn(function()
		result = bind.Event:Wait()
	end)
	
	local initialTime = os.clock()
	repeat 
		task.wait()
		local deltaTime = os.clock() - initialTime
		if deltaTime >= timeout then break end --forcibly end the loop if timeout passed
	until result ~= nil and deltaTime >= timeout
	
	pendingGambles[player] = nil
	bind:Destroy()
	return result --which can be nil if timeout
end

receiveParlay.OnServerEvent:Connect(function(player, choice)
	local pending = pendingGambles[player]
	if not pending or pending.choiceMade then return end --guard against multiple inputs
	pending.choiceMade = true --debounce, my old friend
	pending.bind:Fire(choice)
end)

local BM4 = {}

function BM4:Trigger(player: Player)
	print("bm4") --phase one
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	
	local dmg = 0
	local duration = 4*(timing.GetValue("Bluee", "Bare", 3, 4) - timing.GetValue("Bluee", "Bare", 1, 4)) --the actual duration
	
	local attackData = {
		atkdur = duration*0.24,
		atkrad = 25,
		atktype = "medium",
		bdmg = dmg,
		dmg = dmg,
		getTargets = true,
		ID = 4,
		precedent = true,
		style = "Bare"
	}
	
	char:AddTag("Resistance")

	local targets: {Instance} = damager:Damage(player, attackData)
	local targetRoots = {}

	for i, targetHum in ipairs(targets) do
		local targetRoot: Part = targetHum.Parent:WaitForChild("HumanoidRootPart")
		table.insert(targetRoots, targetRoot)
	end

	table.sort(targetRoots, function(a, b)
		local directionA = (root.Position - a.Position).Magnitude
		local directionB = (root.Position - b.Position).Magnitude
		return directionA < directionB
	end)

	if not targetRoots[1] then return end
	
	local targetPlayer 
	for i, plr in ipairs(targetRoots) do --in case character dummies were caught in the crossfire, looks for the nearest valid player
		targetPlayer = Players:GetPlayerFromCharacter(targetRoots[i].Parent)
		if targetPlayer ~= nil then break end
	end
	
	print("End of Phase 1")
	
	if not targetPlayer or targetPlayer.Parent ~= Players or player.Parent ~= Players then return end --phase two
	
	local targetHum = targetPlayer.Character:WaitForChild("Humanoid")
	char:RemoveTag("Resistance")
	
	print("Phase 2")
	
	char:AddTag("Continue") --for continuing the animation (cosmetic purpose only)
	hum:AddTag("Immortal") --adding i-frames
	targetHum:AddTag("Immortal") --for both players
	
	stunManager.Eval(player, nil, duration*0.75, "Recovery")
	stunManager.Eval(targetPlayer, nil, duration*0.75, "Recovery")
	
	sendParlay:FireClient(player, duration*0.4)
	sendParlay:FireClient(targetPlayer, duration*0.49)
	
	local result1, result2
	task.spawn(function() result1 = awaitingChoice(player, duration*0.5) end)
	task.spawn(function() result2 = awaitingChoice(targetPlayer, duration*0.5) end)
	
	local initialTime = os.clock()
	repeat task.wait() until os.clock() - initialTime > duration*0.51 --slight buffer, wont be noticeable in the animation
	
	if not result1 then result1 = options[math.random(1, 2)].name end --no one would
	if not result2 then result2 = options[math.random(1, 2)].name end --bet on sides
	
	local randomFlip = flipCoin(options) --phase three
	
	task.delay(duration*0.25, function()
		char:RemoveTag("Continue")
		hum:RemoveTag("Immortal") --removing i-frames
		targetHum:RemoveTag("Immortal") --for both players
		
		if result1 == result2 then
			print("Both made the same bet! No show!")
			return --nothing happens (will be made cooler post-MVP phase)
		else
			if randomFlip == result1 then --Bluee won
				print(player, "won!")
				stunManager:DurReg(player, targetPlayer, "heavy", "Bare", 4, "Hitstun")
			elseif randomFlip == result2 then --other Crusader won
				print(targetPlayer, "won!")
				stunManager:DurReg(targetPlayer, player, "heavy", "Bare", 4, "Hitstun")
			else --if both picked different options and neither won (yes, this can happen with three choices)
				print("Neither player won!")
			end
		end
	end)
end

return BM4