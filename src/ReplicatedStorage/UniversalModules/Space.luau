--for PHYSICS :)

local configTable = {
	--1 = bspd, 2 = sspd/tolerance divisor, 3 = dmg query's basis
	Redd = {16, 24, 5},
	Yello = {15.5, 25, 4.85},
	Gleen = {17, 22, 4.95},
	Bluee = {16.5, 23, 4.9}
}

local kbSpecs = {
	light = 4.5,
	medium = 2.75,
	heavy = 1.05,
	reverse = -3
}

local frames = { --1 = recovery frames during animation, 2 = endlag (WIP, will finalize after enough beta testing)
	Redd = {
		M1 = {{false, false,false, false}, {0, 0, 0, 0}},
		Bare = {{true, true, true, true}, {0, 0, 0, 0}},
		Weapon = {{true, true, true, true}, {0, 0, 0, 0}},
		Tech = {{true, true, true, true}, {0, 0, 0, 0}}
	},

	Yello = {
		M1 = {{false, false,false, false}, {0, 0, 0, 0}},
		Bare = {{true, true, true, true}, {0, 0, 0, 0}},
		Weapon = {{true, true, true, false}, {0, 0, 0, 0}},
		Tech = {{true, true, true, true}, {0, 0, 0, 0}}
	},

	Gleen = {
		M1 = {{false, false,false, false}, {0, 0, 0, 0}},
		Bare = {{true, true, true, true}, {0, 0, 0, 0}},
		Weapon = {{true, true, true, true}, {0, 0, 0, 0}},
		Tech = {{true, true, true, true}, {0, 0, 0, 0}}
	},

	Bluee = {
		M1 = {{false, false,false, false}, {0, 0, 0, 0}},
		Bare = {{true, true, true, true}, {0, 0, 0, 0}},
		Weapon = {{true, true, true, true}, {0, 0, 0, 0}},
		Tech = {{true, true, true, true}, {0, 0, 0, 0}}
	}
}

local Space = {}

function Space.GetValue(char: string, ID: number)
	return configTable[char][ID]
end

function Space.Knockback(attackerRoot: Part, targetRoot: Part, atktype: string)
	local modifier = kbSpecs[atktype]
	local direction = (targetRoot.Position - attackerRoot.Position).Unit
	
	local base = kbSpecs.medium
	local velocity: Vector3 = ((direction*100) - direction*((base^modifier)/base)) * (base/modifier) --random formula i made up based on feel; will recalibrate to make cleaner in a future update
	
	return velocity
end

function Space.GetFrameInfo(char: string, style: string, category: number, ID: number)
	return frames[char][style][category][ID]
end

function Space.NearestCardinal(root: Part, fromPoint: Vector3)
	local direction = (fromPoint - root.Position).Unit

	local directions = {
		Front = root.CFrame.LookVector,
		Back = -root.CFrame.LookVector,
		Right = root.CFrame.RightVector,
		Left = -root.CFrame.RightVector
	}

	local best, bestName = -math.huge, nil --arbitrary values for setting the baseline
	for name, vector in pairs(directions) do
		local dot = direction:Dot(vector)
		if dot > best then
			best = dot
			bestName = name
		end
	end

	return best::number, bestName::string
end

return Space