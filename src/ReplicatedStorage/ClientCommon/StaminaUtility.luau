--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local sendSignal = RedEvents.SystemConnect.CreateSender("Stamina")

local StaminaUtility = {}

--[[
    Will determine if the player is allowed to use there Stamina or not.

    @param activate boolean - can it be activated by player?
]]
function StaminaUtility.SetCanSprint(activate: boolean)
	sendSignal("SetCanSprint", activate)
end

--[[
    Checks if the Stamina was activated so it can be used.

    @return boolean - is it possible to activate?
]]
function StaminaUtility.GetCanSprint(): boolean
	return sendSignal("GetCanSprint")
end

--[[
    Will determine if the player is allowed to use there Crouch or not.

    @param activate boolean - can it be activated by player?
]]
function StaminaUtility.SetCanCrouch(activate: boolean)
	sendSignal("SetCanCrouch", activate)
end

--[[
    Checks if the Crouch was activated so it can be used.

    @return boolean - is it possible to activate?
]]
function StaminaUtility.GetCanCrouch(): boolean
	return sendSignal("GetCanCrouch")
end

--[[
    Sets the speed multiplier

	Used for side meter

    @param multiplier number - The number to multiply the speed
]]
function StaminaUtility.SetSpeedMultiplier(multiplier: number?)
	sendSignal("SetSpeedMultiplier", multiplier)
end

--[[
    Sets the regen multiplier

	Used for side meter

    @param multiplier number - The number to multiply the regen speed
]]
function StaminaUtility.SetRegenMultiplier(multiplier: number?)
	sendSignal("SetRegenMultiplier", multiplier)
end

--[[
    Sets the drain multiplier

	Used for side meter

    @param multiplier number - The number to multiply the drain speed
]]
function StaminaUtility.SetDrainMultiplier(multiplier: number?)
	sendSignal("SetDrainMultiplier", multiplier)
end

return StaminaUtility
