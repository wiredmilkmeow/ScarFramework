--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local sendSignal = RedEvents.SystemConnect.CreateSender("HighlightPromptServer")

--[[
	Utility for listening to local Player Activating HighlightPrompts from Server if a class was set Locally.
]]
local HighlightPromptUtility = {}

--[[
	This is for listening to players activating prompts on the server
	more meant for objects like vents, doors, etc

	@param class string - name of the class to track
	@param instance Instance - specific instance with class
	@param onActivation () -> () - function to run when player clicks a ClassPrompt

	@return (Player) -> () - cleanup
]]
function HighlightPromptUtility.ListenToClass(class: string, instance: Instance, onActivation: (Player) -> ()): () -> ()
	return sendSignal("ListenToClass", class, instance, onActivation)
end

return HighlightPromptUtility
