local cache = {}

local animHandler = {}

function animHandler:ClearCache()
	table.clear(cache)
end

function animHandler:LoadAnimations(animator: Animator, animations: Folder, crusader: string, style: string)
	local ID = crusader .. "_" .. style
	if cache[ID] then
		return cache[ID]
	end
	
	local animTracks = {}
	
	local charAnims = animations[crusader]:GetChildren()
	table.sort(charAnims, function(a, b)
		return a:GetAttribute("Order") < b:GetAttribute("Order")
	end)
	
	for i, anim in ipairs(charAnims) do
		local animTrack = animator:LoadAnimation(anim)
		animTrack.Name = ID
		table.insert(animTracks, animTrack)
	end
	
	cache[ID] = animTracks
	return animTracks
end

return animHandler