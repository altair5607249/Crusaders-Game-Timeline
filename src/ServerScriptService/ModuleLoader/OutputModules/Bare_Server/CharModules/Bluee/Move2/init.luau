local RS = game:GetService("ReplicatedStorage")

local timing = require(RS.UniversalModules.Time)

local copyAnim = RS.Remotes.CopyAnimation
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
	
	local bareManager = require(script.Parent.Parent.Parent)
	
	local copiedCrusader = Crusaders[math.random(1, 3)]
	local copiedMove = math.random(1, 3)
	
	local duration = timing.GetValue(copiedCrusader, "Bare", 3, copiedMove)
	
	local vfx = Instance.new("Sparkles")
	vfx.Color = Color3.new(0, 0, 1)
	vfx.Parent = root
	
	copyAnim:FireClient(player, copiedCrusader, copiedMove)
	bareManager.Action(player, copiedMove, copiedCrusader)
	
	task.delay(duration, function()
		vfx:Destroy()
	end)
end

return BM2
