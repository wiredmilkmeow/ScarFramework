--!strict

--[[
    Initializes all the Server side code for the game.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Loader = require(ReplicatedStorage:WaitForChild("Loader"))

Loader()
