--!strict

--[[
	Set specified players health.
]]

local ServerStorage = game:GetService("ServerStorage")

local PlayerStatusUtility = require(ServerStorage.ServerCommon.PlayerStatusUtility)

return function(_data, players, amount)
	local names = {}
	for _, player in pairs(players) do
		PlayerStatusUtility.SetHealth(player, amount)
		table.insert(names, player.Name)
	end

	local setAmount = math.clamp(amount, 0, PlayerStatusUtility.GetMaxHealth())

	return table.concat(names, ", ") .. ": had there health set too " .. tostring(setAmount) .. "."
end
