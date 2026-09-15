--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)

return {
	New = function(parent: Instance)
		local objectiveUI = Instance.new("ScreenGui")
		objectiveUI.Name = "ObjectiveUI"
		objectiveUI.DisplayOrder = 5
		objectiveUI.ResetOnSpawn = false
		objectiveUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

		local uIPadding = Instance.new("UIPadding")
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingBottom = UDim.new(0, 5)
		uIPadding.PaddingLeft = UDim.new(0, 5)
		uIPadding.PaddingRight = UDim.new(0, 5)
		uIPadding.PaddingTop = UDim.new(0, 5)
		uIPadding.Parent = objectiveUI

		local holder = Instance.new("CanvasGroup")
		holder.Name = "Holder"
		holder.BackgroundTransparency = 1
		holder.GroupTransparency = 1
		holder.Size = UDim2.new(0.16, 85, 0.17, 90)
		holder.SizeConstraint = Enum.SizeConstraint.RelativeXX
		holder.AnchorPoint = Vector2.new(1, 0)
		holder.Position = UDim2.fromScale(0.955, 0)

		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.BackgroundTransparency = 1
		title.FontFace =
			Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		title.LayoutOrder = 1
		title.Size = UDim2.fromScale(1, 0.1)
		title.Text = "Objective"
		title.TextColor3 = GlobalInfo.COLOR_THEME.NEUTRAL.BACKGROUND.LIGHT
		title.TextScaled = true
		title.TextStrokeTransparency = 0.5
		title.TextTransparency = 0.2

		local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
		uITextSizeConstraint.Name = "UITextSizeConstraint"
		uITextSizeConstraint.MaxTextSize = 40
		uITextSizeConstraint.MinTextSize = 15
		uITextSizeConstraint.Parent = title

		title.Parent = holder

		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Name = "UIListLayout"
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.ItemLineAlignment = Enum.ItemLineAlignment.Center
		uIListLayout.Padding = UDim.new(0, 10)
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = holder

		local description = Instance.new("TextLabel")
		description.Name = "Description"
		description.BackgroundTransparency = 1
		description.FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json")
		description.LayoutOrder = 3
		description.Size = UDim2.fromScale(0.9, 0.8)
		description.Text = "Go find your flashlight!"
		description.TextColor3 = GlobalInfo.COLOR_THEME.NEUTRAL.TEXT.PRIMARY
		description.TextScaled = true
		description.TextStrokeTransparency = 0.5
		description.TextTransparency = 0.05
		description.TextYAlignment = Enum.TextYAlignment.Top

		local uITextSizeConstraint1 = Instance.new("UITextSizeConstraint")
		uITextSizeConstraint1.Name = "UITextSizeConstraint"
		uITextSizeConstraint1.MaxTextSize = 20
		uITextSizeConstraint1.MinTextSize = 8
		uITextSizeConstraint1.Parent = description

		description.Parent = holder

		local divider = Instance.new("Frame")
		divider.Name = "Divider"
		divider.BackgroundColor3 = GlobalInfo.COLOR_THEME.NEUTRAL.BACKGROUND.LIGHT
		divider.BackgroundTransparency = 0.15
		divider.BorderColor3 = Color3.new()
		divider.BorderSizePixel = 0
		divider.LayoutOrder = 2
		divider.Size = UDim2.new(0.001, 0, 0, 10)

		local uIGradient = Instance.new("UIGradient")
		uIGradient.Name = "UIGradient"
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.501247, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		uIGradient.Parent = divider

		divider.Parent = holder

		holder.Parent = objectiveUI

		objectiveUI.Parent = parent

		return objectiveUI, holder, description, divider
	end,
}
