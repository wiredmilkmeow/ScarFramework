--!strict

--[[
	All Collision Groups for the Game.

	Needs to be in code so It Applies in New Places.
]]

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

--for players
PhysicsService:RegisterCollisionGroup("Player")
PhysicsService:CollisionGroupSetCollidable("Default", "Player", true)
PhysicsService:CollisionGroupSetCollidable("Player", "Player", false)

--stuff that can only collide with default and nothing else
PhysicsService:RegisterCollisionGroup("DefaultOnly")
PhysicsService:CollisionGroupSetCollidable("Default", "DefaultOnly", true)
PhysicsService:CollisionGroupSetCollidable("Player", "DefaultOnly", false)
PhysicsService:CollisionGroupSetCollidable("DefaultOnly", "DefaultOnly", false)

local function SetPlayerCollisions(player: Player)
	local function setCharacterCollisions(character: Model)
		for _, inst in pairs(character:GetDescendants()) do
			if not inst:IsA("BasePart") then
				continue
			end
			inst.CollisionGroup = "Player"
		end
	end

	if player.Character then
		setCharacterCollisions(player.Character)
	end
	player.CharacterAdded:Connect(function(character: Model)
		setCharacterCollisions(character)
	end)
end

for _, player in pairs(Players:GetPlayers()) do
	SetPlayerCollisions(player)
end
Players.PlayerAdded:Connect(function(player: Player)
	SetPlayerCollisions(player)
end)

return {}
