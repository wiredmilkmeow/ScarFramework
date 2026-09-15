--!strict

export type SoundTable = { Sound: { [string]: any }, Children: { [string]: { [string]: any } } }
export type VarianceTable = {
	PlaybackSpeed: () -> number,
	Volume: () -> number,
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local RedEvents = require(ReplicatedStorage.RedEvents)
local Utility = require(ReplicatedStorage.Utility)

local Random = Random.new()
local UnParentedSounds: Folder = nil

local _soundGroups: { [string]: SoundGroup } = {}
local _sounds: { [string]: SoundTable } = nil

if RunService:IsServer() then
	local ServerStorage = game:GetService("ServerStorage")
	local soundFolder = ServerStorage:FindFirstChild("Sounds")

	UnParentedSounds = Instance.new("Folder")
	UnParentedSounds.Name = "UnParentedSounds"
	UnParentedSounds.Parent = SoundService

	local soundTable = {}

	local function getSoundChildren(sound: Sound): { [string]: { [string]: any } }
		local children = {}

		for _, child in pairs(sound:GetChildren()) do
			children[child.ClassName] = Utility.Properties.InstanceToProperties(child)
		end

		return children
	end

	local soundGroupConfig = Instance.new("Configuration")
	soundGroupConfig.Name = "SoundGroups"

	for _, childFolder in pairs(soundFolder:GetChildren()) do
		local soundGroup = Instance.new("SoundGroup")
		soundGroup.Name = childFolder.Name
		soundGroup.Parent = soundGroupConfig

		_soundGroups[childFolder.Name] = soundGroup

		for _, sound in pairs(childFolder:GetDescendants()) do
			if not sound:IsA("Sound") then
				continue
			end

			local success, errorMessage = pcall(function()
				soundTable[sound.Name] = { --create sound and its children
					Sound = Utility.Properties.InstanceToProperties(sound),
					Children = getSoundChildren(sound),
				}

				soundTable[sound.Name].Sound.Name = sound.Name --add to sound group
				soundTable[sound.Name].Sound.SoundGroup = childFolder.Name --add to sound group
			end)

			if not success then
				warn(errorMessage)
			end
		end
	end

	soundGroupConfig.Parent = SoundService
	_sounds = soundTable

	local soundRequestLimit = RedEvents.Ratelimit(5, 5)
	RedEvents.Network.Client.SoundsRequest:SetCallback(function(_player)
		if not soundRequestLimit(_player) then
			warn("Sound Data was request to many times by, ", _player)
			return {}
		end

		return soundTable
	end)
elseif RunService:IsClient() then
	local function getSoundForClient()
		local success, sounds = RedEvents.Network.Client.SoundsRequest:Call():Await()
		if success then
			_sounds = sounds
		else
			warn("Server did not return sounds to local player, reattempting!")

			task.wait(0.5)

			getSoundForClient()
		end
	end

	getSoundForClient()

	UnParentedSounds = SoundService:WaitForChild("UnParentedSounds")

	local soundGroupInstances = SoundService:WaitForChild("SoundGroups")
	for _, soundGroup in pairs(soundGroupInstances:GetChildren()) do
		_soundGroups[soundGroup.Name] = soundGroup
	end
end

----------------------------------------------------------------------------------------------------------------

--[[
	Custom Sound Player

	Keeps all sound data in a table and loads it when called
	All sounds should be requested from this system on server and client
]]
local Sounds = {}

--[[
	Returns name of sound group if it exists

	@param name string - Name of the SoundGroup

	@return SoundGroup? - The SoundGroup you were looking for
]]
function Sounds.FindSoundGroup(name: string): SoundGroup?
	return _soundGroups[name]
end

--[[
	Returns all sound groups that exist

	@return { [string]: SoundGroup } - A list of all SoundGroups
]]
function Sounds.GetSoundGroups(): { [string]: SoundGroup }
	return _soundGroups
end

--[[
	Converts SoundTable Data into a real sound Instance
	Can also remember child modifiers for manipulating sound

	@param soundData SoundTable - Table storing all the data to make a sound Instance

	@return Sound - The sound Instance you requested to be made from a SoundTable
]]
function Sounds.CreateSound(soundData: SoundTable): Sound
	local newSound = Instance.new("Sound")
	newSound:SetAttribute("IsFrameworkSound", true)

	if not _sounds then
		newSound.Name = "SoundsNotLoadedYet"
		return newSound
	end

	for property, value in pairs(soundData.Sound) do --create new sound
		Utility.Properties.ApplyPropertyValueToInstance(newSound, property, value)
	end

	local realSoundGroup = Sounds.FindSoundGroup(soundData.Sound.SoundGroup)
	newSound.SoundGroup = realSoundGroup and realSoundGroup or nil

	for class, properties in pairs(soundData.Children) do --create new sound
		pcall(function()
			local newClass = Instance.new(class)

			for property, value in pairs(properties) do --create new child class
				Utility.Properties.ApplyPropertyValueToInstance(newClass, property, value)
			end

			newClass.Parent = newSound
		end)
	end

	return newSound
end

--[[
	Searches through all the saved sounds and makes an Instance of it

	@param name string - The name of the sound you want to play
	@param variance VarianceTable? - A table for varying the sound to make it less repetitive
	@param parent Instance? - The instance you want to parent the sound too

	@return Sound? - Returns a Sound if it exists
]]
function Sounds.FindSoundByName(name: string, variance: VarianceTable?, parent: Instance?): Sound?
	local soundData = _sounds[name]

	if not _sounds then
		warn("Sound data is currently nil, cannot pull sound named " .. name)
		return
	end
	if not soundData then
		warn("Could not find sound named " .. name)
		return
	end

	local newSound = Sounds.CreateSound(soundData)
	if newSound then
		newSound.Parent = parent and parent or UnParentedSounds

		if variance then
			newSound.PlaybackSpeed = newSound.PlaybackSpeed * (variance.PlaybackSpeed() or 1)
			newSound.Volume = newSound.Volume * (variance.Volume() or 1)
		end
	else
		warn("Could not create sound named " .. name)
	end

	return newSound
end

--[[
	Will automatically play the sound and clean it up when called

	@param name string - The name of the sound you want to play
	@param variance VarianceTable? - A table for varying the sound to make it less repetitive
	@param parent Instance? - The instance you want to parent the sound too
]]
function Sounds.PlaySoundByName(name: string, variance: VarianceTable?, parent: Instance?)
	local sound = Sounds.FindSoundByName(name, variance, parent)
	if not sound then
		return
	end

	sound.PlayOnRemove = true
	sound:Destroy()
end

--[[
	Creates random variance values for sound playback
	
	@param minSpeed number? - Minimum playback speed multiplier (default: 0.95)
	@param maxSpeed number? - Maximum playback speed multiplier (default: 1.05)
	@param minVolume number? - Minimum volume multiplier (default: 0.95)
	@param maxVolume number? - Maximum volume multiplier (default: 1.05)

	@return VarianceTable - Random options decided from the givin params
]]
function Sounds.Variance(minSpeed: number?, maxSpeed: number?, minVolume: number?, maxVolume: number?): VarianceTable
	return {
		PlaybackSpeed = function()
			return Random:NextNumber(minSpeed or 0.95, maxSpeed or 1.05)
		end,
		Volume = function()
			return Random:NextNumber(minVolume or 0.95, maxVolume or 1.05)
		end,
	}
end

return Sounds
