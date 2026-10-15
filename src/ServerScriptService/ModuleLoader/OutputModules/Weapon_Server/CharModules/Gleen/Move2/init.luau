local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)
local stunManager = require(SSS.ModuleLoader.Managers.StunManager)

local delayTime = timing.GetValue("Gleen", "Weapon", 1, 2)
local duration = timing.GetValue("Gleen", "Weapon", 3, 2) - delayTime

local GM2 = {}

function GM2:Trigger(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	char:AddTag("SolDisabled")
	char:AddTag("TechsDisabled")
	
	local attackData = {
		atkdur = duration,
		atkrad = 12,
		atktype = "heavy",
		customSound = script.Hit,
		dmg = 35,
		DOT = 0.35,
		DOTchange = 1.35239,
		drainStamina = 35,
		ID = 2,
		noStun = true,
		origin = root,
		style = "Weapon"
	}
	
	--note: to find DOTchange, i used Newton's method to sharpen an approximation of a geometric series's common ratio
	--i modeled the geometric series by using a summation wrapper on the basic function detailing the DOTchange's exponential growth curve
	--and i found the initial approximation by using an n-th root trick i accidentally discovered while running some numbers
	--i further confirmed the answer i got by manually finding the DOTchange on Desmos
	
	damager:Damage(player, attackData)
	
	task.delay(duration, function()
		if hum.Health <= 0 or not hum or player.Parent ~= Players then return end
		
		char:RemoveTag("SolDisabled")
		char:RemoveTag("TechsDisabled")
		
		stunManager.Eval(player, nil, 0.5, "Recovery")
	end)
	
	local spin = script.Spin:Clone()
	spin.Parent = root
	spin:Play()
	spin.DidLoop:Connect(function(id, num)
		spin.PlaybackSpeed /= attackData.DOTchange
		
		if num >= 5 then spin:Destroy() end
	end)
end

return GM2