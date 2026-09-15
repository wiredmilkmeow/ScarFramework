--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)
local RedEvents = require(ReplicatedStorage.RedEvents)

--[[
    Tools for sending Info Lines to specified Players with specified info.
]]
local InfoBox = {}

--[[
    Calculates how long the info line will appear for.

    @param header Player | string - header for line
    @param text string - text for line

    @return number - assumed time to finish
]]
function InfoBox.CalculateTextDisplayTime(header: Player | string, text: string): number
	local textLength = (#text / GlobalInfo.INFO_TEXT.CHAR_PER_MIN)

	local headerString: string = "ERROR"
	if typeof(header) == "Instance" and header:IsA("Player") then
		headerString = header.Name
	else
		headerString = header
	end

	local headerLength = (#headerString / GlobalInfo.INFO_TEXT.CHAR_PER_MIN)

	return 2 + headerLength + textLength
end

--[[
    Displays an InfoLine to the specified player.

    @param player Player - player to have info line appear
    @param header Player | string - header for line
    @param text string - text for line
    @param weight number - priority of text

    @return number - assumed time to finish
]]
function InfoBox.SendLineToPlayer(player: Player, header: Player | string, text: string, weight: number): number
	local realWeight = weight or 0 --red will throw silent error if type is nil

	RedEvents.Network.Server.SendLine:FireClient(player, header, text, realWeight)
	return InfoBox.CalculateTextDisplayTime(header, text)
end

--[[
    Displays an InfoLine to all players with the same provided header.

    @param header Player | string - header for line
    @param text string - text for line
    @param weight number - priority of text

    @return number - assumed time to finish
]]
function InfoBox.SendLineToPlayers(header: Player | string, text: string, weight: number): number
	RedEvents.Network.Server.SendLine:FireAllClients(header, text, weight)
	return InfoBox.CalculateTextDisplayTime(header, text)
end

--[[
    Displays an InfoLine to all players. The header is grabbed from each individual players info.

    @param text string - text for line
    @param weight number - priority of text

    @return number - assumed time to finish
]]
function InfoBox.SendLineToPlayersIndividually(text: string, weight: number): number
	for _, player in pairs(Players:GetPlayers()) do
		InfoBox.SendLineToPlayer(player, player, text, weight)
	end

	return InfoBox.CalculateTextDisplayTime("Ambiguous", text)
end

return InfoBox
