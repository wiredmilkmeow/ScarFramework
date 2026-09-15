--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RedEvents = require(ReplicatedStorage:WaitForChild("RedEvents"))

local sendSignal = RedEvents.SystemConnect.CreateSender("ADMIN")

--[[
	Checks if a player is an admin by Id
]]
local Admin = {}

--[[
	Checks if the provided ID is from an admin.

	@param id number - id of a roblox player

	@return boolean - was that id an admin?
]]
function Admin.IsAdmin(id: number): boolean
	if RunService:IsServer() then
		return sendSignal("IsAdmin", id)
	else
		return RedEvents.Network.Client.IsAdmin:Call(id):Await()
	end
end

--[[
	Checks if local player is an admin.
	
	@note only works locally

	@return boolean - is local player admin?
]]
function Admin.IsLocalAdmin(): boolean
	if RunService:IsServer() then
		warn("IsLocalAdmin was ran on the server!")
		return false
	end

	local player = Players.LocalPlayer
	if not player then
		return false
	end
	return Admin.IsAdmin(player.UserId)
end

return Admin
