--!strict

--[[
	Weight Schedular

	Determines what is currently allowed to run
	Higher weight is higher priority
]]
local WeightScheduler = {}
WeightScheduler.__index = WeightScheduler

type self = {
	_weights: { number },
}

export type WeightScheduler = typeof(setmetatable({} :: self, WeightScheduler))

--[[
	Constructor

	@return self - the new object
]]
function WeightScheduler.new()
	local self = setmetatable({} :: self, WeightScheduler)
	self._weights = {}

	return self
end

--[[
	Add a weight to evaluate what is allowed to run

	@param self WeightSchedular - object
	@param weight number - Priority of this request
]]
function WeightScheduler.Add(self: WeightScheduler, weight: number)
	if table.find(self._weights, weight) then
		return
	end
	table.insert(self._weights, weight)
end

--[[
	Remove a weight to evaluate what is allowed to run

	@param self WeightSchedular - object
	@param weight number - Priority of this request
]]
function WeightScheduler.Remove(self: WeightScheduler, weight: number)
	local index = table.find(self._weights, weight)
	if index then
		table.remove(self._weights, index)
	end
end

--[[
	Check if this weight is currently allowed to run

	@param self WeightSchedular - object
	@param weight number - Priority of this request

	@return boolean - Is the weight equal or higher to what is currently running
]]
function WeightScheduler.IsMax(self: WeightScheduler, weight: number): boolean
	if #self._weights <= 1 then
		return true
	end

	local heaviestWeight = math.max(table.unpack(self._weights))

	return weight >= heaviestWeight
end

--[[
	Cleans up the weight object

	@param self WeightSchedular - object
]]
function WeightScheduler.Cleanup(self: WeightScheduler)
	table.clear(self._weights)
end

return WeightScheduler
