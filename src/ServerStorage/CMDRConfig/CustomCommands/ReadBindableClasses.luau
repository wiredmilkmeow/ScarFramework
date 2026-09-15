local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

--we return bindable data from client back to server.

return {
	Name = "ReadBindableClasses",
	Aliases = { "RBC", "ReadBindable" },
	Description = "Read the Connected Bindable Classes on Server and Client.",
	Group = "DefaultDebug",
	AutoExec = {},
	Args = {},
	Data = function(_context)
		return RedEvents.SystemConnect.ReadBindables()
	end,
}
