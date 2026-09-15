--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient")) :: any

local Modal = require(ReplicatedStorage.ClientCommon.Modal)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

--seems like cmdr doesn't have an easy way to see if the UI is visible
local cmdrUI = player.PlayerGui:WaitForChild("Cmdr")
local mainFrame = cmdrUI:WaitForChild("Frame") :: ScrollingFrame

-- Configurable, and you can choose multiple keys
Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })

local cmdrModal = Modal.new("CMDR")
mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	cmdrModal:Enable(mainFrame.Visible)
end)

return {}
