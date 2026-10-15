local configTable = {
	--category 1 = delay, category 2 = cooldown, category 3 = full anim time, category 4 = hitstun times, category 5 = continuation (nil if early end)
	Redd = {
		M1 = {{0.2, 0.2, 0.2, 0.2}, {0.399, 0.399, 0.399, 2.249}, {0.4, 0.4, 0.4, 0.4}, {0.8, 0.8, 0.8, 0}, {false, false, false, false}},
		Bare = {{0.25, 0.5, 0.4, 0.05}, {14, 20, 25, 30}, {0.6, 1.5, 4, 1.5}, {1, 2.5, 0.35, 0}, {false, false, false, nil}},
		Weapon = {{0.3, 0.5, 0.25, 0.05}, {16, 1, 1, 3}, {0.6, 1, 1.25, 2.03}, {0.5, 0.5, 0.5, 0.5}, {false, false, false, false}},
		Tech = {{0, 0, 0.13, 0}, {8, 4, 2, 0.8}, {0.7, 0.3, 0.93, 0.8}, {0, 0, 0, 0}, {false, false, nil, false}}
	},

	Yello = {
		M1 = {{0.15, 0.15, 0.15, 0.3}, {0.299, 0.299, 0.299, 1.999}, {0.3, 0.3, 0.3, 0.5}, {0.5, 0.5, 0.5, 0.1}, {false, false, false, false}},
		Bare = {{0.3, 0.1, 0.2, 0.01}, {10, 13, 17, 14}, {0.4, 0.2, 0.5, 0.06}, {0.5, 0.5, 1, 0.25}, {false, false, false, false}},
		Weapon = {{0.4, 0.4, 0.4, 0.4}, {1, 1, 1, 1}, {0.4, 0.4, 0.4, 0.4}, {0.5, 0.5, 0.5, 0.5}, {false, false, false, false}},
		Tech = {{0, 0, 0.13, 0}, {8, 4, 2, 0.8}, {0.7, 0.3, 0.93, 0.8}, {0, 0, 0, 0}, {false, false, nil, false}}
	},

	Gleen = {
		M1 = {{0.25, 0.25, 0.25, 0.25}, {0.499, 0.499, 0.499, 2.499}, {0.5, 0.5, 0.5, 0.5}, {0.8, 0.8, 0.8, 0}, {false, false, false, false}},
		Bare = {{0.3, 0.4, 0.25, 0.3}, {17, 26, 14, 20}, {0.8, 1.9, 1, 1.8}, {0.3, 0, 0.75, 1}, {true, true, true, nil}},
		Weapon = {{0.4, 0.4, 0.4, 0.4}, {1, 1, 1, 1}, {0.4, 0.4, 0.4, 0.4}, {1, 1, 1, 1}, {false, false, false, false}},
		Tech = {{0, 0, 0.13, 0}, {8, 4, 2, 0.8}, {0.7, 0.3, 0.93, 0.8}, {0, 0, 0, 0}, {false, false, nil, false}}
	},

	Bluee = {
		M1 = {{0.2, 0.2, 0.2, 0.2}, {0.399, 0.399, 0.299, 2.249}, {0.4, 0.4, 0.4, 0.4}, {0.75, 0.75, 0.75, 0}, {false, false, false, false}},
		Bare = {{0.3, 0.01, 0.4, 0.5}, {20, 25, 23, 35}, {1.3, 0.01, 3.4, 3}, {1, 0, 0.25, 2.5}, {false, false, false, nil}},
		Weapon = {{0.4, 0.4, 0.4, 0.4}, {1, 1, 1, 1}, {0.4, 0.4, 0.4, 0.4}, {0.5, 0.5, 0.5, 0.5}, {false, false, false, false}},
		Tech = {{0, 0, 0.13, 0}, {8, 4, 2, 0.8}, {0.7, 0.3, 0.93, 0.8}, {0, 0, 0, 0}, {false, false, nil, false}}
	}
}

local Time = {}

function Time.GetValue(char: string, style: string, category: number, ID: number)
	return configTable[char][style][category][ID]
end

function Time.CheckConstraint(prevInput: number, constraint: number) --checks if the constraint is active
	return os.clock() - prevInput < constraint
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