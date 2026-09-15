return {
	Name = "InfoBox",
	Aliases = { "InBox" },
	Description = "The text box for the players.",
	Group = "DefaultDebug",
	AutoExec = {},
	Args = {
		{
			Type = "players",
			Name = "targets",
			Description = "Player to send line.",
		},

		function(context)
			return {
				Type = context.Cmdr.Util.MakeEnumType("option", { "LocalHeader", "CustomHeader", "TestLine" }),
				Name = "action",
				Description = "The action you would like to do with the Objective.",
			}
		end,

		function(context)
			local action = context:GetArgument(2):GetValue()

			if action == "LocalHeader" then
				return {
					Type = "string",
					Name = "text",
					Description = "text to display in info line.",
				}
			elseif action == "CustomHeader" then
				return {
					Type = "string",
					Name = "header",
					Description = "The header for the info line.",
				}
			else
				return nil
			end
		end,

		function(context)
			local action = context:GetArgument(2):GetValue()

			if action == "LocalHeader" then
				return {
					Type = "number",
					Name = "weight",
					Description = "priority of this line you want to send.",
					Optional = true,
				}
			elseif action == "CustomHeader" then
				return {
					Type = "string",
					Name = "text",
					Description = "text to display in info line.",
				}
			else
				return nil
			end
		end,

		function(context)
			local action = context:GetArgument(2):GetValue()

			if action == "CustomHeader" then
				return {
					Type = "number",
					Name = "weight",
					Description = "priority of this line you want to send.",
					Optional = true,
				}
			else
				return nil
			end
		end,
	},
}
