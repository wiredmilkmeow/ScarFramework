--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signal = require(ReplicatedStorage.Packages._Index["red-blox_signal@2.0.2"].signal)

local signals = {
	client = {
		sender = Signal(),
		receiver = Signal(),
	},

	server = {
		sender = Signal(),
		receiver = Signal(),
	},
}

local registeredFunctions = {}

local function getSignals(): { sender: typeof(Signal()), receiver: typeof(Signal()) }
	return RunService:IsServer() and signals.server or signals.client
end

--[[
	Used for Global/Common Modules to prevent cyclic dependencies.

	returns a function thats yielding
]]
local function fireSystem(class: string): (string, ...any) -> ...any
	local bindableSignals = getSignals()

	local function fire(name: string, ...: any): ...any
		local results = { "NoResult" }
		local connection = bindableSignals.receiver:Connect(function(newClass: string, newName: string, ...: any)
			if newClass ~= class or newName ~= name then
				return
			end

			results = { ... }
		end)

		local function cleanup()
			if connection then
				connection()
			end
		end

		local function functionExists(): boolean
			return registeredFunctions[class] ~= nil and registeredFunctions[class][name] ~= nil
		end

		while not functionExists() do
			task.wait()
		end

		bindableSignals.sender:Fire(class, name, ...)

		--took to long to send back
		task.delay(10, function()
			if results[1] == "NoResult" then
				warn("System Signal not received, class: " .. class .. ", name: " .. name .. ", Input: ", results)
				cleanup()
			end
		end)

		repeat
			task.wait()
		until results[1] ~= "NoResult"

		cleanup()

		return table.unpack(results)
	end

	return fire
end

--[[
	Used for Controller/Manager Modules to prevent cyclic dependencies.

	does not yield
]]
local function connectSystem(class: string)
	if not registeredFunctions[class] then
		registeredFunctions[class] = {}
	end

	local bindableSignals = getSignals()

	local function connect(name: string, signal: (...any) -> ...any): () -> ()
		registeredFunctions[class][name] = true

		local cleanup = bindableSignals.sender:Connect(function(newClass: string, newName: string, ...: any)
			if newClass ~= class or newName ~= name then
				return
			end

			bindableSignals.receiver:Fire(class, name, signal(...))
		end)

		return cleanup
	end

	return connect
end

local function readBindables(): { [string]: { [string]: boolean } }
	return registeredFunctions
end

return {
	FireSystem = fireSystem,
	ConnectSystem = connectSystem,
	ReadBindables = readBindables,
}
