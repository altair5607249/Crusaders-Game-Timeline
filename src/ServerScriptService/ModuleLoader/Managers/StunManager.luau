local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local toggle = RS.Remotes.ToggleStun

local timing = require(RS.UniversalModules.Time)

local stunRegistry = {}

Players.PlayerAdded:Connect(function(player)
	stunRegistry[player] = {false, 0, false}
end)

Players.PlayerRemoving:Connect(function(player)
	stunRegistry[player] = nil
end)

local stunManager = {}

function stunManager.Eval(player: Player, atktype: string, duration: number) --can be called instead of DurReg if caller already has a duration in mind
	if player == nil then return end
	
	if not stunRegistry[player][1] then
		stunRegistry[player][1], stunRegistry[player][2] = true, duration --1 is stun state, 2 is stun time, 3 is task debounce
		
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:FindFirstChild("Humanoid")
		hum.WalkSpeed = 0
		hum.JumpPower = 0
	else
		stunRegistry[player][2] += duration
	end
	
	stunRegistry[player][4] = atktype --stores the most recent atktype
	
	if not stunRegistry[player][3] then
		toggle:FireClient(player, atktype, true)
		
		local initialStun = tick()
		task.spawn(function()
			stunRegistry[player][3] = true
			repeat task.wait() until tick() - initialStun >= stunRegistry[player][2] --repeats until change in time outweighs the duration
			
			toggle:FireClient(player, stunRegistry[player][4], false)
			stunRegistry[player][1], stunRegistry[player][2], stunRegistry[player][3] = false, 0, false

			local char = player.Character or player.CharacterAdded:Wait()
			local hum = char:FindFirstChild("Humanoid") --use the space module to set these values back correctly )
			hum.WalkSpeed = 0
			hum.JumpPower = 0
		end)
	end
end

function stunManager:DurReg(player: Player, atktype: string, style: string, ID: number)
	if player == nil then return end
	local char = player.Character or player.CharacterAdded:Wait()
	local duration = timing.GetValue(char:GetAttribute("Name"), style, 4, ID)
	stunManager.Eval(player, atktype, duration)
end

function stunManager:GetStunState(player: Player)
	return stunRegistry[player][1] --returns a boolean regarding whether or not the indicated player is stunned
end

return stunManager