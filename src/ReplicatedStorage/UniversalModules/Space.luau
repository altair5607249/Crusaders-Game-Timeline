local configTable = {
	--1 = bspd, 2 = sspd, 3 = jump, 4 = dmg query's basis
	Redd = {16, 24, 50, 5},
	Yello = {15, 25, 50, 4},
	Gleen = {18, 22, 50, 6},
	Bluee = {17, 23, 50, 5}
}

local kbSpecs = {
	light = 3.5,
	medium = 3.99,
	heavy = 4
}

local Space = {}

function Space.GetValue(char: string, ID: number)
	return configTable[char][ID]
end

function Space.Knockback(root: Part, attackData: {Instance})
	local modifier = kbSpecs[attackData["atktype"]]
	local direction = root.CFrame.LookVector
	
	local velocity: number = direction*(100^(100^(modifier-4))*(attackData["dmg"]/attackData["bdmg"])) + direction*35
	return velocity
end

return Space