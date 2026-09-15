--!strict

--[[
	crouch and run and walk state should be connected through signal for other things to read
	
	anim will be connected through these signals
]]

local UN_CROUCH_CHECK_DISTANCE = 2

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(ReplicatedStorage.Packages.trove)

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)
local RedEvents = require(ReplicatedStorage.RedEvents)
local Utility = require(ReplicatedStorage.Utility)

--local Market = require(ReplicatedStorage.Common.Market)
local Sounds = require(ReplicatedStorage.Common.Sounds)

local CameraBobbing = require(ReplicatedStorage.ClientCommon.CameraUtility)

local StaminaUI = require(script:WaitForChild("StaminaUI"))

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local camera = workspace.CurrentCamera

--variables across objects
local canSprint = true
local canCrouch = true
local speedMultiplier = 1
local regenMultiplier = 1
local drainMultiplier = 1

local defaultBarColor = GlobalInfo.COLOR_THEME.NEUTRAL.BACKGROUND.VERY_LIGHT
local tiredBarColor = Color3.new(defaultBarColor.R * 0.5, defaultBarColor.G * 0.5, defaultBarColor.B * 0.5)

local Stamina = {}
Stamina.__index = Stamina
Stamina.TAG_NAME = "Stamina"

type self = {
	root: Part,
	humanoid: Humanoid,

	staminaHolder: CanvasGroup,
	staminaBar: Frame,

	breathingSound: Sound,
	crouchSound: Sound,

	currentStamina: number,
	prevClick: number,
	regenPauseTime: number,

	reachedTop: boolean,
	reachedBottom: boolean,
	requestingSprint: boolean,
	requestingCrouch: boolean,
	prevCrouch: boolean,

	prevFovState: boolean,
	isFirstPerson: boolean,

	_cleaner: typeof(Trove.new()),
}

export type Stamina = typeof(setmetatable({} :: self, Stamina))

--[[
	Constructor

	@return self - the new object
]]
function Stamina.new(root: Part?)
	if not root then
		return
	end

	local humanoid = root.Parent and root.Parent:FindFirstChildWhichIsA("Humanoid") or nil
	assert(humanoid, "Could not find humanoid for " .. Stamina.TAG_NAME)

	local breathingSound = Sounds.FindSoundByName("StaminaBreathing", nil, root)
	assert(breathingSound, "Could not find Sound for " .. Stamina.TAG_NAME)

	local crouchSound = Sounds.FindSoundByName("StaminaCrouch", nil, root)
	assert(crouchSound, "Could not find Sound for " .. Stamina.TAG_NAME)

	if not Utility.Tags.GetUnique(Stamina.TAG_NAME) then
		warn("There is more than one object with the " .. Stamina.TAG_NAME .. " Tag")
	end

	local self = setmetatable({} :: self, Stamina)
	self._cleaner = Trove.new()

	self.root = root
	self.prevClick = 0
	self.currentStamina = GlobalInfo.MOVEMENT.STAMINA.MAX_STAMINA

	local staminaGUI, staminaHolder, staminaBar = StaminaUI.New(player.PlayerGui)
	self._cleaner:Add(staminaGUI)
	self.staminaHolder = staminaHolder

	self.staminaBar = staminaBar
	self.staminaBar.BackgroundColor3 = defaultBarColor

	self.humanoid = humanoid

	self.breathingSound = breathingSound
	self.breathingSound.Looped = true
	self.breathingSound.Volume = 0
	self.breathingSound:Play()

	self.crouchSound = crouchSound

	self.staminaHolder.GroupTransparency = 1
	self.regenPauseTime = 0

	self:SetWalkSpeed("Walk")
	self:Track()
	self:ConnectKey()

	return self
end

--[[
	Returns current percentage of stamina

	@param self Stamina - object
	@return number - percentage of current stamina
]]
function Stamina.GetStaminaPercentage(self: Stamina): number
	return self.currentStamina / GlobalInfo.MOVEMENT.STAMINA.MAX_STAMINA
end

--[[
	Sets the speed of the player and plays attached sounds

	@param self Stamina - object
	@param speed number - speed of player
]]
function Stamina.SetWalkSpeed(self: Stamina, type: "Crouch" | "Walk" | "Sprint")
	local setMultiplier = speedMultiplier or 1

	if type == "Crouch" then
		self.humanoid.WalkSpeed = GlobalInfo.MOVEMENT.SPEED.CROUCHING * setMultiplier
	elseif type == "Walk" then
		self.humanoid.WalkSpeed = GlobalInfo.MOVEMENT.SPEED.WALKING * setMultiplier
	elseif type == "Sprint" then
		self.humanoid.WalkSpeed = GlobalInfo.MOVEMENT.SPEED.RUNNING * setMultiplier
	end

	--crouchSound
	if type == "Crouch" and not self.prevCrouch then
		self.prevCrouch = true
		self.crouchSound.PlaybackSpeed = 1
		self.crouchSound:Play()
	elseif type ~= "Crouch" and self.prevCrouch then
		self.prevCrouch = false
		self.crouchSound.PlaybackSpeed = 0.8
		self.crouchSound:Play()
	end

	--breathingSound
	local volumeGoal = 0
	if self.reachedBottom then
		volumeGoal = 0.1
	elseif type == "Sprint" then
		volumeGoal = 0.04
	else
		volumeGoal = 0
	end

	self.breathingSound.Volume = math.lerp(self.breathingSound.Volume, volumeGoal, 0.01)

	--for animation systems to read
	RedEvents.Signal.Client.WalkState:Fire(type)
end

--[[
	Regen stamina for that frame

	@param self Stamina - object
]]
function Stamina.Regen(self: Stamina)
	if self.requestingCrouch then
		self:SetWalkSpeed("Crouch")
	elseif not self.requestingSprint then
		self:SetWalkSpeed("Walk")
	end

	if time() - self.regenPauseTime < GlobalInfo.MOVEMENT.STAMINA.REGEN_PAUSE then
		return
	end

	self.currentStamina = math.clamp(
		self.currentStamina + GlobalInfo.MOVEMENT.STAMINA.STAMINA_REGEN * regenMultiplier,
		0,
		GlobalInfo.MOVEMENT.STAMINA.MAX_STAMINA
	)

	local newScaleSize = UDim2.fromScale(self:GetStaminaPercentage(), 1)
	TweenService:Create(self.staminaBar, TweenInfo.new(0.1), { Size = newScaleSize }):Play()
end

--[[
	Drain stamina for that frame

	@param self Stamina - object
]]
function Stamina.Drain(self: Stamina)
	self.regenPauseTime = time()

	self:SetWalkSpeed("Sprint")

	local velocity = self.root.AssemblyLinearVelocity
	local velocityXZ = Vector3.new(velocity.X, 0, velocity.Z)
	if velocityXZ.Magnitude < GlobalInfo.MOVEMENT.SPEED.WALKING + 0.5 then -- not running when holding shift
		self:Regen()
		return
	end

	local localVelocity = self.root.CFrame:VectorToObjectSpace(velocity)
	if localVelocity.Z > 0.03 then --backwards (its a positive number)
		self.requestingSprint = false
		self:Regen()
		return
	end

	self.currentStamina = math.clamp(
		self.currentStamina - GlobalInfo.MOVEMENT.STAMINA.STAMINA_DRAIN * drainMultiplier,
		0,
		GlobalInfo.MOVEMENT.STAMINA.MAX_STAMINA
	)

	local newScaleSize = UDim2.fromScale(self:GetStaminaPercentage(), 1)
	TweenService:Create(self.staminaBar, TweenInfo.new(0.1), { Size = newScaleSize }):Play()
end

--[[
	Determines when the player drained there stamina too much

	@param self Stamina - object
]]
function Stamina.SetReachBottom(self: Stamina)
	if self:GetStaminaPercentage() <= 0.0001 then
		self.reachedBottom = true
		self:SetWalkSpeed("Walk")
		self.staminaBar.BackgroundColor3 = tiredBarColor
	elseif self:GetStaminaPercentage() >= 0.5 then
		self.reachedBottom = false

		if self.staminaBar.BackgroundColor3 == tiredBarColor then
			local tweenInfo = TweenInfo.new(GlobalInfo.MOVEMENT.STAMINA.TIRED_TRANSITION_TIME, Enum.EasingStyle.Sine)

			TweenService:Create(self.staminaBar, tweenInfo, { BackgroundColor3 = defaultBarColor }):Play()
		end
	end
end

--[[
	Fades the stamina bar out once full

	@param self Stamina - object
]]
function Stamina.SetFade(self: Stamina)
	if not self.reachedTop and self:GetStaminaPercentage() == 1 then
		self.reachedTop = true

		local tweenInfo = TweenInfo.new(
			GlobalInfo.MOVEMENT.STAMINA.FULL_STAMIN_FADE_TIME,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut,
			0,
			false,
			GlobalInfo.MOVEMENT.STAMINA.FULL_STAMIN_WAIT_TIME
		)

		TweenService:Create(self.staminaHolder, tweenInfo, { GroupTransparency = 1 }):Play()
	elseif self.reachedTop and self:GetStaminaPercentage() ~= 1 then
		self.reachedTop = false

		local tweenInfo = TweenInfo.new(GlobalInfo.MOVEMENT.STAMINA.FULL_STAMIN_FADE_TIME, Enum.EasingStyle.Sine)

		TweenService:Create(self.staminaHolder, tweenInfo, { GroupTransparency = 0 }):Play()
	end
end

--[[
	Changes fov so player looks like there running fast

	@param self Stamina - object
]]
function Stamina.SetFOV(self: Stamina)
	if not self.isFirstPerson then
		return
	end

	if self.root.AssemblyLinearVelocity.Magnitude >= GlobalInfo.MOVEMENT.SPEED.RUNNING - 1 then
		if self.prevFovState == true then
			return
		end
		self.prevFovState = true

		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
		local fov = GlobalInfo.CAMERA.DEFAULT_FOV + GlobalInfo.MOVEMENT.STAMINA.FOV_ZOOM_OUT

		TweenService:Create(camera, tweenInfo, { FieldOfView = fov }):Play()
	else
		if self.prevFovState == false then
			return
		end
		self.prevFovState = false

		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
		local fov = GlobalInfo.CAMERA.DEFAULT_FOV + 0

		TweenService:Create(camera, tweenInfo, { FieldOfView = fov }):Play()
	end
end

--[[
	Checks if player can unCrouch.

	@param self Stamina - object
]]
function Stamina.CanUnCrouch(self: Stamina): boolean
	if not player.Character then
		return false
	end

	local param = RaycastParams.new()
	param.RespectCanCollide = false
	param.FilterDescendantsInstances = { table.unpack(player.Character:GetDescendants()) }

	local ray = workspace:Raycast(self.root.Position, self.root.CFrame.UpVector * UN_CROUCH_CHECK_DISTANCE, param)

	return ray == nil
end

--[[
	Main loop

	@param self Stamina - object
	@param on boolean - turn the Stamina on?
]]
function Stamina.Track(self: Stamina)
	self._cleaner:Connect(RunService.Heartbeat, function()
		self:SetFade()
		self:SetReachBottom()
		self:SetFOV()

		if not canSprint then
			self.requestingSprint = false
		end

		if not canCrouch then
			self.requestingCrouch = false
		end

		if not self.requestingSprint or self.reachedBottom then
			self:Regen()
		else
			self:Drain()
		end
	end)

	CameraBobbing.ConnectAndListenToFirstPersonType(function()
		self.isFirstPerson = true
	end, function()
		self.isFirstPerson = false
		camera.FieldOfView = GlobalInfo.CAMERA.DEFAULT_FOV
	end)
end

--[[
	Connects key binds to running

	@param self Stamina - object
]]
function Stamina.ConnectKey(self: Stamina)
	--sprint
	local function activatedStamina(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		if inputState == Enum.UserInputState.End then
			self.requestingSprint = false
			return Enum.ContextActionResult.Pass
		end

		if self.requestingCrouch then
			return Enum.ContextActionResult.Pass
		end

		if self.reachedBottom then
			return Enum.ContextActionResult.Pass
		end

		if not self:CanUnCrouch() then
			return Enum.ContextActionResult.Pass
		end

		if time() - self.prevClick < 0.1 then
			return Enum.ContextActionResult.Pass
		end
		self.prevClick = time()

		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		self.requestingSprint = true

		return Enum.ContextActionResult.Sink
	end

	ContextActionService:BindActionAtPriority(
		"Stamina",
		activatedStamina,
		true,
		3000,
		Enum.KeyCode.LeftShift,
		Enum.KeyCode.ButtonR2
	)

	self._cleaner:Add(function()
		ContextActionService:UnbindAction("Stamina")
	end)

	--crouch
	local function activatedCrouch(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		if inputState == Enum.UserInputState.End then
			return Enum.ContextActionResult.Pass
		end

		if self.requestingSprint then
			return Enum.ContextActionResult.Pass
		end

		if not self:CanUnCrouch() then
			return Enum.ContextActionResult.Pass
		end

		if time() - self.prevClick < 0.1 then
			return Enum.ContextActionResult.Pass
		end
		self.prevClick = time()

		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		self.requestingCrouch = not self.requestingCrouch

		return Enum.ContextActionResult.Sink
	end

	ContextActionService:BindActionAtPriority(
		"Crouch",
		activatedCrouch,
		true,
		3000,
		Enum.KeyCode.C,
		Enum.KeyCode.LeftControl,
		Enum.KeyCode.ButtonR1
	)

	self._cleaner:Add(function()
		ContextActionService:UnbindAction("Crouch")
	end)
end

--[[
	Cleans up the Stamina object.

	@param self Stamina - object
]]
function Stamina.Cleanup(self: Stamina)
	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _characterTagConnection = Utility.Tags.TagCharacterConnection(Stamina.TAG_NAME)
local _cleanup, _objects = Utility.Tags.SetObjectListener(Stamina)
local _uniqueClass = Utility.Tags.GetUniqueClass(Stamina.TAG_NAME, _objects)

-------------------------------------------------------------------------------------------

local receiveSignal = RedEvents.SystemConnect.CreateReceiver("Stamina")

receiveSignal("SetCanSprint", function(activate: boolean)
	canSprint = activate
end)

receiveSignal("GetCanSprint", function(): boolean
	return canSprint
end)

receiveSignal("SetCanCrouch", function(activate: boolean)
	canCrouch = activate
end)

receiveSignal("GetCanCrouch", function(): boolean
	return canCrouch
end)

receiveSignal("SetSpeedMultiplier", function(multiplier: number?)
	Stamina.speedMultiplier = multiplier or 1
end)

receiveSignal("SetRegenMultiplier", function(multiplier: number?)
	Stamina.regenMultiplier = multiplier or 1
end)

receiveSignal("SetDrainMultiplier", function(multiplier: number?)
	Stamina.drainMultiplier = multiplier or 1
end)

return {}
