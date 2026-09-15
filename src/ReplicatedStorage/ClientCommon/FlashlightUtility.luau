--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local sendSignal = RedEvents.SystemConnect.CreateSender("Flashlight")

local flashlightUtility = {}

--[[
    Will determine if the player is allowed to use there flashlight or not.

    @param activate boolean - can it be activated by player?
]]
function flashlightUtility.SetCanActivate(activate: boolean)
	sendSignal("SetCanActivate", activate)
end

--[[
    Checks if the flashlight was activated so it can be used.

    @return boolean - is it possible to activate?
]]
function flashlightUtility.GetCanActivate(): boolean
	return sendSignal("GetCanActivate")
end

--[[
    Checks if the Player is currently holding there light or not.

    @return boolean - is the player holding a light?
]]
function flashlightUtility.HoldingLight(): boolean
	return sendSignal("HoldingLight")
end

--[[
    Puts the light in the players hand or puts it away.

    This only works if there Flashlight is Active.

    @param holding boolean - should the player be holding the light currently?
]]
function flashlightUtility.SetLight(holding: boolean)
	sendSignal("SetLight", holding)
end

return flashlightUtility
