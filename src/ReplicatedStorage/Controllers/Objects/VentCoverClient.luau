--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)

local Utility = require(ReplicatedStorage.Utility)

local HighlightPrompt = require(ReplicatedStorage.ClientCommon.HighlightPrompt)

local VentCover = {}
VentCover.__index = VentCover
VentCover.TAG_NAME = "VentCover"

type self = {
	model: Model,
	base: BasePart,
	prompt: HighlightPrompt.HighlightPrompt,

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

	self:_CreatePrompt()
	self:_Listen()

	return self
end

--[[
	Create the prompt for the VentCover.

	@param self VentCover - object
]]
function VentCover._CreatePrompt(self: VentCover)
	local prompt = HighlightPrompt.Create(self.base)
	prompt.ServerClass = VentCover.TAG_NAME

	HighlightPrompt.SetHighlightPreset(prompt, "Confirm")

	self._cleaner:Add(function()
		prompt:Destroy()
	end)

	self.prompt = prompt
end

--[[
	Create the prompt for the VentCover.

	@param self VentCover - object
]]
function VentCover._Listen(self: VentCover)
	self._cleaner:Connect(self.base:GetAttributeChangedSignal("VentActivated"), function()
		self.prompt.Enabled = false
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
