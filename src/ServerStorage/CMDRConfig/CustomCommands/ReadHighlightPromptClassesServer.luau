--!strict

--[[
	Read registered HighlightPrompt classes.

	We read class data from client.
]]

local HttpService = game:GetService("HttpService")

return function(_data)
	local registeredClasses = _data:GetData()

	local function formatTable(table: {}): string
		return HttpService:JSONEncode(table):gsub("{", "{\n\n"):gsub("}", "\n\n}"):gsub("},", "},\n\n"):gsub(",", ",\n")
			.. "<<<"
	end

	local clientString = formatTable(registeredClasses)

	return "HighlightPromptClasses:" .. clientString
end
