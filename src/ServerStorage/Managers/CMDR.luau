--!strict

--[[
	Initialization for Server side of CMDR.
]]

local ServerStorage = game:GetService("ServerStorage")

local Cmdr = require(ServerStorage.ServerPackages.cmdr)

local cmdrConfig = ServerStorage.CMDRConfig

local removableCommands = {
	"kill",
	"respawn",
}

Cmdr:RegisterHooksIn(cmdrConfig.Hooks)

Cmdr:RegisterDefaultCommands(function(command)
	return table.find(removableCommands, command.Name) == nil
end)

Cmdr:RegisterCommandsIn(cmdrConfig.CustomCommands)

return {}
