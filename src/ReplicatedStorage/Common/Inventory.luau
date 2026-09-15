--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Utility = require(ReplicatedStorage.Utility)

local inventoryConfig: Configuration = nil

function currentItems(): { string: any }
	return Utility.Properties.AttributesToProperties(inventoryConfig)
end

function hasItem(name: string): boolean
	return currentItems()[name] ~= nil
end

function addedItem(name: string, value: string | boolean)
	inventoryConfig:SetAttribute(name, value)
end

function removeItem(name: string)
	inventoryConfig:SetAttribute(name, nil)
end

function addedItemByLink(linkModel: Model): boolean
	local key = linkModel:GetAttribute("Key") or nil

	if typeof(key) == "string" and hasItem(key) then
		removeItem(key)
		addedItem(linkModel.Name, key)
		linkModel:Destroy()

		return true
	elseif typeof(key) ~= "string" and (key == nil or key == true) then
		addedItem(linkModel.Name, true)
		linkModel:Destroy()

		return true
	end

	return false
end

if RunService:IsServer() then
	inventoryConfig = Instance.new("Configuration")
	inventoryConfig.Name = "Inventory"
	inventoryConfig.Parent = Players
elseif RunService:IsClient() then
	inventoryConfig = Players:WaitForChild("Inventory")
end

local Inventory = {}

--gives current items
function Inventory.CurrentItems(): { string: any }
	return currentItems()
end

--checks if item exist in inventory
function Inventory.HasItem(name: string): boolean
	return hasItem(name)
end

--added item to inventory, works on server only
function Inventory.AddedItem(name: string, value: string | boolean)
	addedItem(name, value)
end

--removes item to inventory, works on server only
function Inventory.RemoveItem(name: string)
	removeItem(name)
end

--adds item to inventory by checking link Model, works on server only
function Inventory.AddedItemByLink(linkModel: Model)
	return addedItemByLink(linkModel)
end

return Inventory
