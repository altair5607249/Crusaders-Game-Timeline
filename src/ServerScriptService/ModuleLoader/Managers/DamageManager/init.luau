local Players = game:GetService("Players")
local CS = game:GetService("CollectionService")
local debby = game:GetService("Debris")
local RNS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS.Remotes
local hitboxes = remotes.Hitboxes
local playAnim = remotes.PlayAnimation

local spacing = require(RS.UniversalModules.Space)

local data = require(script.Parent.DataManager)
local kb = require(script.Parent.KnockbackManager)
local stun = require(script.Parent.StunManager)

local DamageManager = {}

--Deals damage, with the player argument as the adminstrator of said damage.
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
			
			-- prevent any inherited weld/motor6d from repositioning this clone via physics
			origin.Anchored = true
			for _, child in ipairs(origin:GetChildren()) do
				if child:IsA("WeldConstraint") or child:IsA("Motor6D") or child:IsA("Weld") then
					child:Destroy()
				end
			end
			
			origin.CFrame = oldOrigin.CFrame * CFrame.new(0, 0, -attributes.atkrad/2)
			origin.CanCollide = false
			origin.CanQuery = false
			origin.Parent = workspace
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
					duration = attributes.atkdur --cuts off the sequential damage frames
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
					
					local reflect = script.ReflectHit:Clone()
					reflect.Parent = root
					reflect:Play()
					reflect.Ended:Connect(function()
						reflect:Destroy()
					end)
					
					if attributes["precedent"] ~= true then
						if not attributes["noStun"] then --ideal for shockwaves
							stun:DurReg(player, targetPlr, attributes["atktype"], attributes["style"], attributes["ID"], "Hit") --hitstun 
						end

						if not attributes["noKB"] then --ideal for DOT
							kb.Eval(player, targetPlr, targetRoot, attributes["atktype"]) --knockback
						end
					end
					
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
								
								local breaking = script.ShieldBreak:Clone()
								breaking.Parent = targetRoot
								breaking:Play()
								breaking.Ended:Connect(function()
									breaking:Destroy()
								end)
							else
								local block = script.ShieldHit:Clone()
								block.Parent = targetRoot
								block:Play()
								block.Ended:Connect(function()
									block:Destroy()
								end)
								
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
				
				if not attributes.noSound then --for avoiding too much boilerplate sfx code
					local damageSfx = (attributes.customSound::Sound ~= nil and attributes.customSound:Clone()::Sound) or script.Damage:Clone()
					damageSfx.Parent = (attributes.soundTarget::Part ~= nil and attributes.soundTarget::Part) or root
					damageSfx:Play()
					damageSfx.Ended:Connect(function()
						damageSfx:Destroy()
					end)
				end
				
				if not targetHum or targetHum.Health <= 0 then 
					if targetPlr then --adds a KO if it's a player
						player.leaderstats["KO's"].Value += 1
						
						if not hum or hum.Health <= 0 or player.Parent ~= Players then return end
						
						local regen = ((hum.MaxHealth - hum.Health) / hum.MaxHealth) * 100
						hum.Health += math.clamp(regen, 0, hum.MaxHealth)
						
						local sfx = script.Regen:Clone()
						sfx.Parent = root
						sfx:Play()
						sfx.Ended:Connect(function()
							sfx:Destroy()
						end)
					end
					continue 
				end
				
				if attributes.drainStamina and targetHum:GetAttribute("Stamina") then
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
						stun:DurReg(player, targetPlr, attributes["atktype"], attributes["style"], attributes["ID"], "Hit") --hitstun 
					end
					
					if not attributes["noKB"] then --ideal for DOT
						kb.Eval(player, targetPlr, targetRoot, attributes["atktype"]) --knockback
					end
				end
			end
		end

		--debug visualization
		local playerData = data.GetPlayerData(player)
		if playerData and playerData.preferences.Hitboxes == true then
			hitboxes:FireClient(player, attributes.atkrad, attributes.bypassParry, origin)
		end

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