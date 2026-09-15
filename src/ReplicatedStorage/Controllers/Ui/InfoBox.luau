--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Trove = require(ReplicatedStorage.Packages.trove)

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)
local Sounds = require(ReplicatedStorage.Common.Sounds)

local RedEvents = require(ReplicatedStorage.RedEvents)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local CHARACTERS_PER_SECOND = 17

local infoBox = Instance.new("ScreenGui")
infoBox.Name = "InfoBox"
infoBox.IgnoreGuiInset = true
infoBox.ResetOnSpawn = false
infoBox.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
infoBox.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
infoBox.Parent = player.PlayerGui

local function newLine(): TextLabel
	local infoText = Instance.new("TextLabel")
	infoText.Name = "InfoText"
	infoText.AnchorPoint = Vector2.new(0.5, 1)
	infoText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	infoText.BackgroundTransparency = 1
	infoText.BorderColor3 = Color3.fromRGB(0, 0, 0)
	infoText.BorderSizePixel = 1
	infoText.FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json")
	infoText.Position = UDim2.new(0.5, 0, 0.97, -3)
	infoText.RichText = true
	infoText.Size = UDim2.new(0.65, 0, 0.01, 15)
	infoText.TextColor3 = GlobalInfo.COLOR_THEME.NEUTRAL.TEXT.PRIMARY
	infoText.TextScaled = false
	infoText.TextSize = 17
	infoText.TextTruncate = Enum.TextTruncate.AtEnd
	infoText.TextWrapped = true
	infoText.TextTransparency = 1
	infoText.TextStrokeTransparency = 0.5
	infoText.TextStrokeColor3 = Color3.new(0, 0, 0)
	infoText.TextYAlignment = Enum.TextYAlignment.Top

	local textSizeConstraint = Instance.new("UITextSizeConstraint")
	textSizeConstraint.MinTextSize = 4
	textSizeConstraint.MaxTextSize = 17
	textSizeConstraint.Parent = infoText

	return infoText
end

local requestedWeight, lineCreationCount = 0, 0
local createNewLine = Instance.new("BindableEvent")
local function addLine(text: string, weight: number)
	if weight < requestedWeight then
		return
	end
	requestedWeight = weight

	createNewLine:Fire()

	lineCreationCount += 1
	local currentLineCount = lineCreationCount

	local cleaner = Trove.new()

	local info = TweenInfo.new(1, Enum.EasingStyle.Cubic)

	local infoText = newLine()
	infoText.Text = text
	infoText.Parent = infoBox

	local targetPos = infoText.Position
	cleaner:Connect(createNewLine.Event, function()
		targetPos += UDim2.new(0, 0, -(0.01 + 0.002), -(15 + 2))

		if targetPos.Y.Scale < 0.94 then
			cleaner:Destroy()
		end

		TweenService:Create(infoText, info, { Position = targetPos }):Play()
	end)

	cleaner:Add(function()
		TweenService:Create(infoText, info, { TextTransparency = 1 }):Play()

		task.wait(1)

		infoText:Destroy()

		if currentLineCount == lineCreationCount then
			requestedWeight = 0
		end
	end)

	task.delay(2 + (#text / CHARACTERS_PER_SECOND), function()
		if cleaner then
			cleaner:Destroy()
		end
	end)

	TweenService:Create(infoText, info, { TextTransparency = 0 }):Play()
	Sounds.PlaySoundByName("NewInfoLine", Sounds.Variance())
end

local function colorText(text: string, color: Color3)
	local realText = "[" .. text .. "]"

	return '<font color="'
		.. "rgb("
		.. tostring(math.round(color.R * 255))
		.. ","
		.. tostring(math.round(color.G * 255))
		.. ","
		.. tostring(math.round(color.B * 255))
		.. ')">'
		.. realText
		.. "</font>"
end

local function getPlayerColor(playerForColor: Player)
	local sortedPlayers = {}
	for _, newPlayer in pairs(Players:GetPlayers()) do
		table.insert(sortedPlayers, newPlayer.UserId)
	end
	table.sort(sortedPlayers)

	local index = table.find(sortedPlayers, playerForColor.UserId) or GlobalInfo.MAX_PLAYERS + 1

	return GlobalInfo.INFO_TEXT.PLAYER_COLORS[index]
end

local function addFullLine(name: string, text: string, weight: number)
	addLine(name .. ":" .. text, weight)
end

local function addFullPlayerLine(playerForLine: Player, text: string, weight: number)
	local color = getPlayerColor(playerForLine)
	local name = colorText(playerForLine.Name, color)
	addLine(name .. ":" .. text, weight)
end

local function addFullLocalLine(text: string, weight: number)
	local realWeight = math.clamp(weight, 0, 99)
	local color = getPlayerColor(player)
	local name = colorText(player.Name, color)

	addFullLine(name, text, realWeight)
end

--local
local receiveSignal = RedEvents.SystemConnect.CreateReceiver("InfoBox")

receiveSignal("ColorText", function(text: string, color: Color3)
	colorText(text, color)
end)

receiveSignal("GetPlayerColor", function(playerForColor: Player)
	return getPlayerColor(playerForColor)
end)

receiveSignal("AddLine", function(text: string, weight: number)
	addLine(text, weight)
end)

receiveSignal("AddFullLine", function(name: string, text: string, weight: number)
	addFullLine(name, text, weight)
end)

receiveSignal("AddFullPlayerLine", function(playerForLine: Player, text: string, weight: number)
	addFullPlayerLine(playerForLine, text, weight)
end)

receiveSignal("AddFullLocalLine", function(text: string, weight: number)
	addFullLocalLine(text, weight)
end)

--server
RedEvents.Network.Server.SendLine:OnClient(function(header: Instance | string, text: string, weight: number)
	local realWeight = math.clamp(weight or 0, 100, math.huge)

	if typeof(header) == "string" then
		addFullLine(header, text, realWeight)
	elseif typeof(header) == "Instance" and header:IsA("Player") then
		addFullPlayerLine(header, text, realWeight)
	else
		warn("Header was incorrect type; " .. typeof(header) .. ". Text data: ", text)
	end
end)

return {}
