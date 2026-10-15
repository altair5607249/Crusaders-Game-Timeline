local debby = game:GetService("Debris")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local receiver = RS.Remotes.Hitboxes

local vfxQuirks = {
	Redd = Color3.new(1, 0, 0),
	Yello = Color3.new(1, 1, 0),
	Gleen = Color3.new(0, 1, 0),
	Bluee = Color3.new(0, 0, 1)
}

local function generateHitbox(atkrad: number, bypassParry: boolean, origin: CFrame | Part)
	local testPart = Instance.new("Part")
	testPart.Shape = Enum.PartType.Block
	testPart.Anchored = true
	testPart.CastShadow = false
	testPart.Color = vfxQuirks[player:GetAttribute("Crusader")]
	testPart.CFrame = (typeof(origin) == "CFrame" and origin) or origin.CFrame
	local size = atkrad
	testPart.Size = Vector3.new(size, size, size)
	testPart.CanCollide = false
	testPart.CanQuery = false
	testPart.Transparency = 0.95
	testPart.Parent = workspace

	if bypassParry == true then 
		testPart.Material = Enum.Material.Neon 
		testPart.Transparency = 0.97
	end

	if testPart == nil then warn("Hitbox is nil!") end

	debby:AddItem(testPart, 0.2)
end

receiver.OnClientEvent:Connect(function(atkrad: number, bypassParry: boolean, origin: CFrame | Part)
	generateHitbox(atkrad, bypassParry, origin)
end)