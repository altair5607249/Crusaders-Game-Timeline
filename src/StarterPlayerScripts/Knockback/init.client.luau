local Players = game:GetService("Players")
local player = Players.LocalPlayer

local RS = game:GetService("ReplicatedStorage")
local remotes = RS:WaitForChild("Remotes")
local knockback = remotes:WaitForChild("Knockback")

local function respawn()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local animator = hum:WaitForChild("Animator")
	local animation = script.Animation
	local animTrack = animator:LoadAnimation(animation)
	local root = char:WaitForChild("HumanoidRootPart")
	
	knockback.OnClientEvent:Connect(function(velocity)
	--[[note: i know applying impulse is more realistic,
	--but linear velocity is more cleaner for what i have in mind]]
		animTrack:Play()
		root.AssemblyLinearVelocity = velocity
	end)
end

repeat task.wait() until player.Character
respawn()

player:GetPropertyChangedSignal("Character"):Connect(respawn)

--[[ NOTE TO SELF ON WHY :GetPropertyChangedSignal() WORKS:
because im changing the player's character model on the SERVER each time the player respawns,
this CLIENT-SIDE knockback script cannot respond to the SERVER-HANDLED event accordingly;
therefore, i had to switch up how this script received said signal using the dark magic indicated above...
it only listens for when the character is changed, contrary to how CharacterAdded waits for the whole character to load in!
in this case, it loads way faster, and can match the speed of the server's respawn handler :D
]]