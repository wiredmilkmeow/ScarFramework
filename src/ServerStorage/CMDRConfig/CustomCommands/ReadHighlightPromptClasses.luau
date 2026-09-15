local ReplicatedStorage = game:GetService("ReplicatedStorage")

--we return registered classes from client back to server.

return {
	Name = "ReadHighlightPromptClasses",
	Aliases = { "RHPC", "ReadHighlightClasses", "ReadHClasses" },
	Description = "Read the Registered classes for HighlightPrompts.",
	Group = "DefaultDebug",
	AutoExec = {},
	Args = {},
	Data = function(_context)
		local HighlightPrompt = require(ReplicatedStorage.ClientCommon.HighlightPrompt)
		return HighlightPrompt.GetRegisteredClasses()
	end,
}
