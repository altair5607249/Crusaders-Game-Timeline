local Players = game:GetService("Players")
local CS = game:GetService("CollectionService")
local debby = game:GetService("Debris")
local RNS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local attack = remotes.Attack
local playAnim = remotes.PlayAnimation

local spacing = require(RS.UniversalModules.Space)
local stun = require(script.Parent.StunManager)
local kb = require(script.Parent.KnockbackManager)

local vfxQuirks = {
	Redd = Color3.new(1, 0, 0),
	Yello = Color3.new(1, 1, 0),
	Gleen = Color3.new(0, 1, 0),
	Bluee = Color3.new(0, 0, 1)
}

local DamageManager = {}

function DamageManager:Damage(player: Player, attributes: {any})
	local char = nil 
	
	if player:IsA("Player") then char = player.Character or player.CharacterAdded:Wait()
	else char = player end --for dummies (remove after testing phase)
	
	local root: Part = char:WaitForChild("HumanoidRootPart")
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local origin: Part = attributes["origin"] or char:WaitForChild("hitPart", 2)

	if hum == nil or hum.Health <= 0 then return end

	local targets = {}
	local dotTargets = {}
	
	local characterList = CS:GetTagged("Character")
	local filtered = {}
	for i, c in ipairs(characterList) do
		if c ~= char then
			table.insert(filtered, c)
		end
	end
	
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = filtered
	
	local center
	local oldOrigin
	
	if attributes["shockwave"] then
		oldOrigin = origin
		if typeof(origin) ~= "CFrame" then
			origin = oldOrigin:Clone()
			origin.CFrame = oldOrigin.CFrame * CFrame.new(0, 0, -attributes.atkrad/2)
		else
			origin *= CFrame.new(0, 0, -attributes.atkrad/2)
		end
	end
	
	local bind
	if attributes["getTargets"] then
		bind = Instance.new("BindableEvent")
	end
	
	local changingDOT = false
	
	local loop
	local duration = 0
	loop = RNS.Heartbeat:Connect(function(dt)
		if hum == nil or hum.Health <= 0 then --early end
			loop:Disconnect()
			table.clear(targets)
			if attributes["shockwave"] then origin:Destroy() end
			if attributes["getTargets"] then bind:Fire(nil) end
			return --ends current frame too
		end
		
		if attributes.expanding then attributes.atkrad *= attributes.expanding^dt end
		
		if attributes.DOTchange and not changingDOT then
			changingDOT = true
			
			task.spawn(function()
				while true do
					local initialTime = os.clock()
					
					repeat task.wait() until os.clock() - initialTime >= attributes.DOT or duration >= attributes.atkdur
					
					attributes.DOT *= attributes.DOTchange
					
					if duration >= attributes.atkdur then break end
				end
				
				for i, targetHum: Humanoid in ipairs(dotTargets) do
					if targetHum:HasTag("Immortal") then
						targetHum:RemoveTag("Immortal")
					end
				end
			end)
		end
		
		center = (typeof(origin) == "CFrame" and origin) or origin.CFrame
		
		local hits = workspace:GetPartBoundsInBox(center, Vector3.new(attributes["atkrad"], attributes["atkrad"], attributes["atkrad"]), params)
		for i, part in hits do
			local targetChar = part:FindFirstAncestorOfClass("Model")
			if not targetChar then continue end
			
			local targetPlr = Players:GetPlayerFromCharacter(targetChar)
			local targetRoot: Part = targetChar:FindFirstChild("HumanoidRootPart")
			if not targetRoot then continue end
			
			local targetHum: Humanoid = targetChar:FindFirstChild("Humanoid")
			if not targetHum or targetHum.Health <= 0 or targetHum == hum then continue end
			
			if targetHum:HasTag("Immortal") or targetHum:HasTag("Blessed") then continue end --for i-frames
			
			if targetChar:HasTag("LoadingAttack") then 
				targetChar:AddTag("CancellingAttack")
				
				local connection: RBXScriptConnection
				connection = CS:GetInstanceRemovedSignal("LoadingAttack"):Connect(function(instance)
					if instance == targetChar then
						targetChar:RemoveTag("CancellingAttack")
						connection:Disconnect()
					end
				end)
			end
			
			if not attributes.bypassParry and targetChar:HasTag("Parrying") then
				char:AddTag("Parried")
				
				targetChar:AddTag("SuccessfulParry")
				
				local connection: RBXScriptConnection
				connection = CS:GetInstanceRemovedSignal("Parrying"):Connect(function(instance)
					if instance == targetChar then
						char:RemoveTag("Parried")
						connection:Disconnect()
					end
				end)

				duration = attributes["atkdur"] --cuts off the sequential damage frames

				continue --and protects the parrying player
			end
			
			if attributes["shockwave"] ~= nil then
				local direction = (targetRoot.Position - oldOrigin.Position).Unit
				local dotProduct = (typeof(oldOrigin) == "CFrame" and oldOrigin.LookVector:Dot(direction)) or oldOrigin.CFrame.LookVector:Dot(direction)
				
				if dotProduct < attributes["shockwave"] then continue end
			end

			if not table.find(targets, targetHum) then
				if not attributes["DOT"] then 
					table.insert(targets, targetHum) 
				else
					if not table.find(dotTargets, targetHum) then table.insert(dotTargets, targetHum) end
				end
				
				local dmg: number?, resetDmg: boolean = nil, false
				
				if attributes["oneHit"] and targetPlr then
					duration = attributes["atkdur"] --cuts off the sequential damage frames
					char:AddTag("HitFinished")
					task.delay(0.1, function()
						char:RemoveTag("HitFinished")
					end)
				end

				if attributes["DOT"] then 
					targetHum:AddTag("Immortal") --i-frames for DOT; we're not adding Sans-level mechanics here
					task.delay(attributes["DOT"], function()
						targetHum:RemoveTag("Immortal")
					end)
				end
				
				if targetHum:GetAttribute("Reflect") then
					hum:TakeDamage(attributes.dmg / targetHum:GetAttribute("Reflect"))
					continue
				end
				
				if targetHum:GetAttribute("Shield") then
					if targetHum:GetAttribute("ShieldDirection") then
						local validDirection: string = targetHum:GetAttribute("ShieldDirection")
						
						local dot, direction = spacing.NearestCardinal(targetRoot, origin.Position)
						
						if direction == validDirection then
							local currentShield: number = targetHum:GetAttribute("Shield")
							local newShield: number = currentShield - attributes.dmg

							targetHum:SetAttribute("Shield", newShield)

							if newShield < 0 then
								dmg = newShield * -1
								resetDmg = true
								targetHum:SetAttribute("Shield", nil)
							else
								continue
							end
						end
					end
				end
				
				if not dmg then 
					targetHum:TakeDamage(attributes.dmg) --most important line obviously
				else
					targetHum:TakeDamage(dmg) --for target-specific damage
					if resetDmg then dmg = nil; resetDmg = false end --not useful now, but remains in the case of scripting unique, same-iteration logic
				end
				
				if not targetHum or targetHum.Health <= 0 then 
					if targetPlr then --adds a KO if it's a player
						player.leaderstats["KO's"].Value += 1
						
						local regen = ((hum.MaxHealth - hum.Health) / hum.MaxHealth) * 100
						hum.Health += math.clamp(regen, 0, hum.MaxHealth)
					end
					continue 
				end
				
				if attributes.drainStamina then
					local stamina: number = targetHum:GetAttribute("Stamina")
					if stamina > attributes.drainStamina then 
						targetHum:SetAttribute("Stamina", stamina - attributes.drainStamina)
					else
						targetHum:SetAttribute("Stamina", 0)
					end
				end
				
				if targetChar:HasTag("Resistance") then continue end --available during rush-style and ult attacks
				
				if attributes["precedent"] ~= true then
					if not attributes["noStun"] then --ideal for shockwaves
						print("Hitstun!")
						stun:DurReg(player, targetPlr, attributes["atktype"], attributes["style"], attributes["ID"], "Hit") --hitstun 
					end
					
					if not attributes["noKB"] then --ideal for DOT
						print("Knockback!")
						kb.Eval(player, targetPlr, targetRoot, attributes["atktype"]) --knockback
					end
				end
			end
		end

		--debug visualization (make optional later)
		local testPart = Instance.new("Part")
		testPart.Shape = Enum.PartType.Block
		testPart.Anchored = true
		testPart.CastShadow = false
		testPart.Color = vfxQuirks[player:GetAttribute("Crusader")]
		testPart.CFrame = (typeof(origin) == "CFrame" and origin) or origin.CFrame
		local size = attributes["atkrad"]
		testPart.Size = Vector3.new(size, size, size)
		testPart.CanCollide = false
		testPart.CanQuery = false
		testPart.Transparency = 0.95
		testPart.Parent = workspace
		
		if attributes.bypassParry == true then 
			testPart.Material = Enum.Material.Neon 
			testPart.Transparency = 0.97
		end

		if testPart == nil then warn("Hitbox is nil!") end

		debby:AddItem(testPart, 0.2)

		duration += dt
		if duration >= attributes.atkdur then
			loop:Disconnect()
			if attributes["shockwave"] then 
				if typeof(origin) ~= "CFrame" then 
					origin:Destroy() 
				end
			end
			if attributes["getTargets"] then
				local clonedTargets = table.clone(targets)
				bind:Fire(clonedTargets)
			end
			table.clear(targets)
		end
	end)
	
	if attributes["getTargets"] then
		local clonedTargets = bind.Event:Wait()
		bind:Destroy()
		return clonedTargets
	end
end

return DamageManager