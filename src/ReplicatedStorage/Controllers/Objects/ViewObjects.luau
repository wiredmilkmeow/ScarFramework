--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Input = require(ReplicatedStorage.Packages.input)
local Trove = require(ReplicatedStorage.Packages.trove)

local Utility = require(ReplicatedStorage.Utility)

local CameraUtility = require(ReplicatedStorage.ClientCommon.CameraUtility)
local HighlightPrompt = require(ReplicatedStorage.ClientCommon.HighlightPrompt)
local InfoBoxUtility = require(ReplicatedStorage.ClientCommon.InfoBoxUtility)

local camera = workspace.CurrentCamera

local ViewObject = {}
ViewObject.__index = ViewObject
ViewObject.TAG_NAME = "ViewObject"

type self = {
	model: Model,
	focusCamera: BasePart,
	focusPart: BasePart,

	priorityIsHigher: boolean,

	prompt: HighlightPrompt.HighlightPrompt,

	_cleaner: typeof(Trove.new()),
}

export type ViewObject = typeof(setmetatable({} :: self, ViewObject))

--[[
	Constructor

	@return self - the new object
]]
function ViewObject.new(model: Model)
	assert(model.PrimaryPart, "Could not find primary part for ViewObject: " .. model:GetFullName())

	local viewCamera = model:FindFirstChild("ViewCamera") :: BasePart
	assert(viewCamera, "Could not find ViewCamera for ViewObject: " .. model:GetFullName())

	local self = setmetatable({} :: self, ViewObject)
	self._cleaner = Trove.new()

	self.model = model
	self.focusPart = model.PrimaryPart

	self.priorityIsHigher = false

	self.focusCamera = viewCamera
	self.focusCamera.Transparency = 1

	self:_CreatePrompt()
	self:_Listen()

	return self
end

--[[
	Create the prompt for the ViewObject.

	@param self ViewObject - object
]]
function ViewObject._CreatePrompt(self: ViewObject)
	local prompt = HighlightPrompt.Create(self.focusPart)
	prompt.ServerClass = ViewObject.TAG_NAME

	HighlightPrompt.SetHighlightPreset(prompt, "Neutral")

	self._cleaner:Add(function()
		prompt:Destroy()
	end)

	self.prompt = prompt
end

--[[
	Create the prompt for the ViewObject.

    yielding

	@param self ViewObject - object
]]
function ViewObject.TweenCFrame(self: ViewObject, start: CFrame, target: CFrame, onChange: (CFrame) -> ())
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = start

	local distance = (target.Position - start.Position).Magnitude
	local info = TweenInfo.new(distance / 6, Enum.EasingStyle.Quad)

	local tween = TweenService:Create(cFrameValue, info, { Value = target })
	tween:Play()

	local connection = cFrameValue.Changed:Connect(function()
		onChange(cFrameValue.Value)
	end)

	repeat
		if CameraUtility.GetCameraPriority() > 30 then
			break
		end

		task.wait()
	until tween.PlaybackState == Enum.PlaybackState.Completed

	connection:Disconnect()
	cFrameValue:Destroy()
end

--[[
	Create the prompt for the ViewObject.

	@param self ViewObject - object
]]
function ViewObject._Listen(self: ViewObject)
	self._cleaner:Connect(self.prompt.Activated, function()
		self.prompt.Enabled = false

		local prevCamPosition = camera.CFrame
		self:TweenCFrame(camera.CFrame, self.focusCamera.CFrame, function(newCFrame: CFrame)
			CameraUtility.SetScriptableTargetCFrame(30, newCFrame)
		end)

		self:_SayLine()

		--exit
		local foundInput = false
		repeat
			if CameraUtility.GetCameraPriority() > 30 then
				break
			end

			camera.CFrame = self.focusCamera.CFrame --stay on object

			task.wait()

			local currentInput = Input.PreferredInput.Current
			if currentInput == "MouseKeyboard" then
				foundInput = Input.Mouse:IsLeftDown()
			elseif currentInput == "Gamepad" then
				foundInput = Input.Gamepad:GetTrigger(Enum.KeyCode.ButtonR1) >= 0.9
			elseif currentInput == "Touch" then
				foundInput = false --prob need to update the systems used for detecting some inputs
			end

		until foundInput

		self:TweenCFrame(self.focusCamera.CFrame, prevCamPosition, function(newCFrame: CFrame)
			CameraUtility.SetScriptableTargetCFrame(30, newCFrame)
		end)
		CameraUtility.SetFirstPerson(30, true)

		self.prompt.Enabled = true
	end)
end

--[[
	Transition the camera from 1st and 3rd person.

	@param self ViewObject - object
    @param direction "In" | "Out" - direction to animate too

    @param number - transition time
]]
function ViewObject._MoveCamera(self: ViewObject, direction: "In" | "Out"): boolean
	local inDirection = direction == "In" and true or false

	local success = false

	if inDirection then
		success = CameraUtility.SetFirstPerson(30, false)
	end

	local info = TweenInfo.new(3)

	print(CameraUtility.GetFirstPersonCamCFrame())
	local target = inDirection and self.focusCamera.CFrame or CameraUtility.GetFirstPersonCamCFrame()
	CameraUtility.SetScriptableTargetCFrame(30, target, 1)

	TweenService:Create(camera, info, { CFrame = target }):Play()
	task.wait(info.DelayTime + info.Time)

	if not inDirection then
		success = CameraUtility.SetFirstPerson(30, true)
	end

	return success
end

--[[
	Will say a lin ein info box if provided.

	@param self ViewObject - object
]]
function ViewObject._SayLine(self: ViewObject)
	local text = self.model:GetAttribute("ViewInfo") :: string
	if not text then
		return
	end

	InfoBoxUtility.AddFullLocalLine(text, 30)
end

--[[
	Cleans up the ViewObject object.

	@param self ViewObject - object
]]
function ViewObject.Cleanup(self: ViewObject)
	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _cleanup, _objects = Utility.Tags.SetObjectListener(ViewObject)

-------------------------------------------------------------------------------------------

return {}
