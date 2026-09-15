--!strict

--[[
	Kill specified Players.
]]

local ServerStorage = game:GetService("ServerStorage")

local PlayerStatusUtility = require(ServerStorage.ServerCommon.PlayerStatusUtility)

return function(_data, players)
	local names = {}
	for _, player in pairs(players) do
		PlayerStatusUtility.KillPlayer(player)
		table.insert(names, player.Name)
	end

	return table.concat(names, ", ") .. ": were killed!"
end
