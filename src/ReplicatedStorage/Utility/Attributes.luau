--!strict

--[[
	Extra functions to use for attributes
]]
local Attributes = {}

--[[
	Adds multiple attributes at one time with the same value

	@param instance Instance - The Instance to add the attribute
	@param value any - The value the attribute will hold
	@param ... string - The attributes that should be added with the specified value
]]
function Attributes.Add(instance: Instance, value: any, ...: string)
	for _, attribute in pairs({ ... }) do
		instance:SetAttribute(attribute, value)
	end
end

--[[
	listens for given attributes on an instance, can be disconnected

	@param instance Instance - The Instance to listen in for attributes
	@param func () -> () - Function to run when attribute changes
	@param ... string - The attributes that should be listened in

	@return { Disconnect: (self: any) -> () } - Table of functions you can run
]]
function Attributes.Listen(instance: Instance, func: () -> (), ...: string): { Disconnect: () -> () }
	local connections = {}
	local attributes = { ... }

	if #attributes == 0 then
		warn("No attributes were provided to Listen in")
		return { Disconnect = function() end }
	end

	local event = Instance.new("BindableEvent")

	event.Event:Connect(function()
		func()
	end)

	local function clean()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		event:Destroy()
	end

	local removed: RBXScriptConnection
	removed = instance.AncestryChanged:Connect(function()
		if instance:IsDescendantOf(game) then
			return
		end
		clean()
		removed:Disconnect()
	end)

	for _, attribute in ipairs(attributes) do
		local connection = instance:GetAttributeChangedSignal(attribute):Connect(function()
			event:Fire()
		end)

		table.insert(connections, connection)
	end

	return {
		Disconnect = function()
			clean()
			removed:Disconnect()
		end,
	}
end

--[[
	Checks if at least 1 given attributes exist on the given instance

	@param instance Instance - The Instance to check
	@param ... string - The attributes that may exist

	@return boolean - Does one of these attributes exist?
]]
function Attributes.Exists(instance: Instance, ...: string): boolean
	for _, attribute in ipairs({ ... }) do
		if instance:GetAttribute(attribute) ~= nil then
			return true
		end
	end

	return false
end

--[[
	Checks if all given attributes exist on the given instance

	@param instance Instance - The Instance to check
	@param ... string - The attributes that may exist

	@return boolean - Do all of these attributes exist?
]]
function Attributes.AllExists(instance: Instance, ...: string): boolean
	for _, attribute in ipairs({ ... }) do
		if instance:GetAttribute(attribute) == nil then
			return false
		end
	end

	return true
end

--[[
	Get all descendants that have at least 1 given attributes

	@param folder Instance - The Instance to check
	@param ... string - The attributes that may exist

	@return {Instance} - all instances that have at least 1 of the attributes
]]
function Attributes.GetAny(folder: Instance, ...: string): { Instance }
	local instances = {}

	for _, inst in ipairs(folder:GetDescendants()) do
		if not Attributes.Exists(inst, ...) then
			continue
		end
		table.insert(instances, inst)
	end

	return instances
end

--[[
	Get all descendants that have all given attributes

	@param folder Instance - The Instance to check
	@param ... string - The attributes that may exist

	@return {Instance} - all instances that have all of the attributes
]]
function Attributes.GetAll(folder: Instance, ...: string): { Instance }
	local instances = {}

	for _, inst in ipairs(folder:GetDescendants()) do
		if not Attributes.AllExists(inst, ...) then
			continue
		end
		table.insert(instances, inst)
	end

	return instances
end

--[[
	Clear all attributes on an instance

	@param instance Instance - The Instance to clear all attributes of
]]
function Attributes.Clear(instance: Instance)
	for attribute, _ in pairs(instance:GetAttributes()) do
		instance:SetAttribute(attribute, nil)
	end
end

return Attributes
