local StarterGui = game:GetService("StarterGui")

local function setScreen(boolean)
	--StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, boolean)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, boolean)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, boolean)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, boolean)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, boolean)

	--this causes an error sometimes and idk why yet
	StarterGui:SetCore("ResetButtonCallback", boolean)
end

task.spawn(function()
	while true do --roblox is dumb so im gonna just be safe here and loop
		setScreen(false)
		task.wait(0.5)
	end
end)

return {}
