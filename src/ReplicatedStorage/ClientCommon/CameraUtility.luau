--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local sendSignal = RedEvents.SystemConnect.CreateSender("CameraBobbing")

local cameraUtility = {}

--[[
    Sets the camera to fist person or unlocks it.

    @param weight number - priority of request
    @param set boolean - Set to first person or unlock

    @return boolean - success of request
]]
function cameraUtility.SetFirstPerson(weight: number, set: boolean): boolean
	return sendSignal("SetFirstPerson", weight, set)
end

--[[
    Gets the camera state of fist person or unlock.

    @return boolean - current state of first person or unlock
]]
function cameraUtility.GetFirstPerson(): boolean
	return sendSignal("GetFirstPerson")
end

--[[
    Tells you what the current weight/priority is.

    @return number - current priority of camera
]]
function cameraUtility.GetCameraPriority(): number
	return sendSignal("CameraPriorityChanged")
end

--[[
    Tells you the current CFrame of the first person camera.
    Also works in 3rd person.

    @return CFrame - firstPerson Camera position
]]
function cameraUtility.GetFirstPersonCamCFrame(): CFrame
	return sendSignal("GetFirstPersonCamCFrame")
end

--[[
    Sets the CFrame of the camera with/without bobbing effects.
    Automatically sets camera to scriptable.

    @param weight number - priority of request
    @param target CFrame - targetFor the camera to reach too

    @return boolean - success of request
]]
function cameraUtility.SetScriptableTargetCFrame(weight: number, target: CFrame, bobbingStrength: number?): boolean
	return sendSignal("SetScriptableTargetCFrame", weight, target, bobbingStrength)
end

--[[
    Gets the CFrame of the target camera for scriptables.

    @return CFrame - current TargetCFrame
]]
function cameraUtility.GetScriptableTargetCFrame(): CFrame
	return sendSignal("GetScriptableTargetCFrame")
end

--[[
    Connect a function to the FirstPerson camera type.
    Will run when the character dies or the camera type was switched to unlock.
    @param func () -> () - function you want to run
]]
function cameraUtility.ConnectFunctionToFirstPersonType(func: () -> ())
	sendSignal("ConnectFunctionToFirstPersonType", func)
end

--[[
    Connect a function to the FirstPerson camera type to run while in first person.
    Cleanup function will run when the character dies or the camera type was switched to unlock.

    @param run () -> () - function you want to run in first person
    @param cleanup () -> () - function you want to cleanup the run
]]
function cameraUtility.ConnectAndListenToFirstPersonType(run: () -> (), cleanup: () -> ())
	sendSignal("ConnectFunctionToFirstPersonType", run, cleanup)
end

return cameraUtility
