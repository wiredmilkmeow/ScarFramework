--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local Sounds = require(ReplicatedStorage.Common.Sounds)

local footsteps = require(script:FindFirstChild("FootstepTable"))

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local humanoid: Humanoid? = nil
local root: Part? = nil

local variance = Sounds.Variance(0.97, 1.03, 0.97, 1.03)

local lastFootstepSound = nil
local function PlayFootstepSound(foot, material)
	if not foot then
		return
	end

	local sounds = footsteps.sounds[material]
	if not sounds then
		return
	end

	local random = Random.new()
	local soundId = sounds[random:NextInteger(1, #sounds)]

	if soundId and soundId ~= lastFootstepSound then
		lastFootstepSound = soundId

		task.spawn(function()
			local sfx = Sounds.FindSoundByName("Footstep", variance, root)
			if not sfx then
				return
			end

			sfx.SoundId = soundId
			sfx.Volume = (footsteps.volume[material] or 0.2) * variance.Volume()

			sfx.PlayOnRemove = true
			sfx:Destroy()
		end)
	else
		PlayFootstepSound(foot, material)
	end
end

local function OnFootStep()
	if not humanoid or not root then
		return
	end

	local floorMaterial = humanoid.FloorMaterial
	local material = footsteps.materialMap[floorMaterial]

	PlayFootstepSound(root, material)
end

------------------------------------------------------------------------------------

local function getCharacterParts()
	if not player.Character then
		return
	end

	pcall(function()
		humanoid = player.Character:WaitForChild("Humanoid", 3) :: Humanoid
		root = player.Character:WaitForChild("HumanoidRootPart", 3) :: Part
	end)
end

getCharacterParts()
player.CharacterAdded:Connect(getCharacterParts)

RedEvents.Signal.Client.FootStep:Connect(function(isRightFoot: boolean)
	local _side = isRightFoot and "Right " or "Left "
	OnFootStep()
end)

return {}
