--!strict

--[[
	Server Logic for Vents.

	Since vents are very simple most code is on the Server.
]]

---------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Trove = require(ReplicatedStorage.Packages.trove)

local Sounds = require(ReplicatedStorage.Common.Sounds)
local Utility = require(ReplicatedStorage.Utility)

local HighlightPromptUtility = require(ServerStorage.ServerCommon.HighlightPromptUtility)

local VentCover = {}
VentCover.__index = VentCover
VentCover.TAG_NAME = "VentCover"

type self = {
	model: Model,
	base: BasePart,

	_cleaner: typeof(Trove.new()),
}

export type VentCover = typeof(setmetatable({} :: self, VentCover))

--[[
	Constructor

	@return self - the new object
]]
function VentCover.new(model: Model)
	assert(model.PrimaryPart, "Could not find primary part for VentModel: " .. model:GetFullName())

	local self = setmetatable({} :: self, VentCover)
	self._cleaner = Trove.new()

	self.model = model
	self.base = model.PrimaryPart

	self:_MonitorActivation()

	return self
end

--[[
	Create the prompt for the VentCover.

	@param self VentCover - object
]]
function VentCover._MonitorActivation(self: VentCover)
	local cleaner = HighlightPromptUtility.ListenToClass(VentCover.TAG_NAME, self.base, function(_player: Player)
		if self.base:GetAttribute("VentActivated") then
			return
		end

		self.base:SetAttribute("VentActivated", true)

		self.base.CollisionGroup = "DefaultOnly"
		self.base.CanTouch = false
		self.base.Anchored = false

		local force = self.model:GetAttribute("VentForce") :: number or 200
		self.base:ApplyImpulse(self.base.CFrame.LookVector * force)

		Sounds.PlaySoundByName("OpenedVentCover", Sounds.Variance(), self.base)
	end)

	self._cleaner:Add(function()
		self.base:SetAttribute("VentActivated", nil)
		cleaner()
	end)
end

--[[
	Cleans up the VentCover object.

	@param self VentCover - object
]]
function VentCover.Cleanup(self: VentCover)
	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _cleanup, _objects = Utility.Tags.SetObjectListener(VentCover)

-------------------------------------------------------------------------------------------

return {}
