--!strict

--[[
	this is old code, this may get merged with PlayerStatus
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local SpawnPointFolder = ServerStorage:FindFirstChild("SpawnLocations")

local currentSpawnFolder = Instance.new("Folder")
currentSpawnFolder.Name = "CurrentSpawns"
currentSpawnFolder:AddTag("KeepOnRun") --keep on workspace cleanup
currentSpawnFolder.Parent = workspace

local SpawnManager = {}

--[[Sets new spawns by there name]]
function SpawnManager.SetNewSpawns(name: string, ...: string)
	local spawns = { name, ... }

	currentSpawnFolder:ClearAllChildren()

	for _, spawnName in pairs(spawns) do
		task.spawn(function()
			local spawner = SpawnPointFolder:FindFirstChild(spawnName, 2)
			local newSpawner = spawner:Clone()
			newSpawner.Parent = currentSpawnFolder
		end)
	end
end

--[[Reloads the player with a load screen, you can add a function that runs after they are loaded in]]
function SpawnManager.ReloadPlayer(player: Player, onSpawn: () -> ()?)
	task.spawn(function()
		player:SetAttribute("Loading", true)
		task.wait(1)
		player:LoadCharacter()
		task.wait(2)

		if onSpawn then
			onSpawn() --anything you want to happen right after they load
		end

		player:SetAttribute("Loading", false)
	end)
end

--[[Reloads all players in the game]]
function SpawnManager.ReloadPlayers()
	for _, player in pairs(Players:GetPlayers()) do
		SpawnManager.ReloadPlayer(player)
	end
end

return SpawnManager
