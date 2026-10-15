local charModules = script.CharModules:GetChildren()
local characters = {}

for i, character in ipairs(charModules) do
	for j, move in ipairs(character:GetChildren()) do
		local class = require(move)
		characters[character.Name] = characters[character.Name] or {}
		table.insert(characters[character.Name], class)
	end
end

local weaponManager = {}

local db = false

function weaponManager.Action(player: Player, move: number)
	if not db then
		db = true
		
		local char = player.Character or player.CharacterAdded:Wait()
		
		task.delay(0.5, function()
			characters[char:GetAttribute("Name")][move]:Trigger()
			task.wait(3)
			db = false
		end)
	end
end

return weaponManager