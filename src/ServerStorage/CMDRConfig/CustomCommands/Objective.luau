return {
	Name = "Objective",
	Aliases = { "Task" },
	Description = "Updates the games Objective.",
	Group = "DefaultDebug",
	AutoExec = {},
	Args = {
		function(context)
			return {
				Type = context.Cmdr.Util.MakeEnumType("option", { "New", "Update", "Remove" }),
				Name = "action",
				Description = "The action you would like to do with the Objective.",
			}
		end,

		function(context)
			local action = context:GetArgument(1):GetValue()

			if action == "New" then
				return {
					Type = "string",
					Name = "name",
					Description = "Name of the New Objective.",
				}
			elseif action == "Update" then
				return {
					Type = "string",
					Name = "description",
					Description = "Description of the Objective you want to Update.",
				}
			else
				return nil
			end
		end,

		function(context)
			local action = context:GetArgument(1):GetValue()

			if action == "New" then
				return {
					Type = "string",
					Name = "description",
					Description = "Description of the New Objective.",
				}
			else
				return nil
			end
		end,
	},
}
