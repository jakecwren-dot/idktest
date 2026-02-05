local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DATA_KEY = "IncrementalSimV1"
local dataStore = DataStoreService:GetDataStore(DATA_KEY)

local dataEvent = Instance.new("RemoteEvent")
dataEvent.Name = "DataSync"
dataEvent.Parent = ReplicatedStorage

local function defaultData()
	return {
		Power = 0,
		Essence = 0,
		Cores = 0,
		VoidMatter = 0,
		Rebirths = 0,
		Ascensions = 0,
		Transcendence = 0,
		Inventory = {},
		Unlocks = {},
		BestRarity = "None",
		Settings = {
			Music = true,
			SFX = true,
			DamageNumbers = true,
		},
	}
end

local function loadData(player)
	local success, data = pcall(function()
		return dataStore:GetAsync(player.UserId)
	end)

	if not success or not data then
		data = defaultData()
	end

	dataEvent:FireClient(player, data)
	return data
end

local function saveData(player, data)
	pcall(function()
		dataStore:SetAsync(player.UserId, data)
	end)
end

local cached = {}

local function updateLeaderstats(player, data)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local powerValue = leaderstats:FindFirstChild("Power") or Instance.new("IntValue")
	powerValue.Name = "Power"
	powerValue.Value = data.Power or 0
	powerValue.Parent = leaderstats

	local essenceValue = leaderstats:FindFirstChild("Essence") or Instance.new("IntValue")
	essenceValue.Name = "Essence"
	essenceValue.Value = data.Essence or 0
	essenceValue.Parent = leaderstats

	local bestRarityValue = leaderstats:FindFirstChild("Best Rarity") or Instance.new("StringValue")
	bestRarityValue.Name = "Best Rarity"
	bestRarityValue.Value = data.BestRarity or data.BestItem or "None"
	bestRarityValue.Parent = leaderstats
end

Players.PlayerAdded:Connect(function(player)
	local data = loadData(player)
	cached[player.UserId] = data
	updateLeaderstats(player, data)
end)

Players.PlayerRemoving:Connect(function(player)
	local data = cached[player.UserId] or defaultData()
	saveData(player, data)
	cached[player.UserId] = nil
end)

dataEvent.OnServerEvent:Connect(function(player, payload)
	if typeof(payload) ~= "table" then
		return
	end
	cached[player.UserId] = payload
	updateLeaderstats(player, payload)
end)
