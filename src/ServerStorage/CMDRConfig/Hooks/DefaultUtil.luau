--!nonstrict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Admin = require(ReplicatedStorage.Admin)

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		if context.Group == "DefaultUtil" and not Admin.IsAdmin(context.Executor.UserId) then
			return "You don't have permission to run this util command"
		end
	end)
end
