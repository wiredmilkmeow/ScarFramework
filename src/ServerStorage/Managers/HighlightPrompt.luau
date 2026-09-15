--!strict

--[[
	Initializes HighlightPrompt for Server side use.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local classActivated = RedEvents.NewSignal()

local limit = RedEvents.Ratelimit(15, 1)
RedEvents.Network.Client.PromptClassActivation:OnServer(function(player: Player, class: string, instance: Instance)
	if not limit(player) then
		warn(player.Name .. " requested promptClassActivation too many times!")
		return
	end

	classActivated:Fire(player, class, instance)
end)

---------------------------------------------------------------------------------------

local receiveSignal = RedEvents.SystemConnect.CreateReceiver("HighlightPromptServer")

receiveSignal("ListenToClass", function(class: string, instance: Instance, onActivation: (Player) -> ()): () -> ()
	return classActivated:Connect(function(player, newClass, newInstance)
		if newClass ~= class or newInstance ~= instance then
			return
		end

		onActivation(player)
	end)
end)

return {}
