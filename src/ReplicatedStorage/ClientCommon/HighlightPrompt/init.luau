--!strict

--[[
	Highlights objects

	replaces proximity prompts
]]

local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Input = require(ReplicatedStorage.Packages.input)
local Trove = require(ReplicatedStorage.Packages.trove)

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)
local RedEvents = require(ReplicatedStorage.RedEvents)

local Highlighter = require(script:WaitForChild("Highlighter"))

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local buttonActivated = RedEvents.NewSignal()

local registeredClasses: { [string]: boolean } = {}

export type HighlightPrompt = {
	ClickablePrompt: boolean,
	Enabled: boolean,
	MaxActivationDistance: number,

	HighlightDepthMode: Enum.HighlightDepthMode,
	HighlightOutlineColor: Color3,
	HighlightFillColor: Color3,
	HighlightOutlineTransparency: number,
	HighlightFillTransparency: number,

	ServerClass: string?,

	HoverEnter: RBXScriptSignal,
	HoverEscape: RBXScriptSignal,
	Activated: RBXScriptSignal,

	Destroy: (HighlightPrompt) -> (),
}

local function createPrompt(parent: Instance): HighlightPrompt
	local cleaner = Trove.new()
	local hoverEnter = cleaner:Add(Instance.new("BindableEvent"))
	local hoverEscape = cleaner:Add(Instance.new("BindableEvent"))
	local activated = cleaner:Add(Instance.new("BindableEvent"))

	local base = parent:IsA("BasePart") and parent or parent:FindFirstAncestorWhichIsA("BasePart")

	local self = Highlighter.new(parent)

	local results = {
		ClickablePrompt = true,
		Enabled = true,
		MaxActivationDistance = 8,

		HighlightDepthMode = Enum.HighlightDepthMode.Occluded,
		HighlightOutlineColor = Color3.new(1, 1, 1),
		HighlightFillColor = Color3.new(1, 1, 1),
		HighlightOutlineTransparency = 0.25,
		HighlightFillTransparency = 0.7,

		ServerClass = nil,

		HoverEnter = hoverEnter.Event,
		HoverEscape = hoverEscape.Event,
		Activated = activated.Event,

		Destroy = function()
			self._cleaner:Destroy()
		end,
	} :: HighlightPrompt

	if base then
		parent:AddTag("HighlightHover")

		local function foundTaggedObject(object: BasePart)
			local isHover = CollectionService:HasTag(object, "HighlightHover")
			return isHover and object == parent
		end

		local function hitBase(raycast: RaycastResult)
			local directTag = foundTaggedObject(raycast.Instance)
			local indirectTag = nil

			local ancestorBase = raycast.Instance:FindFirstAncestorWhichIsA("BasePart")
			if ancestorBase then
				indirectTag = foundTaggedObject(ancestorBase)
			end

			return directTag or indirectTag
		end

		local function inRange(raycast: RaycastResult)
			return results.MaxActivationDistance > raycast.Distance
		end

		local function hitHighlightPrompt(): boolean
			if not player.Character then
				return false
			end

			local raycastParams = RaycastParams.new()
			raycastParams.IgnoreWater = true

			raycastParams.FilterDescendantsInstances = { table.unpack(player.Character:GetDescendants()) }

			local ray = Input.Mouse:Raycast(raycastParams)

			if ray and hitBase(ray) and inRange(ray) then
				return true
			else
				return false
			end
		end

		local function fadeHighlight(direction: "In" | "Out")
			local increment = direction == "In" and -0.04 or 0.04

			local currentOutlineTransparency = self:GetProperty("OutlineTransparency") :: number
			local newOutlineTransparency =
				math.clamp(currentOutlineTransparency + increment, results.HighlightOutlineTransparency, 1)
			self:SetProperty("OutlineTransparency", newOutlineTransparency)

			local currentFillTransparency = self:GetProperty("FillTransparency") :: number
			self:SetProperty(
				"FillTransparency",
				math.clamp(currentFillTransparency + increment, results.HighlightFillTransparency, 1)
			)
		end

		local prevHit = false
		local currentlyHit = false

		--self:SetProperty("Enabled", false)
		self:SetProperty("OutlineTransparency", 1)
		self:SetProperty("FillTransparency", 1)

		local totalFrames = 0
		cleaner:Connect(RunService.RenderStepped, function()
			totalFrames += 1
			if totalFrames % 2 ~= 0 then --prob only need to check every other frame or think of a more performant solution
				return
			end

			self:SetProperty("DepthMode", results.HighlightDepthMode)
			self:SetProperty("OutlineColor", results.HighlightOutlineColor)
			self:SetProperty("FillColor", results.HighlightFillColor)

			if results.Enabled then
				self:SetProperty("Enabled", true)
			else
				self:SetProperty("Enabled", false)
				currentlyHit = false
				return
			end

			local hitResult = hitHighlightPrompt()
			currentlyHit = hitResult

			if hitResult then
				fadeHighlight("In")
			else
				fadeHighlight("Out")
			end

			if prevHit ~= hitResult then
				if hitResult then
					hoverEnter:Fire()
				else
					hoverEscape:Fire()
				end
			end

			prevHit = hitResult

			if results.ServerClass and not registeredClasses[results.ServerClass] then
				registeredClasses[results.ServerClass] = true
			end
		end)

		local function sendClassToServer()
			if not results.ServerClass then
				return
			end

			RedEvents.Network.Client.PromptClassActivation:FireServer(results.ServerClass, parent)
		end

		local lastActivationTime = 0
		local connection = buttonActivated:Connect(function()
			if not results.ClickablePrompt then
				return
			end

			if not results.Enabled then
				return
			end

			if time() - lastActivationTime < 0.1 then
				return
			end
			lastActivationTime = time()

			if not currentlyHit then
				return
			end

			sendClassToServer()
			activated:Fire()
		end)

		cleaner:Add(function()
			parent:RemoveTag("HighlightHover")
			connection()
			self:Cleanup()
		end)
	else
		warn("Could not find base to attach HighlightHover, Parent: " .. parent:GetFullName())
	end

	return results
end

-------------------------------------------------------------------------------------------

local lastClickState = false
RunService.RenderStepped:Connect(function()
	if Input.Mouse:IsLeftDown() then
		if lastClickState then
			return
		end
		lastClickState = true

		buttonActivated:Fire()
	else
		lastClickState = false
	end
end)

local function buttonPressed(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
	if inputState == Enum.UserInputState.End then
		return Enum.ContextActionResult.Pass
	end

	buttonActivated:Fire()

	return Enum.ContextActionResult.Sink
end

ContextActionService:BindActionAtPriority(
	"HighlightPrompt",
	buttonPressed,
	true,
	3000,
	Enum.KeyCode.E,
	Enum.KeyCode.ButtonR1
)

-------------------------------------------------------------------------------------------

local HighlightPrompt = {}

--[[
	Adds Highlight Preset to HighlightPrompt.

	@param prompt HighlightPrompt - Prompt to apply preset
	@param preset "Neutral" | "Confirm" | "Deny" - name of the preset
]]
function HighlightPrompt.SetHighlightPreset(prompt: HighlightPrompt, preset: "Neutral" | "Confirm" | "Deny")
	local whiteAccent = GlobalInfo.COLOR_THEME.ACCENT.WHITE
	local greenAccent = GlobalInfo.COLOR_THEME.ACCENT.GREEN
	local redAccent = GlobalInfo.COLOR_THEME.ACCENT.RED

	if preset == "Neutral" then
		prompt.HighlightOutlineColor = whiteAccent
		prompt.HighlightFillColor = Color3.new(whiteAccent.R * 1.2, whiteAccent.G * 1.2, whiteAccent.B * 1.2)
		prompt.HighlightOutlineTransparency = 0.25
		prompt.HighlightFillTransparency = 0.7
	elseif preset == "Confirm" then
		prompt.HighlightOutlineColor = greenAccent
		prompt.HighlightFillColor = Color3.new(greenAccent.R * 1.2, greenAccent.G * 1.2, greenAccent.B * 1.2)
		prompt.HighlightOutlineTransparency = 0.25
		prompt.HighlightFillTransparency = 0.7
	elseif preset == "Deny" then
		prompt.HighlightOutlineColor = redAccent
		prompt.HighlightFillColor = Color3.new(redAccent.R * 1.2, redAccent.G * 1.2, redAccent.B * 1.2)
		prompt.HighlightOutlineTransparency = 0.25
		prompt.HighlightFillTransparency = 0.7
	end
end

--[[
	Create a HighlightPrompt to use locally.

	@param parent Instance - Instance to attach prompt

	@return HighlightPrompt - the HighlightPrompt (fake)Instance
]]
function HighlightPrompt.Create(parent: Instance): HighlightPrompt
	return createPrompt(parent)
end

--[[
	Get all HighlightPrompt class names registered to the server.

	@return { [string]: boolean } - classes table
]]
function HighlightPrompt.GetRegisteredClasses(): { [string]: boolean }
	return registeredClasses
end

return HighlightPrompt
