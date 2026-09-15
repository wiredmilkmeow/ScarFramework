--!strict

--[[
	Send InfoBox to specified Players.
]]

local ServerStorage = game:GetService("ServerStorage")

local InfoBox = require(ServerStorage.ServerCommon.InfoBox)

local random = Random.new()

local thread: thread? = nil
return function(_data, players, action, v1, v2, v3)
	local length = 0

	if action == "TestLine" then
		local prevState = thread ~= nil

		if thread then
			task.cancel(thread)
		else
			thread = task.spawn(function()
				while task.wait(random:NextNumber(1, 5)) do
					local text = ("This is the test line made %s seconds on startup!!!!"):format(tostring(time()))
					for _, player in pairs(players) do
						InfoBox.SendLineToPlayer(player, player, text, 500)
					end
				end
			end)
		end

		return ("Test line was %s"):format(not prevState and "Enabled" or "Disabled")
	end

	for _, player in pairs(players) do
		if action == "LocalHeader" then
			length = InfoBox.SendLineToPlayer(player, player, v1, v2)
		elseif action == "CustomHeader" then
			length = InfoBox.SendLineToPlayer(player, v1, v2, v3)
		end
	end

	return ("Sent a line that will exist for %s seconds."):format(tostring(length))
end
