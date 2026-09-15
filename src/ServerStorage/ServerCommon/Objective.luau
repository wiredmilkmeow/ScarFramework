--!strict

local Players = game:GetService("Players")

--[[
    Tools for setting the current Objective for all Players.
]]
local Objective = {}

--[[
	Create a new Objective for the player to follow.

	@param name string - the unique name of the objective
	@param text string - the text of the new objective
]]
function Objective.New(name: string, text: string)
	Players:SetAttribute("_ObjectiveName", name)
	Players:SetAttribute("_Objective", text)
end

--[[
	Update the current Objective if the name matches. And return a result depending on the Objective being the same or not.

	@param name string - the unique name of the objective
	@param text string - the text of the new objective

	@return boolean - success of update
]]
function Objective.Update(name: string, text: string): boolean
	if Players:GetAttribute("_ObjectiveName") ~= name then
		return false
	end
	Players:SetAttribute("_Objective", text)

	return true
end

--[[
	Clear the player of the current Objective.
]]
function Objective.Remove()
	Players:SetAttribute("_ObjectiveName", nil)
	Players:SetAttribute("_Objective", nil)
end

--[[
	Get the name of the current Objective.

	@return string? - name of the objective
]]
function Objective.FetchCurrentName(): string?
	return Players:GetAttribute("_ObjectiveName") :: string?
end

return Objective
