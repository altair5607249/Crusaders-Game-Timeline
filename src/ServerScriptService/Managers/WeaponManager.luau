local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local attack = remotes.Attack

local WeaponManager = {}

local managers = script.Parent
local dmgManager = require(managers.DamageManager)

--default settings
local CD = 2
local dmg = 10
local atk_rad = 4
local atk_dur = 0.5

function WeaponManager.Attack(weapon, ownerHum)
	dmgManager.Damage(weapon.Handle, weapon, ownerHum, atk_dur, atk_rad, CD, dmg)
end

attack.OnServerEvent:Connect(function(player, weapon, ownerHum) --respond to remote event
	-- THE FANTASTIC BLOCKADE (the ultimate sanity check)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChild("Humanoid")
	if not hum or hum.Health <= 0 then return end
	local weapon = char:FindFirstChildOfClass("Tool")
	if not weapon or not weapon:HasTag("Weapon") then return end
	
	atk_dur = char:GetAttribute("atkdur")
	atk_rad = char:GetAttribute("atkrad")
	CD = char:GetAttribute("cd")
	dmg = char:GetAttribute("dmg")
	
	WeaponManager.Attack(weapon, hum) -- if they pass the blockade, let them cook
end)

return WeaponManager
