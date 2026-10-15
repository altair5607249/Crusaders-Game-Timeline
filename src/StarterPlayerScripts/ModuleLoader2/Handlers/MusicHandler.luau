local Players = game:GetService("Players")
local SNS = game:GetService("SoundService")
local TS = game:GetService("TweenService")

local player = Players.LocalPlayer
local PG = player:WaitForChild("PlayerGui")

local settingsManager = require(PG:WaitForChild("Settings").ModuleLoader4.Manager)

local tweenTime = 5
local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local music = {}

function music.Volume(music: string, enabled: boolean)
	local goal: number = settingsManager.GetSetting("Music")/100

	if enabled then --to enable
		music.Playing = enabled
	else --to disable
		goal = 0
		task.delay(tweenTime, function()
			music.Playing = enabled
		end)
	end

	local tweenMusic = TS:Create(music, tweenInfo, {Volume = goal})

	tweenMusic:Play()

	tweenMusic.Completed:Connect(function()
		tweenMusic:Destroy()
	end)
end

return music