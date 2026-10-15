local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local toggle = RS.Remotes.ToggleStun
local mouselock = RS.Remotes.Mouselock

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local stunPriority = {
	Recovery = 1,
	Hit = 2
}

local staticInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local stunManager = {}

function stunManager.Eval(player: Player, atktype: string, duration: number, source: string) --can be called instead of DurReg if caller already has a duration in mind
	if player == nil or player.Parent ~= Players then return end
	
	local crusader = player:GetAttribute("Crusader")
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local head: Part = char:WaitForChild("Head")
	
	if not char:GetAttribute("Stunned") then
		if char:HasTag("LoadingAttack") and atktype == "heavy" then char:AddTag("CancellingAttack") end
		
		char:SetAttribute("Stunned", true)
		char:SetAttribute("StunTime", duration)
	else
		if char:GetAttribute("StunTime") > 4 then return end --stun time is capped :)
		duration += char:GetAttribute("StunTime")
		char:SetAttribute("StunTime", duration)
	end
	
	if atktype then char:SetAttribute("StunType", atktype) end
	
	local previousSource = char:GetAttribute("StunSource")
	if not previousSource or stunPriority[source] > stunPriority[previousSource] then char:SetAttribute("StunSource", source) end
	
	local static: Part? = nil
	
	if not char:GetAttribute("StunExt") then
		char:SetAttribute("StunExt", true)
		
		local savedSpeed: number? = nil
		if char:HasTag("ConserveSpeed") then savedSpeed = hum.WalkSpeed end
		
		hum.WalkSpeed = 0

		local initialStun = os.clock()

		task.spawn(function()
			repeat task.wait() until (os.clock() - initialStun >= char:GetAttribute("StunTime")) or player.Parent ~= Players or not hum

			if player.Parent ~= Players then return end

			char:SetAttribute("Stunned", false)
			char:SetAttribute("StunTime", nil)
			char:SetAttribute("StunExt", nil)
			char:SetAttribute("StunSource", nil)
			char:SetAttribute("StunType", nil)
			char:SetAttribute("StunStart", nil)
			
			if char:HasTag("ConserveSpeed") then
				hum.WalkSpeed = savedSpeed
				char:AddTag("Running")
			else
				hum.WalkSpeed = spacing.GetValue(crusader, 1)
			end 
			
			if static then
				local staticVfx: ParticleEmitter = static.VFX_Attachment:FindFirstChildWhichIsA("ParticleEmitter")
				local staticWeld: WeldConstraint = static.StaticWeld
				
				local alpha = Instance.new("NumberValue")
				alpha.Value = 0.3
				
				local tweenStaticOut = TS:Create(alpha, staticInfo, {Value = 1})
				
				alpha.Changed:Connect(function(value)
					staticVfx.Transparency = NumberSequence.new(value)
				end)
				
				tweenStaticOut:Play()
				tweenStaticOut.Completed:Connect(function()
					tweenStaticOut:Destroy()
					alpha:Destroy()
					staticWeld:Destroy()
					static:Destroy()
				end)
			end
		end)
	end

	if not char:GetAttribute("StunStart") then --makes sure of legitimate pairing
		char:SetAttribute("StunStart", true)
		if char:HasTag("Running") then char:RemoveTag("Running") end
		
		if stunPriority[source] == 2 then --only for hitstun
			static = RS.AttackVFX.Static:Clone()
			static.Parent = head
			static.CFrame = head.CFrame
			
			local staticVfx = static.VFX_Attachment:FindFirstChildWhichIsA("ParticleEmitter")
			local alpha = Instance.new("NumberValue")
			alpha.Value = 1
			
			local tweenStaticIn = TS:Create(alpha, staticInfo, {Value = 0.3})
			
			alpha.Changed:Connect(function(value)
				staticVfx.Transparency = NumberSequence.new(value)
			end)
			
			tweenStaticIn:Play()
			tweenStaticIn.Completed:Connect(function()
				tweenStaticIn:Destroy()
				alpha:Destroy()
			end)
			
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = head
			weld.Part1 = static
			weld.Parent = static
			weld.Name = "StaticWeld"
			
			if atktype == "heavy" then
				toggle:FireClient(player)
			end
		end
	end
end

function stunManager:DurReg(player: Player, targetPlayer: Player, atktype: string, style: string, ID: number, source: string)
	if player == nil then return end
	local duration = timing.GetValue(player:GetAttribute("Crusader"), style, 4, ID)
	stunManager.Eval(targetPlayer, atktype, duration, source)
end

return stunManager