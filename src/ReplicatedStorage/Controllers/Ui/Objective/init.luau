--!strict

--[[
	need to add in new UI for this
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Trove = require(ReplicatedStorage.Packages.trove)

local Utility = require(ReplicatedStorage.Utility)

local Sounds = require(ReplicatedStorage.Common.Sounds)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local ObjectiveUI = require(script.ObjectiveUI)

local Objective = {}
Objective.__index = Objective
Objective.TAG_NAME = "Objective"
Objective.PrevNameUsed = nil :: string?

type self = {
	gui: ScreenGui,
	canvas: CanvasGroup,
	description: TextLabel,
	divider: Frame,

	newObjectiveThread: thread?,
	removeObjectiveThread: thread?,

	fadeTween: Tween,

	prevName: string?,
	prevDescription: string?,

	_cleaner: typeof(Trove.new()),
}

export type Objective = typeof(setmetatable({} :: self, Objective))

--[[
	Constructor

	@return self - the new object
]]
function Objective.new()
	if not Utility.Tags.GetUnique(Objective.TAG_NAME) then
		warn("There is more than one object with the " .. Objective.TAG_NAME .. " Tag")
	end

	local self = setmetatable({} :: self, Objective)
	self._cleaner = Trove.new()

	local gui, canvas, description, divider = ObjectiveUI.New(player.PlayerGui)
	self.gui = gui
	self.canvas = canvas
	self.description = description
	self.divider = divider

	self._cleaner:Add(gui)

	self:Listen()

	return self
end

--[[
	Read player Objective data.

	@return string? - name of Objective
	@return string? - description of Objective
]]
function Objective.GetData(): (string?, string?)
	return Players:GetAttribute("_ObjectiveName") :: string, Players:GetAttribute("_Objective") :: string
end

--[[
	Creates a new Objective

	@param self Objective - object

	@return number - wait time
]]
function Objective.FadeUI(self: Objective, direction: "In" | "Out"): number
	local transparencyValue = direction == "In" and 0 or 1
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)

	TweenService:Create(self.canvas, tweenInfo, { GroupTransparency = transparencyValue }):Play()

	return tweenInfo.Time + tweenInfo.DelayTime
end

--[[
	Animates the separator line

	@param self Objective - object

	@return number - wait time
]]
function Objective.AnimateLine(self: Objective, direction: "In" | "Out"): number
	local sizeValue = direction == "In" and 1 or 0.001
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)

	TweenService:Create(self.divider, tweenInfo, { Size = UDim2.new(sizeValue, 0, 0, 10) }):Play()

	return tweenInfo.Time + tweenInfo.DelayTime
end

--[[
	Creates a new Objective

	@param self Objective - object
	@param name string? - name of the Objective
	@param description string? - description of the text
]]
function Objective.NewObjective(self: Objective, name: string?, description: string?)
	if self.newObjectiveThread then
		task.cancel(self.newObjectiveThread)
	end

	self.newObjectiveThread = task.spawn(function()
		--fade out

		if self.prevName then
			self:RemoveObjective()
			task.wait(1)
		end

		--add new Objective
		self.prevName = name
		self.prevDescription = description
		self.description.Text = description or ""

		if Objective.PrevNameUsed ~= name then -- no sound if you respawn unless its new
			Sounds.PlaySoundByName("NewObjective")
		end

		--fade in
		self:FadeUI("In")

		task.wait(0.3)

		self:AnimateLine("In")
	end)
end

--[[
	Updates the current Objective.

	@param self Objective - object
]]
function Objective.UpdateObjective(self: Objective, name: string?, description: string?)
	if self.prevName ~= name then
		return
	end

	self.description.Text = description or ""
end

--[[
	Removes the current Objective.

	@param self Objective - object
]]
function Objective.RemoveObjective(self: Objective, quite: boolean?)
	if self.removeObjectiveThread then
		task.cancel(self.removeObjectiveThread)
	end

	self.prevName = nil
	self.prevDescription = nil

	if not quite and self.canvas.GroupTransparency == 0 then
		Sounds.PlaySoundByName("RemoveObjective")
	end

	self.removeObjectiveThread = task.spawn(function()
		self:AnimateLine("Out")

		task.wait(0.3)

		self:FadeUI("Out")
	end)
end

--[[
	Listens to player service for any changes in the Objective

	@param self Objective - object
]]
function Objective.Listen(self: Objective)
	local function addOrRemove()
		local description = Players:GetAttribute("_Objective") :: string?
		local name = Players:GetAttribute("_ObjectiveName") :: string?

		if not name then
			self:RemoveObjective()
		elseif self.prevName ~= name then
			self:NewObjective(name, description)
		end
	end

	local function update()
		local description = Players:GetAttribute("_Objective") :: string?
		local name = Players:GetAttribute("_ObjectiveName") :: string?

		if self.prevName == name and self.prevDescription ~= description then
			self:UpdateObjective(name, description)
		end
	end

	addOrRemove()
	self._cleaner:Connect(Players:GetAttributeChangedSignal("_ObjectiveName"), function()
		addOrRemove()
	end)

	self._cleaner:Connect(Players:GetAttributeChangedSignal("_Objective"), function()
		update()
	end)
end

--[[
	Cleans up the Objective object.

	@param self Objective - object
]]
function Objective.Cleanup(self: Objective)
	Objective.PrevNameUsed = self.prevName
	self:RemoveObjective(true)

	task.wait(1.2)

	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _characterTagConnection = Utility.Tags.TagCharacterConnection(Objective.TAG_NAME)
local _cleanup, _objects = Utility.Tags.SetObjectListener(Objective)
local _uniqueClass = Utility.Tags.GetUniqueClass(Objective.TAG_NAME, _objects)

-------------------------------------------------------------------------------------------

return {}
