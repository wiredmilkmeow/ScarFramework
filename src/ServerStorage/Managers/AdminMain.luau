--!strict

--[[
    All the logic that determines if your an admin or not.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RedEvents = require(ReplicatedStorage.RedEvents)

local adminIds = {
	328686652, --fatmad
	2221989135, --viper
}

function isAdmin(id: number): boolean
	local isRegular = Players:GetAttribute("AdminIsRegularPlayer") and RunService:IsStudio() --only for studio testing.
	local existsOnLookup = table.find(adminIds, id) ~= nil

	if not isRegular and existsOnLookup then
		return true
	elseif not isRegular and id < 0 then
		return true
	else
		return false
	end
end

local receiveSignal = RedEvents.SystemConnect.CreateReceiver("ADMIN")
receiveSignal("IsAdmin", isAdmin)

RedEvents.Network.Client.IsAdmin:SetCallback(function(_playerWhoCalled: Player, playerId: number): boolean
	return isAdmin(playerId)
end)

return {}
