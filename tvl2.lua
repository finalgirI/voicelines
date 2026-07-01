local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
-- SpeciesData require removed to prevent module loading errors

local TOGGLE_KEY = Enum.KeyCode.RightShift
local ICON_IMAGE = "rbxassetid://107731607621543"
local CUSTOM_FIRE_ICON = "rbxassetid://107731607621543"

--// Fire recolor settings
local fireEnabled = false
local currentR, currentG, currentB = 255, 100, 0

local FIRE_TAGS = {
	"Phasmatos Motus Incendiamos",
	"IncendiaTarget",
	"Incendia",
	"IncendiaHit",
}

local FIRE_TEMPLATE_NAMES = {
	"IncendiaHit",
	"CustomIncendiaHit",
}

local FIRE_NAME_PATTERNS = {
	"fire", "incend", "ignis", "flame", "ember",
	"dragon", "solaris", "phoenix", "infernal", "tornado",
	"solball", "solparticle", "solvictim",
}

local PRESETS = {
	Color3.fromRGB(255, 105, 180), Color3.fromRGB(255, 0, 120), Color3.fromRGB(255, 0, 220),
	Color3.fromRGB(255, 30, 30), Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 230, 0),
	Color3.fromRGB(160, 255, 0), Color3.fromRGB(30, 255, 20), Color3.fromRGB(0, 230, 255),
	Color3.fromRGB(80, 180, 255), Color3.fromRGB(60, 60, 255), Color3.fromRGB(140, 0, 255),
	Color3.fromRGB(160, 0, 220), Color3.fromRGB(100, 0, 150), Color3.fromRGB(240, 240, 240),
	Color3.fromRGB(190, 190, 190), Color3.fromRGB(75, 75, 75), Color3.fromRGB(0, 0, 0),
	Color3.fromRGB(255, 100, 80), Color3.fromRGB(30, 210, 200), Color3.fromRGB(50, 255, 170),
	Color3.fromRGB(180, 90, 0),
}

--// Auto Ictus settings
local autoIctusEnabled = false
local autoIctusDebounce = false
local AUTO_ICTUS_RANGE = 50

do
local AUTO_ICTUS_ANIMS = {
	["81743171989186"] = true,
	["71157109677249"] = true,
	["12308799798"] = true,
	["12308812216"] = true,
	["13632446588"] = true,
	["13632450363"] = true,
	["10748176216"] = true,
}

--// ESP settings
local espEnabled = false
local ESP_WHITELIST = {
	-- Add Roblox usernames here to restrict ESP access.
	-- If this table is empty, ESP is available to everyone.
	-- Example: ["RobloxUser"] = true,
}
local spectatingPlayer = nil
local spectatingMode = nil -- "body" or "astral"
local camlockEnabled = false
local camlockTarget = nil -- the player being camlocked
local camlockKeybind = Enum.KeyCode.E
local camlockListening = false -- waiting for new keybind input
local antiAnnoyEnabled = false
local antiAnnoyConnections = {}
local antiStunEnabled = false
local DEFAULT_WALK_SPEED = 16
local espObjects = {} -- [player] = esp data
local espPlayerRows = {} -- [player] = row UI elements
local updatePlayerRowAstralState -- forward declaration

local function isEspWhitelisted()
	if next(ESP_WHITELIST) == nil then return true end
	return ESP_WHITELIST[LocalPlayer.Name] == true
end

local function getCharacterName(player)
	return player:GetAttribute("CharacterName") or player:GetAttribute("DisplayName") or player.DisplayName
end

local SPECIES_INFO = {
	["Heretic"] = {displayName = "Heretic", color = Color3.fromRGB(188, 101, 169)},
	["Hybrid"] = {displayName = "Hybrid", color = Color3.fromRGB(245, 185, 102)},
	["Original"] = {displayName = "Original", color = Color3.fromRGB(178, 58, 64)},
	["Phoenix"] = {displayName = "Phoenix", color = Color3.fromRGB(223, 129, 96)},
	["Siphoner"] = {displayName = "Siphoner", color = Color3.fromRGB(114, 147, 202)},
	["Tribrid"] = {displayName = "Tribrid", color = Color3.fromRGB(36, 70, 242)},
	["Transitioning Vampire"] = {displayName = "Transitioning Vampire", color = Color3.fromRGB(138, 49, 52)},
	["Transitioning Heretic"] = {displayName = "Transitioning Heretic", color = Color3.fromRGB(188, 101, 169)},
	["Transitioning Hybrid"] = {displayName = "Transitioning Hybrid", color = Color3.fromRGB(245, 185, 102)},
	["Transitioning Tribrid"] = {displayName = "Transitioning Tibrid", color = Color3.fromRGB(36, 70, 242)},
	["Vampire"] = {displayName = "Vampire", color = Color3.fromRGB(205, 54, 59)},
	["Werewitch"] = {displayName = "Werewitch", color = Color3.fromRGB(201, 69, 150)},
	["Werewolf"] = {displayName = "Werewolf", color = Color3.fromRGB(249, 228, 103)},
	["Witch"] = {displayName = "Witch", color = Color3.fromRGB(195, 145, 195)},
	["Mortal"] = {displayName = "Mortal", color = Color3.fromRGB(195, 145, 195)},
	["Hunter"] = {displayName = "Hunter", color = Color3.fromRGB(120, 199, 114)},
	["Immortal"] = {displayName = "Immortal", color = Color3.fromRGB(126, 53, 248)},
	["Elder Witch"] = {displayName = "Elder Witch", color = Color3.fromRGB(195, 145, 195)},
	["Muse"] = {displayName = "Muse", color = Color3.fromRGB(254, 194, 14)},
	["Fairy"] = {displayName = "Fairy", color = Color3.fromRGB(254, 194, 14)},
}

local function getSpeciesInfo(character)
	if not character then return nil end
	local speciesType = character:GetAttribute("SpecieType")
	if not speciesType then return nil end
	local key = tostring(speciesType)
	local info = SPECIES_INFO[key]
	if info then
		return info.displayName, info.color
	end
	return key, Color3.fromRGB(230, 230, 240)
end

local function normalizeAnimId(id)
	local num = string.match(tostring(id), "%d+")
	return num or id
end

local function tryEquipIctus()
	if not autoIctusEnabled then return end
	if autoIctusDebounce then return end

	autoIctusDebounce = true

	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local abilityService = remotes and remotes:FindFirstChild("AbilityService")
	local toServer = abilityService and abilityService:FindFirstChild("ToServer")
	local abilitySelected = toServer and toServer:FindFirstChild("AbilitySelected")

	if abilitySelected then
		abilitySelected:FireServer("Ictus")
	end

	task.delay(2, function()
		autoIctusDebounce = false
	end)
end

local function hookAnimatorForAutoIctus(animator, character)
	animator.AnimationPlayed:Connect(function(track)
		if not autoIctusEnabled then return end
		if autoIctusDebounce then return end

		local myChar = LocalPlayer.Character
		if not myChar then return end
		local myRoot = myChar:FindFirstChild("HumanoidRootPart")
		if not myRoot then return end

		local theirRoot = character:FindFirstChild("HumanoidRootPart")
		if not theirRoot then return end

		local dist = (theirRoot.Position - myRoot.Position).Magnitude
		if dist > AUTO_ICTUS_RANGE then return end

		local anim = track.Animation
		if not anim then return end

		local animId = normalizeAnimId(anim.AnimationId)
		if AUTO_ICTUS_ANIMS[animId] then
			tryEquipIctus()
		end
	end)
end

local function hookCharacterForAutoIctus(character)
	if character == LocalPlayer.Character then return end

	local function tryHookAnimator(humanoid)
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			hookAnimatorForAutoIctus(animator, character)
		else
			humanoid.ChildAdded:Connect(function(child)
				if child:IsA("Animator") then
					hookAnimatorForAutoIctus(child, character)
				end
			end)
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		tryHookAnimator(humanoid)
	else
		local conn
		conn = character.ChildAdded:Connect(function(child)
			if child:IsA("Humanoid") then
				conn:Disconnect()
				tryHookAnimator(child)
			end
		end)
	end
end

local function onPlayerAddedForAutoIctus(player)
	if player == LocalPlayer then return end
	player.CharacterAdded:Connect(hookCharacterForAutoIctus)
	if player.Character then
		hookCharacterForAutoIctus(player.Character)
	end
end

for _, player in Players:GetPlayers() do
	onPlayerAddedForAutoIctus(player)
end

Players.PlayerAdded:Connect(onPlayerAddedForAutoIctus)
end

local applyColor, clearColor

do
local partConnections = {}

local function getColor()
	local c = Color3.fromRGB(currentR, currentG, currentB)
	return c, ColorSequence.new(c)
end

local function recolorInstance(inst, colorSeq, color3)
	if inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail") then
		inst.Color = colorSeq
	elseif inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
		inst.Color = color3
	elseif inst:IsA("Fire") then
		inst.Color = color3
		inst.SecondaryColor = color3
	elseif inst:IsA("Smoke") then
		inst.Color = color3
	end
end

local function recolorPart(part, colorSeq, color3)
	recolorInstance(part, colorSeq, color3)
	for _, child in part:GetDescendants() do
		recolorInstance(child, colorSeq, color3)
	end
end

local function recolorFireTemplates(colorSeq, color3)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local particles = assets and assets:FindFirstChild("Particles")
	if not particles then return end

	for _, templateName in ipairs(FIRE_TEMPLATE_NAMES) do
		local template = particles:FindFirstChild(templateName)
		if template then
			recolorPart(template, colorSeq, color3)
		end
	end
end

function applyColor()
	if not fireEnabled then return end

	local color3, colorSeq = getColor()
	recolorFireTemplates(colorSeq, color3)
	LocalPlayer:SetAttribute("CustomColor", colorSeq)

	for _, tagName in ipairs(FIRE_TAGS) do
		for _, part in CollectionService:GetTagged(tagName) do
			part:SetAttribute("CustomColor", colorSeq)
			part:SetAttribute("FireColor", colorSeq)
			recolorPart(part, colorSeq, color3)
		end
	end
end

function clearColor()
	LocalPlayer:SetAttribute("CustomColor", nil)
end

local function onPartTagged(part)
	if not fireEnabled then return end

	local color3, colorSeq = getColor()
	part:SetAttribute("CustomColor", colorSeq)
	part:SetAttribute("FireColor", colorSeq)
	recolorPart(part, colorSeq, color3)

	if not partConnections[part] then
		partConnections[part] = {}

		local conn = part.DescendantAdded:Connect(function(descendant)
			if not fireEnabled then return end
			local c3, cs = getColor()
			recolorInstance(descendant, cs, c3)
			for _, child in descendant:GetDescendants() do
				recolorInstance(child, cs, c3)
			end
		end)

		table.insert(partConnections[part], conn)
	end

	for _, delayTime in {0.05, 0.2, 0.5} do
		task.delay(delayTime, function()
			if fireEnabled and part and part.Parent then
				local c3, cs = getColor()
				recolorPart(part, cs, c3)
			end
		end)
	end
end

local function onPartUntagged(part)
	if partConnections[part] then
		for _, conn in ipairs(partConnections[part]) do
			conn:Disconnect()
		end
		partConnections[part] = nil
	end
end

local function hookCharacter(character)
	local function isFireRelated(inst)
		local name = string.lower(inst.Name)
		for _, pattern in ipairs(FIRE_NAME_PATTERNS) do
			if string.find(name, pattern) then
				return true
			end
		end

		if inst.Parent then
			local parentName = string.lower(inst.Parent.Name)
			for _, pattern in ipairs(FIRE_NAME_PATTERNS) do
				if string.find(parentName, pattern) then
					return true
				end
			end
		end

		return false
	end

	local conn
	conn = character.DescendantAdded:Connect(function(descendant)
		if not fireEnabled then return end
		task.defer(function()
			if descendant and descendant.Parent and isFireRelated(descendant) then
				local c3, cs = getColor()
				recolorInstance(descendant, cs, c3)
				for _, child in descendant:GetDescendants() do
					recolorInstance(child, cs, c3)
				end
			end
		end)
	end)

	character.AncestryChanged:Connect(function()
		if not character:IsDescendantOf(game) and conn then
			conn:Disconnect()
		end
	end)
end

for _, tagName in ipairs(FIRE_TAGS) do
	CollectionService:GetInstanceAddedSignal(tagName):Connect(onPartTagged)
	CollectionService:GetInstanceRemovedSignal(tagName):Connect(onPartUntagged)
end

LocalPlayer.CharacterAdded:Connect(hookCharacter)
if LocalPlayer.Character then
	task.spawn(hookCharacter, LocalPlayer.Character)
end
end

--// UI helpers
local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, transparency, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.Parent = parent
	return s
end

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CustomIncendiasGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 540, 0, 400)
main.Position = UDim2.new(0.5, -270, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
main.BorderSizePixel = 0
main.Parent = gui
addCorner(main, 12)
addStroke(main, Color3.fromRGB(35, 38, 48), 0.15)

--// Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(16, 17, 24)
header.BorderSizePixel = 0
header.Parent = main
addCorner(header, 12)

local headerIcon = Instance.new("ImageLabel")
headerIcon.Size = UDim2.new(0, 20, 0, 20)
headerIcon.Position = UDim2.new(0, 14, 0.5, -10)
headerIcon.BackgroundTransparency = 1
headerIcon.Image = CUSTOM_FIRE_ICON
headerIcon.ScaleType = Enum.ScaleType.Fit
headerIcon.Parent = header

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(0, 200, 0, 44)
headerTitle.Position = UDim2.new(0, 40, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "TVL 2"
headerTitle.TextColor3 = Color3.fromRGB(230, 230, 240)
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 16
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.TextYAlignment = Enum.TextYAlignment.Center
headerTitle.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(140, 142, 155)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.AutoButtonColor = false
closeBtn.Parent = header
addCorner(closeBtn, 6)
closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 30, 30), TextColor3 = Color3.fromRGB(255, 100, 100)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 27, 36), TextColor3 = Color3.fromRGB(140, 142, 155)}):Play()
end)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -78, 0.5, -16)
minBtn.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(140, 142, 155)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.AutoButtonColor = false
minBtn.Parent = header
addCorner(minBtn, 6)
minBtn.MouseEnter:Connect(function()
	TweenService:Create(minBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 38, 50), TextColor3 = Color3.fromRGB(220, 220, 230)}):Play()
end)
minBtn.MouseLeave:Connect(function()
	TweenService:Create(minBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 27, 36), TextColor3 = Color3.fromRGB(140, 142, 155)}):Play()
end)

-- Header bottom line
local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, -24, 0, 1)
headerLine.Position = UDim2.new(0, 12, 1, -1)
headerLine.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
headerLine.BorderSizePixel = 0
headerLine.Parent = header

--// Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 80, 1, -44)
sidebar.Position = UDim2.new(0, 0, 0, 44)
sidebar.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sidebarLine = Instance.new("Frame")
sidebarLine.Size = UDim2.new(0, 1, 1, -16)
sidebarLine.Position = UDim2.new(1, -1, 0, 8)
sidebarLine.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
sidebarLine.BorderSizePixel = 0
sidebarLine.Parent = sidebar

local tabPages = {}
local selectedTabBtn = nil
local tabCount = 0

local function makeTab(icon, label, isDefault)
	tabCount = tabCount + 1
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -8, 0, 56)
	btn.Position = UDim2.new(0, 4, 0, (tabCount - 1) * 60 + 8)
	btn.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = sidebar
	addCorner(btn, 8)

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 3, 0, 20)
	indicator.Position = UDim2.new(0, 0, 0.5, -10)
	indicator.BackgroundColor3 = Color3.fromRGB(88, 72, 255)
	indicator.BorderSizePixel = 0
	indicator.BackgroundTransparency = 1
	indicator.Parent = btn
	addCorner(indicator, 2)

	local ic = Instance.new("ImageLabel")
	ic.Size = UDim2.new(0, 20, 0, 20)
	ic.Position = UDim2.new(0.5, -10, 0, 6)
	ic.BackgroundTransparency = 1
	ic.Image = icon
	ic.ScaleType = Enum.ScaleType.Fit
	ic.ImageColor3 = Color3.fromRGB(100, 102, 120)
	ic.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 16)
	lbl.Position = UDim2.new(0, 0, 0, 30)
	lbl.BackgroundTransparency = 1
	lbl.Text = label
	lbl.TextColor3 = Color3.fromRGB(100, 102, 120)
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.Parent = btn

	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, -96, 1, -60)
	page.Position = UDim2.new(0, 88, 0, 52)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = main

	local function selectTab()
		if selectedTabBtn then
			local prev = tabPages[selectedTabBtn]
			TweenService:Create(selectedTabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(14, 15, 20)}):Play()
			TweenService:Create(prev.indicator, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
			TweenService:Create(prev.icon, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(100, 102, 120)}):Play()
			TweenService:Create(prev.label, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(100, 102, 120)}):Play()
			prev.page.Visible = false
		end
		selectedTabBtn = btn
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 18, 38)}):Play()
		TweenService:Create(indicator, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
		TweenService:Create(ic, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(88, 72, 255)}):Play()
		TweenService:Create(lbl, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(88, 72, 255)}):Play()
		page.Visible = true
	end

	btn.MouseEnter:Connect(function()
		if selectedTabBtn ~= btn then
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18, 19, 28)}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if selectedTabBtn ~= btn then
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(14, 15, 20)}):Play()
		end
	end)

	btn.MouseButton1Click:Connect(selectTab)

	tabPages[btn] = {page = page, indicator = indicator, icon = ic, label = lbl}

	if isDefault then
		selectTab()
	end

	return page
end

local funTab = makeTab(CUSTOM_FIRE_ICON, "Fun", true)
local mainTab = makeTab("rbxassetid://3926305904", "Main", false)
local scriptTab = makeTab(ICON_IMAGE, "Script", false)
local aimTab = makeTab("rbxassetid://3926305904", "Aim", false)
local visualsTab = makeTab("rbxassetid://3926305904", "Visuals", false)

--// Placeholder content for other tabs
local function addPlaceholder(tabPage, title, desc)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 24)
	lbl.Position = UDim2.new(0, 0, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = title
	lbl.TextColor3 = Color3.fromRGB(200, 202, 215)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = tabPage

	local d = Instance.new("TextLabel")
	d.Size = UDim2.new(1, 0, 0, 18)
	d.Position = UDim2.new(0, 0, 0, 28)
	d.BackgroundTransparency = 1
	d.Text = desc
	d.TextColor3 = Color3.fromRGB(110, 112, 128)
	d.Font = Enum.Font.Gotham
	d.TextSize = 12
	d.TextXAlignment = Enum.TextXAlignment.Left
	d.Parent = tabPage

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 38)
	row.Position = UDim2.new(0, 0, 0, 56)
	row.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
	row.BorderSizePixel = 0
	row.Parent = tabPage
	addCorner(row, 8)
	addStroke(row, Color3.fromRGB(30, 32, 42), 0.3)

	local rowLabel = Instance.new("TextLabel")
	rowLabel.Size = UDim2.new(1, -20, 1, 0)
	rowLabel.Position = UDim2.new(0, 14, 0, 0)
	rowLabel.BackgroundTransparency = 1
	rowLabel.Text = "Coming soon"
	rowLabel.TextColor3 = Color3.fromRGB(80, 82, 100)
	rowLabel.Font = Enum.Font.GothamSemibold
	rowLabel.TextSize = 13
	rowLabel.TextXAlignment = Enum.TextXAlignment.Left
	rowLabel.TextYAlignment = Enum.TextYAlignment.Center
	rowLabel.Parent = row
end

addPlaceholder(scriptTab, "Script", "Script execution and management.")
addPlaceholder(visualsTab, "Visuals", "Visual enhancement options.")

--// Aim tab content (Camlock)
local aimScroll = Instance.new("ScrollingFrame")
aimScroll.Size = UDim2.new(1, 0, 1, 0)
aimScroll.BackgroundTransparency = 1
aimScroll.BorderSizePixel = 0
aimScroll.ScrollBarThickness = 4
aimScroll.ScrollBarImageColor3 = Color3.fromRGB(88, 72, 255)
aimScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
aimScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
aimScroll.Parent = aimTab

local aimLayout = Instance.new("UIListLayout")
aimLayout.SortOrder = Enum.SortOrder.LayoutOrder
aimLayout.Padding = UDim.new(0, 8)
aimLayout.Parent = aimScroll

local aimPadding = Instance.new("UIPadding")
aimPadding.PaddingTop = UDim.new(0, 4)
aimPadding.PaddingLeft = UDim.new(0, 4)
aimPadding.PaddingRight = UDim.new(0, 4)
aimPadding.Parent = aimScroll

-- Camlock Category
local camlockCategory = Instance.new("Frame")
camlockCategory.Size = UDim2.new(1, 0, 0, 180)
camlockCategory.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
camlockCategory.BorderSizePixel = 0
camlockCategory.LayoutOrder = 1
camlockCategory.Parent = aimScroll
addCorner(camlockCategory, 8)
addStroke(camlockCategory, Color3.fromRGB(30, 32, 42), 0.3)

local camlockHeader = Instance.new("TextLabel")
camlockHeader.Size = UDim2.new(1, 0, 0, 28)
camlockHeader.BackgroundTransparency = 1
camlockHeader.Text = "  Camlock"
camlockHeader.TextColor3 = Color3.fromRGB(88, 72, 255)
camlockHeader.Font = Enum.Font.GothamBold
camlockHeader.TextSize = 14
camlockHeader.TextXAlignment = Enum.TextXAlignment.Left
camlockHeader.TextYAlignment = Enum.TextYAlignment.Center
camlockHeader.Parent = camlockCategory

-- Camlock toggle row
local camlockToggleRow = Instance.new("Frame")
camlockToggleRow.Size = UDim2.new(1, -28, 0, 38)
camlockToggleRow.Position = UDim2.new(0, 14, 0, 32)
camlockToggleRow.BackgroundColor3 = Color3.fromRGB(22, 23, 32)
camlockToggleRow.BorderSizePixel = 0
camlockToggleRow.Parent = camlockCategory
addCorner(camlockToggleRow, 8)

local camlockLabel = Instance.new("TextLabel")
camlockLabel.Size = UDim2.new(0, 100, 1, 0)
camlockLabel.Position = UDim2.new(0, 14, 0, 0)
camlockLabel.BackgroundTransparency = 1
camlockLabel.Text = "Enabled"
camlockLabel.TextColor3 = Color3.fromRGB(200, 202, 215)
camlockLabel.Font = Enum.Font.GothamBold
camlockLabel.TextSize = 13
camlockLabel.TextXAlignment = Enum.TextXAlignment.Left
camlockLabel.TextYAlignment = Enum.TextYAlignment.Center
camlockLabel.Parent = camlockToggleRow

local camlockToggle = Instance.new("TextButton")
camlockToggle.Size = UDim2.new(0, 48, 0, 24)
camlockToggle.Position = UDim2.new(1, -62, 0.5, -12)
camlockToggle.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
camlockToggle.Text = ""
camlockToggle.AutoButtonColor = false
camlockToggle.Parent = camlockToggleRow
addCorner(camlockToggle, 12)

local camlockKnob = Instance.new("Frame")
camlockKnob.Size = UDim2.new(0, 18, 0, 18)
camlockKnob.Position = UDim2.new(0, 3, 0, 3)
camlockKnob.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
camlockKnob.BorderSizePixel = 0
camlockKnob.Parent = camlockToggle
addCorner(camlockKnob, 9)

local function setCamlockToggleVisual(state)
	if state then
		TweenService:Create(camlockToggle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(88, 72, 255)
		}):Play()
		TweenService:Create(camlockKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -21, 0, 3)
		}):Play()
	else
		TweenService:Create(camlockToggle, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(50, 52, 65)
		}):Play()
		TweenService:Create(camlockKnob, TweenInfo.new(0.15), {
			Position = UDim2.new(0, 3, 0, 3)
		}):Play()
	end
end

camlockToggle.MouseButton1Click:Connect(function()
	camlockEnabled = not camlockEnabled
	setCamlockToggleVisual(camlockEnabled)
	if not camlockEnabled then
		camlockTarget = nil
		camlockTargetLabel.Text = "Target: None"
		camlockTargetLabel.TextColor3 = Color3.fromRGB(110, 112, 128)
		-- Restore camera to local player
		local character = LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				workspace.CurrentCamera.CameraSubject = humanoid
			end
		end
	end
end)

-- Keybind row
local camlockKeybindRow = Instance.new("Frame")
camlockKeybindRow.Size = UDim2.new(1, -28, 0, 38)
camlockKeybindRow.Position = UDim2.new(0, 14, 0, 76)
camlockKeybindRow.BackgroundColor3 = Color3.fromRGB(22, 23, 32)
camlockKeybindRow.BorderSizePixel = 0
camlockKeybindRow.Parent = camlockCategory
addCorner(camlockKeybindRow, 8)

local camlockKeybindLabel = Instance.new("TextLabel")
camlockKeybindLabel.Size = UDim2.new(0, 100, 1, 0)
camlockKeybindLabel.Position = UDim2.new(0, 14, 0, 0)
camlockKeybindLabel.BackgroundTransparency = 1
camlockKeybindLabel.Text = "Keybind"
camlockKeybindLabel.TextColor3 = Color3.fromRGB(200, 202, 215)
camlockKeybindLabel.Font = Enum.Font.GothamBold
camlockKeybindLabel.TextSize = 13
camlockKeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
camlockKeybindLabel.TextYAlignment = Enum.TextYAlignment.Center
camlockKeybindLabel.Parent = camlockKeybindRow

local camlockKeybindBtn = Instance.new("TextButton")
camlockKeybindBtn.Size = UDim2.new(0, 90, 0, 24)
camlockKeybindBtn.Position = UDim2.new(1, -104, 0.5, -12)
camlockKeybindBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
camlockKeybindBtn.Text = camlockKeybind.Name
camlockKeybindBtn.TextColor3 = Color3.fromRGB(200, 202, 215)
camlockKeybindBtn.Font = Enum.Font.GothamBold
camlockKeybindBtn.TextSize = 11
camlockKeybindBtn.AutoButtonColor = false
camlockKeybindBtn.Parent = camlockKeybindRow
addCorner(camlockKeybindBtn, 6)

camlockKeybindBtn.MouseButton1Click:Connect(function()
	camlockListening = true
	camlockKeybindBtn.Text = "..."
	camlockKeybindBtn.TextColor3 = Color3.fromRGB(88, 72, 255)
end)

-- Target display
local camlockTargetLabel = Instance.new("TextLabel")
camlockTargetLabel.Size = UDim2.new(1, -28, 0, 20)
camlockTargetLabel.Position = UDim2.new(0, 14, 0, 120)
camlockTargetLabel.BackgroundTransparency = 1
camlockTargetLabel.Text = "Target: None"
camlockTargetLabel.TextColor3 = Color3.fromRGB(110, 112, 128)
camlockTargetLabel.Font = Enum.Font.GothamSemibold
camlockTargetLabel.TextSize = 12
camlockTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
camlockTargetLabel.Parent = camlockCategory

-- Camlock description
local camlockDesc = Instance.new("TextLabel")
camlockDesc.Size = UDim2.new(1, -28, 0, 30)
camlockDesc.Position = UDim2.new(0, 14, 0, 140)
camlockDesc.BackgroundTransparency = 1
camlockDesc.Text = "Locks your camera to the nearest player's torso. Enable the toggle, then press the keybind to lock/unlock on a target. Turning the toggle off clears any active lock."
camlockDesc.TextColor3 = Color3.fromRGB(120, 122, 138)
camlockDesc.Font = Enum.Font.Gotham
camlockDesc.TextSize = 11
camlockDesc.TextXAlignment = Enum.TextXAlignment.Left
camlockDesc.TextYAlignment = Enum.TextYAlignment.Top
camlockDesc.TextWrapped = true
camlockDesc.Parent = camlockCategory

--// Aim Assist Category
local aimAssistEnabled = false
local aimAssistRange = 100
local aimAssistFOV = 120 -- pixels radius around mouse to detect targets
local aimAssistTarget = nil
local aimAssistHighlight = nil

local aimAssistCategory = Instance.new("Frame")
aimAssistCategory.Size = UDim2.new(1, 0, 0, 210)
aimAssistCategory.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
aimAssistCategory.BorderSizePixel = 0
aimAssistCategory.LayoutOrder = 2
aimAssistCategory.Parent = aimScroll
addCorner(aimAssistCategory, 8)
addStroke(aimAssistCategory, Color3.fromRGB(30, 32, 42), 0.3)

local aimAssistHeader = Instance.new("TextLabel")
aimAssistHeader.Size = UDim2.new(1, 0, 0, 28)
aimAssistHeader.BackgroundTransparency = 1
aimAssistHeader.Text = "  Aim Assist"
aimAssistHeader.TextColor3 = Color3.fromRGB(88, 72, 255)
aimAssistHeader.Font = Enum.Font.GothamBold
aimAssistHeader.TextSize = 14
aimAssistHeader.TextXAlignment = Enum.TextXAlignment.Left
aimAssistHeader.TextYAlignment = Enum.TextYAlignment.Center
aimAssistHeader.Parent = aimAssistCategory

-- Aim Assist toggle row
local aimAssistToggleRow = Instance.new("Frame")
aimAssistToggleRow.Size = UDim2.new(1, -28, 0, 38)
aimAssistToggleRow.Position = UDim2.new(0, 14, 0, 32)
aimAssistToggleRow.BackgroundColor3 = Color3.fromRGB(22, 23, 32)
aimAssistToggleRow.BorderSizePixel = 0
aimAssistToggleRow.Parent = aimAssistCategory
addCorner(aimAssistToggleRow, 8)

local aimAssistLabel = Instance.new("TextLabel")
aimAssistLabel.Size = UDim2.new(0, 100, 1, 0)
aimAssistLabel.Position = UDim2.new(0, 14, 0, 0)
aimAssistLabel.BackgroundTransparency = 1
aimAssistLabel.Text = "Enabled"
aimAssistLabel.TextColor3 = Color3.fromRGB(200, 202, 215)
aimAssistLabel.Font = Enum.Font.GothamBold
aimAssistLabel.TextSize = 13
aimAssistLabel.TextXAlignment = Enum.TextXAlignment.Left
aimAssistLabel.TextYAlignment = Enum.TextYAlignment.Center
aimAssistLabel.Parent = aimAssistToggleRow

local aimAssistToggle = Instance.new("TextButton")
aimAssistToggle.Size = UDim2.new(0, 48, 0, 24)
aimAssistToggle.Position = UDim2.new(1, -62, 0.5, -12)
aimAssistToggle.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
aimAssistToggle.Text = ""
aimAssistToggle.AutoButtonColor = false
aimAssistToggle.Parent = aimAssistToggleRow
addCorner(aimAssistToggle, 12)

local aimAssistKnob = Instance.new("Frame")
aimAssistKnob.Size = UDim2.new(0, 18, 0, 18)
aimAssistKnob.Position = UDim2.new(0, 3, 0, 3)
aimAssistKnob.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
aimAssistKnob.BorderSizePixel = 0
aimAssistKnob.Parent = aimAssistToggle
addCorner(aimAssistKnob, 9)

local function setAimAssistVisual(state)
	if state then
		TweenService:Create(aimAssistToggle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(88, 72, 255)
		}):Play()
		TweenService:Create(aimAssistKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -21, 0, 3)
		}):Play()
	else
		TweenService:Create(aimAssistToggle, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(50, 52, 65)
		}):Play()
		TweenService:Create(aimAssistKnob, TweenInfo.new(0.15), {
			Position = UDim2.new(0, 3, 0, 3)
		}):Play()
	end
end

-- FOV slider row
local aimAssistFOVRow = Instance.new("Frame")
aimAssistFOVRow.Size = UDim2.new(1, -28, 0, 38)
aimAssistFOVRow.Position = UDim2.new(0, 14, 0, 76)
aimAssistFOVRow.BackgroundColor3 = Color3.fromRGB(22, 23, 32)
aimAssistFOVRow.BorderSizePixel = 0
aimAssistFOVRow.Parent = aimAssistCategory
addCorner(aimAssistFOVRow, 8)

local aimAssistFOVLabel = Instance.new("TextLabel")
aimAssistFOVLabel.Size = UDim2.new(0, 80, 1, 0)
aimAssistFOVLabel.Position = UDim2.new(0, 14, 0, 0)
aimAssistFOVLabel.BackgroundTransparency = 1
aimAssistFOVLabel.Text = "FOV (px)"
aimAssistFOVLabel.TextColor3 = Color3.fromRGB(200, 202, 215)
aimAssistFOVLabel.Font = Enum.Font.GothamBold
aimAssistFOVLabel.TextSize = 13
aimAssistFOVLabel.TextXAlignment = Enum.TextXAlignment.Left
aimAssistFOVLabel.TextYAlignment = Enum.TextYAlignment.Center
aimAssistFOVLabel.Parent = aimAssistFOVRow

local aimAssistFOVValue = Instance.new("TextLabel")
aimAssistFOVValue.Size = UDim2.new(0, 34, 0, 18)
aimAssistFOVValue.Position = UDim2.new(1, -48, 0.5, -9)
aimAssistFOVValue.BackgroundColor3 = Color3.fromRGB(20, 21, 28)
aimAssistFOVValue.BackgroundTransparency = 0.5
aimAssistFOVValue.Text = tostring(aimAssistFOV)
aimAssistFOVValue.TextColor3 = Color3.fromRGB(200, 202, 215)
aimAssistFOVValue.Font = Enum.Font.Gotham
aimAssistFOVValue.TextSize = 11
aimAssistFOVValue.Parent = aimAssistFOVRow
addCorner(aimAssistFOVValue, 5)

local aimAssistFOVBar = Instance.new("Frame")
aimAssistFOVBar.Size = UDim2.new(1, -160, 0, 5)
aimAssistFOVBar.Position = UDim2.new(0, 96, 0.5, -2.5)
aimAssistFOVBar.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
aimAssistFOVBar.BorderSizePixel = 0
aimAssistFOVBar.Parent = aimAssistFOVRow
addCorner(aimAssistFOVBar, 3)

local aimAssistFOVFill = Instance.new("Frame")
aimAssistFOVFill.Size = UDim2.new((aimAssistFOV - 30) / 270, 0, 1, 0)
aimAssistFOVFill.BackgroundColor3 = Color3.fromRGB(88, 72, 255)
aimAssistFOVFill.BorderSizePixel = 0
aimAssistFOVFill.Parent = aimAssistFOVBar
addCorner(aimAssistFOVFill, 3)

local aimAssistFOVDot = Instance.new("Frame")
aimAssistFOVDot.Size = UDim2.new(0, 13, 0, 13)
aimAssistFOVDot.Position = UDim2.new((aimAssistFOV - 30) / 270, -6.5, 0.5, -6.5)
aimAssistFOVDot.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
aimAssistFOVDot.BorderSizePixel = 0
aimAssistFOVDot.ZIndex = 2
aimAssistFOVDot.Parent = aimAssistFOVBar
addCorner(aimAssistFOVDot, 7)
addStroke(aimAssistFOVDot, Color3.fromRGB(88, 72, 255), 0.2, 1.5)

local aimAssistFOVDragging = false
local function setAimAssistFOV(v)
	v = math.clamp(math.floor(v), 30, 300)
	aimAssistFOV = v
	aimAssistFOVValue.Text = tostring(v)
	local rel = (v - 30) / 270
	aimAssistFOVFill.Size = UDim2.new(rel, 0, 1, 0)
	aimAssistFOVDot.Position = UDim2.new(rel, -6.5, 0.5, -6.5)
end

aimAssistFOVBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		aimAssistFOVDragging = true
		local rel = math.clamp((input.Position.X - aimAssistFOVBar.AbsolutePosition.X) / aimAssistFOVBar.AbsoluteSize.X, 0, 1)
		setAimAssistFOV(30 + rel * 270)
	end
end)
aimAssistFOVDot.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		aimAssistFOVDragging = true
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		aimAssistFOVDragging = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if aimAssistFOVDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local rel = math.clamp((input.Position.X - aimAssistFOVBar.AbsolutePosition.X) / aimAssistFOVBar.AbsoluteSize.X, 0, 1)
		setAimAssistFOV(30 + rel * 270)
	end
end)

-- Aim Assist target display
local aimAssistTargetLabel = Instance.new("TextLabel")
aimAssistTargetLabel.Size = UDim2.new(1, -28, 0, 20)
aimAssistTargetLabel.Position = UDim2.new(0, 14, 0, 120)
aimAssistTargetLabel.BackgroundTransparency = 1
aimAssistTargetLabel.Text = "Target: None"
aimAssistTargetLabel.TextColor3 = Color3.fromRGB(110, 112, 128)
aimAssistTargetLabel.Font = Enum.Font.GothamSemibold
aimAssistTargetLabel.TextSize = 12
aimAssistTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
aimAssistTargetLabel.Parent = aimAssistCategory

-- Aim Assist description
local aimAssistDesc = Instance.new("TextLabel")
aimAssistDesc.Size = UDim2.new(1, -28, 0, 40)
aimAssistDesc.Position = UDim2.new(0, 14, 0, 144)
aimAssistDesc.BackgroundTransparency = 1
aimAssistDesc.Text = "Highlights and assists your aim toward the nearest player when your cursor is near them. Adjust the FOV slider to control detection radius."
aimAssistDesc.TextColor3 = Color3.fromRGB(120, 122, 138)
aimAssistDesc.Font = Enum.Font.Gotham
aimAssistDesc.TextSize = 11
aimAssistDesc.TextXAlignment = Enum.TextXAlignment.Left
aimAssistDesc.TextYAlignment = Enum.TextYAlignment.Top
aimAssistDesc.TextWrapped = true
aimAssistDesc.Parent = aimAssistCategory

aimAssistToggle.MouseButton1Click:Connect(function()
	aimAssistEnabled = not aimAssistEnabled
	setAimAssistVisual(aimAssistEnabled)
	if not aimAssistEnabled then
		aimAssistTarget = nil
		aimAssistTargetLabel.Text = "Target: None"
		aimAssistTargetLabel.TextColor3 = Color3.fromRGB(110, 112, 128)
		-- Remove highlight
		for _, child in ipairs(workspace:GetChildren()) do
			local hl = child:FindFirstChild("AimAssistHighlight", true)
			if hl then hl:Destroy() end
		end
	end
end)

--// Camlock keybind input handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- Handle keybind rebinding
	if camlockListening then
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			camlockKeybind = input.KeyCode
			camlockListening = false
			camlockKeybindBtn.Text = camlockKeybind.Name
			camlockKeybindBtn.TextColor3 = Color3.fromRGB(200, 202, 215)
		end
		return
	end

	-- Camlock keybind: toggle target lock (only works when enabled)
	if input.KeyCode == camlockKeybind then
		if not camlockEnabled then return end

		if camlockTarget then
			-- Unlock from current target
			camlockTarget = nil
			camlockTargetLabel.Text = "Target: None"
			camlockTargetLabel.TextColor3 = Color3.fromRGB(110, 112, 128)
			-- Restore camera to local player
			local character = LocalPlayer.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					workspace.CurrentCamera.CameraSubject = humanoid
				end
			end
		else
			-- Find and lock nearest target
			camlockTarget = getCamlockTarget()
			if camlockTarget then
				local targetName = getCharacterName(camlockTarget) .. " (@" .. camlockTarget.Name .. ")"
				camlockTargetLabel.Text = "Target: " .. targetName
				camlockTargetLabel.TextColor3 = Color3.fromRGB(88, 72, 255)
			end
		end
	end
end)

--// Camlock logic - find closest player to mouse and lock camera to their torso
local function getCamlockTarget()
	local mousePos = UserInputService:GetMouseLocation()
	local camera = workspace.CurrentCamera
	if not camera then return nil end

	local closestPlayer = nil
	local closestAngle = math.huge

	for _, player in Players:GetPlayers() do
		if player == LocalPlayer then continue end
		local character = player.Character
		if not character then continue end
		local torso = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if not torso then continue end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then continue end

		-- Project torso position to screen
		local screenPos, onScreen = camera:WorldToViewportPoint(torso.Position)
		if not onScreen then continue end

		-- Calculate angle distance from mouse to target on screen
		local screenVec = Vector2.new(screenPos.X, screenPos.Y) - mousePos
		local angleDist = screenVec.Magnitude

		if angleDist < closestAngle then
			closestAngle = angleDist
			closestPlayer = player
		end
	end

	-- Only lock if target is reasonably close to mouse (within 300px)
	if closestPlayer and closestAngle < 300 then
		return closestPlayer
	end
	return nil
end

--// Camlock RenderStepped - hard lock camera to target torso
RunService.RenderStepped:Connect(function()
	if not camlockEnabled then return end

	-- Only lock camera if a target was manually selected via keybind
	if not camlockTarget then return end

	-- Validate target still alive and exists
	local character = camlockTarget.Character
	if not character then
		camlockTarget = nil
		camlockTargetLabel.Text = "Target: None"
		camlockTargetLabel.TextColor3 = Color3.fromRGB(110, 112, 128)
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		camlockTarget = nil
		camlockTargetLabel.Text = "Target: None"
		camlockTargetLabel.TextColor3 = Color3.fromRGB(110, 112, 128)
		return
	end

	local torso = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if torso and torso.Parent then
		-- Hard lock: set camera CFrame to look directly at the torso
		local camera = workspace.CurrentCamera
		if camera then
			local camPos = camera.CFrame.Position
			camera.CFrame = CFrame.new(camPos, torso.Position)
		end
	end

	-- Update target label
	local targetName = getCharacterName(camlockTarget) .. " (@" .. camlockTarget.Name .. ")"
	camlockTargetLabel.Text = "Target: " .. targetName
	camlockTargetLabel.TextColor3 = Color3.fromRGB(88, 72, 255)
end)

--// Aim Assist logic - find nearest player to mouse within FOV and highlight
local function getAimAssistTarget()
	local mousePos = UserInputService:GetMouseLocation()
	local camera = workspace.CurrentCamera
	if not camera then return nil end

	local closestPlayer = nil
	local closestDist = aimAssistFOV

	for _, player in Players:GetPlayers() do
		if player == LocalPlayer then continue end
		local character = player.Character
		if not character then continue end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then continue end

		-- Check distance (3D world distance)
		local myChar = LocalPlayer.Character
		if not myChar then continue end
		local myHrp = myChar:FindFirstChild("HumanoidRootPart")
		if not myHrp then continue end
		local worldDist = (hrp.Position - myHrp.Position).Magnitude
		if worldDist > aimAssistRange then continue end

		-- Project to screen and check distance from mouse
		local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
		if not onScreen then continue end

		local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
		if screenDist < closestDist then
			closestDist = screenDist
			closestPlayer = player
		end
	end

	return closestPlayer
end

local function applyAimAssistHighlight(character)
	-- Remove old highlights from all characters
	for _, child in ipairs(workspace:GetChildren()) do
		local hl = child:FindFirstChild("AimAssistHighlight", true)
		if hl then hl:Destroy() end
	end

	if not character then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "AimAssistHighlight"
	highlight.FillColor = Color3.fromRGB(88, 72, 255)
	highlight.FillTransparency = 0.7
	highlight.OutlineColor = Color3.fromRGB(180, 170, 255)
	highlight.OutlineTransparency = 0
	highlight.Adornee = character
	highlight.Parent = character
end

RunService.RenderStepped:Connect(function()
	if not aimAssistEnabled then return end

	local newTarget = getAimAssistTarget()
	if newTarget ~= aimAssistTarget then
		aimAssistTarget = newTarget
		if aimAssistTarget then
			local targetName = getCharacterName(aimAssistTarget) .. " (@" .. aimAssistTarget.Name .. ")"
			aimAssistTargetLabel.Text = "Target: " .. targetName
			aimAssistTargetLabel.TextColor3 = Color3.fromRGB(88, 72, 255)

			-- Apply highlight
			if aimAssistTarget.Character then
				applyAimAssistHighlight(aimAssistTarget.Character)
			end
		else
			aimAssistTargetLabel.Text = "Target: None"
			aimAssistTargetLabel.TextColor3 = Color3.fromRGB(110, 112, 128)
			-- Remove all highlights
			for _, child in ipairs(workspace:GetChildren()) do
				local hl = child:FindFirstChild("AimAssistHighlight", true)
				if hl then hl:Destroy() end
			end
		end
	elseif aimAssistTarget and aimAssistTarget.Character then
		-- Ensure highlight follows the correct character
		local existingHL = aimAssistTarget.Character:FindFirstChild("AimAssistHighlight")
		if not existingHL then
			applyAimAssistHighlight(aimAssistTarget.Character)
		end
	end
end)

--// Main tab content
local mainScroll = Instance.new("ScrollingFrame")
mainScroll.Size = UDim2.new(1, 0, 1, 0)
mainScroll.BackgroundTransparency = 1
mainScroll.BorderSizePixel = 0
mainScroll.ScrollBarThickness = 4
mainScroll.ScrollBarImageColor3 = Color3.fromRGB(88, 72, 255)
mainScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
mainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
mainScroll.Parent = mainTab

local mainLayout = Instance.new("UIListLayout")
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Padding = UDim.new(0, 8)
mainLayout.Parent = mainScroll

local mainPadding = Instance.new("UIPadding")
mainPadding.PaddingTop = UDim.new(0, 4)
mainPadding.PaddingLeft = UDim.new(0, 4)
mainPadding.PaddingRight = UDim.new(0, 4)
mainPadding.Parent = mainScroll

--// Fun tab scroll
local funScroll = Instance.new("ScrollingFrame")
funScroll.Size = UDim2.new(1, 0, 1, 0)
funScroll.BackgroundTransparency = 1
funScroll.BorderSizePixel = 0
funScroll.ScrollBarThickness = 4
funScroll.ScrollBarImageColor3 = Color3.fromRGB(88, 72, 255)
funScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
funScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
funScroll.Parent = funTab

local funLayout = Instance.new("UIListLayout")
funLayout.SortOrder = Enum.SortOrder.LayoutOrder
funLayout.Padding = UDim.new(0, 8)
funLayout.Parent = funScroll

local funPadding = Instance.new("UIPadding")
funPadding.PaddingTop = UDim.new(0, 4)
funPadding.PaddingLeft = UDim.new(0, 4)
funPadding.PaddingRight = UDim.new(0, 4)
funPadding.Parent = funScroll

--// Auto Ictus Category
local autoIctusCategory = Instance.new("Frame")
autoIctusCategory.Size = UDim2.new(1, 0, 0, 120)
autoIctusCategory.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
autoIctusCategory.BorderSizePixel = 0
autoIctusCategory.LayoutOrder = 1
autoIctusCategory.Parent = mainScroll
addCorner(autoIctusCategory, 8)
addStroke(autoIctusCategory, Color3.fromRGB(30, 32, 42), 0.3)

local autoIctusHeader = Instance.new("TextLabel")
autoIctusHeader.Size = UDim2.new(1, 0, 0, 28)
autoIctusHeader.BackgroundTransparency = 1
autoIctusHeader.Text = "  Auto Ictus"
autoIctusHeader.TextColor3 = Color3.fromRGB(88, 72, 255)
autoIctusHeader.Font = Enum.Font.GothamBold
autoIctusHeader.TextSize = 14
autoIctusHeader.TextXAlignment = Enum.TextXAlignment.Left
autoIctusHeader.TextYAlignment = Enum.TextYAlignment.Center
autoIctusHeader.Parent = autoIctusCategory

local autoIctusToggleRow = Instance.new("Frame")
autoIctusToggleRow.Size = UDim2.new(1, -28, 0, 38)
autoIctusToggleRow.Position = UDim2.new(0, 14, 0, 32)
autoIctusToggleRow.BackgroundColor3 = Color3.fromRGB(22, 23, 32)
autoIctusToggleRow.BorderSizePixel = 0
autoIctusToggleRow.Parent = autoIctusCategory
addCorner(autoIctusToggleRow, 8)

local autoIctusLabel = Instance.new("TextLabel")
autoIctusLabel.Size = UDim2.new(0, 100, 1, 0)
autoIctusLabel.Position = UDim2.new(0, 14, 0, 0)
autoIctusLabel.BackgroundTransparency = 1
autoIctusLabel.Text = "Enabled"
autoIctusLabel.TextColor3 = Color3.fromRGB(200, 202, 215)
autoIctusLabel.Font = Enum.Font.GothamBold
autoIctusLabel.TextSize = 13
autoIctusLabel.TextXAlignment = Enum.TextXAlignment.Left
autoIctusLabel.TextYAlignment = Enum.TextYAlignment.Center
autoIctusLabel.Parent = autoIctusToggleRow

local autoIctusToggle = Instance.new("TextButton")
autoIctusToggle.Size = UDim2.new(0, 48, 0, 24)
autoIctusToggle.Position = UDim2.new(1, -62, 0.5, -12)
autoIctusToggle.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
autoIctusToggle.Text = ""
autoIctusToggle.AutoButtonColor = false
autoIctusToggle.Parent = autoIctusToggleRow
addCorner(autoIctusToggle, 12)

local autoIctusKnob = Instance.new("Frame")
autoIctusKnob.Size = UDim2.new(0, 18, 0, 18)
autoIctusKnob.Position = UDim2.new(0, 3, 0, 3)
autoIctusKnob.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
autoIctusKnob.BorderSizePixel = 0
autoIctusKnob.Parent = autoIctusToggle
addCorner(autoIctusKnob, 9)

local function setAutoIctusVisual(state)
	if state then
		TweenService:Create(autoIctusToggle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(88, 72, 255)
		}):Play()
		TweenService:Create(autoIctusKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -21, 0, 3)
		}):Play()
	else
		TweenService:Create(autoIctusToggle, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(50, 52, 65)
		}):Play()
		TweenService:Create(autoIctusKnob, TweenInfo.new(0.15), {
			Position = UDim2.new(0, 3, 0, 3)
		}):Play()
	end
end

autoIctusToggle.MouseButton1Click:Connect(function()
	autoIctusEnabled = not autoIctusEnabled
	setAutoIctusVisual(autoIctusEnabled)
end)

local autoIctusDesc = Instance.new("TextLabel")
autoIctusDesc.Size = UDim2.new(1, -28, 0, 40)
autoIctusDesc.Position = UDim2.new(0, 14, 0, 76)
autoIctusDesc.BackgroundTransparency = 1
autoIctusDesc.Text = "Auto-equips Ictus when nearby opponents use Super Slap, Super Kick, Heart Rip , or Delfan Eoten Cor"
autoIctusDesc.TextColor3 = Color3.fromRGB(120, 122, 138)
autoIctusDesc.Font = Enum.Font.Gotham
autoIctusDesc.TextSize = 11
autoIctusDesc.TextXAlignment = Enum.TextXAlignment.Left
autoIctusDesc.TextYAlignment = Enum.TextYAlignment.Top
autoIctusDesc.TextWrapped = true
autoIctusDesc.Parent = autoIctusCategory

--// ESP Runtime
local function getHealthColor(percent)
	if percent > 0.5 then
		return Color3.fromRGB(50, 255, 50)
	elseif percent > 0.25 then
		return Color3.fromRGB(255, 200, 50)
	else
		return Color3.fromRGB(255, 50, 50)
	end
end

local function destroyESPData(data)
	if not data then return end
	if data.billboard then data.billboard:Destroy() end
	if data.connections then
		for _, conn in ipairs(data.connections) do
			conn:Disconnect()
		end
	end
end

local function removeESPForPlayer(player)
	local data = espObjects[player]
	if data then
		destroyESPData(data.main)
		destroyESPData(data.astral)
		espObjects[player] = nil
	end
end



local function updateESPName(player)
	local data = espObjects[player]
	if not data then return end
	local nameText = getCharacterName(player) .. " (@" .. player.Name .. ")"
	local speciesName, speciesColor = getSpeciesInfo(player.Character)

	local isAstral = player:GetAttribute("AstralProjection") == true
	if data.main and data.main.nameLabel then
		data.main.nameLabel.Text = isAstral and (nameText .. " [Real Body]") or nameText
		data.main.nameLabel.TextColor3 = isAstral and Color3.fromRGB(255, 200, 100) or (speciesColor or Color3.fromRGB(230, 230, 240))
		if data.main.speciesLabel then
			data.main.speciesLabel.Text = speciesName or ""
			data.main.speciesLabel.TextColor3 = speciesColor or Color3.fromRGB(180, 180, 190)
		end
	end
	if data.astral and data.astral.nameLabel then
		data.astral.nameLabel.Text = nameText .. " [Astral]"
		data.astral.nameLabel.TextColor3 = speciesColor or Color3.fromRGB(180, 200, 255)
		if data.astral.speciesLabel then
			data.astral.speciesLabel.Text = speciesName or ""
			data.astral.speciesLabel.TextColor3 = speciesColor or Color3.fromRGB(180, 180, 190)
		end
	end
end

local function buildBillboard(player, character, isAstral)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return nil end

	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then return nil end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = isAstral and "CustomIncendiasESPAstral" or "CustomIncendiasESP"
	billboard.Adornee = hrp
	billboard.Size = UDim2.new(0, 160, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.Parent = playerGui

	local speciesName, speciesColor = getSpeciesInfo(character)
	if not speciesName and not isAstral then
		speciesName, speciesColor = getSpeciesInfo(player.Character)
	end

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 20)
	nameLabel.BackgroundTransparency = 1
	local nameText = getCharacterName(player) .. " (@" .. player.Name .. ")"
	if isAstral then
		nameText = nameText .. " [Astral]"
	end
	nameLabel.Text = nameText
	if isAstral then
		nameLabel.TextColor3 = speciesColor or Color3.fromRGB(180, 200, 255)
	elseif speciesColor then
		nameLabel.TextColor3 = speciesColor
	else
		nameLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
	end
	nameLabel.Font = Enum.Font.RobotoMono
	nameLabel.TextSize = 11
	addStroke(nameLabel, Color3.fromRGB(0, 0, 0), 0, 1)
	nameLabel.Parent = billboard



	-- Species label (bigger, bold, colored)
	local speciesLabel = Instance.new("TextLabel")
	speciesLabel.Size = UDim2.new(1, 0, 0, 20)
	speciesLabel.Position = UDim2.new(0, 0, 0, 22)
	speciesLabel.BackgroundTransparency = 1
	speciesLabel.Text = speciesName or ""
	speciesLabel.TextColor3 = speciesColor or Color3.fromRGB(180, 180, 190)
	speciesLabel.Font = Enum.Font.RobotoMono
	speciesLabel.TextSize = 11
	speciesLabel.Parent = billboard
	addStroke(speciesLabel, Color3.fromRGB(0, 0, 0), 0, 1)

	local connections = {}
	table.insert(connections, humanoid.Died:Connect(function()
		if isAstral then
			local data = espObjects[player]
			if data then
				destroyESPData(data.astral)
				data.astral = nil
			end
		else
			local data = espObjects[player]
			if data then
				destroyESPData(data.main)
				data.main = nil
			end
		end
	end))

	local data = {
		billboard = billboard,
		nameLabel = nameLabel,
		speciesLabel = speciesLabel,
		humanoid = humanoid,
		connections = connections,
	}

	return data
end

local function createAstralESP(player)
	if player == LocalPlayer then return end
	if not espEnabled then return end
	local data = espObjects[player]
	if not data then return end
	if data.astral then return end

	local astralFolder = workspace:FindFirstChild("AstralProjection")
	local astralBody = astralFolder and astralFolder:FindFirstChild(player.Name)
	if not astralBody then return end

	data.astral = buildBillboard(player, astralBody, true)
	if data.astral and astralBody then
		table.insert(data.astral.connections, astralBody:GetAttributeChangedSignal("SpecieType"):Connect(function()
			updateESPName(player)
		end))
	end
end

local createESPForPlayer

local function createESPForPlayerImpl(player, character, isRetry)
	if player == LocalPlayer then return end
	if not espEnabled then return end
	if not character or not character.Parent then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then
		-- Character parts not ready yet - retry after a delay
		if not isRetry then
			task.delay(1, function()
				if espEnabled and player.Character == character and character.Parent then
					createESPForPlayerImpl(player, character, true)
				end
			end)
			task.delay(2.5, function()
				if espEnabled and player.Character == character and character.Parent then
					createESPForPlayerImpl(player, character, true)
				end
			end)
		end
		return
	end

	removeESPForPlayer(player)

	local mainData = buildBillboard(player, character, false)
	if not mainData then return end

	espObjects[player] = {
		main = mainData,
		astral = nil,
	}

	-- Check for existing astral body
	createAstralESP(player)

	-- Listen for name changes
	table.insert(mainData.connections, player:GetAttributeChangedSignal("CharacterName"):Connect(function()
		updateESPName(player)
	end))

	-- Listen for species changes
	table.insert(mainData.connections, character:GetAttributeChangedSignal("SpecieType"):Connect(function()
		updateESPName(player)
	end))

	-- Listen for astral projection state changes to update real body label
	table.insert(mainData.connections, player:GetAttributeChangedSignal("AstralProjection"):Connect(function()
		updateESPName(player)
		if updatePlayerRowAstralState then
			updatePlayerRowAstralState(player)
		end
	end))
end

createESPForPlayer = function(player, character)
	createESPForPlayerImpl(player, character, false)
end

local function refreshESPForPlayer(player)
	if player == LocalPlayer then return end
	if not espEnabled then
		removeESPForPlayer(player)
		return
	end
	if player.Character then
		createESPForPlayer(player, player.Character)
	end
end

local function refreshAllESP()
	for _, player in Players:GetPlayers() do
		refreshESPForPlayer(player)
	end
end

local function onESPPlayerAdded(player)
	if player == LocalPlayer then return end
	player.CharacterAdded:Connect(function(character)
		if espEnabled then
			refreshESPForPlayer(player)
		end
	end)
	if player.Character then
		task.spawn(function()
			task.wait(0.5)
			refreshESPForPlayer(player)
		end)
	end
end

for _, player in Players:GetPlayers() do
	onESPPlayerAdded(player)
end
Players.PlayerAdded:Connect(onESPPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	removeESPForPlayer(player)
end)

--// ESP health check - periodically verifies ESP is working and recreates if broken
local lastRebuildAttempt = {}
task.spawn(function()
	while true do
		task.wait(5)
		if not espEnabled then continue end
		for _, player in Players:GetPlayers() do
			if player ~= LocalPlayer and player.Character then
				local data = espObjects[player]
				local needsRebuild = false

				if not data or not data.main then
					needsRebuild = true
				elseif data.main and data.main.billboard then
					local bb = data.main.billboard
					if not bb.Parent or not bb.Adornee or not bb.Adornee.Parent then
						needsRebuild = true
					end
				end

				if needsRebuild then
					local now = os.clock()
					if lastRebuildAttempt[player] and (now - lastRebuildAttempt[player]) < 10 then
						continue
					end
					lastRebuildAttempt[player] = now
					local hum = player.Character:FindFirstChildOfClass("Humanoid")
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")
					if hrp and hum and hum.Health > 0 then
						refreshESPForPlayer(player)
					end
				end
			end
		end
	end
end)

--// Astral projection body tracking
local function setupAstralWatcher(folder)
	for _, child in folder:GetChildren() do
		local player = Players:FindFirstChild(child.Name)
		if player and player ~= LocalPlayer then
			task.spawn(function()
				task.wait(0.5)
				createAstralESP(player)
			end)
		end
	end
	folder.ChildAdded:Connect(function(child)
		local player = Players:FindFirstChild(child.Name)
		if player and player ~= LocalPlayer then
			task.wait(0.5)
			createAstralESP(player)
			if updatePlayerRowAstralState then
				updatePlayerRowAstralState(player)
			end
		end
	end)
	folder.ChildRemoved:Connect(function(child)
		local player = Players:FindFirstChild(child.Name)
		if player then
			local data = espObjects[player]
			if data and data.astral then
				destroyESPData(data.astral)
				data.astral = nil
			end
			if updatePlayerRowAstralState then
				updatePlayerRowAstralState(player)
			end
		end
	end)
end

local astralFolder = workspace:FindFirstChild("AstralProjection")
if astralFolder then
	setupAstralWatcher(astralFolder)
else
	workspace.ChildAdded:Connect(function(child)
		if child.Name == "AstralProjection" then
			setupAstralWatcher(child)
		end
	end)
end

--// Dynamic ESP offset based on distance (fixes stats not showing when close)
RunService.RenderStepped:Connect(function()
	if not espEnabled then return end
	local myChar = LocalPlayer.Character
	if not myChar then return end
	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	for player, data in pairs(espObjects) do
		local isSpectated = (spectatingPlayer == player)
		if data.main and data.main.billboard and data.main.billboard.Adornee then
			local targetPart = data.main.billboard.Adornee
			if targetPart and targetPart.Parent then
				local dist = (targetPart.Position - myRoot.Position).Magnitude
				local offset = math.clamp(3 + math.max(0, 20 - dist) * 0.1, 3, 5.0)
				data.main.billboard.StudsOffset = Vector3.new(0, offset, 0)
				data.main.billboard.AlwaysOnTop = true
				if isSpectated then
					data.main.billboard.Size = UDim2.new(0, 180, 0, 36)
					if data.main.nameLabel then
						data.main.nameLabel.TextSize = 13
					end
					if data.main.speciesLabel then
						data.main.speciesLabel.TextSize = 12
					end
				else
					data.main.billboard.Size = UDim2.new(0, 160, 0, 30)
					if data.main.nameLabel then
						data.main.nameLabel.TextSize = 11
					end
					if data.main.speciesLabel then
						data.main.speciesLabel.TextSize = 11
					end
				end
			end
		end
		if data.astral and data.astral.billboard and data.astral.billboard.Adornee then
			local targetPart = data.astral.billboard.Adornee
			if targetPart and targetPart.Parent then
				local dist = (targetPart.Position - myRoot.Position).Magnitude
				local offset = math.clamp(3 + math.max(0, 20 - dist) * 0.1, 3, 5.0)
				data.astral.billboard.StudsOffset = Vector3.new(0, offset, 0)
				data.astral.billboard.AlwaysOnTop = true
				local isAstralSpectated = isSpectated and spectatingMode == "astral"
				if isAstralSpectated then
					data.astral.billboard.Size = UDim2.new(0, 180, 0, 36)
					if data.astral.nameLabel then
						data.astral.nameLabel.TextSize = 13
					end
					if data.astral.speciesLabel then
						data.astral.speciesLabel.TextSize = 12
					end
				else
					data.astral.billboard.Size = UDim2.new(0, 160, 0, 30)
					if data.astral.nameLabel then
						data.astral.nameLabel.TextSize = 11
					end
					if data.astral.speciesLabel then
						data.astral.speciesLabel.TextSize = 11
					end
				end
			end
		end
	end
end)

--// Spectate system
local function startSpectate(player, mode)
	-- Disable camlock when spectating
	if camlockEnabled then
		camlockEnabled = false
		camlockTarget = nil
		setCamlockToggleVisual(false)
		camlockTargetLabel.Text = "Target: None"
		camlockTargetLabel.TextColor3 = Color3.fromRGB(110, 112, 128)
	end
	spectatingPlayer = player
	spectatingMode = mode or "body"
end

local function stopSpectate()
	spectatingPlayer = nil
	spectatingMode = nil
	local character = LocalPlayer.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			workspace.CurrentCamera.CameraSubject = humanoid
		end
	end
end

RunService.RenderStepped:Connect(function()
	if spectatingPlayer and spectatingPlayer.Parent then
		local humanoid = nil
		if spectatingMode == "astral" then
			local astralFolder = workspace:FindFirstChild("AstralProjection")
			local astralBody = astralFolder and astralFolder:FindFirstChild(spectatingPlayer.Name)
			if astralBody then
				humanoid = astralBody:FindFirstChildOfClass("Humanoid")
			end
			if not humanoid then
				local character = spectatingPlayer.Character
				if character then
					humanoid = character:FindFirstChildOfClass("Humanoid")
				end
			end
		else
			local character = spectatingPlayer.Character
			if character then
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end
		end
		if humanoid and workspace.CurrentCamera.CameraSubject ~= humanoid then
			workspace.CurrentCamera.CameraSubject = humanoid
		end
	end
end)

--// Anti Annoy system
local function cleanupCameraEffects()
	local camera = workspace.CurrentCamera
	if not camera then return end
	for _, child in camera:GetChildren() do
		if child:IsA("ColorCorrectionEffect") or child:IsA("BlurEffect") then
			child:Destroy()
		end
	end
end

local function cleanupScreenOverlays()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then return end
	for _, sg in playerGui:GetChildren() do
		if sg:IsA("ScreenGui") then
			for _, desc in sg:GetDescendants() do
				if (desc:IsA("Frame") or desc:IsA("ImageLabel")) and desc.ZIndex >= 30 then
					if desc.BackgroundTransparency and desc.BackgroundTransparency < 0.1 then
						local c = desc.BackgroundColor3
						if (c.R < 0.05 and c.G < 0.05 and c.B < 0.05)
							or (c.R > 0.95 and c.G > 0.95 and c.B > 0.95) then
							desc.Visible = false
						end
					end
				end
			end
		end
	end
end

local function startAntiAnnoy()
	local bindables = ReplicatedStorage:FindFirstChild("Bindables")
	local FusionStates = bindables and bindables:FindFirstChild("FusionStates")
	if not FusionStates then return end

	antiAnnoyConnections = {}

	-- Intercept InstantScreenTransition (Ossox, MenedekQualSurenta)
	local instantTrans = FusionStates:FindFirstChild("InstantScreenTransition")
	if instantTrans then
		table.insert(antiAnnoyConnections, instantTrans.Event:Connect(function(state)
			if state == true and antiAnnoyEnabled then
				instantTrans:Fire(false)
			end
		end))
	end

	-- Intercept PlayerSleepingEffect (AdSomnum)
	local sleepEffect = FusionStates:FindFirstChild("PlayerSleepingEffect")
	local stopSleep = FusionStates:FindFirstChild("StopSleepEffect")
	if sleepEffect and stopSleep then
		table.insert(antiAnnoyConnections, sleepEffect.Event:Connect(function()
			if antiAnnoyEnabled then
				stopSleep:Fire()
			end
		end))
	end

	-- Intercept ToggledScreenTransition when white (Sol)
	local toggledTrans = FusionStates:FindFirstChild("ToggledScreenTransition")
	local setScreenTrans = FusionStates:FindFirstChild("SetScreenTransitioned")
	if toggledTrans and setScreenTrans then
		table.insert(antiAnnoyConnections, toggledTrans.Event:Connect(function(args)
			if antiAnnoyEnabled and type(args) == "table" and args.customColor then
				local c = args.customColor
				if c.R > 0.9 and c.G > 0.9 and c.B > 0.9 then
					pcall(function()
						setScreenTrans:Invoke()
					end)
				end
			end
		end))
	end

	-- Monitor CurrentCamera for ColorCorrectionEffects (Sol, HeadSiphon)
	local function hookCamera(cam)
		table.insert(antiAnnoyConnections, cam.ChildAdded:Connect(function(child)
			if antiAnnoyEnabled and (child:IsA("ColorCorrectionEffect") or child:IsA("BlurEffect")) then
				task.defer(function()
					if antiAnnoyEnabled and child.Parent then
						child:Destroy()
					end
					end)
			end
		end))
	end

	local currentCam = workspace.CurrentCamera
	if currentCam then
		hookCamera(currentCam)
	end

	table.insert(antiAnnoyConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		if antiAnnoyEnabled and workspace.CurrentCamera then
			hookCamera(workspace.CurrentCamera)
			cleanupCameraEffects()
		end
	end))

	cleanupCameraEffects()

	-- Backup periodic cleanup
	local lastOverlayCleanup = 0
	table.insert(antiAnnoyConnections, RunService.Heartbeat:Connect(function()
		cleanupCameraEffects()
		local now = os.clock()
		if now - lastOverlayCleanup >= 0.25 then
			lastOverlayCleanup = now
			cleanupScreenOverlays()
		end
		end))
end

local function stopAntiAnnoy()
	for _, conn in ipairs(antiAnnoyConnections) do
		conn:Disconnect()
	end
	antiAnnoyConnections = {}
end

--// Anti Stun system
local antiStunConnection = nil

local function startAntiStun()
	if antiStunConnection then return end
	antiStunConnection = RunService.Heartbeat:Connect(function()
		local character = LocalPlayer.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		-- Break stun by slightly offsetting walk speed past the locked value
		if humanoid.WalkSpeed < DEFAULT_WALK_SPEED then
			humanoid.WalkSpeed = DEFAULT_WALK_SPEED + 0.01
		end

		-- Break PlatformStand (used by some stuns)
		if humanoid.PlatformStand then
			humanoid.PlatformStand = false
		end

		-- Break forced sit from stuns
		if humanoid.Sit then
			humanoid.Sit = false
		end
	end)
end

local function stopAntiStun()
	if antiStunConnection then
		antiStunConnection:Disconnect()
		antiStunConnection = nil
	end
end

--// ESP Category (Main tab)
local espCategory = Instance.new("Frame")
espCategory.Size = UDim2.new(1, 0, 0, 120)
espCategory.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
espCategory.BorderSizePixel = 0
espCategory.LayoutOrder = 2
espCategory.Parent = funScroll
addCorner(espCategory, 8)
addStroke(espCategory, Color3.fromRGB(30, 32, 42), 0.3)

local espHeader = Instance.new("TextLabel")
espHeader.Size = UDim2.new(1, 0, 0, 28)
espHeader.BackgroundTransparency = 1
espHeader.Text = "  ESP System"
espHeader.TextColor3 = Color3.fromRGB(88, 72, 255)
espHeader.Font = Enum.Font.GothamBold
espHeader.TextSize = 14
espHeader.TextXAlignment = Enum.TextXAlignment.Left
espHeader.TextYAlignment = Enum.TextYAlignment.Center
espHeader.Parent = espCategory

local espToggleRow = Instance.new("Frame")
espToggleRow.Size = UDim2.new(1, -28, 0, 38)
espToggleRow.Position = UDim2.new(0, 14, 0, 32)
espToggleRow.BackgroundColor3 = Color3.fromRGB(22, 23, 32)
espToggleRow.BorderSizePixel = 0
espToggleRow.Parent = espCategory
addCorner(espToggleRow, 8)

local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(0, 100, 1, 0)
espLabel.Position = UDim2.new(0, 14, 0, 0)
espLabel.BackgroundTransparency = 1
espLabel.Text = "Enabled"
espLabel.TextColor3 = Color3.fromRGB(200, 202, 215)
espLabel.Font = Enum.Font.GothamBold
espLabel.TextSize = 13
espLabel.TextXAlignment = Enum.TextXAlignment.Left
espLabel.TextYAlignment = Enum.TextYAlignment.Center
espLabel.Parent = espToggleRow

local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(0, 48, 0, 24)
espToggle.Position = UDim2.new(1, -62, 0.5, -12)
espToggle.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
espToggle.Text = ""
espToggle.AutoButtonColor = false
espToggle.Parent = espToggleRow
addCorner(espToggle, 12)

local espKnob = Instance.new("Frame")
espKnob.Size = UDim2.new(0, 18, 0, 18)
espKnob.Position = UDim2.new(0, 3, 0, 3)
espKnob.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
espKnob.BorderSizePixel = 0
espKnob.Parent = espToggle
addCorner(espKnob, 9)

local function setEspToggleVisual(state)
	if state then
		TweenService:Create(espToggle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(88, 72, 255)
		}):Play()
		TweenService:Create(espKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -21, 0, 3)
		}):Play()
	else
		TweenService:Create(espToggle, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(50, 52, 65)
		}):Play()
		TweenService:Create(espKnob, TweenInfo.new(0.15), {
			Position = UDim2.new(0, 3, 0, 3)
		}):Play()
	end
end

espToggle.MouseButton1Click:Connect(function()
	if not isEspWhitelisted() then return end
	espEnabled = not espEnabled
	setEspToggleVisual(espEnabled)
	if espEnabled then
		refreshAllESP()
	else
		for player in pairs(espObjects) do
			removeESPForPlayer(player)
		end
	end
end)

local espDesc = Instance.new("TextLabel")
espDesc.Size = UDim2.new(1, -28, 0, 40)
espDesc.Position = UDim2.new(0, 14, 0, 76)
espDesc.BackgroundTransparency = 1
espDesc.Text = "Shows player names and species above characters. Names are colored by species. Click View below to spectate a player's location."
espDesc.TextColor3 = Color3.fromRGB(120, 122, 138)
espDesc.Font = Enum.Font.Gotham
espDesc.TextSize = 11
espDesc.TextXAlignment = Enum.TextXAlignment.Left
espDesc.TextYAlignment = Enum.TextYAlignment.Top
espDesc.TextWrapped = true
espDesc.Parent = espCategory

--// ESP Player List Category (View / Unview)
local espListCategory = Instance.new("Frame")
espListCategory.Size = UDim2.new(1, 0, 0, 200)
espListCategory.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
espListCategory.BorderSizePixel = 0
espListCategory.LayoutOrder = 3
espListCategory.Parent = funScroll
addCorner(espListCategory, 8)
addStroke(espListCategory, Color3.fromRGB(30, 32, 42), 0.3)

local espListHeader = Instance.new("TextLabel")
espListHeader.Size = UDim2.new(1, 0, 0, 28)
espListHeader.BackgroundTransparency = 1
espListHeader.Text = "  Spectate Players"
espListHeader.TextColor3 = Color3.fromRGB(88, 72, 255)
espListHeader.Font = Enum.Font.GothamBold
espListHeader.TextSize = 14
espListHeader.TextXAlignment = Enum.TextXAlignment.Left
espListHeader.TextYAlignment = Enum.TextYAlignment.Center
espListHeader.Parent = espListCategory

local espListScroll = Instance.new("ScrollingFrame")
espListScroll.Size = UDim2.new(1, -28, 0, 160)
espListScroll.Position = UDim2.new(0, 14, 0, 32)
espListScroll.BackgroundTransparency = 1
espListScroll.BorderSizePixel = 0
espListScroll.ScrollBarThickness = 4
espListScroll.ScrollBarImageColor3 = Color3.fromRGB(88, 72, 255)
espListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
espListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
espListScroll.Parent = espListCategory

local espListLayout = Instance.new("UIListLayout")
espListLayout.SortOrder = Enum.SortOrder.LayoutOrder
espListLayout.Padding = UDim.new(0, 4)
espListLayout.Parent = espListScroll

local function createPlayerRow(player)
	if player == LocalPlayer then return end
	if espPlayerRows[player] then return end

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundColor3 = Color3.fromRGB(22, 23, 32)
	row.BorderSizePixel = 0
	row.Parent = espListScroll
	addCorner(row, 6)

	local playerNameLabel = Instance.new("TextLabel")
	playerNameLabel.Size = UDim2.new(1, -70, 1, 0)
	playerNameLabel.Position = UDim2.new(0, 10, 0, 0)
	playerNameLabel.BackgroundTransparency = 1
	playerNameLabel.Text = getCharacterName(player) .. " (@" .. player.Name .. ")"
	local _, rowSpeciesColor = getSpeciesInfo(player.Character)
	playerNameLabel.TextColor3 = rowSpeciesColor or Color3.fromRGB(200, 202, 215)
	playerNameLabel.Font = Enum.Font.GothamSemibold
	playerNameLabel.TextSize = 12
	playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	playerNameLabel.TextYAlignment = Enum.TextYAlignment.Center
	playerNameLabel.Parent = row

	local viewBodyBtn = Instance.new("TextButton")
	viewBodyBtn.Size = UDim2.new(0, 56, 0, 22)
	viewBodyBtn.Position = UDim2.new(1, -128, 0.5, -11)
	viewBodyBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 40)
	viewBodyBtn.Text = "Body"
	viewBodyBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
	viewBodyBtn.Font = Enum.Font.GothamBold
	viewBodyBtn.TextSize = 10
	viewBodyBtn.AutoButtonColor = false
	viewBodyBtn.Visible = false
	viewBodyBtn.Parent = row
	addCorner(viewBodyBtn, 4)

	local viewBtn = Instance.new("TextButton")
	viewBtn.Size = UDim2.new(0, 56, 0, 22)
	viewBtn.Position = UDim2.new(1, -66, 0.5, -11)
	viewBtn.BackgroundColor3 = Color3.fromRGB(88, 72, 255)
	viewBtn.Text = "View"
	viewBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
	viewBtn.Font = Enum.Font.GothamBold
	viewBtn.TextSize = 10
	viewBtn.AutoButtonColor = false
	viewBtn.Parent = row
	addCorner(viewBtn, 4)

	espPlayerRows[player] = {
		row = row,
		viewBtn = viewBtn,
		viewBodyBtn = viewBodyBtn,
		playerNameLabel = playerNameLabel,
		viewingMode = nil, -- nil, "astral", "body"
	}

	local function clearAllViewing()
		for _, otherRow in pairs(espPlayerRows) do
			if otherRow.viewingMode then
				otherRow.viewingMode = nil
				if otherRow.viewBtn then
					otherRow.viewBtn.Text = "View"
					otherRow.viewBtn.BackgroundColor3 = Color3.fromRGB(88, 72, 255)
				end
				if otherRow.viewBodyBtn then
					otherRow.viewBodyBtn.Text = "Body"
					otherRow.viewBodyBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 40)
				end
			end
		end
	end

	local function updateViewBtns()
		local rowData = espPlayerRows[player]
		if not rowData then return end
		local isAstral = player:GetAttribute("AstralProjection") == true
		if rowData.viewingMode == "astral" then
			viewBtn.Text = "Stop"
			viewBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
		elseif rowData.viewingMode == "body" then
			viewBtn.Text = isAstral and "Astral" or "View"
			viewBtn.BackgroundColor3 = Color3.fromRGB(88, 72, 255)
		else
			viewBtn.Text = isAstral and "Astral" or "View"
			viewBtn.BackgroundColor3 = Color3.fromRGB(88, 72, 255)
		end
		if rowData.viewingMode == "body" then
			viewBodyBtn.Text = "Stop"
			viewBodyBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
		else
			viewBodyBtn.Text = "Body"
			viewBodyBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 40)
		end
	end

	viewBtn.MouseButton1Click:Connect(function()
		local rowData = espPlayerRows[player]
		if not rowData then return end
		local isAstral = player:GetAttribute("AstralProjection") == true
		if rowData.viewingMode == "astral" or (rowData.viewingMode == "body" and not isAstral) then
			rowData.viewingMode = nil
			stopSpectate()
			updateViewBtns()
		else
			clearAllViewing()
			rowData.viewingMode = isAstral and "astral" or "body"
			startSpectate(player, rowData.viewingMode)
			updateViewBtns()
		end
	end)

	viewBodyBtn.MouseButton1Click:Connect(function()
		local rowData = espPlayerRows[player]
		if not rowData then return end
		if rowData.viewingMode == "body" then
			rowData.viewingMode = nil
			stopSpectate()
			updateViewBtns()
		else
			clearAllViewing()
			rowData.viewingMode = "body"
			startSpectate(player, "body")
			updateViewBtns()
		end
	end)

	player:GetAttributeChangedSignal("CharacterName"):Connect(function()
		if espPlayerRows[player] and espPlayerRows[player].playerNameLabel then
			espPlayerRows[player].playerNameLabel.Text = getCharacterName(player) .. " (@" .. player.Name .. ")"
			local _, sc = getSpeciesInfo(player.Character)
			espPlayerRows[player].playerNameLabel.TextColor3 = sc or Color3.fromRGB(200, 202, 215)
		end
	end)

	-- Initialize astral state if player is already projecting
	if player:GetAttribute("AstralProjection") then
		if updatePlayerRowAstralState then
			updatePlayerRowAstralState(player)
		end
	end
end

updatePlayerRowAstralState = function(player)
	local rowData = espPlayerRows[player]
	if not rowData then return end
	local isAstral = player:GetAttribute("AstralProjection") == true
	if isAstral then
		rowData.viewBodyBtn.Visible = true
		rowData.playerNameLabel.Size = UDim2.new(1, -136, 1, 0)
		if not rowData.viewingMode then
			rowData.viewBtn.Text = "Astral"
		end
	else
		rowData.viewBodyBtn.Visible = false
		rowData.playerNameLabel.Size = UDim2.new(1, -70, 1, 0)
		if not rowData.viewingMode then
			rowData.viewBtn.Text = "View"
		end
		-- If spectating astral form and player exits astral, fall back to body
		if rowData.viewingMode == "astral" then
			rowData.viewingMode = "body"
			startSpectate(player, "body")
		end
	end
end

for _, player in Players:GetPlayers() do
	createPlayerRow(player)
end

Players.PlayerAdded:Connect(function(player)
	createPlayerRow(player)
end)

Players.PlayerRemoving:Connect(function(player)
	if spectatingPlayer == player then
		stopSpectate()
	end
	if espPlayerRows[player] then
		espPlayerRows[player].row:Destroy()
		espPlayerRows[player] = nil
	end
	removeESPForPlayer(player)
end)

--// Fire Recolor Category (Fun tab)
local fireCategory = Instance.new("Frame")
fireCategory.Size = UDim2.new(1, 0, 0, 295)
fireCategory.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
fireCategory.BorderSizePixel = 0
fireCategory.LayoutOrder = 4
fireCategory.Parent = funScroll
addCorner(fireCategory, 8)
addStroke(fireCategory, Color3.fromRGB(30, 32, 42), 0.3)

local fireHeader = Instance.new("TextLabel")
fireHeader.Size = UDim2.new(1, 0, 0, 28)
fireHeader.BackgroundTransparency = 1
fireHeader.Text = "  Fire Recolor"
fireHeader.TextColor3 = Color3.fromRGB(88, 72, 255)
fireHeader.Font = Enum.Font.GothamBold
fireHeader.TextSize = 14
fireHeader.TextXAlignment = Enum.TextXAlignment.Left
fireHeader.TextYAlignment = Enum.TextYAlignment.Center
fireHeader.Parent = fireCategory

--// Content area (inside Fire Recolor category)
local content = fireCategory

--// Toggle row
local toggleRow = Instance.new("Frame")
toggleRow.Size = UDim2.new(1, -28, 0, 38)
toggleRow.Position = UDim2.new(0, 14, 0, 32)
toggleRow.BackgroundColor3 = Color3.fromRGB(22, 23, 32)
toggleRow.BorderSizePixel = 0
toggleRow.Parent = content
addCorner(toggleRow, 8)

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size = UDim2.new(0, 100, 1, 0)
toggleLabel.Position = UDim2.new(0, 14, 0, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "Enabled"
toggleLabel.TextColor3 = Color3.fromRGB(200, 202, 215)
toggleLabel.Font = Enum.Font.GothamBold
toggleLabel.TextSize = 13
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.TextYAlignment = Enum.TextYAlignment.Center
toggleLabel.Parent = toggleRow

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 48, 0, 24)
toggle.Position = UDim2.new(1, -62, 0.5, -12)
toggle.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
toggle.Text = ""
toggle.AutoButtonColor = false
toggle.Parent = toggleRow
addCorner(toggle, 12)

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 18, 0, 18)
knob.Position = UDim2.new(0, 3, 0, 3)
knob.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
knob.BorderSizePixel = 0
knob.Parent = toggle
addCorner(knob, 9)

local function setToggleVisual(state)
	if state then
		TweenService:Create(toggle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(88, 72, 255)
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -21, 0, 3)
		}):Play()
	else
		TweenService:Create(toggle, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(50, 52, 65)
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.15), {
			Position = UDim2.new(0, 3, 0, 3)
		}):Play()
	end
end

function setFireEnabled(value)
	fireEnabled = value
	setToggleVisual(fireEnabled)

	if fireEnabled then
		applyColor()
	else
		clearColor()
	end
end

toggle.MouseButton1Click:Connect(function()
	setFireEnabled(not fireEnabled)
end)

--// Presets section
local presetsLabel = Instance.new("TextLabel")
presetsLabel.Size = UDim2.new(0, 100, 0, 20)
presetsLabel.Position = UDim2.new(0, 14, 0, 82)
presetsLabel.BackgroundTransparency = 1
presetsLabel.Text = "Presets"
presetsLabel.TextColor3 = Color3.fromRGB(180, 182, 195)
presetsLabel.Font = Enum.Font.GothamBold
presetsLabel.TextSize = 13
presetsLabel.TextXAlignment = Enum.TextXAlignment.Left
presetsLabel.TextYAlignment = Enum.TextYAlignment.Center
presetsLabel.Parent = content

local presetHolder = Instance.new("Frame")
presetHolder.Size = UDim2.new(1, -144, 0, 64)
presetHolder.Position = UDim2.new(0, 14, 0, 104)
presetHolder.BackgroundTransparency = 1
presetHolder.ClipsDescendants = true
presetHolder.Parent = content

local presetGrid = Instance.new("UIGridLayout")
presetGrid.CellSize = UDim2.new(0, 22, 0, 22)
presetGrid.CellPadding = UDim2.new(0, 6, 0, 6)
presetGrid.SortOrder = Enum.SortOrder.LayoutOrder
presetGrid.Parent = presetHolder

-- Selected preset indicator
local selectedPresetStroke = nil
local function setPresetSelection(btn)
	if selectedPresetStroke then
		selectedPresetStroke:Destroy()
		selectedPresetStroke = nil
	end
	if btn then
		local s = Instance.new("UIStroke")
		s.Color = Color3.fromRGB(255, 255, 255)
		s.Thickness = 2
		s.Transparency = 0.2
		s.Parent = btn
		selectedPresetStroke = s
	end
end

--// Preview box
local previewBox = Instance.new("Frame")
previewBox.Size = UDim2.new(0, 110, 0, 90)
previewBox.Position = UDim2.new(1, -124, 0, 82)
previewBox.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
previewBox.BorderSizePixel = 0
previewBox.Parent = content
addCorner(previewBox, 8)
addStroke(previewBox, Color3.fromRGB(30, 32, 42), 0.3)

local previewTitle = Instance.new("TextLabel")
previewTitle.Size = UDim2.new(1, 0, 0, 20)
previewTitle.Position = UDim2.new(0, 0, 0, 6)
previewTitle.BackgroundTransparency = 1
previewTitle.Text = "Preview"
previewTitle.TextColor3 = Color3.fromRGB(130, 132, 148)
previewTitle.Font = Enum.Font.GothamSemibold
previewTitle.TextSize = 11
previewTitle.Parent = previewBox

local preview = Instance.new("Frame")
preview.Size = UDim2.new(0, 44, 0, 44)
preview.Position = UDim2.new(0.5, -22, 0, 26)
preview.BackgroundColor3 = Color3.fromRGB(currentR, currentG, currentB)
preview.BorderSizePixel = 0
preview.Parent = previewBox
addCorner(preview, 10)

local rgbText = Instance.new("TextLabel")
rgbText.Size = UDim2.new(1, 0, 0, 16)
rgbText.Position = UDim2.new(0, 0, 1, -16)
rgbText.BackgroundTransparency = 1
rgbText.Text = currentR..", "..currentG..", "..currentB
rgbText.TextColor3 = Color3.fromRGB(110, 112, 128)
rgbText.Font = Enum.Font.Gotham
rgbText.TextSize = 10
rgbText.Parent = previewBox

--// RGB Sliders section
local rgbLabel = Instance.new("TextLabel")
rgbLabel.Size = UDim2.new(0, 150, 0, 20)
rgbLabel.Position = UDim2.new(0, 14, 0, 180)
rgbLabel.BackgroundTransparency = 1
rgbLabel.Text = "Custom Color (RGB)"
rgbLabel.TextColor3 = Color3.fromRGB(180, 182, 195)
rgbLabel.Font = Enum.Font.GothamBold
rgbLabel.TextSize = 13
rgbLabel.TextXAlignment = Enum.TextXAlignment.Left
rgbLabel.TextYAlignment = Enum.TextYAlignment.Center
rgbLabel.Parent = content

local sliderArea = Instance.new("Frame")
sliderArea.Size = UDim2.new(1, -28, 0, 80)
sliderArea.Position = UDim2.new(0, 14, 0, 202)
sliderArea.BackgroundTransparency = 1
sliderArea.Parent = content

local setR, setG, setB

function updatePreview()
	local c = Color3.fromRGB(currentR, currentG, currentB)
	preview.BackgroundColor3 = c
	rgbText.Text = currentR..", "..currentG..", "..currentB
	applyColor()
end

local function createSlider(y, letter, default, barColor, callback)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 14, 0, 22)
	label.Position = UDim2.new(0, 0, 0, y)
	label.BackgroundTransparency = 1
	label.Text = letter
	label.TextColor3 = barColor
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = sliderArea

	local value = Instance.new("TextLabel")
	value.Size = UDim2.new(0, 34, 0, 18)
	value.Position = UDim2.new(1, -34, 0, y + 2)
	value.BackgroundColor3 = Color3.fromRGB(20, 21, 28)
	value.BackgroundTransparency = 0.5
	value.Text = tostring(default)
	value.TextColor3 = Color3.fromRGB(200, 202, 215)
	value.Font = Enum.Font.Gotham
	value.TextSize = 11
	value.Parent = sliderArea
	addCorner(value, 5)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -58, 0, 5)
	bar.Position = UDim2.new(0, 20, 0, y + 8)
	bar.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
	bar.BorderSizePixel = 0
	bar.Parent = sliderArea
	addCorner(bar, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(default / 255, 0, 1, 0)
	fill.BackgroundColor3 = barColor
	fill.BorderSizePixel = 0
	fill.Parent = bar
	addCorner(fill, 3)

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 13, 0, 13)
	dot.Position = UDim2.new(default / 255, -6.5, 0.5, -6.5)
	dot.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
	dot.BorderSizePixel = 0
	dot.ZIndex = 2
	dot.Parent = bar
	addCorner(dot, 7)
	addStroke(dot, barColor, 0.2, 1.5)

	local dragging = false

	local function setValue(v)
		v = math.clamp(math.floor(v), 0, 255)
		local rel = v / 255
		fill.Size = UDim2.new(rel, 0, 1, 0)
		dot.Position = UDim2.new(rel, -6.5, 0.5, -6.5)
		value.Text = tostring(v)
		callback(v)
	end

	local function fromX(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		setValue(rel * 255)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			fromX(input.Position.X)
		end
	end)

	dot.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromX(input.Position.X)
		end
	end)

	return setValue
end

local function updateColor(r, g, b)
	currentR, currentG, currentB = r, g, b
	if setR then setR(r) end
	if setG then setG(g) end
	if setB then setB(b) end
	updatePreview()
end

for i, color in ipairs(PRESETS) do
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = color
	btn.Text = ""
	btn.LayoutOrder = i
	btn.AutoButtonColor = false
	btn.Parent = presetHolder
	addCorner(btn, 6)
	addStroke(btn, Color3.fromRGB(40, 42, 52), 0.4)

	btn.MouseButton1Click:Connect(function()
		setPresetSelection(btn)
		updateColor(math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
	end)
end

setR = createSlider(0, "R", currentR, Color3.fromRGB(255, 50, 50), function(v)
	currentR = v
	updatePreview()
end)

setG = createSlider(24, "G", currentG, Color3.fromRGB(50, 255, 50), function(v)
	currentG = v
	updatePreview()
end)

setB = createSlider(48, "B", currentB, Color3.fromRGB(70, 80, 255), function(v)
	currentB = v
	updatePreview()
end)

--// Anti Annoy Category (Fun tab)
local antiAnnoyCategory = Instance.new("Frame")
antiAnnoyCategory.Size = UDim2.new(1, 0, 0, 120)
antiAnnoyCategory.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
antiAnnoyCategory.BorderSizePixel = 0
antiAnnoyCategory.LayoutOrder = 5
antiAnnoyCategory.Parent = funScroll
addCorner(antiAnnoyCategory, 8)
addStroke(antiAnnoyCategory, Color3.fromRGB(30, 32, 42), 0.3)

local antiAnnoyHeader = Instance.new("TextLabel")
antiAnnoyHeader.Size = UDim2.new(1, 0, 0, 28)
antiAnnoyHeader.BackgroundTransparency = 1
antiAnnoyHeader.Text = "  Anti Annoy"
antiAnnoyHeader.TextColor3 = Color3.fromRGB(88, 72, 255)
antiAnnoyHeader.Font = Enum.Font.GothamBold
antiAnnoyHeader.TextSize = 14
antiAnnoyHeader.TextXAlignment = Enum.TextXAlignment.Left
antiAnnoyHeader.TextYAlignment = Enum.TextYAlignment.Center
antiAnnoyHeader.Parent = antiAnnoyCategory

local antiAnnoyToggleRow = Instance.new("Frame")
antiAnnoyToggleRow.Size = UDim2.new(1, -28, 0, 38)
antiAnnoyToggleRow.Position = UDim2.new(0, 14, 0, 32)
antiAnnoyToggleRow.BackgroundColor3 = Color3.fromRGB(22, 23, 32)
antiAnnoyToggleRow.BorderSizePixel = 0
antiAnnoyToggleRow.Parent = antiAnnoyCategory
addCorner(antiAnnoyToggleRow, 8)

local antiAnnoyLabel = Instance.new("TextLabel")
antiAnnoyLabel.Size = UDim2.new(0, 100, 1, 0)
antiAnnoyLabel.Position = UDim2.new(0, 14, 0, 0)
antiAnnoyLabel.BackgroundTransparency = 1
antiAnnoyLabel.Text = "Enabled"
antiAnnoyLabel.TextColor3 = Color3.fromRGB(200, 202, 215)
antiAnnoyLabel.Font = Enum.Font.GothamBold
antiAnnoyLabel.TextSize = 13
antiAnnoyLabel.TextXAlignment = Enum.TextXAlignment.Left
antiAnnoyLabel.TextYAlignment = Enum.TextYAlignment.Center
antiAnnoyLabel.Parent = antiAnnoyToggleRow

local antiAnnoyToggle = Instance.new("TextButton")
antiAnnoyToggle.Size = UDim2.new(0, 48, 0, 24)
antiAnnoyToggle.Position = UDim2.new(1, -62, 0.5, -12)
antiAnnoyToggle.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
antiAnnoyToggle.Text = ""
antiAnnoyToggle.AutoButtonColor = false
antiAnnoyToggle.Parent = antiAnnoyToggleRow
addCorner(antiAnnoyToggle, 12)

local antiAnnoyKnob = Instance.new("Frame")
antiAnnoyKnob.Size = UDim2.new(0, 18, 0, 18)
antiAnnoyKnob.Position = UDim2.new(0, 3, 0, 3)
antiAnnoyKnob.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
antiAnnoyKnob.BorderSizePixel = 0
antiAnnoyKnob.Parent = antiAnnoyToggle
addCorner(antiAnnoyKnob, 9)

local function setAntiAnnoyVisual(state)
	if state then
		TweenService:Create(antiAnnoyToggle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(88, 72, 255)
		}):Play()
		TweenService:Create(antiAnnoyKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -21, 0, 3)
		}):Play()
	else
		TweenService:Create(antiAnnoyToggle, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(50, 52, 65)
		}):Play()
		TweenService:Create(antiAnnoyKnob, TweenInfo.new(0.15), {
			Position = UDim2.new(0, 3, 0, 3)
		}):Play()
	end
end

antiAnnoyToggle.MouseButton1Click:Connect(function()
	antiAnnoyEnabled = not antiAnnoyEnabled
	setAntiAnnoyVisual(antiAnnoyEnabled)
	if antiAnnoyEnabled then
		startAntiAnnoy()
	else
		stopAntiAnnoy()
	end
end)

local antiAnnoyDesc = Instance.new("TextLabel")
antiAnnoyDesc.Size = UDim2.new(1, -28, 0, 40)
antiAnnoyDesc.Position = UDim2.new(0, 14, 0, 76)
antiAnnoyDesc.BackgroundTransparency = 1
antiAnnoyDesc.Text = "Blocks screen blackouts and flashes from Ossox, Menedek Qual Surenta, Ad Somnum, Sol, and Head Siphon"
antiAnnoyDesc.TextColor3 = Color3.fromRGB(120, 122, 138)
antiAnnoyDesc.Font = Enum.Font.Gotham
antiAnnoyDesc.TextSize = 11
antiAnnoyDesc.TextXAlignment = Enum.TextXAlignment.Left
antiAnnoyDesc.TextYAlignment = Enum.TextYAlignment.Top
antiAnnoyDesc.TextWrapped = true
antiAnnoyDesc.Parent = antiAnnoyCategory

--// Anti Stun Category (Fun tab)
local antiStunCategory = Instance.new("Frame")
antiStunCategory.Size = UDim2.new(1, 0, 0, 180)
antiStunCategory.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
antiStunCategory.BorderSizePixel = 0
antiStunCategory.LayoutOrder = 6
antiStunCategory.Parent = funScroll
addCorner(antiStunCategory, 8)
addStroke(antiStunCategory, Color3.fromRGB(30, 32, 42), 0.3)

local antiStunHeader = Instance.new("TextLabel")
antiStunHeader.Size = UDim2.new(1, 0, 0, 28)
antiStunHeader.BackgroundTransparency = 1
antiStunHeader.Text = "  Anti Stun"
antiStunHeader.TextColor3 = Color3.fromRGB(88, 72, 255)
antiStunHeader.Font = Enum.Font.GothamBold
antiStunHeader.TextSize = 14
antiStunHeader.TextXAlignment = Enum.TextXAlignment.Left
antiStunHeader.TextYAlignment = Enum.TextYAlignment.Center
antiStunHeader.Parent = antiStunCategory

local antiStunToggleRow = Instance.new("Frame")
antiStunToggleRow.Size = UDim2.new(1, -28, 0, 38)
antiStunToggleRow.Position = UDim2.new(0, 14, 0, 32)
antiStunToggleRow.BackgroundColor3 = Color3.fromRGB(22, 23, 32)
antiStunToggleRow.BorderSizePixel = 0
antiStunToggleRow.Parent = antiStunCategory
addCorner(antiStunToggleRow, 8)

local antiStunLabel = Instance.new("TextLabel")
antiStunLabel.Size = UDim2.new(0, 100, 1, 0)
antiStunLabel.Position = UDim2.new(0, 14, 0, 0)
antiStunLabel.BackgroundTransparency = 1
antiStunLabel.Text = "Enabled"
antiStunLabel.TextColor3 = Color3.fromRGB(200, 202, 215)
antiStunLabel.Font = Enum.Font.GothamBold
antiStunLabel.TextSize = 13
antiStunLabel.TextXAlignment = Enum.TextXAlignment.Left
antiStunLabel.TextYAlignment = Enum.TextYAlignment.Center
antiStunLabel.Parent = antiStunToggleRow

local antiStunToggle = Instance.new("TextButton")
antiStunToggle.Size = UDim2.new(0, 48, 0, 24)
antiStunToggle.Position = UDim2.new(1, -62, 0.5, -12)
antiStunToggle.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
antiStunToggle.Text = ""
antiStunToggle.AutoButtonColor = false
antiStunToggle.Parent = antiStunToggleRow
addCorner(antiStunToggle, 12)

local antiStunKnob = Instance.new("Frame")
antiStunKnob.Size = UDim2.new(0, 18, 0, 18)
antiStunKnob.Position = UDim2.new(0, 3, 0, 3)
antiStunKnob.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
antiStunKnob.BorderSizePixel = 0
antiStunKnob.Parent = antiStunToggle
addCorner(antiStunKnob, 9)

local function setAntiStunVisual(state)
	if state then
		TweenService:Create(antiStunToggle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(88, 72, 255)
		}):Play()
		TweenService:Create(antiStunKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -21, 0, 3)
		}):Play()
	else
		TweenService:Create(antiStunToggle, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(50, 52, 65)
		}):Play()
		TweenService:Create(antiStunKnob, TweenInfo.new(0.15), {
			Position = UDim2.new(0, 3, 0, 3)
		}):Play()
	end
end

antiStunToggle.MouseButton1Click:Connect(function()
	antiStunEnabled = not antiStunEnabled
	setAntiStunVisual(antiStunEnabled)
	if antiStunEnabled then
		startAntiStun()
	else
		stopAntiStun()
	end
end)

-- Anti Stun keybind row
do
local antiStunKeybind = nil
local antiStunKeybindListening = false

local antiStunKeybindRow = Instance.new("Frame")
antiStunKeybindRow.Size = UDim2.new(1, -28, 0, 38)
antiStunKeybindRow.Position = UDim2.new(0, 14, 0, 76)
antiStunKeybindRow.BackgroundColor3 = Color3.fromRGB(22, 23, 32)
antiStunKeybindRow.BorderSizePixel = 0
antiStunKeybindRow.Parent = antiStunCategory
addCorner(antiStunKeybindRow, 8)

local antiStunKeybindLabel = Instance.new("TextLabel")
antiStunKeybindLabel.Size = UDim2.new(0, 100, 1, 0)
antiStunKeybindLabel.Position = UDim2.new(0, 14, 0, 0)
antiStunKeybindLabel.BackgroundTransparency = 1
antiStunKeybindLabel.Text = "Keybind"
antiStunKeybindLabel.TextColor3 = Color3.fromRGB(200, 202, 215)
antiStunKeybindLabel.Font = Enum.Font.GothamBold
antiStunKeybindLabel.TextSize = 13
antiStunKeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
antiStunKeybindLabel.TextYAlignment = Enum.TextYAlignment.Center
antiStunKeybindLabel.Parent = antiStunKeybindRow

local antiStunKeybindBtn = Instance.new("TextButton")
antiStunKeybindBtn.Size = UDim2.new(0, 90, 0, 24)
antiStunKeybindBtn.Position = UDim2.new(1, -104, 0.5, -12)
antiStunKeybindBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
antiStunKeybindBtn.Text = "None"
antiStunKeybindBtn.TextColor3 = Color3.fromRGB(200, 202, 215)
antiStunKeybindBtn.Font = Enum.Font.GothamBold
antiStunKeybindBtn.TextSize = 11
antiStunKeybindBtn.AutoButtonColor = false
antiStunKeybindBtn.Parent = antiStunKeybindRow
addCorner(antiStunKeybindBtn, 6)

antiStunKeybindBtn.MouseButton1Click:Connect(function()
	antiStunKeybindListening = true
	antiStunKeybindBtn.Text = "..."
	antiStunKeybindBtn.TextColor3 = Color3.fromRGB(88, 72, 255)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if antiStunKeybindListening then
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			antiStunKeybind = input.KeyCode
			antiStunKeybindListening = false
			antiStunKeybindBtn.Text = antiStunKeybind.Name
			antiStunKeybindBtn.TextColor3 = Color3.fromRGB(200, 202, 215)
		end
		return
	end

	if antiStunKeybind and input.KeyCode == antiStunKeybind then
		antiStunEnabled = not antiStunEnabled
		setAntiStunVisual(antiStunEnabled)
		if antiStunEnabled then
			startAntiStun()
		else
			stopAntiStun()
		end
	end
end)
end

local antiStunDesc = Instance.new("TextLabel")
antiStunDesc.Size = UDim2.new(1, -28, 0, 40)
antiStunDesc.Position = UDim2.new(0, 14, 0, 120)
antiStunDesc.BackgroundTransparency = 1
antiStunDesc.Text = "Breaks stun locks by slightly offsetting your walk speed past the locked value, and disabling PlatformStand and forced sit states"
antiStunDesc.TextColor3 = Color3.fromRGB(120, 122, 138)
antiStunDesc.Font = Enum.Font.Gotham
antiStunDesc.TextSize = 11
antiStunDesc.TextXAlignment = Enum.TextXAlignment.Left
antiStunDesc.TextYAlignment = Enum.TextYAlignment.Top
antiStunDesc.TextWrapped = true
antiStunDesc.Parent = antiStunCategory

--// Window controls
closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
end)

minBtn.MouseButton1Click:Connect(function()
	main.Visible = false
end)

--// Draggable window (drag from header)
local draggingWindow = false
local dragStart, startPos

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingWindow = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingWindow = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == TOGGLE_KEY then
		main.Visible = not main.Visible
	end
end)

setToggleVisual(false)
setAutoIctusVisual(false)
setEspToggleVisual(false)
setAntiAnnoyVisual(false)
setAntiStunVisual(false)
setAimAssistVisual(false)
updatePreview()

--// Execution toast notification (pops up from main GUI)
task.spawn(function()
	local toastGui = Instance.new("ScreenGui")
	toastGui.Name = "CustomIncendiasToast"
	toastGui.IgnoreGuiInset = true
	toastGui.ResetOnSpawn = false
	toastGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local toast = Instance.new("Frame")
	toast.Size = UDim2.new(0, 300, 0, 0)
	toast.Position = UDim2.new(1, -20, 1, 20)
	toast.AnchorPoint = Vector2.new(1, 1)
	toast.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
	toast.BorderSizePixel = 0
	toast.BackgroundTransparency = 1
	toast.ClipsDescendants = true
	toast.Parent = toastGui
	addCorner(toast, 10)
	addStroke(toast, Color3.fromRGB(88, 72, 255), 0.3, 1.5)

	local toastIcon = Instance.new("ImageLabel")
	toastIcon.Size = UDim2.new(0, 28, 0, 28)
	toastIcon.Position = UDim2.new(0, 14, 0.5, -14)
	toastIcon.BackgroundTransparency = 1
	toastIcon.Image = ICON_IMAGE
	toastIcon.ScaleType = Enum.ScaleType.Fit
	toastIcon.ImageTransparency = 1
	toastIcon.Parent = toast

	local toastText = Instance.new("TextLabel")
	toastText.Size = UDim2.new(1, -120, 1, 0)
	toastText.Position = UDim2.new(0, 50, 0, 0)
	toastText.BackgroundTransparency = 1
	toastText.Text = "Script successfully executed!"
	toastText.TextColor3 = Color3.fromRGB(230, 230, 240)
	toastText.Font = Enum.Font.GothamBold
	toastText.TextSize = 13
	toastText.TextXAlignment = Enum.TextXAlignment.Left
	toastText.TextTransparency = 1
	toastText.Parent = toast

	local toastMin = Instance.new("TextButton")
	toastMin.Size = UDim2.new(0, 24, 0, 24)
	toastMin.Position = UDim2.new(1, -60, 0.5, -12)
	toastMin.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
	toastMin.Text = "−"
	toastMin.TextColor3 = Color3.fromRGB(140, 142, 155)
	toastMin.Font = Enum.Font.GothamBold
	toastMin.TextSize = 14
	toastMin.AutoButtonColor = false
	toastMin.BackgroundTransparency = 1
	toastMin.TextTransparency = 1
	toastMin.Parent = toast
	addCorner(toastMin, 6)

	local toastClose = Instance.new("TextButton")
	toastClose.Size = UDim2.new(0, 24, 0, 24)
	toastClose.Position = UDim2.new(1, -30, 0.5, -12)
	toastClose.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
	toastClose.Text = "×"
	toastClose.TextColor3 = Color3.fromRGB(140, 142, 155)
	toastClose.Font = Enum.Font.GothamBold
	toastClose.TextSize = 14
	toastClose.AutoButtonColor = false
	toastClose.BackgroundTransparency = 1
	toastClose.TextTransparency = 1
	toastClose.Parent = toast
	addCorner(toastClose, 6)

	local toastDestroyed = false
	local isMinimized = false

	local function closeToast()
		if toastDestroyed then return end
		toastDestroyed = true
		local t = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		TweenService:Create(toast, t, {BackgroundTransparency = 1, Size = UDim2.new(0, 300, 0, 0), Position = UDim2.new(1, -20, 1, 20)}):Play()
		TweenService:Create(toastIcon, t, {ImageTransparency = 1}):Play()
		TweenService:Create(toastText, t, {TextTransparency = 1}):Play()
		TweenService:Create(toastClose, t, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		TweenService:Create(toastMin, t, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		task.wait(0.4)
		toastGui:Destroy()
	end

	toastClose.MouseEnter:Connect(function()
		if toastDestroyed then return end
		TweenService:Create(toastClose, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 30, 30), TextColor3 = Color3.fromRGB(255, 100, 100), BackgroundTransparency = 0}):Play()
	end)
	toastClose.MouseLeave:Connect(function()
		if toastDestroyed then return end
		TweenService:Create(toastClose, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 27, 36), TextColor3 = Color3.fromRGB(140, 142, 155), BackgroundTransparency = 0}):Play()
	end)

	toastMin.MouseEnter:Connect(function()
		if toastDestroyed then return end
		TweenService:Create(toastMin, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 38, 50), TextColor3 = Color3.fromRGB(220, 220, 230), BackgroundTransparency = 0}):Play()
	end)
	toastMin.MouseLeave:Connect(function()
		if toastDestroyed then return end
		TweenService:Create(toastMin, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 27, 36), TextColor3 = Color3.fromRGB(140, 142, 155), BackgroundTransparency = 0}):Play()
	end)

	toastClose.MouseButton1Click:Connect(closeToast)

	toastMin.MouseButton1Click:Connect(function()
		if toastDestroyed or isMinimized then return end
		isMinimized = true
		local t = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		TweenService:Create(toast, t, {Size = UDim2.new(0, 200, 0, 36)}):Play()
		TweenService:Create(toastText, t, {TextTransparency = 1}):Play()
		task.wait(2)
		closeToast()
	end)

	task.wait(0.1)

	local popUp = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(toast, popUp, {BackgroundTransparency = 0, Size = UDim2.new(0, 300, 0, 56), Position = UDim2.new(1, -20, 1, -20)}):Play()
	TweenService:Create(toastIcon, popUp, {ImageTransparency = 0}):Play()
	TweenService:Create(toastText, popUp, {TextTransparency = 0}):Play()
	TweenService:Create(toastClose, popUp, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
	TweenService:Create(toastMin, popUp, {BackgroundTransparency = 0, TextTransparency = 0}):Play()

	task.wait(4)
	closeToast()
end)
