--!strict

--[[
	This reads the server information on player death.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(ReplicatedStorage.Utility)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local diedSignal = Instance.new("BindableEvent")
player:GetAttributeChangedSignal("_Dead"):Connect(function()
	diedSignal:Fire(player:GetAttribute("_Dead") or false)
end)
Utility.Tags.SetCharacterDeathConnection(diedSignal.Event)

return {}
