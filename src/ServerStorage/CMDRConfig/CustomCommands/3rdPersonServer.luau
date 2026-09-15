--!strict

--[[
	Set Your character to first or 3rd person.
]]

local function set3rdPerson(player: Player, enable: boolean)
	player.CameraMaxZoomDistance = enable and 30 or 0.5
	player.CameraMode = enable and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
end

return function(_data, enabled)
	set3rdPerson(_data.Executor, enabled)

	return ("Adjusted 3rdPerson to %s."):format(tostring(enabled))
end
