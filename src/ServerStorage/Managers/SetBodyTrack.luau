--!strict

--[[
    Sets CFrame values onto payer so its not just local.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

RedEvents.Network.Client.BodyCFrame:SetServerListener(function(player: Player, neckCFrame: CFrame, waistCFrame: CFrame)
	RedEvents.Network.Server.ServerBodyCFrame:FireAllClientsExcept(player, player, neckCFrame, waistCFrame)
end)

return {}
