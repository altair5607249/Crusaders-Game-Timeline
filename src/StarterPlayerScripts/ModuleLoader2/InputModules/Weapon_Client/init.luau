local RS = game:GetService("ReplicatedStorage")

local Weapon = {}
Weapon.__index = Weapon
local CD = 2

local weapons = { --improve later to include idle anims
	Fists = "Punch",
	Sparkletime = "Slash"
}

local player = game:GetService("Players").LocalPlayer
function Weapon.new(tool)
	local self = setmetatable({}, Weapon)
	self.tool = tool
	
	self.player = game.Players.LocalPlayer
	self.character = self.player.Character or self.player.CharacterAdded:Wait()
	self.humanoid = self.character.Humanoid
	self.animator = self.humanoid.Animator
	
	self.animations = self:LoadAnimations()

	self.tool.Equipped:Connect(function()
		if not self:IsEquipped() then return end
		--add sound later
		print("Equipped")
	end)
	
	self.tool.Unequipped:Connect(function()
		if not self:IsEquipped() then return end
		--add sound later
		print("Unequipped")
		if self.tool.Name == "Fists" then
			self.animations["Idle"]:Stop()
		end
	end)
	
	self.tool.Activated:Connect(function()
		if not self:IsEquipped() then return end
		--add sound later
		print("Activated")
		self:Attack()
	end)
	
	return self
end

function Weapon:IsEquipped() -- sanity check
	if self.tool.Parent == self.player.Backpack or self.tool.Parent == self.character then
		if self.tool.Name == "Fists" then
			self.animations["Idle"]:Play()
		end
		return true
	else
		return false
	end
end

function Weapon:Attack() 
	if self.attacking then return end
	
	self.attacking = true
	
	RS.Remotes.Attack:FireServer() 
	
	local animName = weapons[self.tool.Name]
	if animName then
		self.animations[animName]:Play()
		task.wait(CD)
		self.attacking = false
	end
end

function Weapon:LoadAnimations()
	local animations = {}
	for i, anim in script.Animations:GetChildren() do
		animations[anim.Name] = self.animator:LoadAnimation(anim)
	end
	return animations
end

function Weapon.Placeholder()
	print("WeaponStyle Move 1")
end

local IASHandler = require(player.PlayerScripts.ModuleLoader2.Handlers.IASHandler)

local weaponSpecs = { --it's so peak... so clean..!
	{name = "Move1", callback = function() Weapon.Placeholder() end}
}

function Weapon.IAS()
	local context = RS.InputContexts.WeaponContext

	IASHandler.ActReg(context, weaponSpecs)
end

return Weapon