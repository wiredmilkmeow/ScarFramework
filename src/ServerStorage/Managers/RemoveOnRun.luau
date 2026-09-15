--!strict

--[[
	Workspace Folder that will Destroy anything in that folder at Run Time.
]]

local folder = workspace:FindFirstChild("RemoveOnRun")
if folder then
	folder:Destroy()
else
	warn("Could not locate the RemoveOnRun Folder in Workspace!")
end

return {}
