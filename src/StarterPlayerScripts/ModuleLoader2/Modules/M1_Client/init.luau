--this manages the animations

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local animator = hum:WaitForChild("Animator")

local CD = char:GetAttribute("cd")
local CD2 = CD

local UIS = game:GetService("UserInputService")
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

function m1.ClickEvent()
	if not db then
		db = true
		
		--timing check
		if tick() - prevInput <= CD2 or prevInput == 0 then
			count += 1
			m1:Attack()
		else
			count = 1
			m1:Attack()
		end
		
		--resets the combo
		if count == 3 then
			CD += 1
			count = 0
		else
			CD = CD2
		end
		
		task.wait(CD)
		db = false
		
		prevInput = tick()
	end
end

function m1:Attack()
	attack:FireServer()
	
	local animation = animations[count]
	animation:Play()
end

return m1