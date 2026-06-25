local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- BLUR EFFECT
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0

-- STATE
local destroyed = false
local minimized = false
local open = true
local connections = {}
local sliderConnections = {}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "JackPetrovaHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 520, 0, 440)
frame.Position = UDim2.new(0.5, -260, 0.5, -220)
frame.BackgroundColor3 = Color3.fromRGB(22,22,28)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

-- Pop-out animation with blur
frame.Size = UDim2.new(0, 0, 0, 0)
frame.BackgroundTransparency = 1
TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	Size = 5
}):Play()
local popTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.new(0, 520, 0, 440),
	BackgroundTransparency = 0
}):Play()

-- TOP BAR
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 55)
top.BackgroundColor3 = Color3.fromRGB(30,30,40)
top.BorderSizePixel = 0
top.Parent = frame
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 16)

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 16, 0, -6)
title.BackgroundTransparency = 1
title.Text = "( ᴗ͈ˬᴗ͈) ♡"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -120, 1, 0)
subtitle.Position = UDim2.new(0, 16, 0, 14)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Made by JackPetrova & Ay ♡"
subtitle.TextColor3 = Color3.fromRGB(170,170,170)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 12
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = top

-- MINIMIZE BUTTON
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 34, 0, 34)
miniBtn.Position = UDim2.new(1, -85, 0.5, -17)
miniBtn.Text = "–"
miniBtn.TextColor3 = Color3.fromRGB(255,255,255)
miniBtn.BackgroundColor3 = Color3.fromRGB(80,120,255)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 18
miniBtn.Parent = top
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -45, 0.5, -17)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundColor3 = Color3.fromRGB(255,80,120)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = top
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)

-- LEFT CATEGORY BAR
local categoriesFrame = Instance.new("ScrollingFrame")
categoriesFrame.Size = UDim2.new(0, 130, 1, -70)
categoriesFrame.Position = UDim2.new(0, 10, 0, 60)
categoriesFrame.BackgroundColor3 = Color3.fromRGB(28,28,35)
categoriesFrame.BorderSizePixel = 0
categoriesFrame.ScrollBarThickness = 4
categoriesFrame.ScrollBarImageColor3 = Color3.fromRGB(80,120,255)
categoriesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
categoriesFrame.Parent = frame
Instance.new("UICorner", categoriesFrame).CornerRadius = UDim.new(0, 12)

local catLayout = Instance.new("UIListLayout", categoriesFrame)
catLayout.Padding = UDim.new(0, 4)

catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	categoriesFrame.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 10)
end)

-- SCROLL
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0, 150, 0, 60)
scroll.Size = UDim2.new(1, -160, 1, -80)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 5
scroll.Parent = frame

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)

---------------------------------------------------
-- DATA
---------------------------------------------------
local data = {
	Waves = {
		{"Warehouse Push", Vector3.new(374,114,114)},
		{"Warehouse Mountain", Vector3.new(612,143,213)},
		{"Castle", Vector3.new(-298,42,-765)},
		{"Beige Roof", Vector3.new(70,123,376)},
		{"Jewelry Push", Vector3.new(-707,117,-402)},
		{"Jewelry Mountain", Vector3.new(-702,102,-132)},
		{"Grenade Walls", Vector3.new(-919,-29,547)},
		{"Grenade Walls 2", Vector3.new(-959,-29,569)},
		{"RPG Vault", Vector3.new(32,-53,206)},
		{"UFO Mountains", Vector3.new(5,124,-810)},
		{"Red PG Edge", Vector3.new(-284,90,-717)},
		{"Red PG Castle Push", Vector3.new(-320,93,-644)},
		{"Water Tank Top", Vector3.new(-672,150,-641)},
		{"Bank Vault", Vector3.new(-678,-32,-261)},
		{"Yellow PG Mountain", Vector3.new(-255,88,-881)},
		{"Furniture Mountain", Vector3.new(-553,167,20)},
		{"School Roof", Vector3.new(-597,68,337)},
		{"Haunted Basement", Vector3.new(178,-42,220)}
	},

	Guns = {
		{"Uphill Gun Shop", Vector3.new(481,48,-620)},
		{"Downhill Gun Shop", Vector3.new(-580,8,-736)},
		{"Carnival DB", Vector3.new(208,24,-989)},
		{"Casino DB", Vector3.new(-1044,21,-265)},
		{"Revolver", Vector3.new(-640,21,-124)},
		{"Flamethrower", Vector3.new(-152,54,-100)},
		{"RPG", Vector3.new(115,-27,-272)},
		{"Rifle & AUG", Vector3.new(-267,52,-217)},
		{"Behind SG Rifle", Vector3.new(-865,2,-687)},
		{"PG Flintlock", Vector3.new(-322,21,-847)},
		{"Flame Flintlock", Vector3.new(-188,21,-125)},
		{"Deagle", Vector3.new(302,64,330)},
		{"LMG", Vector3.new(-619,23,-302)}
	},

	Food = {
		{"Bank Food", Vector3.new(-329,23,-296)},
		{"Beige Building", Vector3.new(56,66,401)},
		{"Lettuce", Vector3.new(-56,22,-609)},
		{"Gas Station", Vector3.new(594,49,-256)},
		{"Market", Vector3.new(-918,22,-673)},
		{"Uphill Food", Vector3.new(300,49,-616)},
		{"Playground Food", Vector3.new(-278,22,-807)},
		{"School Food", Vector3.new(-587,22,288)},
		{"Arcade Popcorn", Vector3.new(-238,22,-301)},
		{"Casino Popcorn", Vector3.new(-996,24,-158)}
	},

	Armor = {
		{"Grenade Armor", Vector3.new(-936,-29,564)},
		{"Police High Medium Armor", Vector3.new(-265,22,-78)},
		{"Warehouse Medium Armor", Vector3.new(409,48,-50)},
		{"Uphill House Medium Armor", Vector3.new(535,50,-638)},
		{"ShotGun House Medium Armor", Vector3.new(-608,10,-800)},
		{"DrumGun Medium & Fire Armor", Vector3.new(-1181,28,-489)},
		{"Broken House Medium & Fire Armor", Vector3.new(91,22,-318)},
		{"Da Vehicles Medium Armor", Vector3.new(-258,26,483)}
	},

	Other = {
		{"Racing Track Void (Teleport out of the map)", Vector3.new(409,65,788)}
	},

	ESP = {
		{"Toggle ESP", nil}
	},
	SpeedWalk = {
		{"Toggle Speed", nil},
		{"Reset Speed", nil}
	}
}

---------------------------------------------------
-- ENHANCED ESP SYSTEM
---------------------------------------------------
local espEnabled = false
local espColor = Color3.fromRGB(255, 80, 80)
local espTextColor = Color3.fromRGB(255, 255, 255)
local espKeybind = nil -- No keybind by default
local espObjects = {}
local espWhitelist = {} -- Table of player names to exclude from ESP
local espShowDisplayNames = true
local espShowHealth = true
local espShowDistance = true
local espShowOutlines = true -- Separate toggle for player outlines (visible through walls)
local espFont = Enum.Font.GothamSemibold -- Cute font
local espTextSize = 13

local function removeESPForPlayer(plr)
	if espObjects[plr] then
		-- Remove all highlights
		if espObjects[plr].highlights then
			for _, hl in ipairs(espObjects[plr].highlights) do
				hl:Destroy()
			end
		end
		if espObjects[plr].billboardGui then espObjects[plr].billboardGui:Destroy() end
		espObjects[plr] = nil
	end
end

local function isWhitelisted(plr)
	local name = string.lower(plr.Name)
	local displayName = string.lower(plr.DisplayName)
	for _, whitelistedName in ipairs(espWhitelist) do
		if string.lower(whitelistedName) == name or string.lower(whitelistedName) == displayName then
			return true
		end
	end
	return false
end

local function createESPForPlayer(plr)
	if plr == player then return end -- Don't show ESP on yourself
	if isWhitelisted(plr) then return end -- Don't show ESP on whitelisted players
	if not plr.Character then return end

	local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
	local head = plr.Character:FindFirstChild("Head")
	if not hrp or not head then return end

	-- Remove existing ESP first
	removeESPForPlayer(plr)

	-- Create a single highlight for the entire character model (whole avatar)
	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_HL_Full"
	highlight.FillColor = espColor
	highlight.OutlineColor = espColor
	highlight.FillTransparency = 0.7
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = espShowOutlines
	highlight.Adornee = plr.Character -- Highlights the entire character model
	highlight.Parent = plr.Character

	local highlights = {highlight}

	-- Create billboard GUI for text above head
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "ESP_Text"
	billboardGui.Size = UDim2.new(0, 200, 0, 80)
	billboardGui.StudsOffsetWorldSpace = Vector3.new(0, 1.5, 0) -- Closer to head
	billboardGui.Adornee = head
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = plr.Character

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = ""
	textLabel.TextColor3 = espTextColor
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Font = espFont
	textLabel.TextSize = espTextSize
	textLabel.TextScaled = false
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.Parent = billboardGui

	espObjects[plr] = {
		highlights = highlights,
		billboardGui = billboardGui,
		textLabel = textLabel
	}
end

local function updateESPForPlayer(plr)
	if not espEnabled then return end
	if not espObjects[plr] then return end
	if not plr.Character then return end

	local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")

	-- Build text
	local text = ""
	if espShowDisplayNames then
		text = plr.DisplayName
	else
		text = plr.Name
	end

	if espShowHealth and humanoid then
		local health = math.floor(humanoid.Health)
		local maxHealth = math.floor(humanoid.MaxHealth)
		text = text .. "\n❤ " .. health .. "/" .. maxHealth
	end

	if espShowDistance and hrp then
		local myChar = player.Character
		if myChar then
			local myHrp = myChar:FindFirstChild("HumanoidRootPart")
			if myHrp then
				local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
				text = text .. "\n📏 " .. dist .. " studs"
			end
		end
	end

	espObjects[plr].textLabel.Text = text
	espObjects[plr].textLabel.TextColor3 = espTextColor

	-- Update all highlights color and visibility
	if espObjects[plr].highlights then
		for _, hl in ipairs(espObjects[plr].highlights) do
			hl.FillColor = espColor
			hl.OutlineColor = espColor
			hl.Enabled = espShowOutlines
		end
	end
end

local function clearAllESP()
	for plr, _ in pairs(espObjects) do
		removeESPForPlayer(plr)
	end
	espObjects = {}
end

local function toggleESP()
	espEnabled = not espEnabled

	if espEnabled then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and not isWhitelisted(p) then
				createESPForPlayer(p)
			end
		end
	else
		clearAllESP()
	end
end

-- Update ESP every frame
local espUpdateConnection
espUpdateConnection = RunService.RenderStepped:Connect(function()
	if not espEnabled then return end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and not isWhitelisted(plr) and plr.Character then
			if not espObjects[plr] then
				createESPForPlayer(plr)
			else
				updateESPForPlayer(plr)
			end
		end
	end
end)
table.insert(connections, espUpdateConnection)

-- Handle new players and respawns
table.insert(connections, Players.PlayerAdded:Connect(function(plr)
	if destroyed or plr == player then return end
	plr.CharacterAdded:Connect(function()
		if destroyed then return end
		task.wait(0.5) -- Wait for character to fully load
		if destroyed then return end
		if espEnabled and not isWhitelisted(plr) then
			createESPForPlayer(plr)
		end
		-- Apply hitbox if enabled (ESP and hitbox can work together now)
		if hbeEnabled and plr.Character and not isHBEWhitelisted(plr) then
			applyHitboxToCharacter(plr.Character, hbeSize)
		end
	end)
end))

-- Handle respawns for existing players
for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= player then
		plr.CharacterAdded:Connect(function()
			if destroyed then return end
			task.wait(0.5)
			if destroyed then return end
			if espEnabled and not isWhitelisted(plr) then
				createESPForPlayer(plr)
			end
			-- Apply hitbox if enabled
			if hbeEnabled and plr.Character and not isHBEWhitelisted(plr) then
				applyHitboxToCharacter(plr.Character, hbeSize)
			end
		end)
	end
end

-- Handle players leaving
table.insert(connections, Players.PlayerRemoving:Connect(function(plr)
	removeESPForPlayer(plr)
end))

-- ESP keybind toggle (only if keybind is set)
table.insert(connections, UIS.InputBegan:Connect(function(input, gpe)
	if destroyed or gpe then return end
	if espKeybind and input.KeyCode == espKeybind then
		toggleESP()
	end
end))

-- No default keybind - player must set their own
-- espKeybind is nil by default
-- SPEED WALK SYSTEM (from speed script - simplified)
local speedEnabled = false
local defaultSpeed = 16
local currentSpeed = 50 -- Default speed like in the speed script
local speedKeybind = Enum.KeyCode.B -- Default keybind from speed script
local speedRenderConnection = nil

-- HITBOX EXPANDER SYSTEM (REWRITTEN - Expands actual character parts!)
local hbeEnabled = false
local hbeSize = 10
local hbeMaxSize = 100
local hbeTransparency = 0.8
local hbeColor = Color3.fromRGB(255, 100, 100)
local hbeKeybind = nil
local hbeWhitelist = {}
local hbeUpdateConnection = nil

local function isHBEWhitelisted(plr)
	local name = string.lower(plr.Name)
	local displayName = string.lower(plr.DisplayName)
	for _, whitelistedName in ipairs(hbeWhitelist) do
		if string.lower(whitelistedName) == name or string.lower(whitelistedName) == displayName then
			return true
		end
	end
	return false
end

-- Expand actual character parts - this is what games use for hit detection
local function applyHitboxToCharacter(char, sizeMultiplier)
	if not char then return end
	
	-- Get all the important hitbox parts
	local head = char:FindFirstChild("Head")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	
	-- Store original sizes if not already stored
	if head and not char:GetAttribute("OriginalHeadSize") then
		char:SetAttribute("OriginalHeadSize", head.Size)
	end
	if hrp and not char:GetAttribute("OriginalHRPSize") then
		char:SetAttribute("OriginalHRPSize", hrp.Size)
	end
	if torso and not char:GetAttribute("OriginalTorsoSize") then
		char:SetAttribute("OriginalTorsoSize", torso.Size)
	end
	
	-- Calculate expansion - sizeMultiplier is the hitbox size in studs
	local expandSize = sizeMultiplier
	
	-- Expand HEAD (most important for headshots)
	if head then
		head.Size = Vector3.new(expandSize, expandSize * 0.6, expandSize)
		head.Transparency = hbeTransparency
		head.CanCollide = false
		head.CanQuery = true
		-- Make sure it's still recognized as a head
		if head:IsA("MeshPart") then
			head.MeshId = ""
		end
	end
	
	-- Expand HumanoidRootPart (main hitbox for body shots)
	if hrp then
		hrp.Size = Vector3.new(expandSize, expandSize * 1.5, expandSize)
		hrp.Transparency = hbeTransparency
		hrp.CanCollide = false
		hrp.CanQuery = true
	end
	
	-- Expand Torso (body shots)
	if torso then
		torso.Size = Vector3.new(expandSize, expandSize * 1.2, expandSize * 0.8)
		torso.Transparency = hbeTransparency
		torso.CanCollide = false
		torso.CanQuery = true
	end
	
	-- Also expand other body parts for full coverage
	local bodyParts = {"LeftArm", "RightArm", "LeftLeg", "RightLeg", 
		"Left Arm", "Right Arm", "Left Leg", "Right Leg",
		"LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg",
		"LeftLowerArm", "RightLowerArm", "LeftLowerLeg", "RightLowerLeg"}
	
	for _, partName in ipairs(bodyParts) do
		local part = char:FindFirstChild(partName)
		if part then
			if not char:GetAttribute("Original" .. partName .. "Size") then
				char:SetAttribute("Original" .. partName .. "Size", part.Size)
			end
			part.Size = Vector3.new(expandSize * 0.8, expandSize * 0.8, expandSize * 0.8)
			part.Transparency = hbeTransparency
			part.CanCollide = false
			part.CanQuery = true
		end
	end
end

-- Reset hitbox to original sizes
local function resetHitboxForCharacter(char)
	if not char then return end
	
	local head = char:FindFirstChild("Head")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	
	-- Reset Head
	if head then
		local originalSize = char:GetAttribute("OriginalHeadSize")
		if originalSize then
			head.Size = originalSize
		else
			head.Size = Vector3.new(2, 1, 1)
		end
		head.Transparency = 0
		head.CanCollide = true
	end
	
	-- Reset HumanoidRootPart
	if hrp then
		local originalSize = char:GetAttribute("OriginalHRPSize")
		if originalSize then
			hrp.Size = originalSize
		else
			hrp.Size = Vector3.new(2, 2, 1)
		end
		hrp.Transparency = 1
		hrp.CanCollide = true
	end
	
	-- Reset Torso
	if torso then
		local originalSize = char:GetAttribute("OriginalTorsoSize")
		if originalSize then
			torso.Size = originalSize
		else
			torso.Size = Vector3.new(2, 2, 1)
		end
		torso.Transparency = 0
		torso.CanCollide = true
	end
	
	-- Reset other body parts
	local bodyParts = {"LeftArm", "RightArm", "LeftLeg", "RightLeg", 
		"Left Arm", "Right Arm", "Left Leg", "Right Leg",
		"LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg",
		"LeftLowerArm", "RightLowerArm", "LeftLowerLeg", "RightLowerLeg"}
	
	for _, partName in ipairs(bodyParts) do
		local part = char:FindFirstChild(partName)
		if part then
			local originalSize = char:GetAttribute("Original" .. partName .. "Size")
			if originalSize then
				part.Size = originalSize
			else
				part.Size = Vector3.new(1, 2, 1)
			end
			part.Transparency = 0
			part.CanCollide = true
		end
	end
	
	-- Clear stored attributes
	for _, attr in ipairs({"OriginalHeadSize", "OriginalHRPSize", "OriginalTorsoSize"}) do
		char:SetAttribute(attr, nil)
	end
	for _, partName in ipairs(bodyParts) do
		char:SetAttribute("Original" .. partName .. "Size", nil)
	end
end

local function resetAllHitboxes()
	if hbeUpdateConnection then
		hbeUpdateConnection:Disconnect()
		hbeUpdateConnection = nil
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			resetHitboxForCharacter(plr.Character)
		end
	end
end

local function startHitboxLoop()
	if hbeUpdateConnection then
		hbeUpdateConnection:Disconnect()
		hbeUpdateConnection = nil
	end
	if not hbeEnabled then return end

	hbeUpdateConnection = RunService.Heartbeat:Connect(function()
		if destroyed or not hbeEnabled then return end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and not isHBEWhitelisted(plr) and plr.Character then
				applyHitboxToCharacter(plr.Character, hbeSize)
			end
		end
	end)
	table.insert(connections, hbeUpdateConnection)
end

local function applyHitboxLive()
	if not hbeEnabled then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and not isHBEWhitelisted(plr) and plr.Character then
			applyHitboxToCharacter(plr.Character, hbeSize)
		end
	end
	startHitboxLoop()
end

-- KORBLOX SYSTEM
local korbloxEnabled = false

-- RESET WARNING SYSTEM
local resetWarningEnabled = false
local resetWarningFrame = nil
local resetWarningDragging = false
local resetWarningDragStart = nil
local resetWarningStartPos = nil

local function createResetWarningGUI()
	if resetWarningFrame and resetWarningFrame.Parent then return end

	local warnFrame = Instance.new("Frame")
	warnFrame.Name = "ResetWarning"
	warnFrame.Size = UDim2.new(0, 240, 0, 140)
	warnFrame.Position = UDim2.new(1, -260, 0.5, -70)
	warnFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
	warnFrame.BorderSizePixel = 0
	warnFrame.Visible = false
	warnFrame.Parent = gui
	Instance.new("UICorner", warnFrame).CornerRadius = UDim.new(0, 14)

	-- Glow border effect
	local glow = Instance.new("UIStroke")
	glow.Color = Color3.fromRGB(255, 100, 130)
	glow.Thickness = 2
	glow.Transparency = 0.3
	glow.Parent = warnFrame

	-- Drag hint (visual only, entire frame is draggable)
	local dragHint = Instance.new("TextLabel")
	dragHint.Size = UDim2.new(1, 0, 0, 18)
	dragHint.Position = UDim2.new(0, 0, 0, 2)
	dragHint.BackgroundTransparency = 1
	dragHint.Text = "⋯ ⋯ ⋯"
	dragHint.TextColor3 = Color3.fromRGB(255, 200, 210)
	dragHint.Font = Enum.Font.GothamBold
	dragHint.TextSize = 12
	dragHint.Parent = warnFrame

	-- Warning text
	local warnText = Instance.new("TextLabel")
	warnText.Size = UDim2.new(1, 0, 0, 35)
	warnText.Position = UDim2.new(0, 0, 0, 18)
	warnText.BackgroundTransparency = 1
	warnText.Text = "⚠ LOW HEALTH!"
	warnText.TextColor3 = Color3.fromRGB(255, 255, 255)
	warnText.Font = Enum.Font.GothamBold
	warnText.TextSize = 20
	warnText.Parent = warnFrame

	-- Hint text
	local hintText = Instance.new("TextLabel")
	hintText.Size = UDim2.new(1, 0, 0, 25)
	hintText.Position = UDim2.new(0, 0, 0, 58)
	hintText.BackgroundTransparency = 1
	hintText.Text = "Press the button below to reset"
	hintText.TextColor3 = Color3.fromRGB(255, 200, 210)
	hintText.Font = Enum.Font.Gotham
	hintText.TextSize = 12
	hintText.Parent = warnFrame

	-- Reset button
	local resetBtn = Instance.new("TextButton")
	resetBtn.Size = UDim2.new(0.8, 0, 0, 35)
	resetBtn.Position = UDim2.new(0.1, 0, 0, 95)
	resetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	resetBtn.Text = "RESET NOW ♡"
	resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	resetBtn.Font = Enum.Font.GothamBold
	resetBtn.TextSize = 14
	resetBtn.Parent = warnFrame
	Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 10)

	resetBtn.MouseButton1Click:Connect(function()
		if destroyed then return end
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.Health = 0
			end
		end
	end)

	-- Dragging logic (entire frame is draggable)
	warnFrame.InputBegan:Connect(function(input)
		if destroyed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resetWarningDragging = true
			resetWarningDragStart = input.Position
			resetWarningStartPos = warnFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resetWarningDragging = false
				end
			end)
		end
	end)

	table.insert(connections, UIS.InputChanged:Connect(function(input)
		if destroyed then return end
		if resetWarningDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - resetWarningDragStart
			warnFrame.Position = UDim2.new(
				resetWarningStartPos.X.Scale,
				resetWarningStartPos.X.Offset + delta.X,
				resetWarningStartPos.Y.Scale,
				resetWarningStartPos.Y.Offset + delta.Y
			)
		end
	end))

	resetWarningFrame = warnFrame
end

local function hookResetWarningCharacter(char)
	if not resetWarningEnabled then return end
	local hum = char:FindFirstChild("Humanoid")
	if not hum then return end

	-- Hide on spawn
	if resetWarningFrame then
		resetWarningFrame.Visible = false
	end

	hum.HealthChanged:Connect(function(hp)
		if destroyed then return end
		if not resetWarningEnabled then
			if resetWarningFrame then resetWarningFrame.Visible = false end
			return
		end
		if hp <= 10 then
			if resetWarningFrame then resetWarningFrame.Visible = true end
		else
			if resetWarningFrame then resetWarningFrame.Visible = false end
		end
	end)
end

-- Create the GUI upfront (hidden)
createResetWarningGUI()

-- Hook existing character
if player.Character then
	hookResetWarningCharacter(player.Character)
end

-- Hook respawns
table.insert(connections, player.CharacterAdded:Connect(function(char)
	if destroyed then return end
	task.wait(0.5)
	if destroyed then return end
	hookResetWarningCharacter(char)
end))

-- JUMP COOLDOWN BYPASS SYSTEM
local jumpCooldownBypassEnabled = false
local jumpBypassConnection = nil
local jumpRequestConnection = nil

-- HIP HEIGHT SYSTEM
local hipHeightEnabled = false
local currentHipHeight = 0
local hipHeightConnection = nil

-- THEME SYSTEM
local currentTheme = "Pastel Pink"
local themes = {
	["Dark"] = {
		Name = "Dark",
		Background = Color3.fromRGB(22,22,28),
		TopBar = Color3.fromRGB(30,30,40),
		CategoryBg = Color3.fromRGB(28,28,35),
		CategoryBtn = Color3.fromRGB(40,40,55),
		ButtonBg = Color3.fromRGB(35,35,45),
		Accent = Color3.fromRGB(80,120,255),
		Text = Color3.fromRGB(235,235,235),
		SubText = Color3.fromRGB(170,170,170),
		Success = Color3.fromRGB(80,200,120),
		Danger = Color3.fromRGB(255,80,80),
		Warning = Color3.fromRGB(255,200,80)
	},
	["Pink"] = {
		Name = "Pink",
		Background = Color3.fromRGB(35,20,30),
		TopBar = Color3.fromRGB(50,25,40),
		CategoryBg = Color3.fromRGB(40,22,35),
		CategoryBtn = Color3.fromRGB(60,30,50),
		ButtonBg = Color3.fromRGB(55,28,45),
		Accent = Color3.fromRGB(255,105,180),
		Text = Color3.fromRGB(255,255,255),
		SubText = Color3.fromRGB(255,180,200),
		Success = Color3.fromRGB(255,150,200),
		Danger = Color3.fromRGB(255,80,120),
		Warning = Color3.fromRGB(255,200,180)
	},
	["Ocean"] = {
		Name = "Ocean",
		Background = Color3.fromRGB(15,25,35),
		TopBar = Color3.fromRGB(20,40,55),
		CategoryBg = Color3.fromRGB(18,30,42),
		CategoryBtn = Color3.fromRGB(25,50,70),
		ButtonBg = Color3.fromRGB(30,55,75),
		Accent = Color3.fromRGB(0,200,255),
		Text = Color3.fromRGB(230,245,255),
		SubText = Color3.fromRGB(150,200,220),
		Success = Color3.fromRGB(0,255,200),
		Danger = Color3.fromRGB(255,100,100),
		Warning = Color3.fromRGB(100,200,255)
	},
	["Purple"] = {
		Name = "Purple",
		Background = Color3.fromRGB(25,18,35),
		TopBar = Color3.fromRGB(40,25,55),
		CategoryBg = Color3.fromRGB(32,20,45),
		CategoryBtn = Color3.fromRGB(55,30,75),
		ButtonBg = Color3.fromRGB(45,25,60),
		Accent = Color3.fromRGB(180,100,255),
		Text = Color3.fromRGB(245,235,255),
		SubText = Color3.fromRGB(180,160,200),
		Success = Color3.fromRGB(200,100,255),
		Danger = Color3.fromRGB(255,80,150),
		Warning = Color3.fromRGB(255,150,255)
	},
	["Red"] = {
		Name = "Red",
		Background = Color3.fromRGB(35,18,18),
		TopBar = Color3.fromRGB(50,25,25),
		CategoryBg = Color3.fromRGB(40,20,20),
		CategoryBtn = Color3.fromRGB(65,30,30),
		ButtonBg = Color3.fromRGB(55,28,28),
		Accent = Color3.fromRGB(255,80,80),
		Text = Color3.fromRGB(255,240,240),
		SubText = Color3.fromRGB(200,160,160),
		Success = Color3.fromRGB(255,150,100),
		Danger = Color3.fromRGB(255,50,50),
		Warning = Color3.fromRGB(255,180,80)
	},
	["Green"] = {
		Name = "Green",
		Background = Color3.fromRGB(18,28,20),
		TopBar = Color3.fromRGB(25,45,30),
		CategoryBg = Color3.fromRGB(20,35,25),
		CategoryBtn = Color3.fromRGB(30,55,35),
		ButtonBg = Color3.fromRGB(28,50,32),
		Accent = Color3.fromRGB(80,255,120),
		Text = Color3.fromRGB(240,255,245),
		SubText = Color3.fromRGB(160,200,170),
		Success = Color3.fromRGB(100,255,150),
		Danger = Color3.fromRGB(255,100,100),
		Warning = Color3.fromRGB(200,255,100)
	},
	["Monochrome"] = {
		Name = "Monochrome",
		Background = Color3.fromRGB(20,20,20),
		TopBar = Color3.fromRGB(35,35,35),
		CategoryBg = Color3.fromRGB(25,25,25),
		CategoryBtn = Color3.fromRGB(45,45,45),
		ButtonBg = Color3.fromRGB(40,40,40),
		Accent = Color3.fromRGB(200,200,200),
		Text = Color3.fromRGB(255,255,255),
		SubText = Color3.fromRGB(150,150,150),
		Success = Color3.fromRGB(180,180,180),
		Danger = Color3.fromRGB(255,100,100),
		Warning = Color3.fromRGB(220,220,180)
	},
	["Cyberpunk"] = {
		Name = "Cyberpunk",
		Background = Color3.fromRGB(15,15,25),
		TopBar = Color3.fromRGB(25,20,40),
		CategoryBg = Color3.fromRGB(18,18,30),
		CategoryBtn = Color3.fromRGB(35,25,55),
		ButtonBg = Color3.fromRGB(30,25,45),
		Accent = Color3.fromRGB(255,0,255),
		Text = Color3.fromRGB(255,255,255),
		SubText = Color3.fromRGB(0,255,255),
		Success = Color3.fromRGB(0,255,200),
		Danger = Color3.fromRGB(255,50,100),
		Warning = Color3.fromRGB(255,255,0)
	},
	["Light"] = {
		Name = "Light",
		Background = Color3.fromRGB(245,245,250),
		TopBar = Color3.fromRGB(255,255,255),
		CategoryBg = Color3.fromRGB(235,235,245),
		CategoryBtn = Color3.fromRGB(220,220,235),
		ButtonBg = Color3.fromRGB(230,230,240),
		Accent = Color3.fromRGB(80,120,255),
		Text = Color3.fromRGB(30,30,40),
		SubText = Color3.fromRGB(100,100,120),
		Success = Color3.fromRGB(50,180,100),
		Danger = Color3.fromRGB(220,60,60),
		Warning = Color3.fromRGB(200,150,50)
	},
	["Pastel Pink"] = {
		Name = "Pastel Pink",
		Background = Color3.fromRGB(255,240,245),
		TopBar = Color3.fromRGB(255,220,230),
		CategoryBg = Color3.fromRGB(255,235,242),
		CategoryBtn = Color3.fromRGB(255,200,220),
		ButtonBg = Color3.fromRGB(255,225,235),
		Accent = Color3.fromRGB(255,130,170),
		Text = Color3.fromRGB(80,40,60),
		SubText = Color3.fromRGB(150,100,120),
		Success = Color3.fromRGB(150,220,150),
		Danger = Color3.fromRGB(255,120,140),
		Warning = Color3.fromRGB(255,180,120)
	},
	["Pastel Blue"] = {
		Name = "Pastel Blue",
		Background = Color3.fromRGB(235,245,255),
		TopBar = Color3.fromRGB(220,235,255),
		CategoryBg = Color3.fromRGB(240,248,255),
		CategoryBtn = Color3.fromRGB(200,220,250),
		ButtonBg = Color3.fromRGB(225,238,255),
		Accent = Color3.fromRGB(100,150,255),
		Text = Color3.fromRGB(40,50,80),
		SubText = Color3.fromRGB(100,120,160),
		Success = Color3.fromRGB(100,200,150),
		Danger = Color3.fromRGB(255,100,120),
		Warning = Color3.fromRGB(255,180,80)
	},
	["Cream"] = {
		Name = "Cream",
		Background = Color3.fromRGB(255,250,240),
		TopBar = Color3.fromRGB(255,245,230),
		CategoryBg = Color3.fromRGB(255,248,238),
		CategoryBtn = Color3.fromRGB(245,235,220),
		ButtonBg = Color3.fromRGB(250,245,235),
		Accent = Color3.fromRGB(180,130,80),
		Text = Color3.fromRGB(60,50,40),
		SubText = Color3.fromRGB(120,100,80),
		Success = Color3.fromRGB(100,160,100),
		Danger = Color3.fromRGB(200,80,80),
		Warning = Color3.fromRGB(200,150,80)
	},
	["Mint"] = {
		Name = "Mint",
		Background = Color3.fromRGB(235,250,245),
		TopBar = Color3.fromRGB(220,245,235),
		CategoryBg = Color3.fromRGB(240,252,248),
		CategoryBtn = Color3.fromRGB(200,235,220),
		ButtonBg = Color3.fromRGB(225,245,235),
		Accent = Color3.fromRGB(60,180,140),
		Text = Color3.fromRGB(30,60,50),
		SubText = Color3.fromRGB(80,120,100),
		Success = Color3.fromRGB(50,200,120),
		Danger = Color3.fromRGB(200,80,80),
		Warning = Color3.fromRGB(220,160,60)
	}
}

local function applyTheme(themeName)
	local theme = themes[themeName]
	if not theme then return end
	currentTheme = themeName

	-- Apply to main frame
	frame.BackgroundColor3 = theme.Background
	top.BackgroundColor3 = theme.TopBar
	categoriesFrame.BackgroundColor3 = theme.CategoryBg

	-- Apply to scroll frame scrollbar
	scroll.ScrollBarImageColor3 = theme.Accent
	categoriesFrame.ScrollBarImageColor3 = theme.Accent

	-- Apply to title
	title.TextColor3 = theme.Text
	subtitle.TextColor3 = theme.SubText

	-- Apply to buttons
	miniBtn.BackgroundColor3 = theme.Accent
	closeBtn.BackgroundColor3 = theme.Danger

	-- Apply to all category buttons
	for _, child in ipairs(categoriesFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child.BackgroundColor3 = theme.CategoryBtn
			child.TextColor3 = theme.Text
		end
	end

	-- Apply to all buttons in scroll
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then
			child.BackgroundColor3 = theme.ButtonBg
			child.TextColor3 = theme.Text
		elseif child:IsA("TextLabel") then
			child.TextColor3 = theme.Text
		elseif child:IsA("Frame") then
			child.BackgroundColor3 = theme.ButtonBg
		end
	end
end

-- CAMLOCK SYSTEM
local camlockEnabled = false
local camlockLocking = false
local camlockTarget = nil
local camlockKeybind = nil -- No default keybind, player must set their own
local camlockTargetPart = "Head" -- Options: Head, Torso, HumanoidRootPart, Random, LeftLeg, RightLeg
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()
local camlockConnection = nil
local camlockWhitelist = {} -- Table of player names to exclude from Camlock

-- Flame Lock removed per user request

local function isCamlockWhitelisted(plr)
	local name = string.lower(plr.Name)
	local displayName = string.lower(plr.DisplayName)
	for _, whitelistedName in ipairs(camlockWhitelist) do
		if string.lower(whitelistedName) == name or string.lower(whitelistedName) == displayName then
			return true
		end
	end
	return false
end

local targetPartOptions = {"Head", "Torso", "HumanoidRootPart", "Random", "LeftLeg", "RightLeg", "LeftArm", "RightArm"}

local function getTargetPartFromCharacter(character)
	if not character then return nil end

	local targetPartName = camlockTargetPart

	if targetPartName == "Random" then
		local parts = {"Head", "Torso", "HumanoidRootPart", "LeftLeg", "RightLeg", "LeftArm", "RightArm"}
		targetPartName = parts[math.random(1, #parts)]
	end

	-- Map common names to actual part names (R6/R15 compatible)
	local partMap = {
		["Head"] = {"Head"},
		["Torso"] = {"Torso", "UpperTorso", "LowerTorso"},
		["HumanoidRootPart"] = {"HumanoidRootPart"},
		["LeftLeg"] = {"Left Leg", "LeftLeg", "LeftUpperLeg", "LeftLowerLeg"},
		["RightLeg"] = {"Right Leg", "RightLeg", "RightUpperLeg", "RightLowerLeg"},
		["LeftArm"] = {"Left Arm", "LeftArm", "LeftUpperArm", "LeftLowerArm"},
		["RightArm"] = {"Right Arm", "RightArm", "RightUpperArm", "RightLowerArm"}
	}

	local possibleNames = partMap[targetPartName]
	if possibleNames then
		for _, name in ipairs(possibleNames) do
			local part = character:FindFirstChild(name)
			if part and part:IsA("BasePart") then
				return part
			end
		end
	end

	-- Fallback to HumanoidRootPart
	return character:FindFirstChild("HumanoidRootPart")
end

local function getPlayerFromPart(part)
	-- Walk up the hierarchy to find a character
	local current = part
	while current do
		-- Check if this is a player's character
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character == current then
				return plr
			end
		end
		current = current.Parent
	end
	return nil
end

-- Old ESP code removed - using enhanced ESP system above

---------------------------------------------------
-- TELEPORT
---------------------------------------------------
local function teleport(pos)
	if destroyed then return end
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = CFrame.new(pos)
	end
end

-- Function to apply speed
local function applySpeed()
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if speedEnabled then
		hum.WalkSpeed = currentSpeed
	else
		hum.WalkSpeed = defaultSpeed
	end
end

-- Start the anti-reset loop (RenderStepped for maximum reliability)
local function startSpeedLoop()
	if speedRenderConnection then
		speedRenderConnection:Disconnect()
		speedRenderConnection = nil
	end
	
	speedRenderConnection = RunService.RenderStepped:Connect(function()
		if destroyed then return end
		if speedEnabled then
			applySpeed()
		end
	end)
end

-- Stop the anti-reset loop
local function stopSpeedLoop()
	if speedRenderConnection then
		speedRenderConnection:Disconnect()
		speedRenderConnection = nil
	end
end

-- Respawn fix - reapply speed when character respawns
table.insert(connections, player.CharacterAdded:Connect(function()
	if destroyed then return end
	task.wait(1)
	applySpeed()
end))

---------------------------------------------------
-- UI LOGIC
---------------------------------------------------
local function clear()
	for _, v in pairs(scroll:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end
	-- Disconnect slider connections from previous category
	for _, c in ipairs(sliderConnections) do
		pcall(function() c:Disconnect() end)
	end
	sliderConnections = {}
end

local function createButton(text, pos)
	local theme = themes[currentTheme]
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 42)
	btn.BackgroundColor3 = theme.ButtonBg
	btn.Text = text
	btn.TextColor3 = theme.Text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Parent = scroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

	btn.MouseButton1Click:Connect(function()
		if text == "Toggle ESP" then
			toggleESP()
		elseif pos then
			teleport(pos)
		end
	end)
end

---------------------------------------------------
-- SPEED WALK UI (FROM BADGUI)
---------------------------------------------------
-- Old hitbox code removed - using clean rewrite above

-- Global speed slider drag state (for smooth dragging like hitbox expander)
local speedDragging = false
local speedBarRef = nil
local speedFillRef = nil
local speedKnobRef = nil
local speedLabelRef = nil

local function updateSpeedSliderVisual(alpha)
	if speedFillRef then speedFillRef.Size = UDim2.new(alpha,0,1,0) end
	if speedKnobRef then speedKnobRef.Position = UDim2.new(alpha,-12,0,-2) end
	if speedLabelRef then
		local speed = math.floor(8 + 292 * alpha)
		speedLabelRef.Text = speedEnabled and "Speed: ON (" .. speed .. ")" or "Speed: OFF (" .. speed .. ")"
	end
end

-- Global speed keybind handler (defined after speedLabelRef)
table.insert(connections, UIS.InputBegan:Connect(function(input, gpe)
	if destroyed or gpe then return end
	if speedKeybind and input.KeyCode == speedKeybind then
		speedEnabled = not speedEnabled
		-- Update the speed label display when keybind is pressed
		if speedLabelRef and speedLabelRef.Parent then
			speedLabelRef.Text = speedEnabled and "Speed: ON (" .. math.floor(currentSpeed) .. ")" or "Speed: OFF (" .. math.floor(currentSpeed) .. ")"
			speedLabelRef.TextColor3 = speedEnabled and Color3.fromRGB(80,200,120) or Color3.fromRGB(170,170,170)
		end
		-- Update the toggle button color if it exists
		if speedToggleRef and speedToggleRef.Parent then
			speedToggleRef.BackgroundColor3 = speedEnabled and themes[currentTheme].Success or themes[currentTheme].ButtonBg
		end
		if speedEnabled then
			startSpeedLoop()
			applySpeed()
		else
			stopSpeedLoop()
			applySpeed()
		end
	end
end))

local speedToggleRef = nil -- Reference to toggle button for keybind updates

local function loadSpeedWalkCategory()
	clear()
	local theme = themes[currentTheme]

	-- Speed display label (shows ON/OFF status)
	local speedLabel = Instance.new("TextLabel")
	speedLabel.Size = UDim2.new(1,0,0,35)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Text = speedEnabled and "Speed: ON (" .. math.floor(currentSpeed) .. ")" or "Speed: OFF (" .. math.floor(currentSpeed) .. ")"
	speedLabel.TextColor3 = speedEnabled and theme.Success or theme.SubText
	speedLabel.Font = Enum.Font.GothamBold
	speedLabel.TextSize = 18
	speedLabel.Parent = scroll
	speedLabelRef = speedLabel

	-- Spacing
	local space1 = Instance.new("Frame")
	space1.Size = UDim2.new(1,0,0,8)
	space1.BackgroundTransparency = 1
	space1.Parent = scroll

	-- Speed Slider
	local speedBar = Instance.new("Frame")
	speedBar.Size = UDim2.new(1,-20,0,24)
	speedBar.BackgroundColor3 = theme.CategoryBtn
	speedBar.Parent = scroll
	Instance.new("UICorner", speedBar).CornerRadius = UDim.new(0,10)
	speedBarRef = speedBar

	local speedFill = Instance.new("Frame")
	speedFill.Size = UDim2.new((currentSpeed-8)/292,0,1,0)
	speedFill.BackgroundColor3 = theme.Success
	speedFill.Parent = speedBar
	Instance.new("UICorner", speedFill).CornerRadius = UDim.new(0,10)
	speedFillRef = speedFill

	local speedKnob = Instance.new("Frame")
	speedKnob.Size = UDim2.new(0,24,0,24)
	speedKnob.Position = UDim2.new((currentSpeed-8)/292,-12,0,-2)
	speedKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	speedKnob.Parent = speedBar
	Instance.new("UICorner", speedKnob).CornerRadius = UDim.new(0,12)
	speedKnobRef = speedKnob

	local function updateSpeedSlider(x)
		local barX = speedBar.AbsolutePosition.X
		local barW = speedBar.AbsoluteSize.X
		local alpha = math.clamp((x - barX) / barW, 0, 1)
		-- Range: 8 to 300
		currentSpeed = math.floor(8 + 292 * alpha)
		speedFill.Size = UDim2.new(alpha,0,1,0)
		speedKnob.Position = UDim2.new(alpha,-12,0,-2)
		speedLabel.Text = speedEnabled and "Speed: ON (" .. currentSpeed .. ")" or "Speed: OFF (" .. currentSpeed .. ")"
		applySpeed()
	end

	speedKnob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			speedDragging = true
		end
	end)

	speedBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateSpeedSlider(input.Position.X)
			speedDragging = true
		end
	end)

	-- Dedicated drag handling for speed slider (like hitbox sliders)
	local speedDragConn
	speedDragConn = UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if speedDragging and speedBarRef then
				local barX = speedBarRef.AbsolutePosition.X
				local barW = speedBarRef.AbsoluteSize.X
				local alpha = math.clamp((input.Position.X - barX) / barW, 0, 1)
				currentSpeed = math.floor(8 + 292 * alpha)
				updateSpeedSliderVisual(alpha)
				applySpeed()
			end
		end
	end)
	table.insert(sliderConnections, speedDragConn)

	local speedEndConn
	speedEndConn = UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			speedDragging = false
		end
	end)
	table.insert(sliderConnections, speedEndConn)

	-- Spacing
	local space2 = Instance.new("Frame")
	space2.Size = UDim2.new(1,0,0,8)
	space2.BackgroundTransparency = 1
	space2.Parent = scroll

	-- Toggle button
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1,0,0,45)
	toggle.BackgroundColor3 = speedEnabled and theme.Success or theme.ButtonBg
	toggle.Text = "Toggle Speed"
	toggle.TextColor3 = theme.Text
	toggle.Font = Enum.Font.GothamBold
	toggle.TextSize = 16
	toggle.Parent = scroll
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,12)
	speedToggleRef = toggle -- Store reference for keybind updates

	toggle.MouseButton1Click:Connect(function()
		speedEnabled = not speedEnabled
		toggle.BackgroundColor3 = speedEnabled and theme.Success or theme.ButtonBg
		-- Update the speed label to show ON/OFF status
		speedLabel.Text = speedEnabled and "Speed: ON (" .. math.floor(currentSpeed) .. ")" or "Speed: OFF (" .. math.floor(currentSpeed) .. ")"
		speedLabel.TextColor3 = speedEnabled and theme.Success or theme.SubText
		if speedEnabled then
			startSpeedLoop()
			applySpeed()
		else
			stopSpeedLoop()
			applySpeed()
		end
	end)

	-- Spacing
	local space3 = Instance.new("Frame")
	space3.Size = UDim2.new(1,0,0,8)
	space3.BackgroundTransparency = 1
	space3.Parent = scroll

	-- Reset to Default button
	local reset = Instance.new("TextButton")
	reset.Size = UDim2.new(1,0,0,40)
	reset.BackgroundColor3 = theme.Danger
	reset.Text = "Reset to Default (16)"
	reset.TextColor3 = Color3.fromRGB(255,255,255)
	reset.Font = Enum.Font.Gotham
	reset.TextSize = 14
	reset.Parent = scroll
	Instance.new("UICorner", reset).CornerRadius = UDim.new(0,10)

	reset.MouseButton1Click:Connect(function()
		currentSpeed = 16
		speedLabel.Text = "Speed: 16"
		speedFill.Size = UDim2.new((16-8)/292,0,1,0)
		speedKnob.Position = UDim2.new((16-8)/292,-12,0,-2)
		if speedEnabled then
			applySpeed()
		end
	end)

	-- Spacing
	local space4 = Instance.new("Frame")
	space4.Size = UDim2.new(1,0,0,8)
	space4.BackgroundTransparency = 1
	space4.Parent = scroll

	-- Keybind button
	local keybindBtn = Instance.new("TextButton")
	keybindBtn.Size = UDim2.new(1,0,0,40)
	keybindBtn.BackgroundColor3 = theme.ButtonBg
	keybindBtn.Text = speedKeybind and ("Keybind: " .. speedKeybind.Name) or "Keybind: None (click to set)"
	keybindBtn.TextColor3 = theme.Text
	keybindBtn.Font = Enum.Font.Gotham
	keybindBtn.TextSize = 14
	keybindBtn.Parent = scroll
	Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0,10)

	local listening = false
	keybindBtn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		keybindBtn.Text = "Press any key..."
		keybindBtn.BackgroundColor3 = theme.Accent

		local conn
		conn = UIS.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				speedKeybind = input.KeyCode
				keybindBtn.Text = "Keybind: " .. input.KeyCode.Name
				keybindBtn.BackgroundColor3 = theme.ButtonBg
				listening = false
				conn:Disconnect()
			end
		end)
	end)

	-- Spacing
	local space5 = Instance.new("Frame")
	space5.Size = UDim2.new(1,0,0,8)
	space5.BackgroundTransparency = 1
	space5.Parent = scroll

	-- Info label
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,0,0,50)
	info.BackgroundTransparency = 1
	info.Text = "Drag the slider to change speed.\nPress the keybind to toggle on/off.\nDefault keybind: B"
	info.TextColor3 = theme.SubText
	info.Font = Enum.Font.Gotham
	info.TextSize = 12
	info.TextWrapped = true
	info.Parent = scroll

end

---------------------------------------------------
-- HITBOX EXPANDER UI
---------------------------------------------------
local function getRightLeg(char)
	-- R15: RightLeg, R6: Right Leg
	-- Also check for MeshPart versions
	local leg = char:FindFirstChild("RightLeg") 
		or char:FindFirstChild("Right Leg")
		or char:FindFirstChild("RightLowerLeg")
		or char:FindFirstChild("RightUpperLeg")

	-- If we found an upper leg, try to find the lower leg too
	if leg and leg.Name == "RightUpperLeg" then
		local lowerLeg = char:FindFirstChild("RightLowerLeg")
		if lowerLeg then
			lowerLeg.Transparency = 1
		end
		local foot = char:FindFirstChild("RightFoot")
		if foot then
			foot.Transparency = 1
		end
	end

	return leg
end

local function removeKorblox(char)
	if not char then return end
	local existing = char:FindFirstChild("KorbloxLeg")
	if existing then existing:Destroy() end

	-- Restore all right leg parts
	local legParts = {"RightLeg", "Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
	for _, partName in ipairs(legParts) do
		local part = char:FindFirstChild(partName)
		if part then part.Transparency = 0 end
	end
end

local function applyKorblox()
	local char = player.Character
	if not char then 
		return 
	end

	-- Remove existing first
	removeKorblox(char)

	if not korbloxEnabled then 
		return 
	end

	-- Find the Right Leg (works for both R6 and R15)
	local rightLeg = getRightLeg(char)
	if not rightLeg then 
		return 
	end

	-- Hide the original right leg parts
	local legParts = {"RightLeg", "Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
	for _, partName in ipairs(legParts) do
		local part = char:FindFirstChild(partName)
		if part then 
			part.Transparency = 1 
		end
	end

	-- Create custom Korblox-style leg
	local korbloxModel = Instance.new("Model")
	korbloxModel.Name = "KorbloxLeg"
	korbloxModel.Parent = char

	-- Helper function to create a part with proper physics settings
	local function createPart(name, size, color, material)
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.Color = color
		part.Material = material
		part.CanCollide = false
		part.Massless = true
		part.Anchored = false
		part.Transparency = 0
		part.Parent = korbloxModel
		return part
	end

	-- Main leg part (dark grey skeletal look)
	local mainPart = createPart("Main", Vector3.new(1, 2, 1), Color3.fromRGB(50, 50, 60), Enum.Material.SmoothPlastic)

	-- Glowing blue rings (Korblox signature)
	local ringPositions = {0.8, 0.4, 0, -0.4, -0.8}
	local rings = {}
	for i, yPos in ipairs(ringPositions) do
		local ring = createPart("Ring" .. i, Vector3.new(1.15, 0.08, 1.15), Color3.fromRGB(0, 170, 255), Enum.Material.Neon)
		rings[i] = ring
	end

	-- Top and bottom caps
	local topCap = createPart("TopCap", Vector3.new(1.1, 0.15, 1.1), Color3.fromRGB(0, 170, 255), Enum.Material.Neon)
	local bottomCap = createPart("BottomCap", Vector3.new(1.1, 0.15, 1.1), Color3.fromRGB(0, 170, 255), Enum.Material.Neon)

	-- Particle effect
	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255))
	particles.Size = NumberSequence.new(0.1, 0)
	particles.Lifetime = NumberRange.new(0.2, 0.4)
	particles.Rate = 15
	particles.Speed = NumberRange.new(1, 2)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.EmissionDirection = Enum.NormalId.Top
	particles.Parent = mainPart

	-- Create ALL welds FIRST before positioning
	-- Weld main part to right leg
	local mainWeld = Instance.new("WeldConstraint")
	mainWeld.Part0 = rightLeg
	mainWeld.Part1 = mainPart
	mainWeld.Parent = mainPart

	-- Weld rings to main part
	local ringPositions = {0.8, 0.4, 0, -0.4, -0.8}
	for i, ring in ipairs(rings) do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = mainPart
		weld.Part1 = ring
		weld.Parent = ring
		ring.CFrame = mainPart.CFrame * CFrame.new(0, ringPositions[i], 0)
	end

	-- Weld caps to main part
	local topWeld = Instance.new("WeldConstraint")
	topWeld.Part0 = mainPart
	topWeld.Part1 = topCap
	topWeld.Parent = topCap

	local bottomWeld = Instance.new("WeldConstraint")
	bottomWeld.Part0 = mainPart
	bottomWeld.Part1 = bottomCap
	bottomWeld.Parent = bottomCap

	-- NOW position everything (after welds are created)
	mainPart.CFrame = rightLeg.CFrame
	topCap.CFrame = mainPart.CFrame * CFrame.new(0, 1.05, 0)
	bottomCap.CFrame = mainPart.CFrame * CFrame.new(0, -1.05, 0)
end

-- Reapply on character spawn
table.insert(connections, player.CharacterAdded:Connect(function(char)
	if destroyed then return end
	char:WaitForChild("HumanoidRootPart", 5)
	task.wait(0.5)
	if destroyed then return end
	if korbloxEnabled then
		applyKorblox()
	end
end))

-- Apply immediately if character already exists
if player.Character and korbloxEnabled then
	task.wait(0.1)
	applyKorblox()
end

local function loadKorbloxCategory()
	clear()

	-- Toggle button
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1,0,0,40)
	toggle.BackgroundColor3 = korbloxEnabled and Color3.fromRGB(80,120,255) or Color3.fromRGB(35,35,45)
	toggle.Text = korbloxEnabled and "Korblox: ON" or "Korblox: OFF"
	toggle.TextColor3 = Color3.fromRGB(235,235,235)
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 14
	toggle.Parent = scroll
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,12)

	toggle.MouseButton1Click:Connect(function()
		korbloxEnabled = not korbloxEnabled
		toggle.Text = korbloxEnabled and "Korblox: ON" or "Korblox: OFF"
		toggle.BackgroundColor3 = korbloxEnabled and Color3.fromRGB(80,120,255) or Color3.fromRGB(35,35,45)
		if korbloxEnabled then
			applyKorblox()
		else
			removeKorblox(player.Character)
		end
	end)

	-- Info label
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,0,0,60)
	info.BackgroundTransparency = 1
	info.Text = "Client-sided only.\nOnly you can see the Korblox leg."
	info.TextColor3 = Color3.fromRGB(170,170,170)
	info.Font = Enum.Font.Gotham
	info.TextSize = 12
	info.TextWrapped = true
	info.Parent = scroll
end

local function loadHitboxExpanderCategory()
	clear()

	-- Toggle button
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1,0,0,40)
	toggle.BackgroundColor3 = hbeEnabled and Color3.fromRGB(80,120,255) or Color3.fromRGB(35,35,45)
	toggle.Text = hbeEnabled and "Hitbox: ON" or "Hitbox: OFF"
	toggle.TextColor3 = Color3.fromRGB(235,235,235)
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 14
	toggle.Parent = scroll
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,12)

	toggle.MouseButton1Click:Connect(function()
		hbeEnabled = not hbeEnabled
		toggle.Text = hbeEnabled and "Hitbox: ON" or "Hitbox: OFF"
		toggle.BackgroundColor3 = hbeEnabled and Color3.fromRGB(80,120,255) or Color3.fromRGB(35,35,45)
		if hbeEnabled then
			applyHitboxLive()
		else
			resetAllHitboxes()
		end
	end)

	-- Size section
	local sizeLabel = Instance.new("TextLabel")
	sizeLabel.Size = UDim2.new(1,0,0,30)
	sizeLabel.BackgroundTransparency = 1
	sizeLabel.Text = "Size: " .. string.format("%.1f", hbeSize)
	sizeLabel.TextColor3 = Color3.fromRGB(0,170,255)
	sizeLabel.Font = Enum.Font.GothamBold
	sizeLabel.TextSize = 14
	sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
	sizeLabel.Parent = scroll

	local sizeBar = Instance.new("Frame")
	sizeBar.Size = UDim2.new(1,-20,0,22)
	sizeBar.BackgroundColor3 = Color3.fromRGB(60,60,70)
	sizeBar.Parent = scroll
	Instance.new("UICorner", sizeBar).CornerRadius = UDim.new(0,9)

	local sizeFill = Instance.new("Frame")
	sizeFill.Size = UDim2.new((hbeSize-1)/(hbeMaxSize-1),0,1,0)
	sizeFill.BackgroundColor3 = Color3.fromRGB(0,170,255)
	sizeFill.Parent = sizeBar
	Instance.new("UICorner", sizeFill).CornerRadius = UDim.new(0,9)

	local sizeKnob = Instance.new("Frame")
	sizeKnob.Size = UDim2.new(0,22,0,22)
	sizeKnob.Position = UDim2.new((hbeSize-1)/(hbeMaxSize-1),-11,0,-2)
	sizeKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	sizeKnob.Parent = sizeBar
	Instance.new("UICorner", sizeKnob).CornerRadius = UDim.new(0,11)

	local sizeDragging = false
	local function updateSizeSlider(x)
		local barX = sizeBar.AbsolutePosition.X
		local barW = sizeBar.AbsoluteSize.X
		local alpha = math.clamp((x - barX) / barW, 0, 1)
		hbeSize = 1 + (hbeMaxSize - 1) * alpha
		sizeFill.Size = UDim2.new(alpha,0,1,0)
		sizeKnob.Position = UDim2.new(alpha,-11,0,-2)
		sizeLabel.Text = "Size: " .. string.format("%.1f", hbeSize)
		if hbeEnabled then applyHitboxLive() end
	end

	sizeKnob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sizeDragging = true
		end
	end)

	sizeBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateSizeSlider(input.Position.X)
			sizeDragging = true
		end
	end)

	-- Small gap below size slider
	local sizeGap = Instance.new("Frame")
	sizeGap.Size = UDim2.new(1,0,0,4)
	sizeGap.BackgroundTransparency = 1
	sizeGap.Parent = scroll

	-- Spacing between sections
	local spacer = Instance.new("Frame")
	spacer.Size = UDim2.new(1,0,0,10)
	spacer.BackgroundTransparency = 1
	spacer.Parent = scroll

	-- Transparency section
	local transLabel = Instance.new("TextLabel")
	transLabel.Size = UDim2.new(1,0,0,30)
	transLabel.BackgroundTransparency = 1
	transLabel.Text = "Transparency: " .. string.format("%.1f", hbeTransparency)
	transLabel.TextColor3 = Color3.fromRGB(255,124,192)
	transLabel.Font = Enum.Font.GothamBold
	transLabel.TextSize = 14
	transLabel.TextXAlignment = Enum.TextXAlignment.Left
	transLabel.Parent = scroll

	local transBar = Instance.new("Frame")
	transBar.Size = UDim2.new(1,-20,0,22)
	transBar.BackgroundColor3 = Color3.fromRGB(60,60,70)
	transBar.Parent = scroll
	Instance.new("UICorner", transBar).CornerRadius = UDim.new(0,9)

	local transFill = Instance.new("Frame")
	transFill.Size = UDim2.new(hbeTransparency,0,1,0)
	transFill.BackgroundColor3 = Color3.fromRGB(255,124,192)
	transFill.Parent = transBar
	Instance.new("UICorner", transFill).CornerRadius = UDim.new(0,9)

	local transKnob = Instance.new("Frame")
	transKnob.Size = UDim2.new(0,22,0,22)
	transKnob.Position = UDim2.new(hbeTransparency,-11,0,-2)
	transKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	transKnob.Parent = transBar
	Instance.new("UICorner", transKnob).CornerRadius = UDim.new(0,11)

	local transDragging = false
	local function updateTransSlider(x)
		local barX = transBar.AbsolutePosition.X
		local barW = transBar.AbsoluteSize.X
		local alpha = math.clamp((x - barX) / barW, 0, 1)
		hbeTransparency = alpha
		transFill.Size = UDim2.new(alpha,0,1,0)
		transKnob.Position = UDim2.new(alpha,-11,0,-2)
		transLabel.Text = "Transparency: " .. string.format("%.1f", hbeTransparency)
		if hbeEnabled then applyHitboxLive() end
	end

	transKnob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			transDragging = true
		end
	end)

	transBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateTransSlider(input.Position.X)
			transDragging = true
		end
	end)

	-- Global slider drag handling for hitbox sliders only
	local hbeDragConn
	hbeDragConn = UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if sizeDragging then
				updateSizeSlider(input.Position.X)
			elseif transDragging then
				updateTransSlider(input.Position.X)
			end
		end
	end)
	table.insert(sliderConnections, hbeDragConn)

	local hbeEndConn
	hbeEndConn = UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sizeDragging = false
			transDragging = false
		end
	end)
	table.insert(sliderConnections, hbeEndConn)

	-- Reset button
	local resetBtn = Instance.new("TextButton")
	resetBtn.Size = UDim2.new(1,0,0,40)
	resetBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
	resetBtn.Text = "Reset All Hitboxes"
	resetBtn.TextColor3 = Color3.fromRGB(255,255,255)
	resetBtn.Font = Enum.Font.Gotham
	resetBtn.TextSize = 14
	resetBtn.Parent = scroll
	Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,12)

	resetBtn.MouseButton1Click:Connect(function()
		hbeEnabled = false
		hbeSize = 1
		hbeTransparency = 0.5
		toggle.Text = "Hitbox: OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(35,35,45)
		sizeLabel.Text = "Size: 1.0"
		sizeFill.Size = UDim2.new(0,0,1,0)
		sizeKnob.Position = UDim2.new(0,-11,0,-2)
		hbeSize = 1
		transLabel.Text = "Transparency: 0.5"
		transFill.Size = UDim2.new(0.5,0,1,0)
		transKnob.Position = UDim2.new(0.5,-11,0,-2)
		resetAllHitboxes()
	end)

	-- Keybind button
	local keybindBtn = Instance.new("TextButton")
	keybindBtn.Size = UDim2.new(1,0,0,35)
	keybindBtn.BackgroundColor3 = Color3.fromRGB(35,35,45)
	keybindBtn.Text = hbeKeybind and ("Keybind: " .. hbeKeybind.Name) or "Keybind: None (click to set)"
	keybindBtn.TextColor3 = Color3.fromRGB(235,235,235)
	keybindBtn.Font = Enum.Font.Gotham
	keybindBtn.TextSize = 13
	keybindBtn.Parent = scroll
	Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0,10)

	local listening = false
	keybindBtn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		keybindBtn.Text = "Press any key..."
		keybindBtn.BackgroundColor3 = Color3.fromRGB(80,120,255)

		local conn
		conn = UIS.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				hbeKeybind = input.KeyCode
				keybindBtn.Text = "Keybind: " .. input.KeyCode.Name
				keybindBtn.BackgroundColor3 = Color3.fromRGB(35,35,45)
				listening = false
				conn:Disconnect()
			end
		end)
	end)

	-- Spacing
	local wlSpace = Instance.new("Frame")
	wlSpace.Size = UDim2.new(1,0,0,8)
	wlSpace.BackgroundTransparency = 1
	wlSpace.Parent = scroll

	-- Players in Server Section (click to whitelist)
	local playersLabel = Instance.new("TextLabel")
	playersLabel.Size = UDim2.new(1,0,0,25)
	playersLabel.BackgroundTransparency = 1
	playersLabel.Text = "Players in Server (click to whitelist)"
	playersLabel.TextColor3 = Color3.fromRGB(100,200,255)
	playersLabel.Font = Enum.Font.GothamBold
	playersLabel.TextSize = 12
	playersLabel.TextXAlignment = Enum.TextXAlignment.Left
	playersLabel.Parent = scroll

	local hbePlayersScroll = Instance.new("ScrollingFrame")
	hbePlayersScroll.Size = UDim2.new(1,0,0,100)
	hbePlayersScroll.BackgroundColor3 = Color3.fromRGB(35,35,45)
	hbePlayersScroll.ScrollBarThickness = 4
	hbePlayersScroll.Parent = scroll
	Instance.new("UICorner", hbePlayersScroll).CornerRadius = UDim.new(0,8)

	local hbePlayersLayout = Instance.new("UIListLayout", hbePlayersScroll)
	hbePlayersLayout.Padding = UDim.new(0,4)

	local hbeWlScrollRef = nil
	local hbeWlLayoutRef = nil

	local function refreshHBEWhitelistDisplay()
		if not hbeWlScrollRef then return end
		for _, child in ipairs(hbeWlScrollRef:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		for i, name in ipairs(hbeWhitelist) do
			local entry = Instance.new("TextButton")
			entry.Size = UDim2.new(1,-10,0,25)
			entry.BackgroundColor3 = Color3.fromRGB(55,55,65)
			entry.Text = name .. " (click to remove)"
			entry.TextColor3 = Color3.fromRGB(255,150,150)
			entry.Font = Enum.Font.Gotham
			entry.TextSize = 11
			entry.Parent = hbeWlScrollRef
			Instance.new("UICorner", entry).CornerRadius = UDim.new(0,6)
			entry.MouseButton1Click:Connect(function()
				table.remove(hbeWhitelist, i)
				refreshHBEWhitelistDisplay()
				refreshHBEPlayersList()
				if hbeEnabled then applyHitboxLive() end
			end)
		end
		if hbeWlLayoutRef then
			hbeWlScrollRef.CanvasSize = UDim2.new(0,0,0,hbeWlLayoutRef.AbsoluteContentSize.Y + 5)
		end
	end

	local function refreshHBEPlayersList()
		for _, child in ipairs(hbePlayersScroll:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local isWl = false
				for _, wName in ipairs(hbeWhitelist) do
					if string.lower(wName) == string.lower(plr.Name) or string.lower(wName) == string.lower(plr.DisplayName) then
						isWl = true
						break
					end
				end

				local entry = Instance.new("TextButton")
				entry.Size = UDim2.new(1,-10,0,28)
				entry.BackgroundColor3 = isWl and Color3.fromRGB(255,80,80) or Color3.fromRGB(55,55,65)
				entry.Text = plr.DisplayName .. " (@" .. plr.Name .. ")" .. (isWl and " [WHITELISTED]" or "")
				entry.TextColor3 = isWl and Color3.fromRGB(255,200,200) or Color3.fromRGB(255,255,255)
				entry.Font = Enum.Font.Gotham
				entry.TextSize = 11
				entry.Parent = hbePlayersScroll
				Instance.new("UICorner", entry).CornerRadius = UDim.new(0,6)

				entry.MouseButton1Click:Connect(function()
					if isWl then
						for i, wName in ipairs(hbeWhitelist) do
							if string.lower(wName) == string.lower(plr.Name) or string.lower(wName) == string.lower(plr.DisplayName) then
								table.remove(hbeWhitelist, i)
								break
							end
						end
					else
						table.insert(hbeWhitelist, plr.Name)
						-- Reset hitbox for this player if currently expanded
						if plr.Character then
							resetHitboxForCharacter(plr.Character)
						end
					end
					refreshHBEPlayersList()
					refreshHBEWhitelistDisplay()
				end)
			end
		end
		hbePlayersScroll.CanvasSize = UDim2.new(0,0,0,hbePlayersLayout.AbsoluteContentSize.Y + 5)
	end

	refreshHBEPlayersList()

	-- Whitelist display
	local wlLabel = Instance.new("TextLabel")
	wlLabel.Size = UDim2.new(1,0,0,25)
	wlLabel.BackgroundTransparency = 1
	wlLabel.Text = "Whitelisted Players"
	wlLabel.TextColor3 = Color3.fromRGB(255,100,150)
	wlLabel.Font = Enum.Font.GothamBold
	wlLabel.TextSize = 12
	wlLabel.TextXAlignment = Enum.TextXAlignment.Left
	wlLabel.Parent = scroll

	local hbeWlScroll = Instance.new("ScrollingFrame")
	hbeWlScroll.Size = UDim2.new(1,0,0,60)
	hbeWlScroll.BackgroundColor3 = Color3.fromRGB(35,35,45)
	hbeWlScroll.ScrollBarThickness = 4
	hbeWlScroll.Parent = scroll
	Instance.new("UICorner", hbeWlScroll).CornerRadius = UDim.new(0,8)
	hbeWlScrollRef = hbeWlScroll

	local hbeWlLayout = Instance.new("UIListLayout", hbeWlScroll)
	hbeWlLayout.Padding = UDim.new(0,4)
	hbeWlLayoutRef = hbeWlLayout

	refreshHBEWhitelistDisplay()
end

local function stopCamlock()
	if camlockConnection then
		camlockConnection:Disconnect()
		camlockConnection = nil
	end
	camlockLocking = false
	camlockTarget = nil
end

-- Find closest player to mouse cursor on screen (new lock style)
local function findClosestToMouse()
	local closest = nil
	local shortestDist = math.huge

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and not isCamlockWhitelisted(plr) and plr.Character then
			local targetPart = getTargetPartFromCharacter(plr.Character)
			if targetPart then
				local pos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
					if dist < shortestDist then
						shortestDist = dist
						closest = plr
					end
				end
			end
		end
	end
	return closest
end

local function startCamlock()
	if camlockConnection then
		camlockConnection:Disconnect()
	end

	-- Very aggressive smoothing for hitting all shots
	local smoothing = 0.95 -- Almost instant lock

	camlockConnection = RunService.RenderStepped:Connect(function()
		if not camlockEnabled or not camlockLocking then
			return
		end

		-- Validate target still exists
		if not camlockTarget or not camlockTarget.Parent then
			stopCamlock()
			return
		end

		-- Check if target player is whitelisted
		if isCamlockWhitelisted(camlockTarget) then
			stopCamlock()
			return
		end

		local char = camlockTarget.Character
		if not char then
			stopCamlock()
			return
		end

		local targetPart = getTargetPartFromCharacter(char)
		if not targetPart then
			stopCamlock()
			return
		end

		-- Get target position with stronger velocity prediction for hitting moving targets
		local targetPos = targetPart.Position
		local velocity = targetPart.AssemblyLinearVelocity or targetPart.Velocity or Vector3.new(0,0,0)
		-- Stronger prediction to hit shots on moving targets
		local predictedPos = targetPos + (velocity * 0.15)
		
		local cameraPos = camera.CFrame.Position
		local newCFrame = CFrame.new(cameraPos, predictedPos)
		
		-- Direct lock - almost instant for hitting all shots
		camera.CFrame = camera.CFrame:Lerp(newCFrame, smoothing)
	end)
end

local function loadCamlockCategory()
	clear()

	-- ========== CAMLOCK SECTION ==========
	local camlockTitle = Instance.new("TextLabel")
	camlockTitle.Size = UDim2.new(1,0,0,35)
	camlockTitle.BackgroundTransparency = 1
	camlockTitle.Text = "🎯 CAMLOCK"
	camlockTitle.TextColor3 = Color3.fromRGB(80,120,255)
	camlockTitle.Font = Enum.Font.GothamBold
	camlockTitle.TextSize = 18
	camlockTitle.Parent = scroll

	-- Toggle button
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1,0,0,40)
	toggle.BackgroundColor3 = camlockEnabled and Color3.fromRGB(80,120,255) or Color3.fromRGB(35,35,45)
	toggle.Text = camlockEnabled and "Camlock: ON" or "Camlock: OFF"
	toggle.TextColor3 = Color3.fromRGB(235,235,235)
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 14
	toggle.Parent = scroll
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,12)

	toggle.MouseButton1Click:Connect(function()
		camlockEnabled = not camlockEnabled
		toggle.Text = camlockEnabled and "Camlock: ON" or "Camlock: OFF"
		toggle.BackgroundColor3 = camlockEnabled and Color3.fromRGB(80,120,255) or Color3.fromRGB(35,35,45)
		if camlockEnabled then
			local closestPlayer = findClosestToMouse()
			if closestPlayer then
				camlockTarget = closestPlayer
				camlockLocking = true
				startCamlock()
			else
				camlockEnabled = false
				toggle.Text = "Camlock: OFF"
				toggle.BackgroundColor3 = Color3.fromRGB(35,35,45)
			end
		else
			stopCamlock()
		end
	end)

	-- Target Part Selection
	local targetLabel = Instance.new("TextLabel")
	targetLabel.Size = UDim2.new(1,0,0,30)
	targetLabel.BackgroundTransparency = 1
	targetLabel.Text = "Target Part: " .. camlockTargetPart
	targetLabel.TextColor3 = Color3.fromRGB(255,200,80)
	targetLabel.Font = Enum.Font.GothamBold
	targetLabel.TextSize = 14
	targetLabel.TextXAlignment = Enum.TextXAlignment.Left
	targetLabel.Parent = scroll

	-- Part selection buttons (define both frames first)
	local partsFrame = Instance.new("Frame")
	partsFrame.Size = UDim2.new(1,0,0,35)
	partsFrame.BackgroundTransparency = 1
	partsFrame.Parent = scroll

	local partsFrame2 = Instance.new("Frame")
	partsFrame2.Size = UDim2.new(1,0,0,35)
	partsFrame2.BackgroundTransparency = 1
	partsFrame2.Parent = scroll

	-- Helper function to update all button colors
	local function updateButtonColors()
		for _, child in ipairs(partsFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child.BackgroundColor3 = child.Text == camlockTargetPart and Color3.fromRGB(80,120,255) or Color3.fromRGB(45,45,55)
			end
		end
		for _, child in ipairs(partsFrame2:GetChildren()) do
			if child:IsA("TextButton") then
				local isMatch = child.Text == camlockTargetPart or (child.Text == "HumanoidRootPart" and camlockTargetPart == "Root")
				child.BackgroundColor3 = isMatch and Color3.fromRGB(80,120,255) or Color3.fromRGB(45,45,55)
			end
		end
	end

	-- First row: Head, Torso, Random
	local partButtons = {"Head", "Torso", "Random"}
	for i, partName in ipairs(partButtons) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.33,-2,1,0)
		btn.Position = UDim2.new((i-1)/3,0,0,0)
		btn.BackgroundColor3 = camlockTargetPart == partName and Color3.fromRGB(80,120,255) or Color3.fromRGB(45,45,55)
		btn.Text = partName
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 12
		btn.Parent = partsFrame
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

		btn.MouseButton1Click:Connect(function()
			camlockTargetPart = partName
			targetLabel.Text = "Target Part: " .. partName
			updateButtonColors()
		end)
	end

	-- Second row: LeftLeg, RightLeg, Root (HumanoidRootPart)
	local partButtons2 = {"LeftLeg", "RightLeg", "Root"}
	for i, partName in ipairs(partButtons2) do
		local displayName = partName
		if partName == "Root" then displayName = "HumanoidRootPart" end
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.33,-2,1,0)
		btn.Position = UDim2.new((i-1)/3,0,0,0)
		btn.BackgroundColor3 = camlockTargetPart == partName and Color3.fromRGB(80,120,255) or Color3.fromRGB(45,45,55)
		btn.Text = displayName
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 12
		btn.Parent = partsFrame2
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

		btn.MouseButton1Click:Connect(function()
			camlockTargetPart = partName
			targetLabel.Text = "Target Part: " .. partName
			updateButtonColors()
		end)
	end

	-- Keybind button
	local keybindBtn = Instance.new("TextButton")
	keybindBtn.Size = UDim2.new(1,0,0,40)
	keybindBtn.BackgroundColor3 = Color3.fromRGB(35,35,45)
	keybindBtn.Text = camlockKeybind and ("Keybind: " .. camlockKeybind.Name) or "Keybind: None (click to set)"
	keybindBtn.TextColor3 = Color3.fromRGB(235,235,235)
	keybindBtn.Font = Enum.Font.Gotham
	keybindBtn.TextSize = 14
	keybindBtn.Parent = scroll
	Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0,12)

	local listening = false
	keybindBtn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		keybindBtn.Text = "Press any key..."
		keybindBtn.BackgroundColor3 = Color3.fromRGB(80,120,255)

		local conn
		conn = UIS.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				camlockKeybind = input.KeyCode
				keybindBtn.Text = "Keybind: " .. input.KeyCode.Name
				keybindBtn.BackgroundColor3 = Color3.fromRGB(35,35,45)
				listening = false
				conn:Disconnect()
			end
		end)
	end)

	-- Status label
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1,0,0,30)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = camlockLocking and "Status: Locked on target" or "Status: Not locked"
	statusLabel.TextColor3 = Color3.fromRGB(170,170,170)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 12
	statusLabel.Parent = scroll

	-- Info label
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,0,0,60)
	info.BackgroundTransparency = 1
	info.Text = "Toggle camlock to lock onto nearest player.\nWhitelisted players will be skipped."
	info.TextColor3 = Color3.fromRGB(170,170,170)
	info.Font = Enum.Font.Gotham
	info.TextSize = 12
	info.TextWrapped = true
	info.Parent = scroll

	-- Spacing
	local wlSpace = Instance.new("Frame")
	wlSpace.Size = UDim2.new(1,0,0,8)
	wlSpace.BackgroundTransparency = 1
	wlSpace.Parent = scroll

	-- Players in Server Section (click to whitelist)
	local playersLabel = Instance.new("TextLabel")
	playersLabel.Size = UDim2.new(1,0,0,25)
	playersLabel.BackgroundTransparency = 1
	playersLabel.Text = "Players in Server (click to whitelist)"
	playersLabel.TextColor3 = Color3.fromRGB(100,200,255)
	playersLabel.Font = Enum.Font.GothamBold
	playersLabel.TextSize = 12
	playersLabel.TextXAlignment = Enum.TextXAlignment.Left
	playersLabel.Parent = scroll

	local playersScroll = Instance.new("ScrollingFrame")
	playersScroll.Size = UDim2.new(1,0,0,100)
	playersScroll.BackgroundColor3 = Color3.fromRGB(35,35,45)
	playersScroll.ScrollBarThickness = 4
	playersScroll.Parent = scroll
	Instance.new("UICorner", playersScroll).CornerRadius = UDim.new(0,8)

	local playersLayout = Instance.new("UIListLayout", playersScroll)
	playersLayout.Padding = UDim.new(0,4)

	local camlockWlScrollRef = nil
	local camlockWlLayoutRef = nil

	local function refreshCamlockWhitelistDisplay()
		if not camlockWlScrollRef then return end
		for _, child in ipairs(camlockWlScrollRef:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		for i, name in ipairs(camlockWhitelist) do
			local entry = Instance.new("TextButton")
			entry.Size = UDim2.new(1,-10,0,25)
			entry.BackgroundColor3 = Color3.fromRGB(55,55,65)
			entry.Text = name .. " (click to remove)"
			entry.TextColor3 = Color3.fromRGB(255,150,150)
			entry.Font = Enum.Font.Gotham
			entry.TextSize = 11
			entry.Parent = camlockWlScrollRef
			Instance.new("UICorner", entry).CornerRadius = UDim.new(0,6)
			entry.MouseButton1Click:Connect(function()
				table.remove(camlockWhitelist, i)
				refreshCamlockWhitelistDisplay()
				refreshCamlockPlayersList()
			end)
		end
		if camlockWlLayoutRef then
			camlockWlScrollRef.CanvasSize = UDim2.new(0,0,0,camlockWlLayoutRef.AbsoluteContentSize.Y + 5)
		end
	end

	local function refreshCamlockPlayersList()
		for _, child in ipairs(playersScroll:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local isWl = false
				for _, wName in ipairs(camlockWhitelist) do
					if string.lower(wName) == string.lower(plr.Name) or string.lower(wName) == string.lower(plr.DisplayName) then
						isWl = true
						break
					end
				end

				local entry = Instance.new("TextButton")
				entry.Size = UDim2.new(1,-10,0,28)
				entry.BackgroundColor3 = isWl and Color3.fromRGB(255,80,80) or Color3.fromRGB(55,55,65)
				entry.Text = plr.DisplayName .. " (@" .. plr.Name .. ")" .. (isWl and " [WHITELISTED]" or "")
				entry.TextColor3 = isWl and Color3.fromRGB(255,200,200) or Color3.fromRGB(255,255,255)
				entry.Font = Enum.Font.Gotham
				entry.TextSize = 11
				entry.Parent = playersScroll
				Instance.new("UICorner", entry).CornerRadius = UDim.new(0,6)

				entry.MouseButton1Click:Connect(function()
					if isWl then
						for i, wName in ipairs(camlockWhitelist) do
							if string.lower(wName) == string.lower(plr.Name) or string.lower(wName) == string.lower(plr.DisplayName) then
								table.remove(camlockWhitelist, i)
								break
							end
						end
					else
						table.insert(camlockWhitelist, plr.Name)
						if camlockLocking and camlockTarget and camlockTarget == plr then
							stopCamlock()
							camlockEnabled = false
							toggle.Text = "Camlock: OFF"
							toggle.BackgroundColor3 = Color3.fromRGB(35,35,45)
						end
					end
					refreshCamlockPlayersList()
					refreshCamlockWhitelistDisplay()
				end)
			end
		end
		playersScroll.CanvasSize = UDim2.new(0,0,0,playersLayout.AbsoluteContentSize.Y + 5)
	end

	refreshCamlockPlayersList()

	-- Whitelist display
	local wlLabel = Instance.new("TextLabel")
	wlLabel.Size = UDim2.new(1,0,0,25)
	wlLabel.BackgroundTransparency = 1
	wlLabel.Text = "Whitelisted Players"
	wlLabel.TextColor3 = Color3.fromRGB(255,100,150)
	wlLabel.Font = Enum.Font.GothamBold
	wlLabel.TextSize = 12
	wlLabel.TextXAlignment = Enum.TextXAlignment.Left
	wlLabel.Parent = scroll

	local camlockWlScroll = Instance.new("ScrollingFrame")
	camlockWlScroll.Size = UDim2.new(1,0,0,60)
	camlockWlScroll.BackgroundColor3 = Color3.fromRGB(35,35,45)
	camlockWlScroll.ScrollBarThickness = 4
	camlockWlScroll.Parent = scroll
	Instance.new("UICorner", camlockWlScroll).CornerRadius = UDim.new(0,8)
	camlockWlScrollRef = camlockWlScroll

	local camlockWlLayout = Instance.new("UIListLayout", camlockWlScroll)
	camlockWlLayout.Padding = UDim.new(0,4)
	camlockWlLayoutRef = camlockWlLayout

	refreshCamlockWhitelistDisplay()
end

local function loadVisualsCategory()
	clear()
	local theme = themes[currentTheme]

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,0,0,40)
	title.BackgroundTransparency = 1
	title.Text = "Select a Theme"
	title.TextColor3 = theme.Accent
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Parent = scroll

	-- Theme buttons
	local themeNames = {"Dark", "Pink", "Ocean", "Purple", "Red", "Green", "Monochrome", "Cyberpunk", "Light", "Pastel Pink", "Pastel Blue", "Cream", "Mint"}
	local themeColors = {
		Dark = Color3.fromRGB(80,120,255),
		Pink = Color3.fromRGB(255,105,180),
		Ocean = Color3.fromRGB(0,200,255),
		Purple = Color3.fromRGB(180,100,255),
		Red = Color3.fromRGB(255,80,80),
		Green = Color3.fromRGB(80,255,120),
		Monochrome = Color3.fromRGB(200,200,200),
		Cyberpunk = Color3.fromRGB(255,0,255),
		Light = Color3.fromRGB(80,120,255),
		["Pastel Pink"] = Color3.fromRGB(255,130,170),
		["Pastel Blue"] = Color3.fromRGB(100,150,255),
		Cream = Color3.fromRGB(180,130,80),
		Mint = Color3.fromRGB(60,180,140)
	}

	for _, themeName in ipairs(themeNames) do
		local theme = themes[themeName]
		local isSelected = currentTheme == themeName

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,45)
		btn.BackgroundColor3 = isSelected and theme.Accent or theme.ButtonBg
		btn.Text = themeName .. (isSelected and " ✓" or "")
		btn.TextColor3 = isSelected and Color3.fromRGB(255,255,255) or theme.Text
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.Parent = scroll
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

		-- Color preview bar
		local previewBar = Instance.new("Frame")
		previewBar.Size = UDim2.new(1,-20,0,6)
		previewBar.Position = UDim2.new(0,10,1,-10)
		previewBar.BackgroundColor3 = themeColors[themeName]
		previewBar.Parent = btn
		Instance.new("UICorner", previewBar).CornerRadius = UDim.new(0,3)

		btn.MouseButton1Click:Connect(function()
			applyTheme(themeName)
			loadVisualsCategory() -- Refresh to show selection
		end)
	end

	-- Info
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,0,0,50)
	info.BackgroundTransparency = 1
	info.Text = "Click a theme to apply it.\nChanges the entire GUI color scheme."
	info.TextColor3 = themes[currentTheme].SubText
	info.Font = Enum.Font.Gotham
	info.TextSize = 12
	info.TextWrapped = true
	info.Parent = scroll
end

local function loadESPCategory()
	clear()

	-- Toggle button
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1,0,0,40)
	toggle.BackgroundColor3 = espEnabled and Color3.fromRGB(80,120,255) or Color3.fromRGB(35,35,45)
	toggle.Text = espEnabled and "ESP: ON" or "ESP: OFF"
	toggle.TextColor3 = Color3.fromRGB(235,235,235)
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 14
	toggle.Parent = scroll
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,12)

	toggle.MouseButton1Click:Connect(function()
		espEnabled = not espEnabled
		toggle.Text = espEnabled and "ESP: ON" or "ESP: OFF"
		toggle.BackgroundColor3 = espEnabled and Color3.fromRGB(80,120,255) or Color3.fromRGB(35,35,45)
		if espEnabled then
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= player and not isWhitelisted(p) then
					createESPForPlayer(p)
				end
			end
		else
			clearAllESP()
		end
	end)

	-- Display Names Toggle
	local displayToggle = Instance.new("TextButton")
	displayToggle.Size = UDim2.new(1,0,0,35)
	displayToggle.BackgroundColor3 = espShowDisplayNames and Color3.fromRGB(80,200,120) or Color3.fromRGB(45,45,55)
	displayToggle.Text = "Display Names: " .. (espShowDisplayNames and "ON" or "OFF")
	displayToggle.TextColor3 = Color3.fromRGB(255,255,255)
	displayToggle.Font = Enum.Font.Gotham
	displayToggle.TextSize = 13
	displayToggle.Parent = scroll
	Instance.new("UICorner", displayToggle).CornerRadius = UDim.new(0,10)

	displayToggle.MouseButton1Click:Connect(function()
		espShowDisplayNames = not espShowDisplayNames
		displayToggle.Text = "Display Names: " .. (espShowDisplayNames and "ON" or "OFF")
		displayToggle.BackgroundColor3 = espShowDisplayNames and Color3.fromRGB(80,200,120) or Color3.fromRGB(45,45,55)
	end)

	-- Health Toggle
	local healthToggle = Instance.new("TextButton")
	healthToggle.Size = UDim2.new(1,0,0,35)
	healthToggle.BackgroundColor3 = espShowHealth and Color3.fromRGB(255,100,100) or Color3.fromRGB(45,45,55)
	healthToggle.Text = "Show Health: " .. (espShowHealth and "ON" or "OFF")
	healthToggle.TextColor3 = Color3.fromRGB(255,255,255)
	healthToggle.Font = Enum.Font.Gotham
	healthToggle.TextSize = 13
	healthToggle.Parent = scroll
	Instance.new("UICorner", healthToggle).CornerRadius = UDim.new(0,10)

	healthToggle.MouseButton1Click:Connect(function()
		espShowHealth = not espShowHealth
		healthToggle.Text = "Show Health: " .. (espShowHealth and "ON" or "OFF")
		healthToggle.BackgroundColor3 = espShowHealth and Color3.fromRGB(255,100,100) or Color3.fromRGB(45,45,55)
	end)

	-- Distance Toggle
	local distToggle = Instance.new("TextButton")
	distToggle.Size = UDim2.new(1,0,0,35)
	distToggle.BackgroundColor3 = espShowDistance and Color3.fromRGB(100,200,255) or Color3.fromRGB(45,45,55)
	distToggle.Text = "Show Distance: " .. (espShowDistance and "ON" or "OFF")
	distToggle.TextColor3 = Color3.fromRGB(255,255,255)
	distToggle.Font = Enum.Font.Gotham
	distToggle.TextSize = 13
	distToggle.Parent = scroll
	Instance.new("UICorner", distToggle).CornerRadius = UDim.new(0,10)

	distToggle.MouseButton1Click:Connect(function()
		espShowDistance = not espShowDistance
		distToggle.Text = "Show Distance: " .. (espShowDistance and "ON" or "OFF")
		distToggle.BackgroundColor3 = espShowDistance and Color3.fromRGB(100,200,255) or Color3.fromRGB(45,45,55)
	end)

	-- Player Outlines Toggle (separate from main ESP)
	local outlineToggle = Instance.new("TextButton")
	outlineToggle.Size = UDim2.new(1,0,0,35)
	outlineToggle.BackgroundColor3 = espShowOutlines and Color3.fromRGB(255,150,50) or Color3.fromRGB(45,45,55)
	outlineToggle.Text = "Player Outlines: " .. (espShowOutlines and "ON" or "OFF")
	outlineToggle.TextColor3 = Color3.fromRGB(255,255,255)
	outlineToggle.Font = Enum.Font.Gotham
	outlineToggle.TextSize = 13
	outlineToggle.Parent = scroll
	Instance.new("UICorner", outlineToggle).CornerRadius = UDim.new(0,10)

	outlineToggle.MouseButton1Click:Connect(function()
		espShowOutlines = not espShowOutlines
		outlineToggle.Text = "Player Outlines: " .. (espShowOutlines and "ON" or "OFF")
		outlineToggle.BackgroundColor3 = espShowOutlines and Color3.fromRGB(255,150,50) or Color3.fromRGB(45,45,55)
		-- Update all existing highlights
		for plr, obj in pairs(espObjects) do
			if obj.highlights then
				for _, hl in ipairs(obj.highlights) do
					hl.Enabled = espShowOutlines
				end
			end
		end
	end)

	-- Text Color Section
	local colorLabel = Instance.new("TextLabel")
	colorLabel.Size = UDim2.new(1,0,0,25)
	colorLabel.BackgroundTransparency = 1
	colorLabel.Text = "Text Color"
	colorLabel.TextColor3 = Color3.fromRGB(255,200,100)
	colorLabel.Font = Enum.Font.GothamBold
	colorLabel.TextSize = 13
	colorLabel.TextXAlignment = Enum.TextXAlignment.Left
	colorLabel.Parent = scroll

	-- Color presets
	local colorPresets = {
		{Name = "White", Color = Color3.fromRGB(255,255,255)},
		{Name = "Pink", Color = Color3.fromRGB(255,105,180)},
		{Name = "Cyan", Color = Color3.fromRGB(0,255,255)},
		{Name = "Yellow", Color = Color3.fromRGB(255,255,0)},
		{Name = "Green", Color = Color3.fromRGB(0,255,128)},
		{Name = "Purple", Color = Color3.fromRGB(200,100,255)}
	}

	local colorFrame = Instance.new("Frame")
	colorFrame.Size = UDim2.new(1,0,0,30)
	colorFrame.BackgroundTransparency = 1
	colorFrame.Parent = scroll

	for i, preset in ipairs(colorPresets) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.16,-2,1,0)
		btn.Position = UDim2.new((i-1)/6,0,0,0)
		btn.BackgroundColor3 = preset.Color
		btn.Text = ""
		btn.Parent = colorFrame
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

		btn.MouseButton1Click:Connect(function()
			espTextColor = preset.Color
		end)
	end

	-- Highlight/Outline Color Section
	local hlColorLabel = Instance.new("TextLabel")
	hlColorLabel.Size = UDim2.new(1,0,0,25)
	hlColorLabel.BackgroundTransparency = 1
	hlColorLabel.Text = "Outline Color"
	hlColorLabel.TextColor3 = Color3.fromRGB(255,150,100)
	hlColorLabel.Font = Enum.Font.GothamBold
	hlColorLabel.TextSize = 13
	hlColorLabel.TextXAlignment = Enum.TextXAlignment.Left
	hlColorLabel.Parent = scroll

	local hlColorFrame = Instance.new("Frame")
	hlColorFrame.Size = UDim2.new(1,0,0,30)
	hlColorFrame.BackgroundTransparency = 1
	hlColorFrame.Parent = scroll

	for i, preset in ipairs(colorPresets) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.16,-2,1,0)
		btn.Position = UDim2.new((i-1)/6,0,0,0)
		btn.BackgroundColor3 = preset.Color
		btn.Text = ""
		btn.Parent = hlColorFrame
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

		btn.MouseButton1Click:Connect(function()
			espColor = preset.Color
			-- Update all existing highlights
			for plr, obj in pairs(espObjects) do
				if obj.highlights then
					for _, hl in ipairs(obj.highlights) do
						hl.FillColor = espColor
						hl.OutlineColor = espColor
					end
				end
			end
		end)
	end

	-- Players in Server Section (click to whitelist)
	local playersLabel = Instance.new("TextLabel")
	playersLabel.Size = UDim2.new(1,0,0,25)
	playersLabel.BackgroundTransparency = 1
	playersLabel.Text = "Players in Server (click to whitelist)"
	playersLabel.TextColor3 = Color3.fromRGB(100,200,255)
	playersLabel.Font = Enum.Font.GothamBold
	playersLabel.TextSize = 12
	playersLabel.TextXAlignment = Enum.TextXAlignment.Left
	playersLabel.Parent = scroll

	local playersScroll = Instance.new("ScrollingFrame")
	playersScroll.Size = UDim2.new(1,0,0,100)
	playersScroll.BackgroundColor3 = Color3.fromRGB(35,35,45)
	playersScroll.ScrollBarThickness = 4
	playersScroll.Parent = scroll
	Instance.new("UICorner", playersScroll).CornerRadius = UDim.new(0,8)

	local playersLayout = Instance.new("UIListLayout", playersScroll)
	playersLayout.Padding = UDim.new(0,4)

	local function refreshPlayersList()
		for _, child in ipairs(playersScroll:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local isWhitelisted = false
				for _, wName in ipairs(espWhitelist) do
					if string.lower(wName) == string.lower(plr.Name) or string.lower(wName) == string.lower(plr.DisplayName) then
						isWhitelisted = true
						break
					end
				end

				local entry = Instance.new("TextButton")
				entry.Size = UDim2.new(1,-10,0,28)
				entry.BackgroundColor3 = isWhitelisted and Color3.fromRGB(255,80,80) or Color3.fromRGB(55,55,65)
				entry.Text = plr.DisplayName .. " (@" .. plr.Name .. ")" .. (isWhitelisted and " [WHITELISTED]" or "")
				entry.TextColor3 = isWhitelisted and Color3.fromRGB(255,200,200) or Color3.fromRGB(255,255,255)
				entry.Font = Enum.Font.Gotham
				entry.TextSize = 11
				entry.Parent = playersScroll
				Instance.new("UICorner", entry).CornerRadius = UDim.new(0,6)

				entry.MouseButton1Click:Connect(function()
					if isWhitelisted then
						-- Remove from whitelist
						for i, wName in ipairs(espWhitelist) do
							if string.lower(wName) == string.lower(plr.Name) or string.lower(wName) == string.lower(plr.DisplayName) then
								table.remove(espWhitelist, i)
								break
							end
						end
						-- Re-add ESP
						if espEnabled then
							createESPForPlayer(plr)
						end
					else
						-- Add to whitelist
						table.insert(espWhitelist, plr.Name)
						removeESPForPlayer(plr)
					end
					refreshPlayersList()
				end)
			end
		end
		playersScroll.CanvasSize = UDim2.new(0,0,0,playersLayout.AbsoluteContentSize.Y + 5)
	end

	refreshPlayersList()

	-- Whitelist display
	local whitelistLabel = Instance.new("TextLabel")
	whitelistLabel.Size = UDim2.new(1,0,0,25)
	whitelistLabel.BackgroundTransparency = 1
	whitelistLabel.Text = "Whitelisted Players"
	whitelistLabel.TextColor3 = Color3.fromRGB(255,100,150)
	whitelistLabel.Font = Enum.Font.GothamBold
	whitelistLabel.TextSize = 12
	whitelistLabel.TextXAlignment = Enum.TextXAlignment.Left
	whitelistLabel.Parent = scroll

	local whitelistScroll = Instance.new("ScrollingFrame")
	whitelistScroll.Size = UDim2.new(1,0,0,60)
	whitelistScroll.BackgroundColor3 = Color3.fromRGB(35,35,45)
	whitelistScroll.ScrollBarThickness = 4
	whitelistScroll.Parent = scroll
	Instance.new("UICorner", whitelistScroll).CornerRadius = UDim.new(0,8)

	local whitelistLayout = Instance.new("UIListLayout", whitelistScroll)
	whitelistLayout.Padding = UDim.new(0,4)

	local function refreshWhitelistDisplay()
		for _, child in ipairs(whitelistScroll:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		for i, name in ipairs(espWhitelist) do
			local entry = Instance.new("TextButton")
			entry.Size = UDim2.new(1,-10,0,25)
			entry.BackgroundColor3 = Color3.fromRGB(55,55,65)
			entry.Text = name .. " (click to remove)"
			entry.TextColor3 = Color3.fromRGB(255,150,150)
			entry.Font = Enum.Font.Gotham
			entry.TextSize = 11
			entry.Parent = whitelistScroll
			Instance.new("UICorner", entry).CornerRadius = UDim.new(0,6)

			entry.MouseButton1Click:Connect(function()
				table.remove(espWhitelist, i)
				refreshWhitelistDisplay()
				refreshPlayersList()
				-- Re-add ESP if player is in game
				for _, plr in pairs(Players:GetPlayers()) do
					if string.lower(plr.Name) == string.lower(name) or string.lower(plr.DisplayName) == string.lower(name) then
						if espEnabled then
							createESPForPlayer(plr)
						end
					end
				end
			end)
		end
		whitelistScroll.CanvasSize = UDim2.new(0,0,0,whitelistLayout.AbsoluteContentSize.Y + 5)
	end

	refreshWhitelistDisplay()

	-- Keybind button
	local keybindBtn = Instance.new("TextButton")
	keybindBtn.Size = UDim2.new(1,0,0,35)
	keybindBtn.BackgroundColor3 = Color3.fromRGB(35,35,45)
	keybindBtn.Text = espKeybind and ("Keybind: " .. espKeybind.Name) or "Keybind: None (click to set)"
	keybindBtn.TextColor3 = Color3.fromRGB(235,235,235)
	keybindBtn.Font = Enum.Font.Gotham
	keybindBtn.TextSize = 13
	keybindBtn.Parent = scroll
	Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0,10)

	local listening = false
	keybindBtn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		keybindBtn.Text = "Press any key..."
		keybindBtn.BackgroundColor3 = Color3.fromRGB(80,120,255)

		local conn
		conn = UIS.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				espKeybind = input.KeyCode
				keybindBtn.Text = "Keybind: " .. input.KeyCode.Name
				keybindBtn.BackgroundColor3 = Color3.fromRGB(35,35,45)
				listening = false
				conn:Disconnect()
			end
		end)
	end)

	-- Info
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,0,0,40)
	info.BackgroundTransparency = 1
	info.Text = espKeybind and ("Press " .. espKeybind.Name .. " to toggle ESP") or "Click toggle button to turn ESP on/off"
	info.Text = info.Text .. "\nWhitelisted players won't show ESP"
	info.TextColor3 = Color3.fromRGB(150,150,150)
	info.Font = Enum.Font.Gotham
	info.TextSize = 11
	info.TextWrapped = true
	info.Parent = scroll
end

-- LIGHTNING SYSTEM
-- Store the ACTUAL default lighting when script starts
local defaultLighting = {
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ColorShift_Bottom = Lighting.ColorShift_Bottom,
	ColorShift_Top = Lighting.ColorShift_Top,
	FogColor = Lighting.FogColor,
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart,
	Brightness = Lighting.Brightness,
	GlobalShadows = Lighting.GlobalShadows,
	ClockTime = Lighting.ClockTime,
	GeographicLatitude = Lighting.GeographicLatitude
}

local lightningPresets = {
	{
		Name = "Default",
		Ambient = defaultLighting.Ambient,
		OutdoorAmbient = defaultLighting.OutdoorAmbient,
		ColorShift_Bottom = defaultLighting.ColorShift_Bottom,
		ColorShift_Top = defaultLighting.ColorShift_Top,
		FogColor = defaultLighting.FogColor,
		FogEnd = defaultLighting.FogEnd,
		Brightness = defaultLighting.Brightness,
		GlobalShadows = defaultLighting.GlobalShadows
	},
	{
		Name = "Wall See",
		Ambient = Color3.fromRGB(255, 255, 255),
		OutdoorAmbient = Color3.fromRGB(255, 255, 255),
		ColorShift_Bottom = Color3.fromRGB(255, 255, 255),
		ColorShift_Top = Color3.fromRGB(255, 255, 255),
		FogColor = Color3.fromRGB(255, 255, 255),
		FogEnd = 1000000,
		Brightness = 5,
		GlobalShadows = false -- No shadows, see everything clearly!
	},
	{
		Name = "Pink Paradise",
		Ambient = Color3.fromRGB(255, 105, 180),
		OutdoorAmbient = Color3.fromRGB(255, 150, 200),
		ColorShift_Bottom = Color3.fromRGB(255, 50, 100),
		ColorShift_Top = Color3.fromRGB(255, 182, 193),
		FogColor = Color3.fromRGB(255, 182, 193),
		FogEnd = 500,
		Brightness = 1.5
	},
	{
		Name = "Ocean Blue",
		Ambient = Color3.fromRGB(0, 150, 255),
		OutdoorAmbient = Color3.fromRGB(50, 200, 255),
		ColorShift_Bottom = Color3.fromRGB(0, 100, 200),
		ColorShift_Top = Color3.fromRGB(100, 200, 255),
		FogColor = Color3.fromRGB(0, 150, 255),
		FogEnd = 300,
		Brightness = 1.8
	},
	{
		Name = "Purple Galaxy",
		Ambient = Color3.fromRGB(150, 50, 255),
		OutdoorAmbient = Color3.fromRGB(180, 100, 255),
		ColorShift_Bottom = Color3.fromRGB(100, 0, 200),
		ColorShift_Top = Color3.fromRGB(200, 100, 255),
		FogColor = Color3.fromRGB(120, 50, 200),
		FogEnd = 400,
		Brightness = 1.2
	},
	{
		Name = "Red Hellfire",
		Ambient = Color3.fromRGB(255, 50, 50),
		OutdoorAmbient = Color3.fromRGB(255, 100, 50),
		ColorShift_Bottom = Color3.fromRGB(200, 0, 0),
		ColorShift_Top = Color3.fromRGB(255, 100, 0),
		FogColor = Color3.fromRGB(255, 50, 0),
		FogEnd = 200,
		Brightness = 1
	},
	{
		Name = "Green Forest",
		Ambient = Color3.fromRGB(50, 200, 50),
		OutdoorAmbient = Color3.fromRGB(100, 255, 100),
		ColorShift_Bottom = Color3.fromRGB(0, 100, 0),
		ColorShift_Top = Color3.fromRGB(150, 255, 150),
		FogColor = Color3.fromRGB(100, 200, 100),
		FogEnd = 600,
		Brightness = 2
	},
	{
		Name = "Cyberpunk Neon",
		Ambient = Color3.fromRGB(255, 0, 255),
		OutdoorAmbient = Color3.fromRGB(0, 255, 255),
		ColorShift_Bottom = Color3.fromRGB(255, 0, 128),
		ColorShift_Top = Color3.fromRGB(0, 255, 200),
		FogColor = Color3.fromRGB(200, 50, 255),
		FogEnd = 250,
		Brightness = 1.5
	},
	{
		Name = "Golden Hour",
		Ambient = Color3.fromRGB(255, 200, 100),
		OutdoorAmbient = Color3.fromRGB(255, 220, 150),
		ColorShift_Bottom = Color3.fromRGB(255, 150, 50),
		ColorShift_Top = Color3.fromRGB(255, 230, 180),
		FogColor = Color3.fromRGB(255, 200, 100),
		FogEnd = 800,
		Brightness = 2.5
	},
	{
		Name = "Midnight Blue",
		Ambient = Color3.fromRGB(20, 30, 60),
		OutdoorAmbient = Color3.fromRGB(30, 50, 100),
		ColorShift_Bottom = Color3.fromRGB(10, 20, 50),
		ColorShift_Top = Color3.fromRGB(50, 80, 150),
		FogColor = Color3.fromRGB(20, 40, 80),
		FogEnd = 300,
		Brightness = 0.5
	},
	{
		Name = "Candy Pink",
		Ambient = Color3.fromRGB(255, 150, 200),
		OutdoorAmbient = Color3.fromRGB(255, 180, 220),
		ColorShift_Bottom = Color3.fromRGB(255, 100, 150),
		ColorShift_Top = Color3.fromRGB(255, 200, 230),
		FogColor = Color3.fromRGB(255, 170, 200),
		FogEnd = 500,
		Brightness = 2
	},
	{
		Name = "Toxic Green",
		Ambient = Color3.fromRGB(100, 255, 100),
		OutdoorAmbient = Color3.fromRGB(150, 255, 150),
		ColorShift_Bottom = Color3.fromRGB(50, 200, 50),
		ColorShift_Top = Color3.fromRGB(200, 255, 200),
		FogColor = Color3.fromRGB(100, 255, 100),
		FogEnd = 350,
		Brightness = 1.8
	},
	{
		Name = "Sunset Orange",
		Ambient = Color3.fromRGB(255, 150, 50),
		OutdoorAmbient = Color3.fromRGB(255, 180, 100),
		ColorShift_Bottom = Color3.fromRGB(200, 80, 20),
		ColorShift_Top = Color3.fromRGB(255, 200, 150),
		FogColor = Color3.fromRGB(255, 130, 50),
		FogEnd = 450,
		Brightness = 2
	},
	{
		Name = "Arctic White",
		Ambient = Color3.fromRGB(220, 240, 255),
		OutdoorAmbient = Color3.fromRGB(240, 250, 255),
		ColorShift_Bottom = Color3.fromRGB(180, 220, 255),
		ColorShift_Top = Color3.fromRGB(255, 255, 255),
		FogColor = Color3.fromRGB(230, 245, 255),
		FogEnd = 700,
		Brightness = 3
	},
	{
		Name = "Lavender Dreams",
		Ambient = Color3.fromRGB(200, 150, 255),
		OutdoorAmbient = Color3.fromRGB(220, 180, 255),
		ColorShift_Bottom = Color3.fromRGB(150, 100, 200),
		ColorShift_Top = Color3.fromRGB(230, 200, 255),
		FogColor = Color3.fromRGB(200, 160, 255),
		FogEnd = 550,
		Brightness = 1.8
	},
	{
		Name = "Blood Moon",
		Ambient = Color3.fromRGB(150, 0, 0),
		OutdoorAmbient = Color3.fromRGB(200, 50, 50),
		ColorShift_Bottom = Color3.fromRGB(100, 0, 0),
		ColorShift_Top = Color3.fromRGB(255, 50, 50),
		FogColor = Color3.fromRGB(120, 20, 20),
		FogEnd = 150,
		Brightness = 0.8
	},
	{
		Name = "Mint Fresh",
		Ambient = Color3.fromRGB(100, 255, 200),
		OutdoorAmbient = Color3.fromRGB(150, 255, 220),
		ColorShift_Bottom = Color3.fromRGB(50, 200, 150),
		ColorShift_Top = Color3.fromRGB(200, 255, 230),
		FogColor = Color3.fromRGB(120, 255, 200),
		FogEnd = 600,
		Brightness = 2.2
	},
	{
		Name = "Violet Storm",
		Ambient = Color3.fromRGB(100, 50, 150),
		OutdoorAmbient = Color3.fromRGB(150, 80, 200),
		ColorShift_Bottom = Color3.fromRGB(80, 20, 120),
		ColorShift_Top = Color3.fromRGB(180, 100, 220),
		FogColor = Color3.fromRGB(100, 60, 150),
		FogEnd = 350,
		Brightness = 1.2
	},
	{
		Name = "Peachy Dawn",
		Ambient = Color3.fromRGB(255, 200, 180),
		OutdoorAmbient = Color3.fromRGB(255, 220, 200),
		ColorShift_Bottom = Color3.fromRGB(255, 150, 120),
		ColorShift_Top = Color3.fromRGB(255, 230, 210),
		FogColor = Color3.fromRGB(255, 200, 170),
		FogEnd = 650,
		Brightness = 2.5
	},
	{
		Name = "Electric Blue",
		Ambient = Color3.fromRGB(0, 150, 255),
		OutdoorAmbient = Color3.fromRGB(50, 180, 255),
		ColorShift_Bottom = Color3.fromRGB(0, 100, 200),
		ColorShift_Top = Color3.fromRGB(100, 200, 255),
		FogColor = Color3.fromRGB(30, 160, 255),
		FogEnd = 400,
		Brightness = 1.6
	},
	{
		Name = "Rose Gold",
		Ambient = Color3.fromRGB(255, 180, 180),
		OutdoorAmbient = Color3.fromRGB(255, 200, 200),
		ColorShift_Bottom = Color3.fromRGB(200, 130, 130),
		ColorShift_Top = Color3.fromRGB(255, 210, 210),
		FogColor = Color3.fromRGB(255, 175, 175),
		FogEnd = 550,
		Brightness = 2
	}
}

local currentLightningPreset = "Default"
local currentSkyPreset = "Default"

local function applyLightningPreset(preset)
	local Lighting = game:GetService("Lighting")
	Lighting.Ambient = preset.Ambient
	Lighting.OutdoorAmbient = preset.OutdoorAmbient
	Lighting.ColorShift_Bottom = preset.ColorShift_Bottom
	Lighting.ColorShift_Top = preset.ColorShift_Top
	Lighting.FogColor = preset.FogColor
	Lighting.FogEnd = preset.FogEnd
	Lighting.FogStart = 0
	Lighting.Brightness = preset.Brightness
	if preset.GlobalShadows ~= nil then
		Lighting.GlobalShadows = preset.GlobalShadows
	end
	currentLightningPreset = preset.Name
end

local function restoreDefaultLightning()
	local Lighting = game:GetService("Lighting")
	-- Restore ALL saved default values
	Lighting.Ambient = defaultLighting.Ambient
	Lighting.OutdoorAmbient = defaultLighting.OutdoorAmbient
	Lighting.ColorShift_Bottom = defaultLighting.ColorShift_Bottom
	Lighting.ColorShift_Top = defaultLighting.ColorShift_Top
	Lighting.FogColor = defaultLighting.FogColor
	Lighting.FogEnd = defaultLighting.FogEnd
	Lighting.FogStart = defaultLighting.FogStart
	Lighting.Brightness = defaultLighting.Brightness
	Lighting.GlobalShadows = defaultLighting.GlobalShadows
	Lighting.ClockTime = defaultLighting.ClockTime
	Lighting.GeographicLatitude = defaultLighting.GeographicLatitude
	currentLightningPreset = "Default"
end

local function applyHipHeight()
	-- Stop any existing connection
	if hipHeightConnection then
		hipHeightConnection:Disconnect()
		hipHeightConnection = nil
	end

	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not humanoid then return end

	if hipHeightEnabled then
		-- Get default hip height for R15 (usually around 2.1)
		local defaultHipHeight = 2.1

		if currentHipHeight >= 0 then
			-- Positive: add to default height
			humanoid.HipHeight = defaultHipHeight + currentHipHeight
		else
			-- Negative: push below ground
			humanoid.HipHeight = defaultHipHeight

			hipHeightConnection = RunService.Heartbeat:Connect(function()
				if not hipHeightEnabled then return end
				local c = player.Character
				if not c then return end
				local h = c:FindFirstChild("HumanoidRootPart")
				if not h then return end

				-- Push down by the negative offset, preserving rotation
				local currentCFrame = h.CFrame
				local targetY = currentCFrame.Position.Y + currentHipHeight
				h.CFrame = CFrame.new(currentCFrame.Position.X, targetY, currentCFrame.Position.Z) * (currentCFrame - currentCFrame.Position)
			end)
		end
	else
		-- Reset to default (don't change anything - let Roblox handle it)
		humanoid.HipHeight = 2.1
	end
end

local function loadHipHeightCategory()
	clear()
	local theme = themes[currentTheme]

	-- Info label showing current hip height
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,0,0,30)
	info.BackgroundTransparency = 1
	info.Text = "Height Offset: " .. string.format("%.1f", currentHipHeight)
	info.TextColor3 = theme.Success
	info.Font = Enum.Font.GothamBold
	info.TextSize = 16
	info.Parent = scroll

	-- Spacing
	local space1 = Instance.new("Frame")
	space1.Size = UDim2.new(1,0,0,4)
	space1.BackgroundTransparency = 1
	space1.Parent = scroll

	-- Hip Height Slider (range -10 to 20)
	local hipBar = Instance.new("Frame")
	hipBar.Size = UDim2.new(1,-20,0,22)
	hipBar.BackgroundColor3 = theme.CategoryBtn
	hipBar.Parent = scroll
	Instance.new("UICorner", hipBar).CornerRadius = UDim.new(0,9)

	-- Calculate initial fill (center is 0, range is -10 to 20)
	local initialAlpha = (currentHipHeight + 10) / 30
	local hipFill = Instance.new("Frame")
	hipFill.Size = UDim2.new(initialAlpha,0,1,0)
	hipFill.BackgroundColor3 = theme.Success
	hipFill.Parent = hipBar
	Instance.new("UICorner", hipFill).CornerRadius = UDim.new(0,9)

	local hipKnob = Instance.new("Frame")
	hipKnob.Size = UDim2.new(0,22,0,22)
	hipKnob.Position = UDim2.new(initialAlpha,-11,0,-2)
	hipKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	hipKnob.Parent = hipBar
	Instance.new("UICorner", hipKnob).CornerRadius = UDim.new(0,11)

	-- Center marker (shows where 0 is)
	local centerMarker = Instance.new("Frame")
	centerMarker.Size = UDim2.new(0,2,1,0)
	centerMarker.Position = UDim2.new(10/30,-1,0,0)
	centerMarker.BackgroundColor3 = Color3.fromRGB(255,255,255)
	centerMarker.Parent = hipBar

	local hipDragging = false
	local function updateHipSlider(x)
		local barX = hipBar.AbsolutePosition.X
		local barW = hipBar.AbsoluteSize.X
		local alpha = math.clamp((x - barX) / barW, 0, 1)
		-- Range: -10 to 20 (total range of 30)
		currentHipHeight = math.floor((-10 + 30 * alpha) * 10) / 10
		hipFill.Size = UDim2.new(alpha,0,1,0)
		hipKnob.Position = UDim2.new(alpha,-11,0,-2)
		info.Text = "Height Offset: " .. string.format("%.1f", currentHipHeight)
		applyHipHeight()
	end

	hipKnob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			hipDragging = true
		end
	end)

	hipBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateHipSlider(input.Position.X)
			hipDragging = true
		end
	end)

	-- Global slider drag handling for hip height
	local hipDragConn
	hipDragConn = UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if hipDragging then
				updateHipSlider(input.Position.X)
			end
		end
	end)
	table.insert(sliderConnections, hipDragConn)

	local hipEndConn
	hipEndConn = UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			hipDragging = false
		end
	end)
	table.insert(sliderConnections, hipEndConn)

	-- Spacing
	local space2 = Instance.new("Frame")
	space2.Size = UDim2.new(1,0,0,4)
	space2.BackgroundTransparency = 1
	space2.Parent = scroll

	-- Toggle button
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1,0,0,40)
	toggle.BackgroundColor3 = hipHeightEnabled and theme.Success or theme.ButtonBg
	toggle.Text = hipHeightEnabled and "Height Offset: ON" or "Height Offset: OFF"
	toggle.TextColor3 = theme.Text
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 14
	toggle.Parent = scroll
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,12)

	local function updateToggleBtn()
		toggle.Text = hipHeightEnabled and "Height Offset: ON" or "Height Offset: OFF"
		toggle.BackgroundColor3 = hipHeightEnabled and theme.Success or theme.ButtonBg
	end

	toggle.MouseButton1Click:Connect(function()
		hipHeightEnabled = not hipHeightEnabled
		updateToggleBtn()
		applyHipHeight()
	end)

	-- Spacing
	local space3 = Instance.new("Frame")
	space3.Size = UDim2.new(1,0,0,4)
	space3.BackgroundTransparency = 1
	space3.Parent = scroll

	-- Reset button
	local reset = Instance.new("TextButton")
	reset.Size = UDim2.new(1,0,0,35)
	reset.BackgroundColor3 = theme.Danger
	reset.Text = "Reset to Default (0)"
	reset.TextColor3 = Color3.fromRGB(255,255,255)
	reset.Font = Enum.Font.Gotham
	reset.TextSize = 13
	reset.Parent = scroll
	Instance.new("UICorner", reset).CornerRadius = UDim.new(0,10)

	reset.MouseButton1Click:Connect(function()
		currentHipHeight = 0
		info.Text = "Height Offset: 0"
		local alpha = 10/30
		hipFill.Size = UDim2.new(alpha,0,1,0)
		hipKnob.Position = UDim2.new(alpha,-11,0,-2)
		applyHipHeight()
	end)

	-- Info label
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1,0,0,60)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "Adjusts your height above/below ground.\nNegative values go below ground.\nClient-sided only."
	infoLabel.TextColor3 = theme.SubText
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextSize = 12
	infoLabel.TextWrapped = true
	infoLabel.Parent = scroll
end

table.insert(connections, player.CharacterAdded:Connect(function()
	if destroyed then return end
	task.wait(0.5)
	if hipHeightEnabled then
		applyHipHeight()
	end
end))

-- SKY LIGHTNING SYSTEM
local skyPresets = {
	{
		Name = "Default Sky",
		ClockTime = 14,
		GeographicLatitude = 41.7,
		Brightness = 2,
		Ambient = Color3.fromRGB(200, 200, 200),
		OutdoorAmbient = Color3.fromRGB(128, 128, 128),
		FogColor = Color3.fromRGB(192, 192, 192),
		FogEnd = 100000
	},
	-- REALLY DARK SKIES
	{
		Name = "Pitch Black Night",
		ClockTime = 0,
		GeographicLatitude = 0,
		Brightness = 0.1,
		Ambient = Color3.fromRGB(5, 5, 10),
		OutdoorAmbient = Color3.fromRGB(10, 10, 20),
		FogColor = Color3.fromRGB(0, 0, 5),
		FogEnd = 50
	},
	{
		Name = "Deep Void",
		ClockTime = 0,
		GeographicLatitude = 0,
		Brightness = 0.05,
		Ambient = Color3.fromRGB(0, 0, 0),
		OutdoorAmbient = Color3.fromRGB(5, 0, 10),
		FogColor = Color3.fromRGB(0, 0, 0),
		FogEnd = 30
	},
	{
		Name = "Dark Abyss",
		ClockTime = 0,
		GeographicLatitude = 0,
		Brightness = 0.02,
		Ambient = Color3.fromRGB(2, 0, 5),
		OutdoorAmbient = Color3.fromRGB(3, 1, 8),
		FogColor = Color3.fromRGB(1, 0, 3),
		FogEnd = 20
	},
	{
		Name = "Midnight Storm",
		ClockTime = 0,
		GeographicLatitude = 0,
		Brightness = 0.15,
		Ambient = Color3.fromRGB(10, 15, 30),
		OutdoorAmbient = Color3.fromRGB(15, 20, 40),
		FogColor = Color3.fromRGB(5, 10, 25),
		FogEnd = 100
	},
	{
		Name = "Eclipse",
		ClockTime = 0,
		GeographicLatitude = 0,
		Brightness = 0.08,
		Ambient = Color3.fromRGB(20, 5, 5),
		OutdoorAmbient = Color3.fromRGB(30, 10, 10),
		FogColor = Color3.fromRGB(15, 5, 5),
		FogEnd = 80
	},
	{
		Name = "Dark Forest Night",
		ClockTime = 0,
		GeographicLatitude = 0,
		Brightness = 0.2,
		Ambient = Color3.fromRGB(5, 15, 5),
		OutdoorAmbient = Color3.fromRGB(10, 25, 10),
		FogColor = Color3.fromRGB(3, 10, 3),
		FogEnd = 120
	},
	{
		Name = "Deep Ocean Night",
		ClockTime = 0,
		GeographicLatitude = 0,
		Brightness = 0.12,
		Ambient = Color3.fromRGB(5, 10, 25),
		OutdoorAmbient = Color3.fromRGB(8, 15, 35),
		FogColor = Color3.fromRGB(3, 8, 20),
		FogEnd = 90
	},
	-- DARK MOODY SKIES
	{
		Name = "Twilight Zone",
		ClockTime = 5,
		GeographicLatitude = 45,
		Brightness = 0.5,
		Ambient = Color3.fromRGB(40, 30, 60),
		OutdoorAmbient = Color3.fromRGB(60, 50, 90),
		FogColor = Color3.fromRGB(35, 25, 50),
		FogEnd = 200
	},
	{
		Name = "Stormy Evening",
		ClockTime = 18,
		GeographicLatitude = 30,
		Brightness = 0.6,
		Ambient = Color3.fromRGB(50, 50, 60),
		OutdoorAmbient = Color3.fromRGB(70, 70, 85),
		FogColor = Color3.fromRGB(45, 45, 55),
		FogEnd = 250
	},
	{
		Name = "Haunted Night",
		ClockTime = 0,
		GeographicLatitude = 0,
		Brightness = 0.25,
		Ambient = Color3.fromRGB(20, 10, 30),
		OutdoorAmbient = Color3.fromRGB(35, 20, 50),
		FogColor = Color3.fromRGB(15, 8, 25),
		FogEnd = 150
	},
	{
		Name = "Blood Night",
		ClockTime = 0,
		GeographicLatitude = 0,
		Brightness = 0.3,
		Ambient = Color3.fromRGB(50, 10, 10),
		OutdoorAmbient = Color3.fromRGB(70, 20, 20),
		FogColor = Color3.fromRGB(40, 5, 5),
		FogEnd = 100
	},
	-- NORMAL SKIES
	{
		Name = "Golden Sunset",
		ClockTime = 18.5,
		GeographicLatitude = 35,
		Brightness = 1.8,
		Ambient = Color3.fromRGB(255, 180, 100),
		OutdoorAmbient = Color3.fromRGB(255, 200, 150),
		FogColor = Color3.fromRGB(255, 170, 80),
		FogEnd = 600
	},
	{
		Name = "Pink Dawn",
		ClockTime = 6,
		GeographicLatitude = 40,
		Brightness = 1.5,
		Ambient = Color3.fromRGB(255, 150, 180),
		OutdoorAmbient = Color3.fromRGB(255, 180, 200),
		FogColor = Color3.fromRGB(255, 160, 190),
		FogEnd = 500
	},
	{
		Name = "Blue Morning",
		ClockTime = 8,
		GeographicLatitude = 45,
		Brightness = 2,
		Ambient = Color3.fromRGB(150, 200, 255),
		OutdoorAmbient = Color3.fromRGB(180, 220, 255),
		FogColor = Color3.fromRGB(160, 210, 255),
		FogEnd = 700
	},
	{
		Name = "Warm Afternoon",
		ClockTime = 14,
		GeographicLatitude = 30,
		Brightness = 2.5,
		Ambient = Color3.fromRGB(255, 240, 200),
		OutdoorAmbient = Color3.fromRGB(255, 250, 230),
		FogColor = Color3.fromRGB(255, 245, 210),
		FogEnd = 900
	},
	-- REALLY BRIGHT SKIES
	{
		Name = "Blinding White",
		ClockTime = 12,
		GeographicLatitude = 0,
		Brightness = 5,
		Ambient = Color3.fromRGB(255, 255, 255),
		OutdoorAmbient = Color3.fromRGB(255, 255, 255),
		FogColor = Color3.fromRGB(255, 255, 255),
		FogEnd = 2000
	},
	{
		Name = "Nuclear Bright",
		ClockTime = 12,
		GeographicLatitude = 0,
		Brightness = 4,
		Ambient = Color3.fromRGB(255, 255, 240),
		OutdoorAmbient = Color3.fromRGB(255, 255, 255),
		FogColor = Color3.fromRGB(255, 255, 245),
		FogEnd = 1500
	},
	{
		Name = "Heaven Light",
		ClockTime = 12,
		GeographicLatitude = 0,
		Brightness = 3.5,
		Ambient = Color3.fromRGB(255, 250, 255),
		OutdoorAmbient = Color3.fromRGB(255, 255, 255),
		FogColor = Color3.fromRGB(255, 252, 255),
		FogEnd = 1200
	},
	{
		Name = "Arctic Day",
		ClockTime = 12,
		GeographicLatitude = 80,
		Brightness = 3,
		Ambient = Color3.fromRGB(220, 240, 255),
		OutdoorAmbient = Color3.fromRGB(240, 250, 255),
		FogColor = Color3.fromRGB(230, 245, 255),
		FogEnd = 1000
	},
	{
		Name = "Desert Sun",
		ClockTime = 12,
		GeographicLatitude = 25,
		Brightness = 3.2,
		Ambient = Color3.fromRGB(255, 250, 220),
		OutdoorAmbient = Color3.fromRGB(255, 255, 240),
		FogColor = Color3.fromRGB(255, 248, 215),
		FogEnd = 800
	},
	{
		Name = "Tropical Paradise",
		ClockTime = 11,
		GeographicLatitude = 20,
		Brightness = 2.8,
		Ambient = Color3.fromRGB(200, 255, 220),
		OutdoorAmbient = Color3.fromRGB(230, 255, 240),
		FogColor = Color3.fromRGB(210, 255, 225),
		FogEnd = 700
	},
	{
		Name = "Candy Clouds",
		ClockTime = 10,
		GeographicLatitude = 35,
		Brightness = 2.2,
		Ambient = Color3.fromRGB(255, 200, 255),
		OutdoorAmbient = Color3.fromRGB(255, 220, 255),
		FogColor = Color3.fromRGB(255, 210, 255),
		FogEnd = 550
	},
	{
		Name = "Neon Dreams",
		ClockTime = 20,
		GeographicLatitude = 0,
		Brightness = 1.2,
		Ambient = Color3.fromRGB(100, 50, 150),
		OutdoorAmbient = Color3.fromRGB(150, 80, 200),
		FogColor = Color3.fromRGB(120, 60, 180),
		FogEnd = 300
	},
	{
		Name = "Cyber Night",
		ClockTime = 22,
		GeographicLatitude = 0,
		Brightness = 0.8,
		Ambient = Color3.fromRGB(50, 0, 100),
		OutdoorAmbient = Color3.fromRGB(80, 20, 130),
		FogColor = Color3.fromRGB(40, 0, 80),
		FogEnd = 200
	},
	{
		Name = "Alien Planet",
		ClockTime = 15,
		GeographicLatitude = 60,
		Brightness = 1.5,
		Ambient = Color3.fromRGB(100, 200, 100),
		OutdoorAmbient = Color3.fromRGB(130, 220, 130),
		FogColor = Color3.fromRGB(80, 180, 80),
		FogEnd = 400
	},
	{
		Name = "Mars Surface",
		ClockTime = 12,
		GeographicLatitude = 25,
		Brightness = 1.8,
		Ambient = Color3.fromRGB(200, 100, 50),
		OutdoorAmbient = Color3.fromRGB(220, 130, 80),
		FogColor = Color3.fromRGB(180, 90, 40),
		FogEnd = 350
	},
	{
		Name = "Purple Haze",
		ClockTime = 19,
		GeographicLatitude = 0,
		Brightness = 1,
		Ambient = Color3.fromRGB(80, 40, 120),
		OutdoorAmbient = Color3.fromRGB(120, 70, 160),
		FogColor = Color3.fromRGB(90, 50, 130),
		FogEnd = 280
	},
	{
		Name = "Toxic Waste",
		ClockTime = 12,
		GeographicLatitude = 0,
		Brightness = 1.6,
		Ambient = Color3.fromRGB(100, 255, 50),
		OutdoorAmbient = Color3.fromRGB(150, 255, 100),
		FogColor = Color3.fromRGB(80, 230, 30),
		FogEnd = 250
	},
	{
		Name = "Ocean Deep",
		ClockTime = 10,
		GeographicLatitude = 45,
		Brightness = 1.4,
		Ambient = Color3.fromRGB(30, 80, 150),
		OutdoorAmbient = Color3.fromRGB(50, 120, 180),
		FogColor = Color3.fromRGB(40, 100, 160),
		FogEnd = 320
	},
	{
		Name = "Frozen World",
		ClockTime = 12,
		GeographicLatitude = 85,
		Brightness = 2.5,
		Ambient = Color3.fromRGB(200, 230, 255),
		OutdoorAmbient = Color3.fromRGB(230, 245, 255),
		FogColor = Color3.fromRGB(210, 235, 255),
		FogEnd = 600
	},
	{
		Name = "Volcanic",
		ClockTime = 0,
		GeographicLatitude = 0,
		Brightness = 0.6,
		Ambient = Color3.fromRGB(80, 30, 10),
		OutdoorAmbient = Color3.fromRGB(120, 50, 20),
		FogColor = Color3.fromRGB(60, 20, 5),
		FogEnd = 150
	},
	{
		Name = "Underworld",
		ClockTime = 0,
		GeographicLatitude = 0,
		Brightness = 0.4,
		Ambient = Color3.fromRGB(50, 20, 20),
		OutdoorAmbient = Color3.fromRGB(80, 30, 30),
		FogColor = Color3.fromRGB(40, 15, 15),
		FogEnd = 100
	}
}

local function applySkyPreset(preset)
	local Lighting = game:GetService("Lighting")
	Lighting.ClockTime = preset.ClockTime
	Lighting.GeographicLatitude = preset.GeographicLatitude
	Lighting.Brightness = preset.Brightness
	Lighting.Ambient = preset.Ambient
	Lighting.OutdoorAmbient = preset.OutdoorAmbient
	Lighting.FogColor = preset.FogColor
	Lighting.FogEnd = preset.FogEnd
	Lighting.FogStart = 0
	currentSkyPreset = preset.Name
end

local function loadSkyLightningCategory()
	clear()
	local theme = themes[currentTheme]

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,0,0,40)
	title.BackgroundTransparency = 1
	title.Text = "Sky & Time Presets"
	title.TextColor3 = theme.Accent
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Parent = scroll

	-- Current preset display
	local currentLabel = Instance.new("TextLabel")
	currentLabel.Size = UDim2.new(1,0,0,30)
	currentLabel.BackgroundTransparency = 1
	currentLabel.Text = "Current: " .. currentSkyPreset
	currentLabel.TextColor3 = theme.Success
	currentLabel.Font = Enum.Font.GothamBold
	currentLabel.TextSize = 14
	currentLabel.Parent = scroll

	-- Section: Really Dark Skies
	local darkLabel = Instance.new("TextLabel")
	darkLabel.Size = UDim2.new(1,0,0,25)
	darkLabel.BackgroundTransparency = 1
	darkLabel.Text = "🌑 REALLY DARK SKIES"
	darkLabel.TextColor3 = Color3.fromRGB(100, 100, 150)
	darkLabel.Font = Enum.Font.GothamBold
	darkLabel.TextSize = 12
	darkLabel.TextXAlignment = Enum.TextXAlignment.Left
	darkLabel.Parent = scroll

	local darkPresets = {"Pitch Black Night", "Deep Void", "Dark Abyss", "Midnight Storm", "Eclipse", "Dark Forest Night", "Deep Ocean Night"}
	for _, presetName in ipairs(darkPresets) do
		for _, preset in ipairs(skyPresets) do
			if preset.Name == presetName then
				local isSelected = currentSkyPreset == preset.Name
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1,0,0,38)
				btn.BackgroundColor3 = isSelected and Color3.fromRGB(30, 30, 60) or theme.ButtonBg
				btn.Text = preset.Name .. (isSelected and " ✓" or "")
				btn.TextColor3 = isSelected and Color3.fromRGB(150, 150, 255) or theme.Text
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 12
				btn.Parent = scroll
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
				btn.MouseButton1Click:Connect(function()
					applySkyPreset(preset)
					loadSkyLightningCategory()
				end)
			end
		end
	end

	-- Section: Dark Moody Skies
	local moodyLabel = Instance.new("TextLabel")
	moodyLabel.Size = UDim2.new(1,0,0,25)
	moodyLabel.BackgroundTransparency = 1
	moodyLabel.Text = "🌙 DARK MOODY SKIES"
	moodyLabel.TextColor3 = Color3.fromRGB(150, 100, 150)
	moodyLabel.Font = Enum.Font.GothamBold
	moodyLabel.TextSize = 12
	moodyLabel.TextXAlignment = Enum.TextXAlignment.Left
	moodyLabel.Parent = scroll

	local moodyPresets = {"Twilight Zone", "Stormy Evening", "Haunted Night", "Blood Night"}
	for _, presetName in ipairs(moodyPresets) do
		for _, preset in ipairs(skyPresets) do
			if preset.Name == presetName then
				local isSelected = currentSkyPreset == preset.Name
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1,0,0,38)
				btn.BackgroundColor3 = isSelected and Color3.fromRGB(60, 40, 80) or theme.ButtonBg
				btn.Text = preset.Name .. (isSelected and " ✓" or "")
				btn.TextColor3 = isSelected and Color3.fromRGB(200, 150, 255) or theme.Text
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 12
				btn.Parent = scroll
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
				btn.MouseButton1Click:Connect(function()
					applySkyPreset(preset)
					loadSkyLightningCategory()
				end)
			end
		end
	end

	-- Section: Normal Skies
	local normalLabel = Instance.new("TextLabel")
	normalLabel.Size = UDim2.new(1,0,0,25)
	normalLabel.BackgroundTransparency = 1
	normalLabel.Text = "☀️ NORMAL SKIES"
	normalLabel.TextColor3 = Color3.fromRGB(200, 150, 100)
	normalLabel.Font = Enum.Font.GothamBold
	normalLabel.TextSize = 12
	normalLabel.TextXAlignment = Enum.TextXAlignment.Left
	normalLabel.Parent = scroll

	local normalPresets = {"Golden Sunset", "Pink Dawn", "Blue Morning", "Warm Afternoon"}
	for _, presetName in ipairs(normalPresets) do
		for _, preset in ipairs(skyPresets) do
			if preset.Name == presetName then
				local isSelected = currentSkyPreset == preset.Name
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1,0,0,38)
				btn.BackgroundColor3 = isSelected and Color3.fromRGB(255, 180, 100) or theme.ButtonBg
				btn.Text = preset.Name .. (isSelected and " ✓" or "")
				btn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or theme.Text
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 12
				btn.Parent = scroll
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
				btn.MouseButton1Click:Connect(function()
					applySkyPreset(preset)
					loadSkyLightningCategory()
				end)
			end
		end
	end

	-- Section: Really Bright Skies
	local brightLabel = Instance.new("TextLabel")
	brightLabel.Size = UDim2.new(1,0,0,25)
	brightLabel.BackgroundTransparency = 1
	brightLabel.Text = "☀️ REALLY BRIGHT SKIES"
	brightLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	brightLabel.Font = Enum.Font.GothamBold
	brightLabel.TextSize = 12
	brightLabel.TextXAlignment = Enum.TextXAlignment.Left
	brightLabel.Parent = scroll

	local brightPresets = {"Blinding White", "Nuclear Bright", "Heaven Light", "Arctic Day", "Desert Sun"}
	for _, presetName in ipairs(brightPresets) do
		for _, preset in ipairs(skyPresets) do
			if preset.Name == presetName then
				local isSelected = currentSkyPreset == preset.Name
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1,0,0,38)
				btn.BackgroundColor3 = isSelected and Color3.fromRGB(255, 255, 200) or theme.ButtonBg
				btn.Text = preset.Name .. (isSelected and " ✓" or "")
				btn.TextColor3 = isSelected and Color3.fromRGB(100, 80, 0) or theme.Text
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 12
				btn.Parent = scroll
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
				btn.MouseButton1Click:Connect(function()
					applySkyPreset(preset)
					loadSkyLightningCategory()
				end)
			end
		end
	end

	-- Section: Special Skies
	local specialLabel = Instance.new("TextLabel")
	specialLabel.Size = UDim2.new(1,0,0,25)
	specialLabel.BackgroundTransparency = 1
	specialLabel.Text = "✨ SPECIAL SKIES"
	specialLabel.TextColor3 = Color3.fromRGB(200, 100, 255)
	specialLabel.Font = Enum.Font.GothamBold
	specialLabel.TextSize = 12
	specialLabel.TextXAlignment = Enum.TextXAlignment.Left
	specialLabel.Parent = scroll

	local specialPresets = {"Tropical Paradise", "Candy Clouds", "Neon Dreams", "Cyber Night", "Alien Planet", "Mars Surface", "Purple Haze", "Toxic Waste", "Ocean Deep", "Frozen World", "Volcanic", "Underworld"}
	for _, presetName in ipairs(specialPresets) do
		for _, preset in ipairs(skyPresets) do
			if preset.Name == presetName then
				local isSelected = currentSkyPreset == preset.Name
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1,0,0,38)
				btn.BackgroundColor3 = isSelected and Color3.fromRGB(100, 50, 150) or theme.ButtonBg
				btn.Text = preset.Name .. (isSelected and " ✓" or "")
				btn.TextColor3 = isSelected and Color3.fromRGB(255, 200, 255) or theme.Text
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 12
				btn.Parent = scroll
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
				btn.MouseButton1Click:Connect(function()
					applySkyPreset(preset)
					loadSkyLightningCategory()
				end)
			end
		end
	end

	-- Spacing
	local space = Instance.new("Frame")
	space.Size = UDim2.new(1,0,0,10)
	space.BackgroundTransparency = 1
	space.Parent = scroll

	-- Restore Default Button
	local restoreBtn = Instance.new("TextButton")
	restoreBtn.Size = UDim2.new(1,0,0,45)
	restoreBtn.BackgroundColor3 = theme.Danger
	restoreBtn.Text = "Restore Default Sky"
	restoreBtn.TextColor3 = Color3.fromRGB(255,255,255)
	restoreBtn.Font = Enum.Font.GothamBold
	restoreBtn.TextSize = 14
	restoreBtn.Parent = scroll
	Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0,12)

	restoreBtn.MouseButton1Click:Connect(function()
		for _, preset in ipairs(skyPresets) do
			if preset.Name == "Default Sky" then
				applySkyPreset(preset)
				break
			end
		end
		loadSkyLightningCategory()
	end)

	-- Info
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,0,0,60)
	info.BackgroundTransparency = 1
	info.Text = "Changes sky time, brightness, and colors!\nDark skies = night time, Bright skies = day time\nClient-sided only."
	info.TextColor3 = theme.SubText
	info.Font = Enum.Font.Gotham
	info.TextSize = 11
	info.TextWrapped = true
	info.Parent = scroll
end

local function loadLightningCategory()
	clear()
	local theme = themes[currentTheme]

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,0,0,40)
	title.BackgroundTransparency = 1
	title.Text = "Sky & Lighting Presets"
	title.TextColor3 = theme.Accent
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Parent = scroll

	-- Current preset display
	local currentLabel = Instance.new("TextLabel")
	currentLabel.Size = UDim2.new(1,0,0,30)
	currentLabel.BackgroundTransparency = 1
	currentLabel.Text = "Current: " .. currentLightningPreset
	currentLabel.TextColor3 = theme.Success
	currentLabel.Font = Enum.Font.GothamBold
	currentLabel.TextSize = 14
	currentLabel.Parent = scroll

	-- Preset color mapping for preview bars
	local presetColors = {
		["Default"] = Color3.fromRGB(200, 200, 200),
		["Pink Paradise"] = Color3.fromRGB(255, 105, 180),
		["Ocean Blue"] = Color3.fromRGB(0, 150, 255),
		["Purple Galaxy"] = Color3.fromRGB(150, 50, 255),
		["Red Hellfire"] = Color3.fromRGB(255, 50, 50),
		["Green Forest"] = Color3.fromRGB(50, 200, 50),
		["Cyberpunk Neon"] = Color3.fromRGB(255, 0, 255),
		["Golden Hour"] = Color3.fromRGB(255, 200, 100),
		["Midnight Blue"] = Color3.fromRGB(20, 30, 60),
		["Candy Pink"] = Color3.fromRGB(255, 150, 200),
		["Toxic Green"] = Color3.fromRGB(100, 255, 100),
		["Sunset Orange"] = Color3.fromRGB(255, 150, 50),
		["Arctic White"] = Color3.fromRGB(220, 240, 255),
		["Lavender Dreams"] = Color3.fromRGB(200, 150, 255),
		["Blood Moon"] = Color3.fromRGB(150, 0, 0),
		["Mint Fresh"] = Color3.fromRGB(100, 255, 200),
		["Violet Storm"] = Color3.fromRGB(100, 50, 150),
		["Peachy Dawn"] = Color3.fromRGB(255, 200, 180),
		["Electric Blue"] = Color3.fromRGB(0, 150, 255),
		["Rose Gold"] = Color3.fromRGB(255, 180, 180)
	}

	-- Create preset buttons
	for _, preset in ipairs(lightningPresets) do
		local isSelected = currentLightningPreset == preset.Name
		local presetColor = presetColors[preset.Name] or Color3.fromRGB(255, 255, 255)

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,42)
		btn.BackgroundColor3 = isSelected and presetColor or theme.ButtonBg
		btn.Text = preset.Name .. (isSelected and " ✓" or "")
		btn.TextColor3 = isSelected and Color3.fromRGB(255,255,255) or theme.Text
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 13
		btn.Parent = scroll
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

		-- Color preview bar
		local previewBar = Instance.new("Frame")
		previewBar.Size = UDim2.new(1,-20,0,5)
		previewBar.Position = UDim2.new(0,10,1,-8)
		previewBar.BackgroundColor3 = presetColor
		previewBar.Parent = btn
		Instance.new("UICorner", previewBar).CornerRadius = UDim.new(0,3)

		btn.MouseButton1Click:Connect(function()
			applyLightningPreset(preset)
			loadLightningCategory() -- Refresh
		end)
	end

	-- Spacing
	local space = Instance.new("Frame")
	space.Size = UDim2.new(1,0,0,10)
	space.BackgroundTransparency = 1
	space.Parent = scroll

	-- Restore Default Button
	local restoreBtn = Instance.new("TextButton")
	restoreBtn.Size = UDim2.new(1,0,0,45)
	restoreBtn.BackgroundColor3 = theme.Danger
	restoreBtn.Text = "Restore Default Lighting"
	restoreBtn.TextColor3 = Color3.fromRGB(255,255,255)
	restoreBtn.Font = Enum.Font.GothamBold
	restoreBtn.TextSize = 14
	restoreBtn.Parent = scroll
	Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0,12)

	restoreBtn.MouseButton1Click:Connect(function()
		restoreDefaultLightning()
		loadLightningCategory() -- Refresh
	end)

	-- Info
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,0,0,50)
	info.BackgroundTransparency = 1
	info.Text = "Click a preset to change the sky!\n'Wall See' removes shadows for clear visibility."
	info.TextColor3 = theme.SubText
	info.Font = Enum.Font.Gotham
	info.TextSize = 12
	info.TextWrapped = true
	info.Parent = scroll
end

local function loadOtherCategory()
	clear()
	local theme = themes[currentTheme]

	-- Jump Cooldown Bypass Toggle
	local jumpBypassToggle = Instance.new("TextButton")
	jumpBypassToggle.Size = UDim2.new(1,0,0,40)
	jumpBypassToggle.BackgroundColor3 = jumpCooldownBypassEnabled and theme.Success or theme.ButtonBg
	jumpBypassToggle.Text = jumpCooldownBypassEnabled and "Jump Cooldown Bypass: ON" or "Jump Cooldown Bypass: OFF"
	jumpBypassToggle.TextColor3 = theme.Text
	jumpBypassToggle.Font = Enum.Font.Gotham
	jumpBypassToggle.TextSize = 14
	jumpBypassToggle.Parent = scroll
	Instance.new("UICorner", jumpBypassToggle).CornerRadius = UDim.new(0,12)

	jumpBypassToggle.MouseButton1Click:Connect(function()
		jumpCooldownBypassEnabled = not jumpCooldownBypassEnabled
		jumpBypassToggle.Text = jumpCooldownBypassEnabled and "Jump Cooldown Bypass: ON" or "Jump Cooldown Bypass: OFF"
		jumpBypassToggle.BackgroundColor3 = jumpCooldownBypassEnabled and theme.Success or theme.ButtonBg
		
		if jumpCooldownBypassEnabled then
			-- Start the jump bypass loop
			if jumpBypassConnection then
				jumpBypassConnection:Disconnect()
				jumpBypassConnection = nil
			end
			
			-- Start the jump bypass loop - constantly enables jumping
			jumpBypassConnection = RunService.Heartbeat:Connect(function()
				if destroyed or not jumpCooldownBypassEnabled then return end
				local char = player.Character
				if char then
					local humanoid = char:FindFirstChildOfClass("Humanoid")
					if humanoid then
						-- Force enable jumping by ensuring jump power is set
						if humanoid.JumpPower <= 0 and humanoid.JumpHeight <= 0 then
							humanoid.JumpPower = 50
						end
						-- Set UseJumpPower to ensure jump works
						humanoid.UseJumpPower = true
						-- Clear any potential cooldown attributes
						for _, attr in ipairs({"JumpCooldown", "LastJumpTime", "NextJumpTime", "JumpDelay"}) do
							if humanoid:GetAttribute(attr) then
								humanoid:SetAttribute(attr, 0)
							end
						end
					end
				end
			end)
			table.insert(connections, jumpBypassConnection)
			
			-- Hook into jump requests to force jump regardless of cooldown
			jumpRequestConnection = UIS.JumpRequest:Connect(function()
				if destroyed or not jumpCooldownBypassEnabled then return end
				local char = player.Character
				if char then
					local humanoid = char:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid.JumpPower > 0 then
						-- Force jump by changing state
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)
			table.insert(connections, jumpRequestConnection)
		else
			-- Stop the bypass
			if jumpBypassConnection then
				jumpBypassConnection:Disconnect()
				jumpBypassConnection = nil
			end
			if jumpRequestConnection then
				jumpRequestConnection:Disconnect()
				jumpRequestConnection = nil
			end
		end
	end)

	-- Jump Bypass Info
	local jumpInfo = Instance.new("TextLabel")
	jumpInfo.Size = UDim2.new(1,0,0,50)
	jumpInfo.BackgroundTransparency = 1
	jumpInfo.Text = "Bypasses jump cooldowns!\nJump infinitely - spam spacebar!\nWorks on most games with jump cooldowns."
	jumpInfo.TextColor3 = theme.SubText
	jumpInfo.Font = Enum.Font.Gotham
	jumpInfo.TextSize = 12
	jumpInfo.TextWrapped = true
	jumpInfo.Parent = scroll

	-- Spacing
	local space1 = Instance.new("Frame")
	space1.Size = UDim2.new(1,0,0,10)
	space1.BackgroundTransparency = 1
	space1.Parent = scroll

	-- Reset Warning Toggle
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1,0,0,40)
	toggle.BackgroundColor3 = resetWarningEnabled and theme.Success or theme.ButtonBg
	toggle.Text = resetWarningEnabled and "Reset Warning: ON" or "Reset Warning: OFF"
	toggle.TextColor3 = theme.Text
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 14
	toggle.Parent = scroll
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,12)

	toggle.MouseButton1Click:Connect(function()
		resetWarningEnabled = not resetWarningEnabled
		toggle.Text = resetWarningEnabled and "Reset Warning: ON" or "Reset Warning: OFF"
		toggle.BackgroundColor3 = resetWarningEnabled and theme.Success or theme.ButtonBg
		if resetWarningEnabled then
			-- Create GUI if needed and hook current character
			createResetWarningGUI()
			if player.Character then
				hookResetWarningCharacter(player.Character)
			end
		else
			-- Hide the warning frame
			if resetWarningFrame then
				resetWarningFrame.Visible = false
			end
		end
	end)

	-- Info label
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,0,0,60)
	info.BackgroundTransparency = 1
	info.Text = "When ON: Shows a draggable warning\non the right side when health is low.\nPress R to reset manually."
	info.TextColor3 = theme.SubText
	info.Font = Enum.Font.Gotham
	info.TextSize = 12
	info.TextWrapped = true
	info.Parent = scroll

	-- Racing Track Teleport button (from original data)
	local space = Instance.new("Frame")
	space.Size = UDim2.new(1,0,0,10)
	space.BackgroundTransparency = 1
	space.Parent = scroll

	local teleportBtn = Instance.new("TextButton")
	teleportBtn.Size = UDim2.new(1,0,0,42)
	teleportBtn.BackgroundColor3 = theme.ButtonBg
	teleportBtn.Text = "Racing Track Void (Teleport out of the map)"
	teleportBtn.TextColor3 = theme.Text
	teleportBtn.Font = Enum.Font.Gotham
	teleportBtn.TextSize = 14
	teleportBtn.Parent = scroll
	Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0,12)

	teleportBtn.MouseButton1Click:Connect(function()
		teleport(Vector3.new(409,65,788))
	end)
end

local function loadCategory(name)
	clear()
	if name == "Speed Walk" then
		loadSpeedWalkCategory()
	elseif name == "Hitbox Expander" then
		loadHitboxExpanderCategory()
	elseif name == "Korblox" then
		loadKorbloxCategory()
	elseif name == "Camlock" then
		loadCamlockCategory()
	elseif name == "ESP" then
		loadESPCategory()
	elseif name == "Visuals" then
		loadVisualsCategory()
	elseif name == "Lightning" then
		loadLightningCategory()
	elseif name == "Sky Lightning" then
		loadSkyLightningCategory()
	elseif name == "Hip Height" then
		loadHipHeightCategory()
	elseif name == "Other" then
		loadOtherCategory()
	else
		for _, v in ipairs(data[name]) do
			createButton(v[1], v[2])
		end
	end
end

local function createCategory(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.Parent = categoriesFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

	btn.MouseButton1Click:Connect(function()
		if destroyed then return end
		loadCategory(name)
	end)
end

createCategory("Waves")
createCategory("Guns")
createCategory("Food")
createCategory("Armor")
createCategory("ESP")
createCategory("Speed Walk")
createCategory("Camlock")
createCategory("Hitbox Expander")
createCategory("Hip Height")
createCategory("Other")
createCategory("Korblox")
createCategory("Visuals")
createCategory("Lightning")
createCategory("Sky Lightning")

-- Apply default theme at startup
applyTheme("Pastel Pink")

loadCategory("Waves")

---------------------------------------------------
-- SHUTDOWN FUNCTION (shared by F3 and X button)
---------------------------------------------------
local function shutdown()
	if destroyed then return end
	destroyed = true

	-- Disable all feature flags immediately
	speedEnabled = false
	espEnabled = false
	espShowOutlines = false
	camlockEnabled = false
	hbeEnabled = false
	korbloxEnabled = false
	hipHeightEnabled = false
	jumpCooldownBypassEnabled = false

	-- Force reset speed to default
	stopSpeedLoop()
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 16
			hum.HipHeight = 2.1
		end
	end

	-- Stop camlock completely
	stopCamlock()

	-- Clear ALL ESP objects
	clearAllESP()

	-- Reset ALL hitboxes
	resetAllHitboxes()

	-- Remove korblox completely
	if player.Character then
		removeKorblox(player.Character)
	end

	-- Disconnect hip height heartbeat loop
	if hipHeightConnection then
		hipHeightConnection:Disconnect()
		hipHeightConnection = nil
	end

	-- Disconnect jump bypass loop
	if jumpBypassConnection then
		jumpBypassConnection:Disconnect()
		jumpBypassConnection = nil
	end
	if jumpRequestConnection then
		jumpRequestConnection:Disconnect()
		jumpRequestConnection = nil
	end

	-- Restore default lighting
	restoreDefaultLightning()

	-- Remove blur
	if blur and blur.Parent then
		blur.Size = 0
	end

	-- Hide and clean up reset warning
	resetWarningEnabled = false
	if resetWarningFrame and resetWarningFrame.Parent then
		resetWarningFrame.Visible = false
	end

	-- Disconnect ALL tracked connections immediately
	for _, c in ipairs(connections) do
		pcall(function() c:Disconnect() end)
	end
	connections = {}

	-- Disconnect ALL slider connections
	for _, c in ipairs(sliderConnections) do
		pcall(function() c:Disconnect() end)
	end
	sliderConnections = {}

	-- Cute shutdown animation
	if gui and gui.Parent then
		title.Text = "bye bye! ♡"
		subtitle.Text = "see you soon~ ✧"

		-- Disable interactions during animation
		closeBtn.Active = false
		miniBtn.Active = false

		-- Shrink and fade out with bounce
		local shrinkTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		})

		-- Fade out top bar
		local topFade = TweenService:Create(top, TweenInfo.new(0.4), {
			BackgroundTransparency = 1
		})

		-- Fade out all text
		local titleFade = TweenService:Create(title, TweenInfo.new(0.35), {
			TextTransparency = 1
		})
		local subFade = TweenService:Create(subtitle, TweenInfo.new(0.35), {
			TextTransparency = 1
		})

		-- Play all tweens
		topFade:Play()
		titleFade:Play()
		subFade:Play()
		shrinkTween:Play()

		-- Cleanup after animation
		shrinkTween.Completed:Connect(function()
			if blur and blur.Parent then
				blur:Destroy()
			end
			gui:Destroy()
		end)
	else
		-- GUI already gone, just clean up blur
		if blur and blur.Parent then
			blur:Destroy()
		end
	end
end

---------------------------------------------------
-- TWEEN / DRAG / MINIMIZE / CLOSE
---------------------------------------------------

local dragging, dragStart, startPos

table.insert(connections, top.InputBegan:Connect(function(input)
	if destroyed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end))

table.insert(connections, UIS.InputChanged:Connect(function(input)
	if destroyed then return end
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end))

-- Camlock keybind toggle only (right-click disabled)
table.insert(connections, UIS.InputBegan:Connect(function(input, gpe)
	if destroyed or gpe then return end

	-- Camlock keybind toggle (only if keybind is set)
	if camlockKeybind and input.KeyCode == camlockKeybind then
		camlockEnabled = not camlockEnabled
		if camlockEnabled then
			local closestPlayer = findClosestToMouse()
			if closestPlayer then
				camlockTarget = closestPlayer
				camlockLocking = true
				startCamlock()
			else
				camlockEnabled = false
			end
		else
			stopCamlock()
		end
		return
	end

	-- Right-click functionality removed - camlock now only works with keybind
end))

-- Flame Lock removed per user request

table.insert(connections, UIS.InputBegan:Connect(function(input, gpe)
	if destroyed or gpe then return end
	if input.KeyCode == Enum.KeyCode.L then
		open = not open
		if open then
			-- Pop-up animation when opening
			frame.Visible = true
			frame.Size = UDim2.new(0, 0, 0, 0)
			frame.BackgroundTransparency = 1
			local popTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 520, 0, 440),
				BackgroundTransparency = 0
			})
			popTween:Play()
		else
			-- Shrink animation when closing
			local shrinkTween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1
			})
			shrinkTween:Play()
			shrinkTween.Completed:Connect(function()
				frame.Visible = false
				-- Reset size for next open
				frame.Size = UDim2.new(0, 520, 0, 440)
				frame.BackgroundTransparency = 0
			end)
		end
		-- Toggle blur when GUI is shown/hidden
		if open then
			blur.Size = 5
		else
			blur.Size = 0
		end
	elseif input.KeyCode == Enum.KeyCode.F3 then
		shutdown()
		return
	end
end))

-- Hitbox Expander keybind handler
table.insert(connections, UIS.InputBegan:Connect(function(input, gpe)
	if destroyed or gpe then return end
	if hbeKeybind and input.KeyCode == hbeKeybind then
		hbeEnabled = not hbeEnabled
		if hbeEnabled then
			applyHitboxLive()
		else
			resetAllHitboxes()
		end
	end
end))

miniBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		TweenService:Create(frame, TweenInfo.new(0.35), {Size = UDim2.new(0,520,0,55)}):Play()
		scroll.Visible = false
		categoriesFrame.Visible = false
	else
		TweenService:Create(frame, TweenInfo.new(0.35), {Size = UDim2.new(0,520,0,440)}):Play()
		task.wait(0.2)
		scroll.Visible = true
		categoriesFrame.Visible = true
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	shutdown()
end)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)
