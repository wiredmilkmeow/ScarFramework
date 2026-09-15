--!strict

local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Trove = require(ReplicatedStorage.Packages.trove)

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)
local RedEvents = require(ReplicatedStorage.RedEvents)
local Utility = require(ReplicatedStorage.Utility)

local Market = require(ReplicatedStorage.Common.Market)
local Sounds = require(ReplicatedStorage.Common.Sounds)

local LightInstance = require(script.LightInstance)

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local canActivate = false

local Light = {}
Light.__index = Light
Light.TAG_NAME = "Light"

type self = {
	ring: Part,
	light1: SpotLight,
	light2: SpotLight,
	alignPosition: AlignPosition,
	alignOrientation: AlignOrientation,

	prevClick: number,
	isHeld: boolean,

	_cleaner: typeof(Trove.new()),
}

export type Light = typeof(setmetatable({} :: self, Light))

--[[
	Constructor

	@return self - the new object
]]
function Light.new()
	if not Utility.Tags.GetUnique(Light.TAG_NAME) then
		warn("There is more than one object with the " .. Light.TAG_NAME .. " Tag")
	end

	local self = setmetatable({} :: self, Light)
	self._cleaner = Trove.new()

	local r, l1, l2, aP, aO = LightInstance.New(camera)
	self.ring = r :: any
	self.light1 = l1 :: any
	self.light2 = l2 :: any
	self.alignPosition = aP :: any
	self.alignOrientation = aO :: any

	self.prevClick = 0

	self:SetGamepass()
	self:Track()
	self:ConnectKey()

	return self
end

--[[
	Turns off light for fake flashlight.
]]
function Light.DisableFakeLight()
	if not player.Character then
		return
	end

	local lights = CollectionService:GetTagged("FakePlayerLight")

	local foundFakeLight = false

	for _, light in pairs(lights) do
		if not light:IsA("SpotLight") then
			continue
		end

		local newCharacter = light:FindFirstAncestorOfClass("Model")
		if newCharacter and newCharacter.Name == player.Character.Name then
			foundFakeLight = true

			light.Enabled = false
			break
		end
	end

	if not foundFakeLight then
		task.wait() --prevent crashing
		Light.DisableFakeLight()
	end
end

--[[
	Turn the Flashlight on and off directly.

	@param self Light - object
	@param on boolean - Set Light
]]
function Light.On(self: Light, on: boolean)
	self.light1.Enabled = on
	self.light2.Enabled = on

	player:SetAttribute("_LightIsOn", on)

	--for putting flashlight in players hand
	RedEvents.Network.Client.FlashlightState:FireServer(on)

	if on then
		task.spawn(Light.DisableFakeLight)
	end
end

--[[
	Will set gamepass flashlight if the player purchased it.

	@param self Light - object
	@param gamepass boolean - Does this person have gamepass?
]]
function Light.SetGamepass(self: Light)
	if Market.LocalPlayerOwnsGamepass(Market.Id.GamePasses.BetterFlashlight) then
		self.light1.Range = 70
		self.light2.Range = 70

		self.light1.Brightness = 0.4
		self.light2.Brightness = 1.7
	else
		self.light1.Range = 40
		self.light2.Range = 40

		self.light1.Brightness = 0.3
		self.light2.Brightness = 1.2
	end
end

--[[
	Will turn the light on and off with added sounds and timing.

	@param self Light - object
	@param on boolean - turn the light on?
]]
function Light.TurnOn(self: Light, on: boolean)
	self.isHeld = on

	if on then
		self:On(true)
		Sounds.PlaySoundByName("FlashlightClick", Sounds.Variance(1, 1.03, 1, 1.05), self.ring)
	else
		task.wait(0.2)
		self:On(false)
		Sounds.PlaySoundByName("FlashlightClick", Sounds.Variance(0.93, 0.97, 0.95, 1), self.ring)
	end
end

--[[
	Tells you if the Flashlight is currently being held or not.

	@param self Light - object

	@return boolean - is it currently held?
]]
function Light.IsHeld(self: Light): boolean
	return self.isHeld
end

--[[
	Will turn the light on and off with added sounds and timing.

	@param self Light - object
	@param on boolean - turn the light on?
]]
function Light.Track(self: Light)
	self._cleaner:Connect(RunService.PreRender, function()
		if not canActivate and self:IsHeld() then
			self:TurnOn(false)
			return
		end

		local goal: CFrame

		if self:IsHeld() then
			goal = camera.CFrame * CFrame.new(0.75, 0, 0) * CFrame.Angles(0, math.rad(0.716), 0)
		else
			goal = camera.CFrame * CFrame.new(1, -3, 0) * CFrame.Angles(math.rad(-90), 0, 0)
		end

		self.ring.LocalTransparencyModifier = -math.huge

		self.alignPosition.Position = goal.Position
		self.alignOrientation.CFrame = goal
	end)
end

--[[
	Tells you if the Flashlight is currently being held or not.

	@param self Light - object
]]
function Light.ConnectKey(self: Light)
	local function activatedFlashlight(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		if not canActivate then
			return Enum.ContextActionResult.Pass
		end

		if time() - self.prevClick < GlobalInfo.FLASHLIGHT.LIGHT_SWITCH_SPEED then
			return Enum.ContextActionResult.Pass
		end
		self.prevClick = time()

		self:TurnOn(not self:IsHeld())

		return Enum.ContextActionResult.Sink
	end

	ContextActionService:BindActionAtPriority(
		"Flashlight",
		activatedFlashlight,
		true,
		3000,
		Enum.KeyCode.F,
		Enum.KeyCode.ButtonR1
	)

	self._cleaner:Add(function()
		ContextActionService:UnbindAction("Flashlight")
	end)
end

--[[
	Cleans up the Light object.

	@param self Light - object
]]
function Light.Cleanup(self: Light)
	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _characterTagConnection = Utility.Tags.TagCharacterConnection(Light.TAG_NAME)
local _cleanup, _objects = Utility.Tags.SetObjectListener(Light)
local _uniqueClass = Utility.Tags.GetUniqueClass(Light.TAG_NAME, _objects)

-------------------------------------------------------------------------------------------

local receiveSignal = RedEvents.SystemConnect.CreateReceiver("Flashlight")

receiveSignal("SetCanActivate", function(activate: boolean)
	canActivate = activate
end)

receiveSignal("GetCanActivate", function(): boolean
	return canActivate
end)

receiveSignal("HoldingLight", function(): boolean
	if not _uniqueClass then
		return false
	end

	return _uniqueClass:IsHeld()
end)

receiveSignal("SetLight", function(holding: boolean)
	if not _uniqueClass then
		return
	end

	_uniqueClass:TurnOn(holding)
end)

return {}
