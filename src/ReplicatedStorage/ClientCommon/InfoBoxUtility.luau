--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local sendSignal = RedEvents.SystemConnect.CreateSender("InfoBox")

local InfoBoxUtility = {}

--[[
    Formats the text to display a certain color.

    RichText must be enabled on Instance.

    @param text string - text to color
    @param color Color3 - text color

    @return string - text with added color
]]
function InfoBoxUtility.ColorText(text: string, color: Color3): string
	return sendSignal("ColorText", text, color)
end

--[[
    Finds the designated color of the player, if it fails it chooses pink.

    @param playerForColor Player - player to find color of

    @return Color3 - header color for player
]]
function InfoBoxUtility.GetPlayerColor(playerForColor: Player): Color3
	return sendSignal("GetPlayerColor", playerForColor)
end

--[[
    Directly adds a text line to the InfoBox.

    @param text string - text to display
    @param weight number - priority of text
]]
function InfoBoxUtility.AddLine(text: string, weight: number)
	sendSignal("AddLine", text, weight)
end

--[[
    Adds a text line to the InfoBox with a header.

    @param name string - header text
    @param text string - text to display
    @param weight number - priority of text
]]
function InfoBoxUtility.AddFullLine(header: string, text: string, weight: number)
	sendSignal("AddFullLine", header, text, weight)
end

--[[
    Adds a text line to the InfoBox with a header using the players Info.

    Header gets automatically colored.

    @param playerForLine Player - player for header
    @param text string - text to display
    @param weight number - priority of text
]]
function InfoBoxUtility.AddFullPlayerLine(playerForLine: Player, text: string, weight: number)
	sendSignal("AddFullPlayerLine", playerForLine, text, weight)
end

--[[
    Adds a text line to the InfoBox, a header is made from the local player's info.

    @param text string - text to display
    @param weight number - priority of text
]]
function InfoBoxUtility.AddFullLocalLine(text: string, weight: number)
	sendSignal("AddFullLocalLine", text, weight)
end

return InfoBoxUtility
