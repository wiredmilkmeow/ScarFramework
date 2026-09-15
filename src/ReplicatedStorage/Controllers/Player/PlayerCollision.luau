--!strict

--[[
    This should have a signal to send to body tracking so it gets camera CFrame without the bobbing

    may need some functions to stop camera bobbing on cutscenes
]]

---------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)

local RedEvents = require(ReplicatedStorage.RedEvents)
local Utility = require(ReplicatedStorage.Utility)

local PlayerCollision = {}
PlayerCollision.__index = PlayerCollision
PlayerCollision.TAG_NAME = "PlayerCollision"

type self = {
	root: Part,
	head: BasePart,

	collisionPart: BasePart,
	collisionWeld: Weld,

	originalSize: Vector3,

	_cleaner: typeof(Trove.new()),
}

export type PlayerCollision = typeof(setmetatable({} :: self, PlayerCollision))

--[[
	Constructor

	@return self - the new object
]]
function PlayerCollision.new(root: Part?)
	if not root then
		return
	end

	local head = root.Parent and root.Parent:FindFirstChild("Head") :: BasePart or nil
	assert(head, "Could not find Head for " .. PlayerCollision.TAG_NAME)

	local collisionPart = root.Parent and root.Parent:FindFirstChild("CollisionPart") :: BasePart or nil
	assert(collisionPart, "Could not find CollisionPart for " .. PlayerCollision.TAG_NAME)

	local weld = collisionPart:FindFirstChildWhichIsA("Weld") or nil
	assert(weld, "Could not find Weld for " .. PlayerCollision.TAG_NAME)

	if not Utility.Tags.GetUnique(PlayerCollision.TAG_NAME) then
		warn("There is more than one object with the " .. PlayerCollision.TAG_NAME .. " Tag")
	end

	local self = setmetatable({} :: self, PlayerCollision)
	self._cleaner = Trove.new()

	self.root = root
	self.head = head
	self.collisionPart = collisionPart
	self.originalSize = collisionPart.Size
	self.collisionWeld = weld

	self:Start()

	return self
end

--[[
	Applies the collision changes.

	@param self PlayerCollision - object
]]
function PlayerCollision.Start(self: PlayerCollision)
	local headCollider = self._cleaner:Add(Instance.new("Part"))
	headCollider.CollisionGroup = "DefaultOnly"
	headCollider.Shape = Enum.PartType.Ball
	headCollider.Size = Vector3.one * 1
	headCollider.Transparency = 1
	headCollider.CastShadow = false
	headCollider.CanTouch = false

	headCollider:PivotTo(self.head.CFrame)
	headCollider.Parent = self.head

	local weld = self._cleaner:Add(Instance.new("WeldConstraint"))
	weld.Part0 = headCollider
	weld.Part1 = self.head

	weld.Parent = self.head

	local function adjustCollisionDepth(depth: number)
		local collisionWeldCFrame = self.collisionWeld.C0
		self.collisionWeld.C0 = CFrame.new(collisionWeldCFrame.Position.X, collisionWeldCFrame.Position.Y, depth)
			* collisionWeldCFrame.Rotation
	end

	adjustCollisionDepth(0.15)
	local connection = RedEvents.Signal.Client.WalkState:Connect(function(type: "Crouch" | "Walk" | "Sprint")
		if type == "Crouch" then
			self.collisionPart.Size = self.originalSize * Vector3.new(0.9, 0.4, 1.3)
			adjustCollisionDepth(0.45)
		else
			self.collisionPart.Size = self.originalSize
			adjustCollisionDepth(0.15)
		end
	end)

	self._cleaner:Add(connection)
end

--[[
	Cleans up the PlayerCollision object.

	@param self PlayerCollision - object
]]
function PlayerCollision.Cleanup(self: PlayerCollision)
	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _characterTagConnection = Utility.Tags.TagCharacterConnection(PlayerCollision.TAG_NAME)
local _cleanup, _objects = Utility.Tags.SetObjectListener(PlayerCollision)
local _uniqueClass = Utility.Tags.GetUniqueClass(PlayerCollision.TAG_NAME, _objects)

-------------------------------------------------------------------------------------------

return {}
