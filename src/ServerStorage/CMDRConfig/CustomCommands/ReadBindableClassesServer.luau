--!strict

--TODO
-- add a ReadHighlightPromptClasses Command

--[[
	Read connected bindables.

	We read bindable data from client, code written in ReadBindableClasses
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

return function(_data)
	local serverBindables = RedEvents.SystemConnect.ReadBindables()
	local clientBindables = _data:GetData()

	local function formatTable(table: {}): string
		return HttpService:JSONEncode(table):gsub("{", "{\n\n"):gsub("}", "\n\n}"):gsub("},", "},\n\n"):gsub(",", ",\n")
			.. "<<<"
	end

	local serverString = formatTable(serverBindables)
	local clientString = formatTable(clientBindables)

	return "Server:" .. serverString .. "\n\n\nClient:" .. clientString
end
