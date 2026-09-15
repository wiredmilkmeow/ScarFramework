--!strict

--roblox/luau-tag-utils

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local diedSignal = nil

--[[
	Get instances with all specified tags

	@param ... string - List of strings to find tag Instances of

	@return {Instance} - All the instances found
]]
local function getAll(...: string): { Instance }
	local totalTags = select("#", ...)
	assert(totalTags ~= 0, "getAll should receive at least one tag")

	local firstTag = ...

	if totalTags == 1 then
		return CollectionService:GetTagged(firstTag)
	else
		local instances = {}
		for _, instance in ipairs(CollectionService:GetTagged(firstTag)) do
			local hasAllTags = true
			for i = 2, totalTags do
				local otherTag = select(i, ...)
				if not CollectionService:HasTag(instance, otherTag) then
					hasAllTags = false
					break
				end
			end

			if hasAllTags then
				table.insert(instances, instance)
			end
		end
		return instances
	end
end

--[[
	Get instances with at least one specified tag
	
	@param ... string - List of strings to find tag Instances of

	@return {Instance} - All the instances found
]]
local function getAny(...: string): { Instance }
	local totalTags = select("#", ...)
	assert(totalTags ~= 0, "getAny should receive at least one tag")

	if totalTags == 1 then
		local firstTag = ...
		return CollectionService:GetTagged(firstTag)
	else
		local inserted = {}
		local instances = {}
		for i = 1, totalTags do
			local tag = select(i, ...)
			for _, taggedInstance in ipairs(CollectionService:GetTagged(tag)) do
				if not inserted[taggedInstance] then
					inserted[taggedInstance] = true
					table.insert(instances, taggedInstance)
				end
			end
		end
		return instances
	end
end

--[[
	If the specified tags only contain one instance across them

	Useful for special tags that are used in making specific cutscenes and events in game progression

	@param ... string - List of strings to find tag Instances of

	@return Instance - If only 1 exists it will return it
]]
local function getUnique(...: string): Instance
	local tagged = getAll(...)
	local total = #tagged

	if total == 1 then
		return tagged[1]
	end

	if total == 0 then
		error(("unable to find instance tagged with %s"):format(table.concat({ ... }, ", ")))
	end

	error(
		("expected to find only one instance tagged with %s, but found %d"):format(table.concat({ ... }, ", "), #tagged)
	)
end

-- made by VIPER

--[[
	Basic setup for listening in on tags for OOP structures

	@param class any - A metatable with some certain requirements

	@return () -> () - Cleanup function
	@return () -> ({ [Instance]: T }) - Instances that have been attached to this class
]]
local function setObjectListener<T>(class: any): (() -> (), () -> { [Instance]: T })
	local instances = {}

	local instanceAddedSignal = CollectionService:GetInstanceAddedSignal(class.TAG_NAME)
	local instanceRemovedSignal = CollectionService:GetInstanceRemovedSignal(class.TAG_NAME)

	local function onInstanceAdded(instance)
		instances[instance] = class.new(instance)
	end

	local function onInstanceRemoved(instance)
		instances[instance]:Cleanup()
		instances[instance] = nil
	end

	for _, instance in pairs(CollectionService:GetTagged(class.TAG_NAME)) do
		task.spawn(onInstanceAdded, instance)
	end
	local listiner1 = instanceAddedSignal:Connect(onInstanceAdded)
	local listiner2 = instanceRemovedSignal:Connect(onInstanceRemoved)

	return function()
		if listiner1 then
			listiner1:Disconnect()
		end
		if listiner2 then
			listiner2:Disconnect()
		end
	end, function()
		return instances
	end
end

--[[
	Logic used in tag character connection for on playerDeath.

	@param died RBXScriptSignal - determines when the player dies
]]
local function setCharacterDeathConnection(died: RBXScriptSignal)
	diedSignal = died
end

--[[
	Will add a tag to the player character root when they spawn in

	This serves as the replacement for player character scripts

	@param tag string - Tag for character

	@return RBXScriptConnection - Disconnects connection
]]
local function tagCharacterConnection(tag: string, tagPlayer: Player?): () -> ()
	local player = tagPlayer

	if player == nil and RunService:IsClient() then
		player = Players.LocalPlayer
	else
		warn("TagCharacterConnection Needs a specified player on Server, Tag: " .. tag)
	end

	if not player then
		return function() end
	end

	local function getRoot(): BasePart?
		local character = player.Character
		if not character then
			return
		end

		return character:FindFirstChild("HumanoidRootPart") :: BasePart?
	end

	local startTime = time()
	repeat
		task.wait()
	until diedSignal or time() - startTime > 10

	assert(
		diedSignal,
		"No DiedSignal found For player after searching for " .. tostring(time() - startTime) .. " seconds!"
	)

	local function setDeath(dead: boolean)
		local root = getRoot()
		assert(root, "Could not find root for DiedSignal Connection!, Player: " .. player.Name)

		if dead then
			print("you died!!!")
			root:RemoveTag(tag)
		else
			print("your alive!!!")
			root:AddTag(tag)
		end
	end

	setDeath(false)
	local diedConnection = diedSignal:Connect(function(dead: boolean) -- this may need to change in the future
		setDeath(dead)
	end)

	return function()
		if diedConnection then
			diedConnection:Disconnect()
		end
	end
end

local function getUniqueClass<T>(tag: string, objects: () -> { [Instance]: T }): T?
	local instance = getUnique(tag)
	if not instance then
		return
	end
	return objects()[instance] :: any
end

--[[
	Taging library with some custom extensions for OOP
]]
return {
	GetUnique = getUnique,
	GetAll = getAll,
	GetAny = getAny,
	SetObjectListener = setObjectListener,
	TagCharacterConnection = tagCharacterConnection,
	SetCharacterDeathConnection = setCharacterDeathConnection,
	GetUniqueClass = getUniqueClass,
}
