--!strict

local Players = game:GetService("Players")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local ModalGUI = Instance.new("ScreenGui")
ModalGUI.DisplayOrder = 499
ModalGUI.ResetOnSpawn = false
ModalGUI.Name = "MainModal"

ModalGUI.Parent = player.PlayerGui

--[[
	New Modal UI
]]
local function newModal(name: string?): TextButton
	local modal = Instance.new("TextButton")
	modal.BackgroundTransparency = 0.99
	modal.Size = UDim2.fromOffset(1, 1)
	modal.Modal = true
	modal.ZIndex = 50
	modal.Name = name or "Modal"
	modal.Text = ""
	modal.Visible = false
	modal.Parent = ModalGUI

	return modal
end

--[[
	This is for Locking and Unlocking the Mouse.
	
	Mostly for UI Purposes.
]]
local Modal = {}
Modal.__index = Modal

type self = {
	name: string,
	_modal: TextButton,
}

export type Modal = typeof(setmetatable({} :: self, Modal))

--[[
	Constructor

	@return self - the new object
]]
function Modal.new(name: string)
	local self = setmetatable({} :: self, Modal)
	self.name = name
	self._modal = newModal(name)

	return self
end

--[[
	Enables the Modal

	@param self Modal - object
	@param enable boolean - State to set the Modal
]]
function Modal.Enable(self: Modal, enable: boolean)
	self._modal.Visible = enable
end

--[[
	Checks this Modals State

	@param self Modal - object

	@return boolean - Current State of the Modal
]]
function Modal.IsOn(self: Modal): boolean
	return self._modal.Visible
end

--[[
	Checks if any of the Modals are on outside of this object and inside

	@return boolean - Are any currently active
]]
function Modal.AnyIsOn(): boolean
	local isOn = false

	for _, modal in pairs(ModalGUI:GetChildren()) do
		if not modal:IsA("TextButton") then
			continue
		end
		if not modal.Visible then
			continue
		end
		isOn = true
		break
	end

	return isOn
end

--[[
	Cleans up the Modal object

	@param self Modal - object
]]
function Modal.Cleanup(self: Modal)
	self._modal:Destroy()
	self = nil :: any
end

return Modal
