--!strict

local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.promise)

--[[
	Tools for finding Badges and Giving them to Players.
]]
local Badge = {}

--[[
	Badge ID's for the game.
]]
Badge.Badges = {
	JoinedTheGame = 00000,
	Test = 00000,
}

--[[
	Attempts to give the given badge to the given player.

	@param player Player - The player to give the badge too
	@param badgeId number - The id of the badge
	@param attempts number - Amount of times to attempt the badge if failed (defaults to 5)
]]
function Badge.Give(player: Player, badgeId: number, attempts: number?)
	local function giveBadge()
		return Promise.new(function(resolve, reject)
			local success = BadgeService:AwardBadge(player.UserId, badgeId)

			if not success then
				reject("Could not award Badge with Id" .. badgeId .. " to Player: " .. player.Name)
			else
				resolve()
			end
		end):catch(warn)
	end

	Promise.retry(giveBadge, attempts or 5):catch(warn)
end

--[[
	Similar to give function but gives badges to all current players.
	
	@param badgeId number - The id of the badge
	@param attempts number - Amount of times to attempt the badge if failed (defaults to 5)
]]
function Badge.GiveAll(badgeId: number, attempts: number?)
	for _, player in Players:GetPlayers() do
		Badge.Give(player, badgeId, attempts)
	end
end

return Badge
