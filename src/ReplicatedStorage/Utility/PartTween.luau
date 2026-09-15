--!strict

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--[[
	For simple movement and rotation by part
]]
local PartTween = {}

--[[
	Move and rotate a part from its pivot point by tween
	
	@param part BasePart - The part you want to tween
	@param target CFrame - The CFrame you want the part to move too
	@param info TweenInfo? - optional TweenInfo for the transition

	@return number - The time the tween will take
]]
function PartTween.Move(part: BasePart, target: CFrame, info: TweenInfo?): number
	local value = Instance.new("CFrameValue")
	value.Value = part:GetPivot()

	value.Changed:Connect(function(v)
		part:PivotTo(v)
	end)

	local newInfo = info or TweenInfo.new(1, Enum.EasingStyle.Sine)
	local tween = TweenService:Create(value, newInfo, { Value = target })
	tween:Play()

	local waitTime = newInfo.Time or 0 + newInfo.DelayTime
	task.delay(waitTime, function()
		value:Destroy()
	end)

	return waitTime
end

--[[
	Move and rotate a part from its pivot point by lerp

	@param part BasePart - The part you want to tween
	@param target CFrame - The CFrame you want the part to move too
	@param alpha number? - Percentage of how close the part should reach the target
]]
function PartTween.Lerp(part: BasePart, target: CFrame, alpha: number?)
	local newAlpha = alpha or 1
	local start = 0

	local connection: RBXScriptConnection = nil
	connection = (RunService:IsClient() and RunService.RenderStepped or RunService.Heartbeat):Connect(
		function(delta: number)
			if start >= newAlpha then
				connection:Disconnect()
			end
			start += delta

			part:PivotTo(part:GetPivot():Lerp(target, start * delta))
		end
	)
end

return PartTween
