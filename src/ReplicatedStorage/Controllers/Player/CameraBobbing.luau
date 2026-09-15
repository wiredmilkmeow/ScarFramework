--!strict

local IDLE_STRENGTH = 1
local TURN_STRENGTH = 1

--[[
    This should have a signal to send to body tracking so it gets camera CFrame without the bobbing

    may need some functions to stop camera bobbing on cutscenes
]]

---------------------------------------------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Trove = require(ReplicatedStorage.Packages.trove)

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)
local RedEvents = require(ReplicatedStorage.RedEvents)
local Utility = require(ReplicatedStorage.Utility)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local camera = workspace.CurrentCamera
player:SetAttribute("IsFirstPerson", true)

--variables across objects
local func1, func2, func3 = 0, 0, 0

local function lerp(a: number, b: number, c: number): number
	return a + (b - a) * c
end

local CameraBobber = {}
CameraBobber.__index = CameraBobber
CameraBobber.TAG_NAME = "CameraBobber"
CameraBobber.FirstPersonCFrame = CFrame.new(0, 0, 0)
CameraBobber.CameraTargetCFrame = CFrame.new(0, 0, 0)
CameraBobber.FullBobbingStrength = 1

type self = {
	root: Part,
	humanoid: Humanoid,
	head: BasePart,

	isCrouched: boolean,
	prevCrouch: boolean,

	rightStep: boolean,

	_cameraCleaner: typeof(Trove.new()),
	_cleaner: typeof(Trove.new()),
}

export type CameraBobber = typeof(setmetatable({} :: self, CameraBobber))

--[[
	Constructor

	@return self - the new object
]]
function CameraBobber.new(root: Part?)
	if not root then
		return
	end

	local humanoid = root.Parent and root.Parent:FindFirstChildWhichIsA("Humanoid") or nil
	assert(humanoid, "Could not find humanoid for " .. CameraBobber.TAG_NAME)

	local head = root.Parent and root.Parent:FindFirstChild("Head") :: BasePart or nil
	assert(head, "Could not find Head for " .. CameraBobber.TAG_NAME)

	if not Utility.Tags.GetUnique(CameraBobber.TAG_NAME) then
		warn("There is more than one object with the " .. CameraBobber.TAG_NAME .. " Tag")
	end

	CameraBobber.FirstPersonCFrame = CFrame.new(0, 0, 0)
	CameraBobber.CameraTargetCFrame = CFrame.new(0, 0, 0)
	CameraBobber.FullBobbingStrength = 1

	local self = setmetatable({} :: self, CameraBobber)
	self._cleaner = Trove.new()

	self.root = root
	self.humanoid = humanoid
	self.head = head

	self.prevCrouch = false
	self.isCrouched = false

	self:Track()

	return self
end

--[[
	Will turn the CameraBobber on and off with added sounds and timing.

	@param type "Crouch" | "Walk" | "Sprint" | "Idle"  - type of bobbing
]]
function CameraBobber.GetBobbingValues(
	self: CameraBobber,
	type: "Crouch" | "Walk" | "Sprint" | "Idle"
): (number, number)
	local tickMultiplier, verticalMultiplier, horizontalMultiplier = 1, 0.001, 0.001

	if type == "Walk" then
		tickMultiplier = 4.5
		verticalMultiplier = 0.07
		horizontalMultiplier = 0.03
	elseif type == "Crouch" then
		tickMultiplier = 3
		verticalMultiplier = 0.05
		horizontalMultiplier = 0.018
	elseif type == "Sprint" then
		tickMultiplier = 7
		verticalMultiplier = 0.13
		horizontalMultiplier = 0.07
	elseif type == "Idle" then
		tickMultiplier = 0
		verticalMultiplier = 0
		horizontalMultiplier = 0
	end

	--creates an arc shape
	local t = tick() * tickMultiplier
	local x = math.sin(t * 2)
	local y = math.sin(t)

	local isRightStep = y < 0 and true or false
	if self.rightStep ~= isRightStep and math.abs(y) >= 0.99 then
		self.rightStep = isRightStep

		RedEvents.Signal.Client.FootStep:Fire(isRightStep)
	end

	local verticalBob = x * verticalMultiplier * 0.01
	local horizontalBob = y * horizontalMultiplier * 0.01

	return verticalBob, horizontalBob
end

--[[
	Sends back the camera bobber additive CFrame

	@param self CameraBobber - object

	@return CFrame - adjusted CFrame
]]
function CameraBobber.BobbingFrame(self: CameraBobber, delta: number, totalStrength: number?): CFrame
	delta = delta * 30

	local realStrength = totalStrength or 1

	local velocity = self.root.AssemblyLinearVelocity
	local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	local strength = IDLE_STRENGTH * realStrength * (1 - (speed / GlobalInfo.MOVEMENT.SPEED.RUNNING))

	--setting camera height for crouch
	if self.isCrouched ~= self.prevCrouch then
		self.prevCrouch = self.isCrouched

		local goal = self.isCrouched and Vector3.new(0, -1.3, -1) or Vector3.zero
		local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad)

		TweenService:Create(self.humanoid, info, { CameraOffset = goal }):Play()
	end

	if delta > 1.5 then
		func1, func2 = 0, 0
	else
		func1 = lerp(
			func1,
			math.cos(time() * 0.5 * math.random(5, 7.5)) * (math.random(2.5, 10) / 100) * strength * delta,
			0.05 * delta
		)
		func2 = lerp(
			func2,
			math.cos(time() * 0.5 * math.random(2.5, 5)) * (math.random(1, 5) / 100) * strength * delta,
			0.05 * delta
		)
	end

	--check the bobbing type that should be used
	local verticalBob, horizontalBob = 0, 0
	if speed > GlobalInfo.MOVEMENT.SPEED.RUNNING - 0.5 then
		verticalBob, horizontalBob = self:GetBobbingValues("Sprint")
	elseif speed > GlobalInfo.MOVEMENT.SPEED.WALKING - 0.5 then
		verticalBob, horizontalBob = self:GetBobbingValues("Walk")
	elseif speed > GlobalInfo.MOVEMENT.SPEED.CROUCHING - 0.5 then
		verticalBob, horizontalBob = self:GetBobbingValues("Crouch")
	else
		verticalBob, horizontalBob = self:GetBobbingValues("Idle")
	end

	verticalBob = verticalBob * realStrength
	horizontalBob = horizontalBob * realStrength

	local bobCFrame = CFrame.fromEulerAnglesXYZ(math.rad(func1 * 0.2), math.rad(func2), math.rad(func2 * 10)) --rnd bobbing
		* CFrame.fromEulerAnglesXYZ(0, 0, math.rad(func3)) --turning
		* CFrame.fromEulerAnglesXYZ(verticalBob, horizontalBob, 0) -- bobbing

	func3 = lerp(
		func3,
		math.clamp(UserInputService:GetMouseDelta().X, -2.5, 2.5) * TURN_STRENGTH * realStrength,
		0.25 * delta
	) -- turn func

	return bobCFrame
end

--[[
	Will turn the CameraBobber on and off with added sounds and timing.

	@param self CameraBobber - object
]]
function CameraBobber.ConnectFunctionToFirstPersonType(self: CameraBobber, func: () -> ())
	if self._cameraCleaner then
		self._cameraCleaner:Add(func)
	else
		func()
	end
end

--[[
	Will turn the CameraBobber on and off with added sounds and timing.

	@param self CameraBobber - object
]]
function CameraBobber.Track(self: CameraBobber)
	local function setCameraType()
		local isFirstPerson = player:GetAttribute("IsFirstPerson")

		if isFirstPerson then
			camera.CameraType = Enum.CameraType.Custom

			self._cameraCleaner = self._cleaner:Extend()
		else
			if self._cameraCleaner then
				self._cameraCleaner:Destroy()
			end

			camera.CameraType = Enum.CameraType.Scriptable
		end
	end

	local offset = self.root.CFrame:ToObjectSpace(camera.CFrame)
	self._cleaner:Connect(RunService.Heartbeat, function()
		CameraBobber.FirstPersonCFrame = self.root.CFrame * offset
	end)

	local strength = 1
	self._cleaner:BindToRenderStep("CustomCamera", Enum.RenderPriority.Camera.Value + 1, function(delta: number)
		local isFirstPerson = player:GetAttribute("IsFirstPerson")
		local additiveStrength = isFirstPerson and 0.01 or -0.01
		strength = math.clamp(strength + additiveStrength, 0, 1)

		if isFirstPerson then
			camera.CFrame = camera.CFrame * self:BobbingFrame(delta, strength)
		else
			camera.CFrame = CameraBobber.CameraTargetCFrame
				* self:BobbingFrame(delta, strength * CameraBobber.FullBobbingStrength)
		end
	end)

	self._cleaner:Add(function()
		RunService:UnbindFromRenderStep("CustomCamera")
	end)

	setCameraType()
	self._cleaner:Connect(player.AttributeChanged, function(attribute: string)
		if attribute ~= "IsFirstPerson" then
			return
		end

		setCameraType()
	end)
end

--[[
	Cleans up the CameraBobber object.

	@param self CameraBobber - object
]]
function CameraBobber.Cleanup(self: CameraBobber)
	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _characterTagConnection = Utility.Tags.TagCharacterConnection(CameraBobber.TAG_NAME)
local _cleanup, _objects = Utility.Tags.SetObjectListener(CameraBobber)
local _uniqueClass = Utility.Tags.GetUniqueClass(CameraBobber.TAG_NAME, _objects)

RedEvents.Signal.Client.WalkState:Connect(function(state: "Crouch" | "Walk" | "Sprint")
	if not _uniqueClass then
		return
	end
	_uniqueClass.isCrouched = (state == "Crouch")
end)

-------------------------------------------------------------------------------------------

local receiveSignal = RedEvents.SystemConnect.CreateReceiver("CameraBobbing")
local cameraWeight = 0

-- TODO need to write code that resets the camera back to firstPerson on death and puts camera weight to high number.

local function SetFirstPerson(weight: number, set: boolean): boolean
	if cameraWeight > weight then
		return false
	end
	cameraWeight = set and 0 or weight

	if player:GetAttribute("IsFirstPerson") :: boolean ~= set then
		player:SetAttribute("IsFirstPerson", set)
	end

	return true
end

receiveSignal("SetFirstPerson", function(weight, set): boolean
	return SetFirstPerson(weight, set)
end)

receiveSignal("GetFirstPerson", function(): boolean
	return player:GetAttribute("IsFirstPerson") :: boolean
end)

receiveSignal("GetCameraPriority", function(): number
	return cameraWeight
end)

receiveSignal("GetFirstPersonCamCFrame", function(): CFrame
	return CameraBobber.FirstPersonCFrame
end)

receiveSignal("SetScriptableTargetCFrame", function(weight, target, strength): boolean
	local success = SetFirstPerson(weight, false)
	if not success then
		return false
	end

	CameraBobber.CameraTargetCFrame = target
	CameraBobber.FullBobbingStrength = strength or 1

	return true
end)

receiveSignal("GetScriptableTargetCFrame", function()
	return CameraBobber.CameraTargetCFrame
end)

receiveSignal("ConnectFunctionToFirstPersonType", function(func: () -> ())
	if not _uniqueClass then
		return
	end

	_uniqueClass:ConnectFunctionToFirstPersonType(func)
end)

receiveSignal("ConnectAndListenToFirstPersonType", function(run: () -> (), cleanup: () -> ())
	if not _uniqueClass then
		return
	end

	_uniqueClass:ConnectFunctionToFirstPersonType(cleanup)
	run()
	_uniqueClass._cleaner:Connect(player.AttributeChanged, function(attribute: string)
		if attribute ~= "IsFirstPerson" then
			return
		end

		local isFirstPerson = player:GetAttribute("IsFirstPerson")

		_uniqueClass:ConnectFunctionToFirstPersonType(cleanup)
		if isFirstPerson then
			run()
		end
	end)
end)

return {}
