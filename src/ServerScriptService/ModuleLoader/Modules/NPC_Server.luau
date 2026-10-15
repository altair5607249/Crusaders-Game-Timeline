local NPC = {}

local range = 10
local minid = 1
local maxid = 3

function NPC.new(object)
	print("NPC:", object)
	
	local root = object.HumanoidRootPart
	local ogPos = root.Position
	local hum = object:WaitForChild("Humanoid")
	
	root:SetNetworkOwner(nil) --helps w buffering i think
	
	--NPC coll group
	for i, v in object:GetDescendants() do
		if v:IsA("BasePart") then
			v.CollisionGroup = "NPC"
		end
	end
	
	task.spawn(function()
		while true do
			local hasRig = object.Parent and hum.Health > 0
			if not hasRig then break end
			
			if not hum:GetAttribute("Target") then
				local x = math.random(ogPos.X - range, ogPos.X + range)
				local z = math.random(ogPos.Z - range, ogPos.Z + range)
				hum:MoveTo(Vector3.new(x, 0, z))
				hum.MoveToFinished:Wait()
				print("Moved!")
			end
			
			task.wait(math.random(minid, maxid))
		end
	end)
end

return NPC