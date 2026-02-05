local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local modulesFolder = ReplicatedStorage:FindFirstChild("Modules")
if not modulesFolder then
	warn("[Bootstrap] ReplicatedStorage.Modules missing; falling back to ReplicatedStorage root.")
	modulesFolder = ReplicatedStorage
end

local uiControllerModule = modulesFolder:WaitForChild("UIController", 10)
if not uiControllerModule then
	warn("[Bootstrap] UIController module not found. Ensure it exists in ReplicatedStorage/Modules.")
	return
end

local UIController = require(uiControllerModule)
local player = Players.LocalPlayer
local dataEvent = ReplicatedStorage:WaitForChild("DataSync", 10)
if not dataEvent then
	warn("[Bootstrap] DataSync RemoteEvent not found. Data will not load.")
	return
end

local initialized = false
dataEvent.OnClientEvent:Connect(function(data)
	if initialized then
		return
	end
	initialized = true
	UIController.init(player, data)
end)
