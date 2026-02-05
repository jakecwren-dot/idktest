local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Animation = require(script.Parent.Animation)
local Rarity = require(script.Parent.Rarity)
local RollLogic = require(script.Parent.RollLogic)
local Items = require(script.Parent.Items)

local UIController = {}

local musicEnabled = true
local sfxEnabled = true

local PAGE_NAMES = {
	"Main",
	"Rolls",
	"Inventory",
	"Auras",
	"Upgrades",
	"Rebirth",
	"Ascension",
	"Automation",
	"Achievements",
	"Stats",
	"Shop",
	"Donations",
	"Settings",
}

local function createRounded(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = instance
end

local function createStroke(instance, color, transparency, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.Parent = instance
	return stroke
end

local function createLabel(parent, text, size, position)
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(245, 245, 255)
	label.Parent = parent
	return label
end

local function createButton(parent, text, size)
	local button = Instance.new("TextButton")
	button.Size = size
	button:SetAttribute("BaseSize", size)
	button.BackgroundColor3 = Color3.fromRGB(30, 34, 56)
	button.Text = text
	button.Font = Enum.Font.GothamSemibold
	button.TextColor3 = Color3.fromRGB(240, 240, 255)
	button.TextScaled = true
	button.AutoButtonColor = false
	createRounded(button, 14)
	createStroke(button, Color3.fromRGB(80, 100, 200), 0.3, 1)
	button.Parent = parent

	button.MouseEnter:Connect(function()
		Animation.buttonHover(button)
	end)
	button.MouseButton1Down:Connect(function()
		Animation.buttonPress(button)
	end)
	button.MouseButton1Up:Connect(function()
		Animation.buttonHover(button)
	end)
	button.MouseButton1Click:Connect(function()
		local sfx = SoundService:FindFirstChild("IncrementalSFX")
		if sfx and sfxEnabled and sfx.SoundId ~= "" then
			sfx:Play()
		end
	end)
	button.MouseLeave:Connect(function()
		local baseSize = button:GetAttribute("BaseSize")
		if baseSize then
			Animation.tween(
				button,
				TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = baseSize }
			)
		end
	end)

	return button
end

local function syncButtonBaseSize(button)
	button:SetAttribute("BaseSize", button.Size)
end

local function createLockedOverlay(parent, reason)
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	overlay.BackgroundTransparency = 0.35
	overlay.Parent = parent
	createRounded(overlay, 16)

	local blur = Instance.new("UIGradient")
	blur.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20)),
	})
	blur.Rotation = 90
	blur.Parent = overlay

	local icon = createLabel(overlay, "\u{1F512}", UDim2.fromScale(0.18, 0.18), UDim2.fromScale(0.41, 0.3))
	icon.TextScaled = true
	local tooltip = createLabel(overlay, reason, UDim2.fromScale(0.7, 0.15), UDim2.fromScale(0.15, 0.6))
	tooltip.TextColor3 = Color3.fromRGB(220, 220, 240)

	return overlay
end

local function createPageBase(container, name)
	local page = Instance.new("Frame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = container

	local header = createLabel(page, name, UDim2.fromScale(0.4, 0.08), UDim2.fromScale(0.3, 0.02))
	local divider = Instance.new("Frame")
	divider.Size = UDim2.fromScale(0.9, 0.003)
	divider.Position = UDim2.fromScale(0.05, 0.11)
	divider.BackgroundColor3 = Color3.fromRGB(80, 90, 140)
	divider.Parent = page

	return page, header
end

local function createSection(parent, title, position, size)
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = Color3.fromRGB(18, 20, 36)
	frame.Parent = parent
	createRounded(frame, 16)
	createStroke(frame, Color3.fromRGB(90, 110, 190), 0.35, 1)

	local label = createLabel(frame, title, UDim2.fromScale(0.8, 0.18), UDim2.fromScale(0.1, 0.05))
	label.TextXAlignment = Enum.TextXAlignment.Left

	return frame
end

local function createScrollingList(parent, position, size, canvasY)
	local scroller = Instance.new("ScrollingFrame")
	scroller.Size = size
	scroller.Position = position
	scroller.CanvasSize = UDim2.fromScale(0, 0)
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.ScrollBarThickness = 6
	scroller.BackgroundTransparency = 1
	scroller.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = scroller

	return scroller
end

local function createStatRow(parent, labelText, valueText)
	local row = Instance.new("Frame")
	row.Size = UDim2.fromScale(1, 0.2)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local label = createLabel(row, labelText, UDim2.fromScale(0.55, 0.8), UDim2.fromScale(0.05, 0.1))
	label.TextXAlignment = Enum.TextXAlignment.Left
	local value = createLabel(row, valueText, UDim2.fromScale(0.35, 0.8), UDim2.fromScale(0.6, 0.1))
	value.TextXAlignment = Enum.TextXAlignment.Right
	value.TextColor3 = Color3.fromRGB(200, 220, 255)

	return value
end

local function createMenu(parent)
	local menu = Instance.new("Frame")
	menu.Name = "MainMenu"
	menu.Size = UDim2.fromScale(1, 1)
	menu.BackgroundColor3 = Color3.fromRGB(10, 12, 24)
	menu.Parent = parent

	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(12, 16, 32)
	background.Parent = menu

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 70)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 40, 90)),
	})
	gradient.Rotation = 45
	gradient.Parent = background

	for i = 1, 4 do
		local orb = Instance.new("Frame")
		orb.Size = UDim2.fromScale(0.2, 0.2)
		orb.Position = UDim2.fromScale(0.1 * i, 0.12 * i)
		orb.BackgroundColor3 = Color3.fromRGB(60, 90, 200)
		orb.BackgroundTransparency = 0.4
		orb.Parent = background
		createRounded(orb, 120)
		createStroke(orb, Color3.fromRGB(120, 150, 255), 0.6, 2)

		local drift = TweenService:Create(
			orb,
			TweenInfo.new(6 + i, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Position = orb.Position + UDim2.fromScale(0.05, 0.03) }
		)
		drift:Play()
	end

	local title = createLabel(menu, "OMNIVERSE INCREMENTAL", UDim2.fromScale(0.8, 0.12), UDim2.fromScale(0.1, 0.08))
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(240, 240, 255)

	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromScale(0.46, 0.5)
	panel.Position = UDim2.fromScale(0.27, 0.32)
	panel.BackgroundColor3 = Color3.fromRGB(16, 18, 34)
	panel.Parent = menu
	createRounded(panel, 18)
	createStroke(panel, Color3.fromRGB(90, 110, 190), 0.35, 1)

	local buttonHolder = Instance.new("Frame")
	buttonHolder.Size = UDim2.fromScale(0.86, 0.8)
	buttonHolder.Position = UDim2.fromScale(0.07, 0.1)
	buttonHolder.BackgroundTransparency = 1
	buttonHolder.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 16)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = buttonHolder

	local playButton = createButton(buttonHolder, "Play", UDim2.fromScale(1, 0.16))
	local inventoryButton = createButton(buttonHolder, "Inventory", UDim2.fromScale(1, 0.16))
	local settingsButton = createButton(buttonHolder, "Settings", UDim2.fromScale(1, 0.16))
	local statsButton = createButton(buttonHolder, "Stats", UDim2.fromScale(1, 0.16))

	menu.BackgroundTransparency = 1
	Animation.fade(menu, 0, 0.5)
	Animation.slide(panel, UDim2.fromScale(0.27, 0.3), 0.6)

	return menu, {
		Play = playButton,
		Inventory = inventoryButton,
		Settings = settingsButton,
		Stats = statsButton,
	}
end

local function createTopNav(parent)
	local nav = Instance.new("Frame")
	nav.Size = UDim2.fromScale(0.92, 0.08)
	nav.Position = UDim2.fromScale(0.04, 0.02)
	nav.BackgroundColor3 = Color3.fromRGB(16, 18, 32)
	nav.Parent = parent
	createRounded(nav, 14)
	createStroke(nav, Color3.fromRGB(80, 100, 160), 0.4, 1)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.fromScale(0.98, 0.9)
	scroll.Position = UDim2.fromScale(0.01, 0.05)
	scroll.CanvasSize = UDim2.fromScale(2.6, 0)
	scroll.ScrollBarThickness = 4
	scroll.BackgroundTransparency = 1
	scroll.Parent = nav

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 10)
	layout.Parent = scroll

	return nav, scroll
end

local function createCurrencyBar(parent)
	local bar = Instance.new("Frame")
	bar.Size = UDim2.fromScale(0.36, 0.06)
	bar.Position = UDim2.fromScale(0.62, 0.1)
	bar.BackgroundColor3 = Color3.fromRGB(16, 18, 32)
	bar.Parent = parent
	createRounded(bar, 12)
	createStroke(bar, Color3.fromRGB(80, 100, 160), 0.4, 1)

	local powerLabel = createLabel(bar, "Power: 0", UDim2.fromScale(0.48, 0.8), UDim2.fromScale(0.04, 0.1))
	powerLabel.TextXAlignment = Enum.TextXAlignment.Left
	local essenceLabel = createLabel(bar, "Essence: 0", UDim2.fromScale(0.48, 0.8), UDim2.fromScale(0.52, 0.1))
	essenceLabel.TextXAlignment = Enum.TextXAlignment.Left
	essenceLabel.TextColor3 = Color3.fromRGB(160, 210, 255)

	return powerLabel, essenceLabel
end

function UIController.init(player, playerData)
	local data = playerData or {}
	data.Inventory = data.Inventory or {}
	data.Settings = data.Settings or {}
	data.BestRarity = data.BestRarity or data.BestItem or "None"
	data.Power = data.Power or 0
	data.Essence = data.Essence or 0
	data.Luck = data.Luck or 1
	local dataEvent = ReplicatedStorage:FindFirstChild("DataSync")
	local syncPending = false
	local function queueSync()
		if not dataEvent or syncPending then
			return
		end
		syncPending = true
		task.delay(0.5, function()
			syncPending = false
			if dataEvent then
				dataEvent:FireServer(data)
			end
		end)
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "IncrementalUI"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = gui

	local function updateScale()
		local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		local base = math.min(viewport.X, viewport.Y)
		scale.Scale = math.clamp(base / 900, 0.75, 1.05)
	end

	updateScale()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	end

	local menu, menuButtons = createMenu(gui)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainHUD"
	mainFrame.Size = UDim2.fromScale(1, 1)
	mainFrame.BackgroundTransparency = 1
	mainFrame.Visible = false
	mainFrame.Parent = gui

	local music = SoundService:FindFirstChild("IncrementalMusic") or Instance.new("Sound")
	music.Name = "IncrementalMusic"
	music.SoundId = "rbxassetid://1846911135"
	music.Looped = true
	music.Volume = 0.4
	music.Parent = SoundService
	music:Play()

	local sfx = SoundService:FindFirstChild("IncrementalSFX") or Instance.new("Sound")
	sfx.Name = "IncrementalSFX"
	sfx.SoundId = "rbxassetid://12221967"
	sfx.Looped = false
	sfx.Volume = 0.6
	sfx.Parent = SoundService

	local nav, navScroll = createTopNav(mainFrame)
	local currencyPowerLabel, currencyEssenceLabel = createCurrencyBar(mainFrame)
	local pagesContainer = Instance.new("Frame")
	pagesContainer.Size = UDim2.fromScale(1, 0.9)
	pagesContainer.Position = UDim2.fromScale(0, 0.1)
	pagesContainer.BackgroundTransparency = 1
	pagesContainer.Parent = mainFrame

	local pages = {}
	local navButtons = {}

	for _, name in ipairs(PAGE_NAMES) do
		local page = createPageBase(pagesContainer, name)
		pages[name] = page

		local navButton = createButton(navScroll, name, UDim2.fromScale(0, 1))
		navButton.Size = UDim2.fromOffset(140, 40)
		syncButtonBaseSize(navButton)
		navButtons[name] = navButton
	end

	local function showPage(name)
		for pageName, page in pairs(pages) do
			page.Visible = pageName == name
			if page.Visible then
				page.Position = UDim2.fromScale(0.03, 0)
				Animation.slide(page, UDim2.fromScale(0, 0), 0.25)
			end
		end
	end

	showPage("Main")

	local powerLabel
	local essenceLabel
	local statusLabel
	local collectButton
	local powerPopup
	local rollButton
	local essenceRollButton
	local cosmicRollButton
	local blessedRollButton
	local mythicRollButton
	local omniversalRollButton
	local revealFrame
	local revealText
	local glow
	local rareFlash
	local rollLog
	local oddsLabels = {}
	local itemOddsLabels = {}
	local inventoryScroller
	local inventoryEntries = {}
	local inventoryApplyFilter
	local statsValues = {}
	local settingsToggles = {}
	local lockedOverlays = {}
	local power = data.Power
	local essence = data.Essence
	local powerPerClick = 1
	local powerPerSecond = 0
	local rollCount = 0
	local luckMultiplier = data.Luck
	local ascensionUpgrades = {}
	musicEnabled = true
	sfxEnabled = true
	local bestRarity = data.BestRarity
	local bestTierIndex = 0
	local tierIndexByName = {}
	for index, tier in ipairs(Rarity.Tiers) do
		tierIndexByName[tier.Name] = index
	end

	local lockedPages = {
		Auras = { UnlockAt = 500, Reason = "Unlock at 500 Power" },
		Automation = { UnlockAt = 5000, Reason = "Unlock at 2 Rebirths" },
		Ascension = { UnlockAt = 6500, Reason = "Unlock at 1 Ascension" },
	}

	local mainPage = pages.Main
	if mainPage then
		statusLabel = createLabel(mainPage, "", UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.25, 0.12))
		statusLabel.TextColor3 = Color3.fromRGB(255, 190, 120)
		collectButton = createButton(mainPage, "Collect Power", UDim2.fromScale(0.24, 0.08))
		collectButton.Position = UDim2.fromScale(0.62, 0.48)

		local summary = createSection(mainPage, "Power Boosts", UDim2.fromScale(0.05, 0.16), UDim2.fromScale(0.4, 0.3))
		local boostList = createScrollingList(summary, UDim2.fromScale(0.06, 0.28), UDim2.fromScale(0.88, 0.66), 1.2)
		local boostData = {
			{ Name = "Focus Drill", Cost = 25, Bonus = 1 },
			{ Name = "Energy Coil", Cost = 80, Bonus = 3 },
			{ Name = "Quantum Tap", Cost = 200, Bonus = 6 },
			{ Name = "Nova Harvester", Cost = 420, Bonus = 12 },
			{ Name = "Eclipse Engine", Cost = 900, Bonus = 24 },
		}
		for _, boost in ipairs(boostData) do
			local button = createButton(
				boostList,
				string.format("%s (+%d/click) - %d Power", boost.Name, boost.Bonus, boost.Cost),
				UDim2.fromScale(1, 0.2)
			)
			button.MouseButton1Click:Connect(function()
				if power >= boost.Cost then
					power -= boost.Cost
					powerPerClick += boost.Bonus
					updatePower(0)
					if statusLabel then
						statusLabel.Text = string.format("Boosted! Power/Click: %d", powerPerClick)
					end
					Animation.flash(button)
				elseif statusLabel then
					statusLabel.Text = "Not enough Power for that boost."
				end
				end)
		end

		local generators = createSection(mainPage, "Power Generators", UDim2.fromScale(0.05, 0.48), UDim2.fromScale(0.4, 0.3))
		local genList = createScrollingList(generators, UDim2.fromScale(0.06, 0.28), UDim2.fromScale(0.88, 0.66), 1.2)
		local generatorData = {
			{ Name = "Spark Reactor", Cost = 60, Gain = 1 },
			{ Name = "Pulse Array", Cost = 180, Gain = 3 },
			{ Name = "Prism Core", Cost = 420, Gain = 6 },
			{ Name = "Nova Engine", Cost = 900, Gain = 12 },
			{ Name = "Eclipse Drive", Cost = 1600, Gain = 20 },
		}
		for _, generator in ipairs(generatorData) do
			local button = createButton(
				genList,
				string.format("%s (+%d/sec) - %d Power", generator.Name, generator.Gain, generator.Cost),
				UDim2.fromScale(1, 0.2)
			)
			button.MouseButton1Click:Connect(function()
				if power >= generator.Cost then
					power -= generator.Cost
					powerPerSecond += generator.Gain
					updatePower(0)
					setStatus(string.format("Generator online! Power/sec: %d", powerPerSecond))
					Animation.flash(button)
				else
					setStatus("Not enough Power for that generator.")
				end
			end)
		end

		local progress = createSection(mainPage, "Progression", UDim2.fromScale(0.52, 0.16), UDim2.fromScale(0.43, 0.3))
		local bar = Instance.new("Frame")
		bar.Size = UDim2.fromScale(0.9, 0.2)
		bar.Position = UDim2.fromScale(0.05, 0.45)
		bar.BackgroundColor3 = Color3.fromRGB(30, 36, 60)
		bar.Parent = progress
		createRounded(bar, 12)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(0.2, 1)
		fill.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
		fill.Parent = bar
		createRounded(fill, 12)

		powerPopup = createLabel(mainPage, "+1", UDim2.fromScale(0.08, 0.05), UDim2.fromScale(0.72, 0.12))
		powerPopup.Visible = false
	end

	local rollPage = pages.Rolls
	if rollPage then
		local rollPanel = createSection(rollPage, "Summon Chamber", UDim2.fromScale(0.05, 0.16), UDim2.fromScale(0.6, 0.6))
		local rollList = createScrollingList(rollPanel, UDim2.fromScale(0.05, 0.22), UDim2.fromScale(0.9, 0.7), 0)

		rollButton = createButton(rollList, "Standard Roll (Free) | Luck x1.00", UDim2.fromScale(1, 0.16))
		essenceRollButton = createButton(rollList, "Essence Roll (25 Essence) | Luck x1.35", UDim2.fromScale(1, 0.16))
		cosmicRollButton = createButton(rollList, "Cosmic Roll (75 Essence) | Luck x1.75", UDim2.fromScale(1, 0.16))
		blessedRollButton = createButton(rollList, "Blessed Roll (150 Essence) | Luck x2.2", UDim2.fromScale(1, 0.16))
		mythicRollButton = createButton(rollList, "Mythic Roll (300 Essence) | Luck x2.8", UDim2.fromScale(1, 0.16))
		omniversalRollButton = createButton(rollList, "Omni Roll (600 Essence) | Luck x3.6", UDim2.fromScale(1, 0.16))

		local oddsPanel = createSection(rollPage, "Rarity Odds", UDim2.fromScale(0.68, 0.16), UDim2.fromScale(0.27, 0.7))
		local oddsList = createScrollingList(oddsPanel, UDim2.fromScale(0.08, 0.25), UDim2.fromScale(0.84, 0.68), 1.6)
		for _, tier in ipairs(Rarity.Tiers) do
			local odds = createLabel(oddsList, "", UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0))
			odds.TextColor3 = tier.Color
			oddsLabels[tier.Name] = odds

			local items = Items.ByRarity[tier.Name] or {}
			for _, itemName in ipairs(items) do
				local itemLabel = createLabel(oddsList, "", UDim2.fromScale(1, 0.16), UDim2.fromScale(0, 0))
				itemLabel.TextColor3 = Color3.fromRGB(200, 210, 230)
				itemOddsLabels[itemName] = { Label = itemLabel, Tier = tier }
			end
		end

		local logPanel = createSection(rollPage, "Recent Rolls", UDim2.fromScale(0.05, 0.78), UDim2.fromScale(0.6, 0.2))
		rollLog = createScrollingList(logPanel, UDim2.fromScale(0.06, 0.25), UDim2.fromScale(0.88, 0.7), 1.4)

		revealFrame = Instance.new("Frame")
		revealFrame.Size = UDim2.fromScale(0.5, 0.22)
		revealFrame.Position = UDim2.fromScale(0.25, 0.36)
		revealFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		revealFrame.BackgroundTransparency = 0.2
		revealFrame.Visible = false
		revealFrame.ZIndex = 20
		revealFrame.Parent = rollPage
		createRounded(revealFrame, 20)
		createStroke(revealFrame, Color3.fromRGB(120, 140, 220), 0.2, 2)

		revealText = createLabel(revealFrame, "", UDim2.fromScale(0.8, 0.6), UDim2.fromScale(0.1, 0.2))
		revealText.ZIndex = 21

		glow = Instance.new("Frame")
		glow.Size = UDim2.fromScale(1, 1)
		glow.Position = UDim2.fromScale(0, 0)
		glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		glow.BackgroundTransparency = 1
		glow.Visible = false
		glow.ZIndex = 19
		glow.Parent = revealFrame
		createRounded(glow, 20)

		rareFlash = Instance.new("Frame")
		rareFlash.Size = UDim2.fromScale(1, 1)
		rareFlash.Position = UDim2.fromScale(0, 0)
		rareFlash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		rareFlash.BackgroundTransparency = 1
		rareFlash.ZIndex = 18
		rareFlash.Parent = rollPage
	end

	local inventoryPage = pages.Inventory
	if inventoryPage then
		local filterBar = Instance.new("ScrollingFrame")
		filterBar.Size = UDim2.fromScale(0.9, 0.08)
		filterBar.Position = UDim2.fromScale(0.05, 0.12)
		filterBar.BackgroundColor3 = Color3.fromRGB(18, 20, 36)
		filterBar.ScrollBarThickness = 6
		filterBar.ScrollBarImageColor3 = Color3.fromRGB(120, 140, 220)
		filterBar.AutomaticCanvasSize = Enum.AutomaticSize.X
		filterBar.CanvasSize = UDim2.fromScale(0, 0)
		filterBar.Parent = inventoryPage
		createRounded(filterBar, 12)
		createStroke(filterBar, Color3.fromRGB(80, 90, 140), 0.4, 1)

		local filterLayout = Instance.new("UIListLayout")
		filterLayout.FillDirection = Enum.FillDirection.Horizontal
		filterLayout.Padding = UDim.new(0, 8)
		filterLayout.Parent = filterBar

		local activeFilter = "All"
		local function applyFilter()
			for _, entry in pairs(inventoryEntries) do
				if activeFilter == "All" or entry.Tier.Name == activeFilter then
					entry.Frame.Visible = true
				else
					entry.Frame.Visible = false
				end
			end
		end
		inventoryApplyFilter = applyFilter

		local allButton = createButton(filterBar, "All", UDim2.fromScale(0, 0.8))
		allButton.Size = UDim2.fromOffset(80, 30)
		syncButtonBaseSize(allButton)
		allButton.MouseButton1Click:Connect(function()
			activeFilter = "All"
			applyFilter()
		end)

		for _, tier in ipairs(Rarity.Tiers) do
			local filter = createButton(filterBar, tier.Name, UDim2.fromScale(0, 0.8))
			filter.Size = UDim2.fromOffset(100, 30)
			syncButtonBaseSize(filter)
			UIController.applyRarityTheme(filter, tier.Name)
			filter.MouseButton1Click:Connect(function()
				activeFilter = tier.Name
				applyFilter()
			end)
		end

		local inventoryPanel = createSection(inventoryPage, "Collected Auras", UDim2.fromScale(0.05, 0.22), UDim2.fromScale(0.9, 0.7))
		inventoryScroller = createScrollingList(inventoryPanel, UDim2.fromScale(0.04, 0.18), UDim2.fromScale(0.92, 0.75), 2)
	end

	local upgradesPage = pages.Upgrades
	if upgradesPage then
		local corePanel = createSection(upgradesPage, "Permanent Upgrades", UDim2.fromScale(0.05, 0.16), UDim2.fromScale(0.55, 0.7))
		local upgradeList = createScrollingList(corePanel, UDim2.fromScale(0.05, 0.2), UDim2.fromScale(0.9, 0.75), 1.8)
		local upgradeData = {
			{ Name = "Precision Matrix", Cost = 40, Luck = 0.05 },
			{ Name = "Temporal Coil", Cost = 90, Luck = 0.08 },
			{ Name = "Ether Circuit", Cost = 160, Luck = 0.12 },
			{ Name = "Nova Optics", Cost = 260, Luck = 0.16 },
			{ Name = "Stellar Engine", Cost = 380, Luck = 0.22 },
			{ Name = "Singularity Core", Cost = 520, Luck = 0.3 },
		}
		for _, upgrade in ipairs(upgradeData) do
			local upgradeButton = createButton(
				upgradeList,
				string.format("%s (+Luck %.2f) - %d Essence", upgrade.Name, upgrade.Luck, upgrade.Cost),
				UDim2.fromScale(1, 0.18)
			)
			upgradeButton.MouseButton1Click:Connect(function()
				if essence < upgrade.Cost then
					setStatus("Not enough Essence for that upgrade.")
					return
				end
				updateEssence(-upgrade.Cost)
				updateLuck(upgrade.Luck)
				setStatus(string.format("Luck increased to x%.2f", luckMultiplier))
				Animation.flash(upgradeButton)
			end)
		end

		local autoPanel = createSection(upgradesPage, "Automation", UDim2.fromScale(0.64, 0.16), UDim2.fromScale(0.31, 0.7))
		local autoList = createScrollingList(autoPanel, UDim2.fromScale(0.08, 0.2), UDim2.fromScale(0.84, 0.75), 1.2)
		local autoData = {
			{ Name = "Auto Collect", Cost = 120, Gain = 1 },
			{ Name = "Auto Roll", Cost = 240, Gain = 2 },
			{ Name = "Auto Rebirth", Cost = 360, Gain = 3 },
			{ Name = "Auto Sell", Cost = 480, Gain = 4 },
		}
		for _, auto in ipairs(autoData) do
			local autoButton = createButton(autoList, string.format("%s - %d Essence", auto.Name, auto.Cost), UDim2.fromScale(1, 0.2))
			autoButton.MouseButton1Click:Connect(function()
				if essence < auto.Cost then
					setStatus("Not enough Essence for automation.")
					return
				end
				updateEssence(-auto.Cost)
				setStatus(string.format("%s unlocked.", auto.Name))
				Animation.flash(autoPanel)
			end)
		end
	end

	local rebirthPage = pages.Rebirth
	if rebirthPage then
		local rebirthPanel = createSection(rebirthPage, "Rebirth Ritual", UDim2.fromScale(0.08, 0.2), UDim2.fromScale(0.84, 0.6))
		local rebirthInfo = createLabel(rebirthPanel, "Trade Power for permanent Essence boosts.", UDim2.fromScale(0.9, 0.2), UDim2.fromScale(0.05, 0.3))
		rebirthInfo.TextScaled = true
		local rebirthButton = createButton(rebirthPanel, "Rebirth Now", UDim2.fromScale(0.4, 0.2))
		rebirthButton.Position = UDim2.fromScale(0.3, 0.62)
		rebirthButton.MouseButton1Click:Connect(function()
			if power < 1000 then
				setStatus("Need 1000 Power to Rebirth.")
				return
			end
			power = 0
			powerPerClick = 1
			updatePower(0)
			updateEssence(150)
			setStatus("Rebirth complete! +150 Essence.")
			Animation.flash(rebirthPanel)
		end)
	end

	local statsPage = pages.Stats
	if statsPage then
		local statsPanel = createSection(statsPage, "Lifetime Stats", UDim2.fromScale(0.12, 0.2), UDim2.fromScale(0.76, 0.6))
		local list = createScrollingList(statsPanel, UDim2.fromScale(0.08, 0.25), UDim2.fromScale(0.84, 0.65), 1.4)
		statsValues.Power = createStatRow(list, "Total Power", "0")
		statsValues.Essence = createStatRow(list, "Total Essence", "0")
		statsValues.Cores = createStatRow(list, "Total Cores", "0")
		statsValues.RollCount = createStatRow(list, "Total Rolls", "0")
	end

	local shopPage = pages.Shop
	if shopPage then
		local shopPanel = createSection(shopPage, "Boost Shop", UDim2.fromScale(0.06, 0.18), UDim2.fromScale(0.88, 0.7))
		local shopList = createScrollingList(shopPanel, UDim2.fromScale(0.05, 0.2), UDim2.fromScale(0.9, 0.75), 1.8)
		local shopData = {
			{ Name = "Essence Cache", Cost = 200, Reward = 40 },
			{ Name = "Essence Bundle", Cost = 600, Reward = 140 },
			{ Name = "Lucky Ticket", Cost = 900, Reward = 0.2 },
			{ Name = "Core Infuser", Cost = 1400, Reward = 0.4 },
			{ Name = "Celestial Coupon", Cost = 2000, Reward = 0.6 },
			{ Name = "Cosmic Voucher", Cost = 2800, Reward = 0.8 },
		}
		for _, item in ipairs(shopData) do
			local itemButton = createButton(shopList, string.format("%s - %d Power", item.Name, item.Cost), UDim2.fromScale(1, 0.18))
			itemButton.MouseButton1Click:Connect(function()
				if power < item.Cost then
					setStatus("Not enough Power for that shop item.")
					return
				end
				power -= item.Cost
				if item.Reward > 1 then
					updatePower(0)
					updateEssence(item.Reward)
					setStatus(string.format("Purchased %s (+%d Essence).", item.Name, item.Reward))
				else
					updateLuck(item.Reward)
					updatePower(0)
					setStatus(string.format("Purchased %s (Luck x%.2f).", item.Name, luckMultiplier))
				end
				Animation.flash(itemButton)
			end)
		end
	end

	local donationsPage = pages.Donations
	if donationsPage then
		local leaderboardPanel = createSection(donationsPage, "Top Donators", UDim2.fromScale(0.06, 0.18), UDim2.fromScale(0.4, 0.7))
		local leaderboardList = createScrollingList(leaderboardPanel, UDim2.fromScale(0.08, 0.22), UDim2.fromScale(0.84, 0.7), 1)
		local placeholders = {
			"#1 - CelestialHero",
			"#2 - VoidWalker",
			"#3 - NovaSpark",
			"#4 - AuraSage",
			"#5 - RiftRunner",
		}
		for _, entry in ipairs(placeholders) do
			local label = createLabel(leaderboardList, entry, UDim2.fromScale(1, 0.16), UDim2.fromScale(0, 0))
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextColor3 = Color3.fromRGB(200, 220, 255)
		end

		local donatePanel = createSection(donationsPage, "Support the Game", UDim2.fromScale(0.52, 0.18), UDim2.fromScale(0.42, 0.7))
		local donateList = createScrollingList(donatePanel, UDim2.fromScale(0.08, 0.22), UDim2.fromScale(0.84, 0.7), 1)
		local donateOptions = {
			{ Label = "Donate 5 Robux", Id = 3529587286 },
			{ Label = "Donate 25 Robux", Id = 3529587755 },
			{ Label = "Donate 50 Robux", Id = 3529587285 },
			{ Label = "Donate 250 Robux", Id = 3529587284 },
			{ Label = "Donate 2,500 Robux", Id = 3529587283 },
			{ Label = "Donate 25,000 Robux", Id = 3529587280 },
		}
		for _, option in ipairs(donateOptions) do
			local donateButton = createButton(donateList, option.Label, UDim2.fromScale(1, 0.18))
			donateButton.MouseButton1Click:Connect(function()
				local success, err = pcall(function()
					MarketplaceService:PromptProductPurchase(player, option.Id)
				end)
				if not success then
					setStatus("Donation prompt failed: " .. tostring(err))
				else
					setStatus("Thanks for supporting the game!")
				end
			end)
		end
	end

	local settingsPage = pages.Settings
	if settingsPage then
		local settingsPanel = createSection(settingsPage, "Settings", UDim2.fromScale(0.2, 0.22), UDim2.fromScale(0.6, 0.6))
		local list = createScrollingList(settingsPanel, UDim2.fromScale(0.08, 0.25), UDim2.fromScale(0.84, 0.65), 1)
		local settingsKeyMap = {
			Music = "Music",
			SFX = "SFX",
			["Damage Numbers"] = "DamageNumbers",
			["Low Power Mode"] = "LowPowerMode",
		}
		for _, setting in ipairs({ "Music", "SFX", "Damage Numbers", "Low Power Mode" }) do
			local toggle = createButton(list, setting .. ": ON", UDim2.fromScale(1, 0.22))
			settingsToggles[setting] = { Button = toggle, Enabled = true }
			toggle.MouseButton1Click:Connect(function()
				local entry = settingsToggles[setting]
				entry.Enabled = not entry.Enabled
				toggle.Text = string.format("%s: %s", setting, entry.Enabled and "ON" or "OFF")
				local dataKey = settingsKeyMap[setting]
				if dataKey then
					data.Settings[dataKey] = entry.Enabled
					queueSync()
				end
				if setting == "Music" then
					musicEnabled = entry.Enabled
					if musicEnabled then
						music:Play()
					else
						music:Stop()
					end
				elseif setting == "SFX" then
					sfxEnabled = entry.Enabled
				end
				Animation.flash(toggle)
			end)
		end
	end

	local aurasPage = pages.Auras
	if aurasPage then
		local craftPanel = createSection(aurasPage, "Aura Crafting", UDim2.fromScale(0.08, 0.2), UDim2.fromScale(0.4, 0.32))
		local craftList = createScrollingList(craftPanel, UDim2.fromScale(0.08, 0.25), UDim2.fromScale(0.84, 0.65), 1)
		local craftOptions = {
			{ Tier = "Common", Cost = 20 },
			{ Tier = "Rare", Cost = 80 },
			{ Tier = "Epic", Cost = 180 },
		}
		for _, option in ipairs(craftOptions) do
			local button = createButton(craftList, string.format("Craft %s Aura (%d Essence)", option.Tier, option.Cost), UDim2.fromScale(1, 0.22))
			button.MouseButton1Click:Connect(function()
				if essence < option.Cost then
					setStatus("Not enough Essence to craft.")
					return
				end
				updateEssence(-option.Cost)
				local tier = Rarity.getByName(option.Tier)
				if tier then
					local itemName = Items.getItem(tier.Name)
					addInventoryItem(tier, itemName)
					setStatus(string.format("Crafted %s Aura.", itemName))
				end
			end)
		end

		local dismantlePanel = createSection(aurasPage, "Dismantle Auras", UDim2.fromScale(0.52, 0.2), UDim2.fromScale(0.4, 0.32))
		local dismantleList = createScrollingList(dismantlePanel, UDim2.fromScale(0.08, 0.25), UDim2.fromScale(0.84, 0.65), 1)
		local dismantleOne = createButton(dismantleList, "Dismantle First Aura", UDim2.fromScale(1, 0.22))
		dismantleOne.MouseButton1Click:Connect(function()
			for name, entry in pairs(inventoryEntries) do
				if entry.Count > 0 then
					entry.Count -= 1
					data.Inventory[name] = math.max(0, (data.Inventory[name] or 1) - 1)
					local reward = math.floor(entry.Tier.Value * 1.2)
					updateEssence(reward)
					setStatus(string.format("Dismantled %s (+%d Essence).", name, reward))
					if entry.Count <= 0 then
						entry.Frame:Destroy()
						inventoryEntries[name] = nil
						if data.Inventory[name] == 0 then
							data.Inventory[name] = nil
						end
					else
						entry.CountLabel.Text = string.format("x%d", entry.Count)
					end
					if inventoryApplyFilter then
						inventoryApplyFilter()
					end
					queueSync()
					return
				end
			end
			setStatus("No auras available to dismantle.")
		end)

		local upgradePanel = createSection(aurasPage, "Aura Infusion", UDim2.fromScale(0.08, 0.56), UDim2.fromScale(0.84, 0.32))
		local upgradeList = createScrollingList(upgradePanel, UDim2.fromScale(0.05, 0.25), UDim2.fromScale(0.9, 0.65), 1)
		local infuseLuck = createButton(upgradeList, "Infuse Element (+0.10 Luck) - 120 Essence", UDim2.fromScale(1, 0.22))
		infuseLuck.MouseButton1Click:Connect(function()
			if essence < 120 then
				setStatus("Not enough Essence for infusion.")
				return
			end
			updateEssence(-120)
			updateLuck(0.1)
			setStatus(string.format("Element infused! Luck x%.2f", luckMultiplier))
		end)
		local infusePower = createButton(upgradeList, "Infuse Power (+2 Power/Click) - 150 Essence", UDim2.fromScale(1, 0.22))
		infusePower.MouseButton1Click:Connect(function()
			if essence < 150 then
				setStatus("Not enough Essence for infusion.")
				return
			end
			updateEssence(-150)
			powerPerClick += 2
			setStatus(string.format("Aura empowered! Power/Click: %d", powerPerClick))
		end)
	end

	local ascensionPage = pages.Ascension
	if ascensionPage then
		local ascensionPanel = createSection(ascensionPage, "Ascension Tree", UDim2.fromScale(0.08, 0.2), UDim2.fromScale(0.84, 0.6))
		local ascensionList = createScrollingList(ascensionPanel, UDim2.fromScale(0.06, 0.22), UDim2.fromScale(0.88, 0.7), 1)
		local ascensionNodes = {
			{ Id = "nova_sense", Label = "Nova Sense (+0.2 Luck) - 500 Essence", Cost = 500, Effect = function() updateLuck(0.2) end },
			{ Id = "core_flow", Label = "Core Flow (+4 Power/sec) - 650 Essence", Cost = 650, Effect = function() powerPerSecond += 4 end },
			{ Id = "rift_tuning", Label = "Rift Tuning (+6 Power/Click) - 800 Essence", Cost = 800, Effect = function() powerPerClick += 6 end },
			{ Id = "omniforge", Label = "Omniforge (+0.4 Luck) - 1200 Essence", Cost = 1200, Effect = function() updateLuck(0.4) end },
		}
		for _, node in ipairs(ascensionNodes) do
			local button = createButton(ascensionList, node.Label, UDim2.fromScale(1, 0.2))
			button.MouseButton1Click:Connect(function()
				if ascensionUpgrades[node.Id] then
					setStatus("Ascension node already unlocked.")
					return
				end
				if essence < node.Cost then
					setStatus("Not enough Essence for ascension node.")
					return
				end
				updateEssence(-node.Cost)
				ascensionUpgrades[node.Id] = true
				node.Effect()
				setStatus("Ascension power unlocked!")
			end)
		end
	end

	local themedPages = {
		Automation = { "Automation Core", { "Auto Collect", "Auto Roll", "Auto Rebirth" } },
		Achievements = { "Achievement Board", { "Claim Rewards", "Track Goals", "Share Progress" } },
	}

	for pageName, info in pairs(themedPages) do
		local page = pages[pageName]
		if page then
			local panel = createSection(page, info[1], UDim2.fromScale(0.08, 0.2), UDim2.fromScale(0.84, 0.6))
			local list = createScrollingList(panel, UDim2.fromScale(0.08, 0.25), UDim2.fromScale(0.84, 0.65), 1)
			for _, label in ipairs(info[2]) do
				local action = createButton(list, label, UDim2.fromScale(1, 0.22))
				action.MouseButton1Click:Connect(function()
					setStatus(string.format("%s activated on %s.", label, pageName))
					Animation.flash(panel)
				end)
			end
		end
	end

	for pageName, info in pairs(lockedPages) do
		if pages[pageName] then
			lockedOverlays[pageName] = createLockedOverlay(pages[pageName], info.Reason)
		end
	end

	local function updateOdds()
		local totalWeight = Rarity.totalWeight(power)
		for _, tier in ipairs(Rarity.Tiers) do
			local label = oddsLabels[tier.Name]
			if label then
				if power >= tier.UnlockAt then
					local percent = totalWeight > 0 and (tier.Weight / totalWeight) * 100 or 0
					label.Text = string.format("%s - %.2f%%", tier.Name, percent)
				else
					label.Text = string.format("%s - Locked (%d Power)", tier.Name, tier.UnlockAt)
				end
			end
		end

		for itemName, data in pairs(itemOddsLabels) do
			local tier = data.Tier
			local label = data.Label
			if power >= tier.UnlockAt then
				local percent = totalWeight > 0 and (tier.Weight / totalWeight) * 100 or 0
				local itemPercent = percent / math.max(1, #(Items.ByRarity[tier.Name] or {}))
				label.Text = string.format("• %s - %.2f%%", itemName, itemPercent)
			else
				label.Text = string.format("• %s - Locked", itemName)
			end
		end
	end

	local function updateLocks()
		for pageName, overlay in pairs(lockedOverlays) do
			local unlock = lockedPages[pageName]
			if unlock and power >= unlock.UnlockAt then
				overlay.Visible = false
			elseif overlay then
				overlay.Visible = true
			end
		end
	end

	local function updatePower(delta)
		power += delta
		data.Power = power
		if powerLabel then
			powerLabel.Text = string.format("Power: %s", power)
		end
		if currencyPowerLabel then
			currencyPowerLabel.Text = string.format("Power: %s", power)
		end
		if powerPopup then
			powerPopup.Text = string.format("+%s", delta)
			Animation.numberPopup(powerPopup)
		end
		if statsValues.Power then
			statsValues.Power.Text = tostring(power)
		end
		updateOdds()
		updateLocks()
		queueSync()
	end

	local function updateEssence(delta)
		essence += delta
		data.Essence = essence
		if essenceLabel then
			essenceLabel.Text = string.format("Essence: %s", essence)
		end
		if currencyEssenceLabel then
			currencyEssenceLabel.Text = string.format("Essence: %s", essence)
		end
		if statsValues.Essence then
			statsValues.Essence.Text = tostring(essence)
		end
		queueSync()
	end

	local function updateLuck(delta)
		luckMultiplier += delta
		data.Luck = luckMultiplier
		queueSync()
	end

	local function setStatus(message)
		if statusLabel then
			statusLabel.Text = message
		end
	end

	local function addInventoryItem(tier, itemName)
		if not inventoryScroller then
			return
		end
		data.Inventory[itemName] = (data.Inventory[itemName] or 0) + 1
		local tierIndex = tierIndexByName[tier.Name] or 0
		if tierIndex > bestTierIndex then
			bestTierIndex = tierIndex
			bestRarity = tier.Name
			data.BestRarity = bestRarity
			queueSync()
		else
			queueSync()
		end
		local entryData = inventoryEntries[itemName]
		if entryData then
			entryData.Count += 1
			entryData.CountLabel.Text = string.format("x%d", entryData.Count)
		else
			local card = Instance.new("Frame")
			card.Size = UDim2.fromScale(1, 0.22)
			card.BackgroundColor3 = Color3.fromRGB(24, 26, 45)
			card.Parent = inventoryScroller
			createRounded(card, 12)
			createStroke(card, tier.Glow, 0.2, 2)
			local nameLabel = createLabel(card, string.format("%s (%s)", itemName, tier.Name), UDim2.fromScale(0.6, 0.6), UDim2.fromScale(0.05, 0.2))
			nameLabel.TextColor3 = tier.Color
			local countLabel = createLabel(card, "x1", UDim2.fromScale(0.12, 0.6), UDim2.fromScale(0.65, 0.2))
			countLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
			local sellButton = createButton(card, string.format("Sell (%d)", tier.Value), UDim2.fromScale(0.2, 0.6))
			sellButton.Position = UDim2.fromScale(0.78, 0.2)
			sellButton.MouseButton1Click:Connect(function()
				local entry = inventoryEntries[itemName]
				if not entry or entry.Count <= 0 then
					return
				end
				entry.Count -= 1
				data.Inventory[itemName] = math.max(0, (data.Inventory[itemName] or 1) - 1)
				updateEssence(tier.Value)
				setStatus(string.format("Sold %s for %d Essence.", itemName, tier.Value))
				if entry.Count <= 0 then
					entry.Frame:Destroy()
					inventoryEntries[itemName] = nil
					if data.Inventory[itemName] == 0 then
						data.Inventory[itemName] = nil
					end
				else
					entry.CountLabel.Text = string.format("x%d", entry.Count)
				end
				if inventoryApplyFilter then
					inventoryApplyFilter()
				end
				queueSync()
			end)
			inventoryEntries[itemName] = {
				Frame = card,
				CountLabel = countLabel,
				Count = 1,
				Tier = tier,
			}
		end
		if inventoryApplyFilter then
			inventoryApplyFilter()
		end
	end

	local passiveAccumulator = 0
	RunService.Heartbeat:Connect(function(dt)
		if powerPerSecond <= 0 then
			return
		end
		passiveAccumulator += dt
		if passiveAccumulator >= 1 then
			local ticks = math.floor(passiveAccumulator)
			passiveAccumulator -= ticks
			updatePower(powerPerSecond * ticks)
		end
	end)

	if collectButton then
		collectButton.MouseButton1Click:Connect(function()
			updatePower(powerPerClick)
			updateOdds()
			updateLocks()
		end)
	end

	local function addRollLogEntry(tier)
		if not rollLog then
			return
		end
		local itemName = Items.getItem(tier.Name)
		local entry = createLabel(rollLog, string.format("Rolled %s (%s)", itemName, tier.Name), UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0))
		entry.TextColor3 = tier.Color

		addInventoryItem(tier, itemName)
	end

	local function performRoll(cost, luckBoost, unlockBonus)
		if cost > 0 and essence < cost then
			setStatus("Not enough Essence for that roll.")
			if rollPage then
				Animation.flash(rollPage)
			end
			return
		end
		if cost > 0 then
			updateEssence(-cost)
		end

		revealFrame.Visible = true
		revealFrame.BackgroundTransparency = 0.2
		revealFrame.Size = UDim2.fromScale(0.3, 0.1)
		revealText.Text = "Rolling..."
		Animation.scale(revealFrame, UDim2.fromScale(0.5, 0.22), 0.25)

		local effectivePower = power + (unlockBonus or 0)
		local tier = RollLogic.roll(effectivePower, luckMultiplier * (luckBoost or 1))
		revealText.Text = tier.Name
		revealText.TextColor3 = tier.Color
		revealFrame.BackgroundColor3 = tier.Color
		Animation.flash(revealFrame)
		if glow then
			Animation.glowBurst(glow)
		end
		Animation.screenShake(rollPage)
		if rareFlash and tier.Weight <= 4 then
			rareFlash.BackgroundColor3 = tier.Glow
			Animation.tween(rareFlash, TweenInfo.new(0.12), { BackgroundTransparency = 0.4 })
			task.delay(0.2, function()
				Animation.tween(rareFlash, TweenInfo.new(0.35), { BackgroundTransparency = 1 })
			end)
		end

		rollCount += 1
		if statsValues.RollCount then
			statsValues.RollCount.Text = tostring(rollCount)
		end
		addRollLogEntry(tier)
		setStatus(string.format("Rolled a %s item!", tier.Name))

		task.delay(2.5, function()
			revealFrame.Visible = false
		end)
	end

	if rollButton and revealFrame and revealText and rollPage then
		rollButton.MouseButton1Click:Connect(function()
			performRoll(0, 1, 0)
		end)
	end

	if essenceRollButton and revealFrame and revealText and rollPage then
		essenceRollButton.MouseButton1Click:Connect(function()
			performRoll(25, 1.35, 1500)
		end)
	end

	if cosmicRollButton and revealFrame and revealText and rollPage then
		cosmicRollButton.MouseButton1Click:Connect(function()
			performRoll(75, 1.75, 5000)
		end)
	end

	if blessedRollButton and revealFrame and revealText and rollPage then
		blessedRollButton.MouseButton1Click:Connect(function()
			performRoll(150, 2.2, 9000)
		end)
	end

	if mythicRollButton and revealFrame and revealText and rollPage then
		mythicRollButton.MouseButton1Click:Connect(function()
			performRoll(300, 2.8, 15000)
		end)
	end

	if omniversalRollButton and revealFrame and revealText and rollPage then
		omniversalRollButton.MouseButton1Click:Connect(function()
			performRoll(600, 3.6, 25000)
		end)
	end

	for name, button in pairs(navButtons) do
		button.MouseButton1Click:Connect(function()
			showPage(name)
		end)
	end

	local function transitionToGame(startPage)
		Animation.fade(menu, 1, 0.4)
		task.delay(0.4, function()
			menu.Visible = false
			mainFrame.Visible = true
			showPage(startPage)
			Animation.fade(mainFrame, 0, 0.4)
		end)
	end

	if menuButtons then
		menuButtons.Play.MouseButton1Click:Connect(function()
			transitionToGame("Main")
		end)

		menuButtons.Inventory.MouseButton1Click:Connect(function()
			transitionToGame("Inventory")
		end)

		menuButtons.Settings.MouseButton1Click:Connect(function()
			transitionToGame("Settings")
		end)

		menuButtons.Stats.MouseButton1Click:Connect(function()
			transitionToGame("Stats")
		end)
	end

	updatePower(0)
	updateEssence(0)
	updateOdds()
	updateLocks()

	return gui
end

function UIController.applyRarityTheme(frame, rarityName)
	local tier = Rarity.getByName(rarityName)
	if not tier then
		return
	end
	frame.BackgroundColor3 = tier.Color
	local stroke = frame:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = tier.Glow
		stroke.Transparency = 0.1
	end
end

return UIController
