--for PHYSICS :)

local configTable = {
	--1 = bspd, 2 = sspd/tolerance divisor, 3 = dmg query's basis
	Redd = {16, 24, 5},
	Yello = {15, 25, 4},
	Gleen = {18, 22, 6},
	Bluee = {17, 23, 5}
}

local kbSpecs = {
	light = 4.5,
	medium = 2.75,
	heavy = 1.25,
	reverse = -3
}

local Space = {}

function Space.GetValue(char: string, ID: number)
	return configTable[char][ID]
end

function Space.Knockback(attackerRoot: Part, targetRoot: Part, atktype: string)
	local modifier = kbSpecs[atktype]
	local direction = -(attackerRoot.Position - targetRoot.Position).Unit
	print(direction)
	
	local base = kbSpecs.medium
	local velocity: Vector3 = ((direction*100) - direction*((base^modifier)/base)) * (base/modifier)
	print(velocity)
	return velocity
end

return Space