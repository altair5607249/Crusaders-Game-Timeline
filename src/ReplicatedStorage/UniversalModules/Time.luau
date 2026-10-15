local configTable = {
	--category 1 = delay, category 2 = cooldown, category 3 = full anim time, category 4 = stun times
	Redd = {
		M1 = {{0.2, 0.2, 0.2, 0.2}, {0.399, 0.399, 0.399, 2.249}, {0.4, 0.4, 0.4, 0.4}, {0.4, 0.4, 0.4, 0}},
		Bare = {{0.3, 0.5, 0.2, 0.083}, {10, 20, 25, 20}, {1.25, 1.5, 1, 0.8}, {0.5, 0.5, 0.5, 0.5}},
		Weapon = {{0.4, 0.4, 0.4, 0.4}, {1, 1, 1, 1}, {0.4, 0.4, 0.4, 0.4}, {0.5, 0.5, 0.5, 0.5}}
	},

	Yello = {
		M1 = {{0.15, 0.15, 0.15, 0.35}, {0.299, 0.299, 0.299, 1.999}, {0.3, 0.3, 0.3, 0.5}, {0.32, 0.32, 0.32, 0.01}},
		Bare = {{0.3, 0.3, 0.3, 0.3}, {1, 1, 1, 1}, {0.4, 0.4, 0.4, 0.4}, {0.5, 0.5, 0.5, 0.5}},
		Weapon = {{0.4, 0.4, 0.4, 0.4}, {1, 1, 1, 1}, {0.4, 0.4, 0.4, 0.4}, {0.5, 0.5, 0.5, 0.5}}
	},

	Gleen = {
		M1 = {{0.25, 0.25, 0.25, 0.25}, {0.499, 0.499, 0.499, 2.499}, {0.5, 0.5, 0.5, 0.5}, {0.5, 0.5, 0.5, 0}},
		Bare = {{0.3, 0.3, 0.3, 0.3}, {1, 1, 1, 1}, {0.4, 0.4, 0.4, 0.4}, {1, 1, 1, 1}},
		Weapon = {{0.4, 0.4, 0.4, 0.4}, {1, 1, 1, 1}, {0.4, 0.4, 0.4, 0.4}, {1, 1, 1, 1}}
	},

	Bluee = {
		M1 = {{0.2, 0.2, 0.2, 0.2}, {0.399, 0.399, 0.299, 2.249}, {0.4, 0.4, 0.4, 0.4}, {0.4, 0.4, 0.4, 0}},
		Bare = {{0.3, 0.3, 0.3, 0.3}, {1, 1, 1, 1}, {0.4, 0.4, 0.4, 0.4}, {0.5, 0.5, 0.5, 0.5}},
		Weapon = {{0.4, 0.4, 0.4, 0.4}, {1, 1, 1, 1}, {0.4, 0.4, 0.4, 0.4}, {0.5, 0.5, 0.5, 0.5}}
	}

}

local Time = {}

function Time.GetValue(char: string, style: string, category: number, ID: number)
	return configTable[char][style][category][ID]
end

function Time.CheckConstraint(prevInput: number, constraint: number) --checks if the constraint is active
	return tick() - prevInput < constraint
end

function Time.M1Timing(prevCount: number, prevInput: number, comboExtension: number)
	local count = prevCount

	if (Time.CheckConstraint(prevInput, comboExtension) or prevInput == 0) and count < 4 then
		count += 1
	else
		count = 1
	end

	return count
end

return Time