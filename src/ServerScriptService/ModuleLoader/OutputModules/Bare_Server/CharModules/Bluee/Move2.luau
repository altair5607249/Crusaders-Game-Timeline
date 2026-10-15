local RS = game:GetService("ReplicatedStorage")
local copyAnim = RS.Remotes.CopyAnimation

local Crusaders = {"Redd", "Yello", "Gleen"}

local BM2 = {}

function BM2:Trigger(player: Player)
	print("BM2")
	local bareManager = require(script.Parent.Parent.Parent)
	
	local copiedCrusader = Crusaders[math.random(1, 3)]
	local copiedMove = math.random(1, 3)
	
	copyAnim:FireClient(player, copiedCrusader, copiedMove)
	bareManager.Action(player, copiedMove, copiedCrusader)
end

return BM2
