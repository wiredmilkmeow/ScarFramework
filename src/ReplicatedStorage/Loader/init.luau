--!strict

--[[
	For loading almost everything in the game.
]]

local RunService = game:GetService("RunService")

local assetsLoader = require(script.AssetLoader)

--starts modules from selected folder
local function LoadFromFile(file: Instance)
	local _files: { any } = {}
	local filesNotLoaded = {}
	local fileRead = ""
	local count = 0

	local function addModules(currentFile: Instance)
		for _, v in pairs(currentFile:GetChildren()) do
			if v:IsA("Folder") then
				addModules(v)
			elseif v:IsA("ModuleScript") then
				count += 1

				task.spawn(function()
					--if a module takes longer than 5 seconds its not loaded right
					local wasSuccess = false
					task.delay(5, function()
						if not wasSuccess then
							table.insert(filesNotLoaded, v.Name)
						end
					end)

					local success, result = pcall(function()
						return require(v) :: any
					end)

					wasSuccess = success

					if not success then
						fileRead = fileRead .. "\t" .. v.Name .. " ERROR \n"
						warn(v.Name .. " module did not load correctly, Error: ", result)
					else
						fileRead = fileRead .. "\t" .. v.Name .. "\n"
						table.insert(_files, result)
					end
				end)
			end
		end
	end

	addModules(file)

	--after 10 seconds it will display any modules that loaded if any
	task.delay(10, function()
		if #filesNotLoaded > 0 then
			warn("NOT ALL FILES LOADED, UnloadedFiles:", filesNotLoaded)
		end
	end)

	--wait until files are loaded then print
	repeat
		task.wait()
	until #_files == count

	print(
		string.format(
			"\n[[------------loading %s file on ------------]]\n %s --------------------------------------------------------\n\n",
			file.Name,
			fileRead
		)
	)
end

--[[
	Initializes Modules depending on it running in server or on client

	@return () -> () - Will setup modules on server or client depending on where this is called
]]
return function()
	if RunService:IsServer() then
		task.wait() --give server a sec to be ready

		assetsLoader()

		local ServerStorage = game:GetService("ServerStorage")
		local managers = ServerStorage:FindFirstChild("Managers")

		LoadFromFile(managers)
	elseif RunService:IsClient() then
		game.Loaded:Wait() --let instances load in
		task.wait(1)

		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local controllers = ReplicatedStorage:WaitForChild("Controllers")

		LoadFromFile(controllers)
	end
end
