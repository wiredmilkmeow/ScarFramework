--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)

return {
	New = function(parent: Instance)
		local stamina = Instance.new("ScreenGui")
		stamina.Name = "Stamina"
		stamina.DisplayOrder = 20
		stamina.IgnoreGuiInset = true
		stamina.ResetOnSpawn = false
		stamina.ScreenInsets = Enum.ScreenInsets.None
		stamina.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

		local stamina1 = Instance.new("CanvasGroup")
		stamina1.Name = "Stamina"
		stamina1.AnchorPoint = Vector2.new(0.5, 1)
		stamina1.BackgroundTransparency = 1
		stamina1.Position = UDim2.fromScale(0.5, 1)
		stamina1.Size = UDim2.new(1, 0, 0.012, 5)

		local bar = Instance.new("Frame")
		bar.Name = "Bar"
		bar.AnchorPoint = Vector2.new(0, 1)
		bar.BackgroundTransparency = 1
		bar.LayoutOrder = 2
		bar.Position = UDim2.fromScale(0, 1)
		bar.Size = UDim2.fromScale(1, 0.7)

		local amount = Instance.new("Frame")
		amount.Name = "Amount"
		amount.BackgroundColor3 = GlobalInfo.COLOR_THEME.NEUTRAL.BACKGROUND.VERY_LIGHT
		amount.BackgroundTransparency = 0.2
		amount.Size = UDim2.fromScale(1, 1)
		amount.Parent = bar

		bar.Parent = stamina1

		local background = Instance.new("Frame")
		background.Name = "Background"
		background.BackgroundColor3 = GlobalInfo.COLOR_THEME.NEUTRAL.BACKGROUND.VERY_DARK
		background.BorderSizePixel = 0
		background.Size = UDim2.fromScale(1, 1)
		background.ZIndex = 0

		local uIGradient = Instance.new("UIGradient")
		uIGradient.Name = "UIGradient"
		uIGradient.Rotation = -90
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.504988, 0),
			NumberSequenceKeypoint.new(0.700748, 0.5125),
			NumberSequenceKeypoint.new(0.901496, 0.75),
			NumberSequenceKeypoint.new(1, 1),
		})
		uIGradient.Parent = background

		background.Parent = stamina1

		stamina1.Parent = stamina

		stamina.Parent = parent

		return stamina, stamina1, amount
	end,
}
