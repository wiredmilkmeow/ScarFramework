--!strict

-- local Players = game:GetService("Players")

-- local function removeRootSounds(player: Player)
-- 	local function removeSounds(character: Model)
-- 		task.wait()
-- 		local root = character:FindFirstChild("HumanoidRootPart") :: BasePart
-- 		if not root then
-- 			return
-- 		end

-- 		for _, inst in pairs(root:GetChildren()) do
-- 			if not inst:IsA("Sound") then
-- 				continue
-- 			end
-- 			if inst:GetAttribute("IsFrameworkSound") then
-- 				continue
-- 			end
-- 			inst.Volume = 0
-- 			inst.PlaybackSpeed = 0
-- 		end
-- 	end

-- 	if player.Character then
-- 		removeSounds(player.Character)
-- 	end

-- 	player.CharacterAdded:Connect(function(character: Model)
-- 		removeSounds(character)
-- 	end)
-- end

-- for _, player in pairs(Players:GetPlayers()) do
-- 	removeRootSounds(player)
-- end

-- Players.PlayerAdded:Connect(function(player: Player)
-- 	removeRootSounds(player)
-- end)

return {}
