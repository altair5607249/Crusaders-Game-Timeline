local RS = game:GetService("ReplicatedStorage")

local timing = require(RS.UniversalModules.Time)

local copy = RS.Remotes.CopyMove
local Crusaders = {"Redd", "Yello", "Gleen"}

local BM2 = {}

function BM2:Trigger(player: Player)
	print("bm2")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	
	--copy and pastable move sfx code
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	local copiedCrusader = Crusaders[math.random(#Crusaders)]
	local copiedMove = math.random(1, 3) --cannot copy the fourth move of any Crusader
	
	local duration = timing.GetValue(copiedCrusader, "Bare", 3, copiedMove)
	
	local vfx = Instance.new("Sparkles")
	vfx.Color = Color3.new(0, 0, 1)
	vfx.Parent = root
	
	copy:FireClient(player, copiedCrusader, copiedMove, "Bare")
	
	task.delay(duration, function()
		vfx:Destroy()
	end)
end

return BM2
