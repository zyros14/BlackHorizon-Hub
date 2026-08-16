local UI = {}
UI.__index = UI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function UI:Create(hub)
	self.Hub = hub
	self.Player = Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")

	self._minimized = false
	self._gui = self:_createBaseGUI()
	self:_buildWindow()
	self:_buildTabs()

	return self
end

function UI:_createBaseGUI()
	local existing = self.PlayerGui:FindFirstChild("BlackHorizonGUI")
	if existing then existing:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BlackHorizonGUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = self.PlayerGui

	return screenGui
end

function UI:_buildWindow()
	local config = self.Hub.Config.UI

	local background = Instance.new("Frame")
	background.Name = "Background"
	background.AnchorPoint = Vector2.new(0.5, 0.5)
	background.Position = UDim2.new(0.5, 0, 0.5, 0)
	background.Size = UDim2.new(0, 750, 0, 500)
	background.BackgroundColor3 = config.OutlineColor
	background.BorderSizePixel = 0
	background.Parent = self._gui

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 6)
	bgCorner.Parent = background

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = config.ButtonColor
	mainFrame.BorderSizePixel = 0
	mainFrame.BackgroundTransparency = 0.05
	mainFrame.Parent = background

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 6)
	mainCorner.Parent = mainFrame

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 45)
	topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Position = UDim2.new(0, 12, 0, 0)
	titleLabel.Size = UDim2.new(0, 300, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = self.Hub.Name .. " " .. self.Hub.Version
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = topBar

	local dragButton = Instance.new("TextButton")
	dragButton.Name = "DragButton"
	dragButton.Position = UDim2.new(0, 0, 0, 0)
	dragButton.Size = UDim2.new(1, -90, 1, 0)
	dragButton.BackgroundTransparency = 1
	dragButton.Text = ""
	dragButton.Parent = topBar

	self._dragging = false
	self._dragInputStart = nil
	self._startPos = nil

	dragButton.MouseButton1Down:Connect(function()
		self._dragging = true
		self._dragInputStart = UserInputService:GetMouseLocation()
		self._startPos = background.Position
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self._dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and self._dragging then
			local delta = input.Position - self._dragInputStart
			background.Position = UDim2.new(
				self._startPos.X.Scale,
				self._startPos.X.Offset + delta.X,
				self._startPos.Y.Scale,
				self._startPos.Y.Offset + delta.Y
			)
		end
	end)

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "MinimizeButton"
	minimizeButton.Position = UDim2.new(1, -82, 0, 8)
	minimizeButton.Size = UDim2.new(0, 28, 0, 28)
	minimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
	minimizeButton.BorderSizePixel = 0
	minimizeButton.Text = "_"
	minimizeButton.Font = Enum.Font.SourceSansBold
	minimizeButton.TextSize = 18
	minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeButton.Parent = topBar

	local minCorner = Instance.new("UICorner")
	minCorner.CornerRadius = UDim.new(0, 6)
	minCorner.Parent = minimizeButton

	minimizeButton.MouseButton1Click:Connect(function()
		self:_toggleMinimize()
	end)

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Position = UDim2.new(1, -42, 0, 8)
	closeButton.Size = UDim2.new(0, 28, 0, 28)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.TextSize = 16
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Parent = topBar

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		self:_close()
	end)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Position = UDim2.new(0, 0, 0, 45)
	sidebar.Size = UDim2.new(0, 150, 1, -45)
	sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainFrame

	self._sidebar = sidebar

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Position = UDim2.new(0, 150, 0, 45)
	contentFrame.Size = UDim2.new(1, -150, 1, -45)
	contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	contentFrame.BorderSizePixel = 0
	contentFrame.Parent = mainFrame

	self._content = contentFrame
	self._background = background
	self._mainFrame = mainFrame
end

function UI:_buildTabs()
	local tabs = {
		{name = "Auto Farm", key = "farm"},
		{name = "Combat", key = "combat"},
		{name = "Auto Raid", key = "raid"},
		{name = "Auto Chest", key = "chest"},
		{name = "Utility", key = "utility"},
		{name = "Settings", key = "settings"},
	}

	self._tabs = {}

	for i, tab in ipairs(tabs) do
		local button = Instance.new("TextButton")
		button.Name = "Tab_" .. tab.key
		button.Position = UDim2.new(0, 4, 0, (i - 1) * 36 + 8)
		button.Size = UDim2.new(1, -8, 0, 30)
		button.BackgroundColor3 = i == 1 and Color3.fromRGB(40, 120, 255) or Color3.fromRGB(35, 35, 40)
		button.BorderSizePixel = 0
		button.Text = "  " .. tab.name
		button.Font = Enum.Font.SourceSans
		button.TextSize = 14
		button.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Parent = self._sidebar

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = button

		button.MouseButton1Click:Connect(function()
			self:_selectTab(tab.key)
		end)

		self._tabs[tab.key] = { button = button, name = tab.name }
	end

	self:_selectTab("farm")
end

function UI:_selectTab(key)
	for k, tab in pairs(self._tabs) do
		local isActive = k == key
		tab.button.BackgroundColor3 = isActive and Color3.fromRGB(40, 120, 255) or Color3.fromRGB(35, 35, 40)
		tab.button.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
	end

	if self._currentContent then
		self._currentContent:Destroy()
	end

	local content = Instance.new("ScrollingFrame")
	content.Name = "TabContent_" .. key
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.ScrollBarThickness = 6
	content.Parent = self._content
	self._currentContent = content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content

	if key == "farm" then
		self:_buildFarmTab(content)
	elseif key == "combat" then
		self:_buildCombatTab(content)
	elseif key == "raid" then
		self:_buildRaidTab(content)
	elseif key == "chest" then
		self:_buildChestTab(content)
	elseif key == "utility" then
		self:_buildUtilityTab(content)
	elseif key == "settings" then
		self:_buildSettingsTab(content)
	end
end

function UI:_createSection(parent, title, order)
	local section = Instance.new("Frame")
	section.Name = title:gsub("%s+", "_") .. "_Section"
	section.Size = UDim2.new(1, -16, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
	section.BorderSizePixel = 0
	section.LayoutOrder = order or 1
	section.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = section

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = section

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 24)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "  " .. title
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 14
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.LayoutOrder = 0
	titleLabel.Parent = section

	return section
end

function UI:_createToggle(parent, label, defaultValue, callback, order)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -8, 0, 32)
	container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	container.BorderSizePixel = 0
	container.LayoutOrder = order or 2
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = container

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -60, 1, 0)
	textLabel.Position = UDim2.new(0, 8, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "  " .. label
	textLabel.Font = Enum.Font.SourceSans
	textLabel.TextSize = 13
	textLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = container

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 44, 0, 24)
	toggle.Position = UDim2.new(1, -52, 0.5, -12)
	toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(40, 120, 255) or Color3.fromRGB(90, 90, 95)
	toggle.BorderSizePixel = 0
	toggle.AutoButtonColor = false
	toggle.Parent = container

	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(0.5, 0)
	tCorner.Parent = toggle

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 20, 0, 20)
	knob.Position = defaultValue and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = toggle

	local kCorner = Instance.new("UICorner")
	kCorner.CornerRadius = UDim.new(0.5, 0)
	kCorner.Parent = knob

	local state = defaultValue

	local function setState(newState)
		state = newState
		toggle.BackgroundColor3 = state and Color3.fromRGB(40, 120, 255) or Color3.fromRGB(90, 90, 95)
		knob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
		if callback then callback(state) end
	end

	toggle.MouseButton1Click:Connect(function()
		setState(not state)
	end)

	return { Set = setState, Get = function() return state end }
end

function UI:_createSlider(parent, label, min, max, default, callback, order)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -8, 0, 52)
	container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	container.BorderSizePixel = 0
	container.LayoutOrder = order or 3
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = container

	local labelLabel = Instance.new("TextLabel")
	labelLabel.Size = UDim2.new(1, -56, 0, 16)
	labelLabel.Position = UDim2.new(0, 8, 0, 4)
	labelLabel.BackgroundTransparency = 1
	labelLabel.Text = "  " .. label
	labelLabel.Font = Enum.Font.SourceSans
	labelLabel.TextSize = 13
	labelLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	labelLabel.TextXAlignment = Enum.TextXAlignment.Left
	labelLabel.Parent = container

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 40, 0, 16)
	valueLabel.Position = UDim2.new(1, -48, 0, 4)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(math.floor(default))
	valueLabel.Font = Enum.Font.SourceSans
	valueLabel.TextSize = 13
	valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = container

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -16, 0, 10)
	track.Position = UDim2.new(0, 8, 0, 30)
	track.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
	track.BorderSizePixel = 0
	track.Parent = container

	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(0.5, 0)
	tCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(40, 120, 255)
	fill.BorderSizePixel = 0
	fill.Parent = track

	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0.5, 0)
	fCorner.Parent = fill

	local thumb = Instance.new("TextButton")
	thumb.Size = UDim2.new(0, 14, 0, 26)
	thumb.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -13)
	thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	thumb.BorderSizePixel = 0
	thumb.AutoButtonColor = false
	thumb.Parent = track

	local thCorner = Instance.new("UICorner")
	thCorner.CornerRadius = UDim.new(0.25, 0)
	thCorner.Parent = thumb

	local dragging = false
	local value = default

	local function setValue(inputX)
		local trackAbs = track.AbsolutePosition.X
		local trackWidth = track.AbsoluteSize.X
		local percent = math.clamp((inputX - trackAbs) / trackWidth, 0, 1)
		value = min + (max - min) * percent
		fill.Size = UDim2.new(percent, 0, 1, 0)
		thumb.Position = UDim2.new(percent, -7, 0.5, -13)
		valueLabel.Text = tostring(math.floor(value))
		if callback then callback(math.floor(value)) end
	end

	thumb.MouseButton1Down:Connect(function() dragging = true end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			setValue(input.Position.X)
		end
	end)

	return { Set = function(v) value = v end, Get = function() return value end }
end

function UI:_buildFarmTab(parent)
	local s1 = self:_createSection(parent, "Auto Farm", 1)
	self:_createToggle(s1, "Auto Farm", self.Hub.Config.Features.AutoFarm.Enabled, function(state)
		self.Hub.Config.Features.AutoFarm.Enabled = state
		if state and self.Hub.Modules and self.Hub.Modules.Farm then
			self.Hub.Modules.Farm.Config = self.Hub.Config.Features.AutoFarm
			self.Hub.Modules.Farm:Start()
		elseif self.Hub.Modules and self.Hub.Modules.Farm then
			self.Hub.Modules.Farm:Stop()
		end
	end, 1)

	self:_createToggle(s1, "Auto Quest", self.Hub.Config.Features.AutoFarm.AutoQuest, function(state)
		self.Hub.Config.Features.AutoFarm.AutoQuest = state
		if self.Hub.Modules and self.Hub.Modules.Farm then
			self.Hub.Modules.Farm.Config.AutoQuest = state
		end
	end, 2)

	self:_createToggle(s1, "Bring Mobs", self.Hub.Config.Features.AutoFarm.BringMobs, function(state)
		self.Hub.Config.Features.AutoFarm.BringMobs = state
		if self.Hub.Modules and self.Hub.Modules.Farm then
			self.Hub.Modules.Farm.Config.BringMobs = state
		end
	end, 3)

	local s2 = self:_createSection(parent, "Settings", 2)
	self:_createSlider(s2, "Tween Speed", 100, 500, self.Hub.Config.Features.AutoFarm.TweenSpeed, function(value)
		self.Hub.Config.Features.AutoFarm.TweenSpeed = value
		if self.Hub.Modules and self.Hub.Modules.Farm then
			self.Hub.Modules.Farm.Config.TweenSpeed = value
		end
	end, 1)
end

function UI:_buildCombatTab(parent)
	local s1 = self:_createSection(parent, "Combat", 1)
	self:_createToggle(s1, "Enable Combat", self.Hub.Config.Features.Combat.Enabled, function(state)
		self.Hub.Config.Features.Combat.Enabled = state
	end, 1)
	self:_createToggle(s1, "Auto Click", self.Hub.Config.Features.Combat.AutoClick, function(state)
		self.Hub.Config.Features.Combat.AutoClick = state
	end, 2)
	self:_createToggle(s1, "Auto Skill", self.Hub.Config.Features.Combat.AutoSkill, function(state)
		self.Hub.Config.Features.Combat.AutoSkill = state
	end, 3)

	local s2 = self:_createSection(parent, "Protection", 2)
	self:_createToggle(s2, "Anti Stun", self.Hub.Config.Features.Combat.AntiStun, function(state)
		self.Hub.Config.Features.Combat.AntiStun = state
		if self.Hub.Modules and self.Hub.Modules.Combat then
			self.Hub.Modules.Combat.State.AntiStun.Enabled = state
			if state then self.Hub.Modules.Combat:ApplyAntiStun() end
		end
	end, 1)
	self:_createToggle(s2, "Anti Knockback", self.Hub.Config.Features.Combat.AntiKnockback, function(state)
		self.Hub.Config.Features.Combat.AntiKnockback = state
		if self.Hub.Modules and self.Hub.Modules.Combat then
			self.Hub.Modules.Combat.State.AntiKnockback.Enabled = state
			if state then self.Hub.Modules.Combat:ApplyAntiKnockback() end
		end
	end, 2)
end

function UI:_buildRaidTab(parent)
	local s = self:_createSection(parent, "Auto Raid", 1)
	self:_createToggle(s, "Enable Auto Raid", self.Hub.Config.Features.AutoRaid.Enabled, function(state)
		self.Hub.Config.Features.AutoRaid.Enabled = state
		if state and self.Hub.Modules and self.Hub.Modules.Raid then
			self.Hub.Modules.Raid.Config = self.Hub.Config.Features.AutoRaid
			self.Hub.Modules.Raid:Start()
		elseif self.Hub.Modules and self.Hub.Modules.Raid then
			self.Hub.Modules.Raid:Stop()
		end
	end, 1)
	self:_createSlider(s, "Delay (sec)", 1, 60, self.Hub.Config.Features.AutoRaid.Intervale, function(value)
		self.Hub.Config.Features.AutoRaid.Intervale = value
		if self.Hub.Modules and self.Hub.Modules.Raid then
			self.Hub.Modules.Raid.Config.Intervale = value
		end
	end, 2)
end

function UI:_buildChestTab(parent)
	local s = self:_createSection(parent, "Auto Chest", 1)
	self:_createToggle(s, "Enable Auto Chest", self.Hub.Config.Features.AutoChest.Enabled, function(state)
		self.Hub.Config.Features.AutoChest.Enabled = state
		if state and self.Hub.Modules and self.Hub.Modules.Chest then
			self.Hub.Modules.Chest.Config = self.Hub.Config.Features.AutoChest
			self.Hub.Modules.Chest:Start()
		elseif self.Hub.Modules and self.Hub.Modules.Chest then
			self.Hub.Modules.Chest:Stop()
		end
	end, 1)
	self:_createToggle(s, "Auto Loot", self.Hub.Config.Features.AutoChest.AutoLoot, function(state)
		self.Hub.Config.Features.AutoChest.AutoLoot = state
		if self.Hub.Modules and self.Hub.Modules.Chest then
			self.Hub.Modules.Chest.Config.AutoLoot = state
		end
	end, 2)
end

function UI:_buildUtilityTab(parent)
	local s1 = self:_createSection(parent, "General", 1)
	self:_createToggle(s1, "Anti AFK", self.Hub.Config.Features.AntiAFK.Enabled, function(state)
		self.Hub.Config.Features.AntiAFK.Enabled = state
		if self.Hub.Modules and self.Hub.Modules.Utility then
			self.Hub.Modules.Utility:AntiAFK(state)
		end
	end, 1)
	self:_createToggle(s1, "White Screen Fix", self.Hub.Config.Features.WhiteScreen.Enabled, function(state)
		self.Hub.Config.Features.WhiteScreen.Enabled = state
		if self.Hub.Modules and self.Hub.Modules.Utility then
			self.Hub.Modules.Utility:WhiteScreenFix(state)
		end
	end, 2)
	self:_createToggle(s1, "NoClip", self.Hub.Config.Features.NoClip.Enabled, function(state)
		self.Hub.Config.Features.NoClip.Enabled = state
		if self.Hub.Modules and self.Hub.Modules.Utility then
			self.Hub.Modules.Utility:NoClip(state)
		end
	end, 3)
end

function UI:_buildSettingsTab(parent)
	local s = self:_createSection(parent, "About", 1)
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, -16, 0, 60)
	info.BackgroundTransparency = 1
	info.Text = "  Black Horizon Hub " .. self.Hub.Version .. "\n  Auto Farm | Combat | Raid | Chest\n  No keybinds - GUI auto-opens"
	info.Font = Enum.Font.SourceSans
	info.TextSize = 13
	info.TextColor3 = Color3.fromRGB(200, 200, 200)
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Top
	info.LayoutOrder = 1
	info.Parent = s
end

function UI:_toggleMinimize()
	self._minimized = not self._minimized

	if self._minimized then
		TweenService:Create(self._background, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 750, 0, 45)
		}):Play()
		if self._sidebar then self._sidebar.Visible = false end
		if self._content then self._content.Visible = false end
		if self._currentContent then self._currentContent.Visible = false end

		for _, child in ipairs(self._mainFrame:GetChildren()) do
			if child.Name ~= "TopBar" then
				child.Visible = false
			end
		end
	else
		TweenService:Create(self._background, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 750, 0, 500)
		}):Play()
		if self._sidebar then self._sidebar.Visible = true end
		if self._content then self._content.Visible = true end
		if self._currentContent then self._currentContent.Visible = true end

		for _, child in ipairs(self._mainFrame:GetChildren()) do
			child.Visible = true
		end
	end

	self.Hub.Config.UI.Minimized = self._minimized
end

function UI:_close()
	self._background.Visible = false
	task.wait(1)
	self._background.Visible = true
end

function UI:SetVisible(visible)
	if not self._background then return end
	self._background.Visible = visible
end

function UI:Notify(title, text, duration)
	duration = duration or 4

	local notif = Instance.new("Frame")
	notif.Name = "Notification"
	notif.AnchorPoint = Vector2.new(1, 0)
	notif.Position = UDim2.new(1, -16, 0, 16)
	notif.Size = UDim2.new(0, 280, 0, 60)
	notif.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	notif.BorderSizePixel = 0
	notif.Parent = self._gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = notif

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -12, 0, 20)
	titleLabel.Position = UDim2.new(0, 6, 0, 4)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title or "Black Horizon"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 14
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notif

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -12, 0, 20)
	textLabel.Position = UDim2.new(0, 6, 0, 28)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text or ""
	textLabel.Font = Enum.Font.SourceSans
	textLabel.TextSize = 12
	textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = notif

	notif.Size = UDim2.new(0, 280, 0, 0)
	TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 280, 0, 60)
	}):Play()

	task.delay(duration, function()
		TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 280, 0, 0),
			BackgroundTransparency = 1
		}):Play()
		task.delay(0.3, function()
			if notif and notif.Parent then notif:Destroy() end
		end)
	end)
end

return UI