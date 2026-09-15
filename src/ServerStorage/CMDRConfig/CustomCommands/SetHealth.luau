return {
	Name = "SetHealth",
	Aliases = {},
	Description = "Set player's health.",
	Group = "DefaultAdmin",
	AutoExec = {},
	Args = {
		{
			Type = "players",
			Name = "targets",
			Description = "players to set health.",
		},
		{
			Type = "number",
			Name = "amount",
			Description = "amount of health to set.",
		},
	},
}
