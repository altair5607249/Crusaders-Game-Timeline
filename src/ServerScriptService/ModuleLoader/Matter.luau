--my alternative to a character-attributes list, because it is way too insecure
local CP = game:GetService("ContentProvider") --dont make fun of me, id rather abbreviate most services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")

local function preloadMapAssets(mapModel: Model)
	local assetsToLoad = {}

	for _, descendant in ipairs(mapModel:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("ParticleEmitter") or descendant:IsA("Sound") or descendant:IsA("Texture") then
			table.insert(assetsToLoad, descendant)
		end
	end

	CP:PreloadAsync(assetsToLoad)
end

local activeSpawns = {}
local CMS = {} --short for Character Management System

--r6 body parts used by skins
local R6BodyParts = {
	"Head",
	"Torso",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
}

local function applyR6Body(character: Model, skinTemplate: Model) --applies r6 appearance without using the rig itself
	for _, item in ipairs(character:GetChildren()) do --remove the base rig's char meshes
		if item:IsA("CharacterMesh") then
			item:Destroy()
		end
	end

	for _, item in ipairs(skinTemplate:GetChildren()) do --copy the skin's char meshes
		if item:IsA("CharacterMesh") and item.BodyPart ~= Enum.BodyPart.Head then
			item:Clone().Parent = character
		end
	end

	--apply the skin's special head mesh to the existing r6 head
	local liveHead = character:FindFirstChild("Head")
	local skinHead = skinTemplate:FindFirstChild("Head")

	if liveHead and skinHead then
		local liveMesh = liveHead:FindFirstChildOfClass("SpecialMesh")
		local skinMesh = skinHead:FindFirstChildOfClass("SpecialMesh")

		if liveMesh and skinMesh then
			liveMesh.MeshId = skinMesh.MeshId
			liveMesh.TextureId = skinMesh.TextureId
			liveMesh.Scale = skinMesh.Scale
			liveMesh.Offset = skinMesh.Offset
		end
	end
end

local function applySkin(model: Model, skinTemplate: Model, hum: Humanoid)
	local liveColors = model:FindFirstChildOfClass("BodyColors")
	local skinColors = skinTemplate:FindFirstChildOfClass("BodyColors")

	if liveColors and skinColors then
		liveColors.HeadColor3 = skinColors.HeadColor3
		liveColors.TorsoColor3 = skinColors.TorsoColor3
		liveColors.LeftArmColor3 = skinColors.LeftArmColor3
		liveColors.RightArmColor3 = skinColors.RightArmColor3
		liveColors.LeftLegColor3 = skinColors.LeftLegColor3
		liveColors.RightLegColor3 = skinColors.RightLegColor3
	end

	local liveShirt = model:FindFirstChildOfClass("Shirt")
	local skinShirt = skinTemplate:FindFirstChildOfClass("Shirt")

	if liveShirt then liveShirt:Destroy() end
	if skinShirt then skinShirt:Clone().Parent = model end

	local livePants = model:FindFirstChildOfClass("Pants")
	local skinPants = skinTemplate:FindFirstChildOfClass("Pants")

	if livePants then livePants:Destroy() end
	if skinPants then skinPants:Clone().Parent = model end

	for _, item in ipairs(model:GetChildren()) do
		if item:IsA("Accessory") then
			if item.Name == "Main" and skinTemplate.Name ~= "Default" then continue end
			item:Destroy()
		end
	end

	for _, item in ipairs(skinTemplate:GetChildren()) do
		if item:IsA("Accessory") then
			hum:AddAccessory(item:Clone())
		end
	end

	for _, item in ipairs(model:GetChildren()) do
		if item:IsA("ShirtGraphic") then
			item:Destroy()
		end
	end

	local skinTShirt = skinTemplate:FindFirstChildOfClass("ShirtGraphic")

	if skinTShirt then
		skinTShirt:Clone().Parent = model
	end

	local liveHead = model:FindFirstChild("Head")
	local skinHead = skinTemplate:FindFirstChild("Head")

	if liveHead and skinHead then
		local liveFace = liveHead:FindFirstChild("face")
		local skinFace = skinHead:FindFirstChild("face")
		if liveFace and skinFace then
			liveFace.Texture = skinFace.Texture
			liveFace.Transparency = 0 --in case a previous skin (with no face decal) hid it
		elseif liveFace and not skinFace then
			--this skin's face is baked into its custom head mesh instead of a separate decal;
			--hide the base rig's default face so it doesn't render underneath/over the mesh's own texture
			liveFace.Transparency = 1
		end
	end
end

local function findTemplate(crusader: string, skin: string)
	if not skin then skin = "Default" end
	local crusaderFolder = SS.Characters:FindFirstChild(crusader)
	if not crusaderFolder then warn("Colored Crusader not found:", crusader) return end

	local baseTemplate = crusaderFolder:FindFirstChild("Default") --default template is the base rig :)
	if not baseTemplate then warn("Default Crusader rig not found:", crusader) return end

	local skinTemplate = crusaderFolder:FindFirstChild(skin) --applies the skin's appearance if found
	if not skinTemplate then
		warn("Skin not found:", crusader, skin, "! Switching to Default") --fallback #1

		skinTemplate = crusaderFolder:FindFirstChild("Default")

		if not skinTemplate then
			warn("Default skin is also missing for", crusader) --fallback #2
			return
		end
	end

	return baseTemplate, skinTemplate
end

RS.Remotes.ClientReadiness.OnServerEvent:Connect(function(player, ready: boolean)
	CMS.Life(player, "Redd", "Default")
end)

function CMS.Life(player: Player, crusader: string, skin: string, immortalDuration: number)
	if player.Parent ~= Players then return end

	local baseTemplate, skinTemplate = findTemplate(crusader, skin)

	player:SetAttribute("Crusader", crusader) --must remain consistent across player deaths
	player:SetAttribute("Skin", skin) --skin is saved LIKE crusader, though they are not equivalent

	local model = baseTemplate:Clone() --uses the base template
	model.Name = player.Name

	if player.Character then player.Character:Destroy() end --destroys any pre-existing models in case of overlap

	player.Character = model --assigns the model
	model.Parent = workspace --brings the model into existence

	local hum = model:WaitForChild("Humanoid")

	applyR6Body(model, skinTemplate) --applies the r6 appearance
	applySkin(model, skinTemplate, hum) --applies the custom skin's appearance

	if #activeSpawns == 0 then
		warn("No active spawns available!")
		repeat task.wait() until #activeSpawns ~= 0 --anything is better than non-existence; this should not return nil and end
	end

	model:MoveTo(activeSpawns[math.random(1, #activeSpawns)].Position) --moves the player model to a random spawn
	player:RemoveTag("Limbo")
	
	if immortalDuration then
		hum:AddTag("Immortal")

		local expiresAt = os.clock() + immortalDuration
		local current = player:GetAttribute("ImmortalUntil") or 0
		if expiresAt > current then
			player:SetAttribute("ImmortalUntil", expiresAt)
		end

		print(("[Life] Immortality added to %s (delay=%d, t=%.3f, until=%.3f)"):format(player.Name, immortalDuration, os.clock(), expiresAt))

		task.delay(immortalDuration, function()
			if hum.Parent and os.clock() >= (player:GetAttribute("ImmortalUntil") or 0) then
				print(("[Life] Immortality rescinded from %s (delay=%d, t=%.3f)"):format(player.Name, immortalDuration, os.clock()))
				hum:RemoveTag("Immortal")
			end
		end)
	end

	hum.Died:Connect(function() --prevents full recursiveness of life and death
		CMS.Death(player, crusader)
	end)
end

function CMS.Death(player: Player, crusader: string, immortalDuration: number)
	if player:HasTag("Limbo") then
		print(("[Death] SKIPPED for %s — already in Limbo"):format(player.Name))
		return
	end
	player:AddTag("Limbo")

	if immortalDuration and player.Character then
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:AddTag("Immortal")

			local expiresAt = os.clock() + 2.25 + immortalDuration
			local current = player:GetAttribute("ImmortalUntil") or 0
			if expiresAt > current then
				player:SetAttribute("ImmortalUntil", expiresAt)
			end
		end
	end

	RS.Remotes.Transition:FireClient(player)
	task.wait(2.25)

	local skin = player:GetAttribute("Skin") or "Default"
	CMS.Life(player, crusader, skin, immortalDuration and 2.25 + immortalDuration)
end

function CMS.ManageSpawns(spawns: Folder, enabled: boolean)
	if enabled then
		for i, location: SpawnLocation in ipairs(spawns:GetChildren()) do
			table.insert(activeSpawns, location)
		end
	else
		for i, location: SpawnLocation in ipairs(spawns:GetChildren()) do
			local index = table.find(activeSpawns, location)

			if index then table.remove(activeSpawns, index) end
		end
	end
end

return CMS