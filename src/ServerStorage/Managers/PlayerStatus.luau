--!strict

--[[
	Initializes players Health and adjusts Health.
]]

local PLAYER_MAX_HEALTH = 100

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local Players = game:GetService("Players")

function SetHealth(player: Player, amount: number)
	player:SetAttribute("_Health", math.clamp(amount, 0, PLAYER_MAX_HEALTH))
end

function GetHealth(player: Player): number
	return player:GetAttribute("_Health") :: number or PLAYER_MAX_HEALTH
end

function AddHealth(player: Player, amount: number)
	SetHealth(player, GetHealth(player) + amount)
end

function GetDeadStatus(player: Player): boolean
	return player:GetAttribute("_Dead") :: boolean or false
end

function KillPlayer(player: Player)
	SetHealth(player, 0)
end

function SetDeath(player: Player)
	player:SetAttribute("_Dead", GetHealth(player) == 0)
end

local regenConnections: { [number]: thread } = {}
local function PassiveRegen(player: Player)
	if regenConnections[player.UserId] then
		task.cancel(regenConnections[player.UserId])
	end

	regenConnections[player.UserId] = task.spawn(function()
		while task.wait(1) do
			if GetDeadStatus(player) then
				task.cancel(regenConnections[player.UserId])
				break
			end

			AddHealth(player, 1)
		end
	end)
end

local function CharacterAdded(player: Player)
	player.CharacterAdded:Connect(function()
		SetHealth(player, PLAYER_MAX_HEALTH)
		PassiveRegen(player)
	end)

	player:GetAttributeChangedSignal("_Health"):Connect(function()
		SetDeath(player)
	end)

	SetHealth(player, PLAYER_MAX_HEALTH)
end

for _, player in ipairs(Players:GetPlayers()) do
	CharacterAdded(player)
end
Players.PlayerAdded:Connect(function(player: Player)
	CharacterAdded(player)
end)

---------------------------------------------------------------------------------------

local receiveSignal = RedEvents.SystemConnect.CreateReceiver("PlayerStatusServer")

receiveSignal("SetHealth", function(player: Player, amount: number)
	SetHealth(player, amount)
end)

receiveSignal("GetHealth", function(player: Player): number
	return GetHealth(player)
end)

receiveSignal("GetMaxHealth", function(): number
	return PLAYER_MAX_HEALTH
end)

receiveSignal("AddHealth", function(player: Player, amount: number)
	AddHealth(player, amount)
end)

receiveSignal("GetDeadStatus", function(player: Player): boolean
	return GetDeadStatus(player)
end)

receiveSignal("KillPlayer", function(player: Player)
	KillPlayer(player)
end)

receiveSignal("CurrentMovementState", function(player: Player): "Crouch" | "Walk" | "Sprint"
	return "Walk" -- logic will be added in later if this even gets used.
end)

--TODO
--option to load player and to set spawn points.

return {}.
