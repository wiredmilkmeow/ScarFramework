--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoadedAssets = ReplicatedStorage:WaitForChild("LoadedAssets")
local flashlight = LoadedAssets:FindFirstChild("flashlight")

--[[
	having the light in all script doesn't seem to work
	codify can't seem to get everything right so it will just have to exist inside roblox
]]

return {
	New = function(parent: Instance)
		local newFlashlight = flashlight:Clone()

		local ring = newFlashlight:FindFirstChild("ring")
		local light1 = newFlashlight:FindFirstChild("OuterLight", true)
		local light2 = newFlashlight:FindFirstChild("InnerLight", true)
		local alignPosition = newFlashlight:FindFirstChild("AlignPosition")
		local alignOrientation = newFlashlight:FindFirstChild("AlignOrientation")

		newFlashlight.Parent = parent

		return ring, light1, light2, alignPosition, alignOrientation
	end,

	-- New = function(parent: Instance)
	-- 	local flashlight = Instance.new("Model")
	-- 	flashlight.Name = "flashlight"
	-- 	flashlight:PivotTo(CFrame.new(11.199, 12.596, -0.457) * CFrame.Angles(0, math.rad(-90), 0))

	-- 	local outer = Instance.new("Part")
	-- 	outer.Name = "outer"
	-- 	outer.BottomSurface = Enum.SurfaceType.Smooth
	-- 	outer.CFrame = CFrame.new(10.712, 12.5962, -0.456709, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	-- 	outer.CanCollide = false
	-- 	outer.CanQuery = false
	-- 	outer.CanTouch = false
	-- 	outer.Size = Vector3.new(0.5, 0.5, 0.20000000298023224)
	-- 	outer.TopSurface = Enum.SurfaceType.Smooth
	-- 	outer.Transparency = 1

	-- 	local light1 = Instance.new("SpotLight")
	-- 	light1.Enabled = false
	-- 	light1.Name = "outer"
	-- 	light1.Angle = 60
	-- 	light1.Brightness = 0.5
	-- 	light1.Color = Color3.fromRGB(240, 255, 220)
	-- 	light1.Range = 60
	-- 	light1.Shadows = true
	-- 	light1.Parent = outer

	-- 	outer.Parent = flashlight

	-- 	local fpart = Instance.new("Part")
	-- 	fpart.Name = "fpart"
	-- 	fpart.BottomSurface = Enum.SurfaceType.Smooth
	-- 	fpart.CFrame = CFrame.new(11.1994, 12.5962, -0.456709, 0, 0, -0.999998, 0, 1, 0, 1, 0, 0)
	-- 	fpart.CanCollide = false
	-- 	fpart.CanQuery = false
	-- 	fpart.CanTouch = false
	-- 	fpart.Size = Vector3.new(1, 1, 0.2)
	-- 	fpart.TopSurface = Enum.SurfaceType.Smooth
	-- 	fpart.Transparency = 1

	-- 	flashlight.PrimaryPart = fpart

	-- 	local light2 = Instance.new("SpotLight")
	-- 	light2.Enabled = false
	-- 	light2.Name = "light2"
	-- 	light2.Angle = 55
	-- 	light2.Brightness = 2
	-- 	light2.Range = 60
	-- 	light2.Shadows = true
	-- 	light2.Parent = fpart

	-- 	local ring1 = Instance.new("UnionOperation")
	-- 	ring1.Name = "ring"
	-- 	ring1.CFrame = CFrame.new(11.8185, 12.5965, -0.456816, -1, 0, 0, 0, 1, 0, 0, 0, -1)
	-- 	ring1.CanCollide = false
	-- 	ring1.CanQuery = false
	-- 	ring1.CanTouch = false
	-- 	ring1.Color = Color3.fromRGB(163, 162, 165)
	-- 	ring1.Material = Enum.Material.ForceField
	-- 	ring1.Size = Vector3.new(0.012260988354682922, 0.6130480766296387, 0.6130446791648865)
	-- 	ring1.Transparency = -math.huge
	-- 	ring1.Parent = flashlight

	-- 	local outer2 = Instance.new("Motor6D")
	-- 	outer2.Name = "outer"
	-- 	outer2.C0 = CFrame.new(0, 0, 0.396202, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	-- 	outer2.C1 = CFrame.new(0, 0, -0.0912208, 1, 0, 0, 0, 1, 0, 0, 0, 0.999996)
	-- 	outer2.Part0 = fpart
	-- 	outer2.Part1 = outer
	-- 	outer2.Parent = fpart

	-- 	local ring = Instance.new("Motor6D")
	-- 	ring.Name = "ring"
	-- 	ring.C0 = CFrame.new(0, 0, -0.622, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	-- 	ring.C1 = CFrame.new(-0.003, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	-- 	ring.Part0 = fpart
	-- 	ring.Part1 = ring1
	-- 	ring.Parent = fpart

	-- 	local attachment = Instance.new("Attachment")
	-- 	attachment.Name = "Attachment"
	-- 	attachment.WorldAxis = Vector3.new(0, 0, 1)
	-- 	attachment.WorldCFrame = CFrame.new(11.1994, 12.5962, -0.456709, 0, 0, -0.999998, 0, 1, 0, 1, 0, 0)
	-- 	attachment.Parent = fpart

	-- 	fpart.Parent = flashlight

	-- 	local alignOrientation = Instance.new("AlignOrientation")
	-- 	alignOrientation.Name = "AlignOrientation"
	-- 	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	-- 	alignOrientation.ReactionTorqueEnabled = true
	-- 	alignOrientation.Responsiveness = 20
	-- 	alignOrientation.Attachment0 = attachment
	-- 	alignOrientation.Parent = flashlight

	-- 	local alignPosition = Instance.new("AlignPosition")
	-- 	alignPosition.Name = "AlignPosition"
	-- 	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	-- 	alignPosition.ReactionForceEnabled = true
	-- 	alignPosition.Responsiveness = 200
	-- 	alignPosition.RigidityEnabled = true
	-- 	alignPosition.Attachment0 = attachment
	-- 	alignPosition.Parent = flashlight

	-- 	flashlight.Parent = parent

	-- 	return ring1, light1, light2, alignPosition, alignOrientation
	-- end,
}
