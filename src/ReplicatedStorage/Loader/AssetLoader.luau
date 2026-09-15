--!strict

local FLASHLIGHT_ASSET_ID = 136192578782497
local FAKE_FLASHLIGHT_ASSET_ID = 82091015194276
local FAKE_GOLD_FLASHLIGHT_ASSET_ID = 127903740994664

local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--locations
local LoadedAssets = ReplicatedStorage:FindFirstChild("LoadedAssets")

local function loadTo(assetId: number, parent: Instance?)
	local success, asset = pcall(InsertService.LoadAsset, InsertService, assetId)
	if success and asset then
		local model = asset:GetChildren()[1]
		model.Parent = parent or LoadedAssets
		asset:Destroy()
	else
		print("Model with assetId of " .. assetId .. " failed to load!")
	end
end

--[[
    loads any assets that cannot be converted into script
]]
return function()
	loadTo(FLASHLIGHT_ASSET_ID) -- player flashlight
	loadTo(FAKE_FLASHLIGHT_ASSET_ID) -- fake player flashlight (3rd person)
	loadTo(FAKE_GOLD_FLASHLIGHT_ASSET_ID) -- fake player gamepass flashlight (3rd person)
end
