--this manages the animations

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local animator = hum:WaitForChild("Animator")

local CD = char:GetAttribute("cd")
local CD2 = CD
local CD3 = CD + 0.5

local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local attack = remotes.Attack

local m1 = {}

local animsFolder = script.Animations:GetChildren()
local animations = {}
table.sort(animsFolder, function(a, b)
	return a:GetAttribute("Order") < b:GetAttribute("Order")
end)
--loading animations for player's initial spawn
for i, a in ipairs(animsFolder) do
	local anim = animator:LoadAnimation(a)
	table.insert(animations, anim)
end

local function respawn(newChar)
	char = newChar
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")
	table.clear(animations)
	for i, a in ipairs(animsFolder) do
		local anim = animator:LoadAnimation(a)
		table.insert(animations, anim)
	end
end

player.CharacterAdded:Connect(respawn)

local prevInput = 0
local count = 0
local db = false

function m1:Click()
	local stunned = char:GetAttribute("Stunned")
	if not db and not stunned then
		db = true
		
		--timing check
		if tick() - prevInput <= CD3 or prevInput == 0 then
			count += 1
			m1.Attack()
		else
			count = 1
			m1.Attack()
		end
		
		--resets the combo
		if count == 4 then
			CD += 1
			count = 0
		else
			CD = CD2
		end
		
		task.wait(CD + 0.15)
		db = false
		prevInput = tick()
	end
end

function m1.Attack()
	local hitPart = char:WaitForChild("hitPart")
	local atkdur = char:GetAttribute("atkdur")
	local atkrad = char:GetAttribute("atkrad")
	local cd = char:GetAttribute("cd")
	local dmg = char:GetAttribute("dmg")
	
	attack:FireServer(hitPart, char, hum, atkdur, atkrad, cd, count, dmg)
	
	local animation = animations[count]
	animation:Play()
end

local IASHandler = require(script.Parent:WaitForChild("IASHandler"))

local mouseSpecs = {
	{name = "Punch", callback = function() m1:Click() end}
}

function m1.IAS()
	local context = RS:WaitForChild("InputContexts"):WaitForChild("MouseContext")

	IASHandler.ActReg(context, mouseSpecs)
end

m1.IAS()

return m1