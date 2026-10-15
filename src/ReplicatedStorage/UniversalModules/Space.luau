--for PHYSICS :)

local configTable = {
	--1 = bspd, 2 = sspd, 3 = jump, 4 = dmg query's basis
	Redd = {16, 24, 50, 5},
	Yello = {15, 25, 50, 4},
	Gleen = {18, 22, 50, 6},
	Bluee = {17, 23, 50, 5}
}

local kbSpecs = {
	light = 4.5,
	medium = 2.75,
	heavy = 1.5
}

local Space = {}

function Space.GetValue(char: string, ID: number)
	return configTable[char][ID]
end

function Space.Knockback(attackerRoot: Part, targetRoot: Part, atktype: string)
	local modifier = kbSpecs[atktype]
	local direction = -(attackerRoot.Position - targetRoot.Position).Unit
	
	local base = kbSpecs.medium
	local velocity: Vector3 = ((direction*100) - direction*((base^modifier)/base)) * (base/modifier)
	return velocity
end

return Space