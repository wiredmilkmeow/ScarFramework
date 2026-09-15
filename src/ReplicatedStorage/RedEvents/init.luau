--!strict

--[[
    Red library should only be called here
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Guard = require(ReplicatedStorage.Packages._Index["red-blox_guard@1.0.1"].guard)
local Ratelimit = require(ReplicatedStorage.Packages.ratelimit)
local Red = require(ReplicatedStorage.Packages.red)
local Signal = require(ReplicatedStorage.Packages._Index["red-blox_signal@2.0.2"].signal)

local BindableFunction = require(script.BindableFunction)

--[[network connections]]
----------------------------------------------------------------------------------------------------

--fired from server
local fromNetworkServer = {

	RoleCredits = Red.SharedSignalEvent("RoleCredits", function()
		return nil
	end),
	SendLine = Red.SharedSignalEvent("SindLineServer", function(header, text, weight)
		return Guard.Or(Guard.Instance, Guard.String)(header), Guard.String(text), Guard.Number(weight)
	end),

	--functions

	--unreliable
	ServerBodyCFrame = Red.SharedEvent({ --send character CFrame info to players
		Name = "ServerBodyCFrame",
		Unreliable = true,
	}, function(player, neck, waist)
		return Guard.Any(player), Guard.CFrame(neck), Guard.CFrame(waist)
	end),
}

--fired from client
local fromNetworkClient = {
	FlashlightState = Red.SharedSignalEvent("FlashlightState", function(on)
		return Guard.Boolean(on)
	end),
	PromptClassActivation = Red.SharedSignalEvent("PromptClassActivation", function(class, instance)
		return Guard.String(class), Guard.Instance(instance)
	end),

	Respawn = Red.SharedSignalEvent("Respawn", function()
		return nil
	end),
	DeathScreenFinished = Red.SharedSignalEvent("DeathScreenFinished", function()
		return nil
	end),

	--functions
	SoundsRequest = Red.Function(
		"SoundsRequest",
		function() end,
		function(Table) --send sound table to client on request
			return Guard.Map(Guard.String, Guard.Any)(Table)
		end
	),

	IsAdmin = Red.Function("IsAdmin", function(playerId)
		return Guard.Number(playerId)
	end, function(result)
		return Guard.Boolean(result)
	end),

	--unreliable
	BodyCFrame = Red.SharedEvent({ --send character CFrame info to server
		Name = "BodyCFrame",
		Unreliable = true,
	}, function(neck, waist)
		return Guard.CFrame(neck), Guard.CFrame(waist)
	end),
}

--[[signal connections]]
----------------------------------------------------------------------------------------------------

--server side
local fromSignalServer = {}

--client side
local fromSignalClient = {
	FootStep = Signal(), --isRightFoot Boolean
	WalkState = Signal(), --state ("Crouch" | "Walk" | "Sprint")
}

----------------------------------------------------------------------------------------------------

--[[
	Anything that needs an event or signal should go through here for security.

	All Events will be created within this Module.

	Signals should be made using NewSignal if it will stay within the module using it.
	If that is not the case it should be created in RedEvents Module.
]]
local RedSignalNetwork = {
	-- client to server and server to client communications
	Network = {
		Server = fromNetworkServer,
		Client = fromNetworkClient,
	},
	-- client to client and server to server communications
	Signal = {
		Server = fromSignalServer,
		Client = fromSignalClient,
	},
	--prevent cyclic dependencies
	SystemConnect = {
		CreateSender = BindableFunction.FireSystem,
		CreateReceiver = BindableFunction.ConnectSystem,
		ReadBindables = BindableFunction.ReadBindables,
	},
	Ratelimit = Ratelimit,
	NewSignal = Signal,
}

return RedSignalNetwork
