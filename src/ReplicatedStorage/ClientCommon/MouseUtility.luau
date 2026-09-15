--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local sendSignal = RedEvents.SystemConnect.CreateSender("Mouse")

local mouseUtility = {}

--[[
    Set the image used for the players mouse.

    @param imageId number? - the image ID for the mouse
]]
function mouseUtility.SetImage(imageId: number?)
	sendSignal("SetImage", imageId)
end

--[[
    Sets the visibility of the mouse.

    @param on boolean - set the mouse visibility
]]
function mouseUtility.SetOn(on: boolean)
	sendSignal("SetOn", on)
end

return mouseUtility
