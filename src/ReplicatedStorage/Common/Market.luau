--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Admin = require(ReplicatedStorage.Admin)

local Market = {}

Market.Id = {
	GamePasses = {
		BetterFlashlight = 0,
	},
	Subscriptions = {},
}

--[[
	Checks if the player has the specified Gamepass.

	@param playerId number -  the ID of the Player
	@param gamepassId number -  the ID of the Gamepass

	@return boolean - was it successful
]]
function Market.PlayerOwnsGamepass(playerId: number, gamepassId: number, attempts: number?): boolean
	local maxAttempts = attempts or 5
	local currentAttempts = 0

	local function giveGamepass()
		if Admin.IsAdmin(playerId) then
			return true
		end

		local gamepassPlayer = Players:GetPlayerByUserId(playerId)

		if not gamepassPlayer then
			warn("Could not find player with Id of " .. playerId .. ", for gamepass Id " .. gamepassId)
			return false
		end

		local success, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(gamepassPlayer, gamepassId)
		end)

		if success then
			return result
		else
			if currentAttempts >= maxAttempts then
				return false
			end
			currentAttempts += 1

			warn("Could not find Gamepass with an Id of " .. gamepassId .. " for player:" .. gamepassPlayer.Name)

			giveGamepass()
		end

		return false
	end

	return giveGamepass()
end

--[[
	Checks if the local player has the specified Gamepass.

	@param Id number -  the ID of the Gamepass

	@return boolean - was it successful
]]
function Market.LocalPlayerOwnsGamepass(Id: number, attempts: number?): boolean
	local player = Players.LocalPlayer

	return Market.PlayerOwnsGamepass(player.UserId, Id, attempts)
end

return Market
