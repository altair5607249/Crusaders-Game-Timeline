--this is the most complicated move in the game...
local debby = game:GetService("Debris")
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
	until result ~= nil or deltaTime >= timeout
	
	pendingGambles[player] = nil
	bind:Destroy()
	return result --which can be nil if timeout
end

receiveParlay.OnServerEvent:Connect(function(player, choice: string)
	local pending = pendingGambles[player]
	if not pending or pending.choiceMade then return end --guard against multiple inputs
	pending.choiceMade = true --debounce, my old friend
	pending.bind:Fire(choice)
end)

local BM4 = {}

function BM4:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	
	char:AddTag("SolDisabled")
	char:AddTag("TechsDisabled")
	
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	local dmg = 0
	local duration = 4*(timing.GetValue("Bluee", "Bare", 3, 4) - timing.GetValue("Bluee", "Bare", 1, 4)) --the actual duration
	
	local attackData = {
		atkdur = duration*0.25,
		atkrad = 25,
		atktype = "medium",
		bypassParry = true,
		dmg = dmg,
		getTargets = true,
		ID = 4,
		oneHit = true,
		origin = root,
		precedent = true,
		style = "Bare"
	}
	
	char:AddTag("Resistance")

	local targets: {Humanoid} = damager:Damage(player, attackData)
	
	if not targets or #targets == 0 then --guard clause
		char:RemoveTag("SolDisabled")
		char:RemoveTag("TechsDisabled")
		return 
	end 
	
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
	
	local targetPlayer 
	for i, plr in ipairs(targetRoots) do --in case character dummies were caught in the crossfire, looks for the nearest valid player
		targetPlayer = Players:GetPlayerFromCharacter(targetRoots[i].Parent)
		if targetPlayer ~= nil then break end
	end
	
	if not targetPlayer or targetPlayer.Parent ~= Players or player.Parent ~= Players then 
		char:RemoveTag("SolDisabled")
		char:RemoveTag("TechsDisabled")
		return 
	end
	
	--phase two!!
	
	local sfx = script.AuxSound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	local targetChar: Model? = targetPlayer.Character
	local targetHum: Humanoid = targetChar:WaitForChild("Humanoid")
	char:RemoveTag("Resistance")
	
	hum:AddTag("Immortal") --adding i-frames
	targetHum:AddTag("Immortal") --for both players
	
	--whoever loses is stuck with these recovery frames
	stunManager.Eval(player, nil, duration, "Recovery")
	stunManager.Eval(targetPlayer, nil, duration, "Recovery")
	
	char:RemoveTag("SolDisabled")
	char:RemoveTag("TechsDisabled")
	
	sendParlay:FireClient(player, duration*0.4)
	sendParlay:FireClient(targetPlayer, duration*0.4)
	
	local result1, result2
	task.spawn(function() result1 = awaitingChoice(player, duration*0.5) end)
	task.spawn(function() result2 = awaitingChoice(targetPlayer, duration*0.5) end)
	
	local initialTime = os.clock()
	repeat task.wait() until (result1 ~= nil and result2 ~= nil) or os.clock() - initialTime > duration*0.51 --slight buffer
	
	if not result1 then result1 = options[math.random(1, 2)].name end --no one would
	if not result2 then result2 = options[math.random(1, 2)].name end --bet on sides
	
	local randomFlip = flipCoin(options) --phase three!!!
	
	task.delay(duration*0.24, function()
		hum:RemoveTag("Immortal") --removing i-frames
		targetHum:RemoveTag("Immortal") --for both players
		
		if result1 == result2 then
			char:SetAttribute("StunTime", 0)
			targetHum.Parent:SetAttribute("StunTime", 0)
			
			local winnerLight1 = Instance.new("Highlight")
			winnerLight1.FillColor = Color3.new(0, 1, 0)
			winnerLight1.Parent = char
			
			local winnerLight2 = Instance.new("Highlight")
			winnerLight2.FillColor = Color3.new(0, 1, 0)
			winnerLight2.Parent = targetChar

			debby:AddItem(winnerLight1, 2.5)
			debby:AddItem(winnerLight2, 2.5)
			
			return
		else
			if randomFlip == result1 then --Bluee won
				char:SetAttribute("StunTime", 0) --ends stun early for winner and leaves loser in recovery frames
				targetHum:TakeDamage(targetHum.Health/8)
				
				local winnerLight = Instance.new("Highlight")
				winnerLight.FillColor = Color3.new(0, 1, 0)
				winnerLight.Parent = char
				
				local loserLight = Instance.new("Highlight")
				loserLight.Parent = targetChar
				
				debby:AddItem(winnerLight, 2.5)
				debby:AddItem(loserLight, 2.5)
				
			elseif randomFlip == result2 then --other Crusader won
				targetHum.Parent:SetAttribute("StunTime", 0) --ends stun early for winner and leaves loser in recovery frames
				hum:TakeDamage(hum.Health/8)
				
				local winnerLight = Instance.new("Highlight")
				winnerLight.FillColor = Color3.new(0, 1, 0)
				winnerLight.Parent = targetChar

				local loserLight = Instance.new("Highlight")
				loserLight.Parent = char

				debby:AddItem(winnerLight, 2.5)
				debby:AddItem(loserLight, 2.5)
				
			else --if both picked different options and neither won (yes, this can happen with three choices)
				local loserLight1 = Instance.new("Highlight")
				loserLight1.Parent = char
				
				local loserLight2 = Instance.new("Highlight")
				loserLight2.Parent = targetChar

				debby:AddItem(loserLight1, 2.5)
				debby:AddItem(loserLight2, 2.5)
			end
		end
	end)
end

return BM4