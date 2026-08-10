local Players = game:GetService("Players")

-- ============================================
-- NAME REPLACEMENTS (one example kept per category)
-- ============================================
local NameReplacements = {
	-- Witches
	["The Firstborn Witch"] = "Freya Mikaelson",
	["Firstborn Witch"] = "Freya Mikaelson",
	["The Gemini Witch"] = "Olivia Parker",
	["Orphan Witch"] = "Alyssa Chang",
	["Psychic - Witch"] = "Bonnie Bennett",
	["The Fury"] = "Cleo Sowande",
	["Witch King"] = "Vincent Griffith",
	["Wonder Twin"] = "Josie Saltzman",
	["Dark Siphoner"] = "Dark Josie",
	["Crazy Twin"] = "Lizzie Saltzman",
	["Psychotic Siphoner"] = "Malachi 'Kai' Parker",
    ["The Almighty"] = "Hope Mikaelson",

	-- Vampires
	["Vampire Blondie"] = "Caroline Forbes",
	["Psycho Doppelg\195\164nger"] = "Katherine Pierce",
	["The Good Brother"] = "Stefan Salvatore",
	["The Bad Brother"] = "Damon Salvatore",
	["The Experiment"] = "Lorenzo 'Enzo' St. John",

	-- Originals
	["Ancient Sister"] = "Rebekah Mikaelson",
	["The Hybrid"] = "Klaus Mikaelson",
	["The Noble One"] = "Elijah Mikaelson",
    ["The Beast"] = "Marcel Gerard",

	-- Hybrids
	["Wolf Queen"] = "Hayley Marshall-Kenner",

	-- Mortals / Humans
	["The Doppelg\195\164nger"] = "Elena Gilbert",

	-- Species
	["Oldblood"] = "Original",

	-- Abilities
	["Mind Control"] = "Compulsion",
}

-- Exact-only replacements: only replace when the ENTIRE text matches the key.
-- Use this for short/common words that would corrupt descriptions if replaced as substrings.
local ExactOnlyReplacements = {
	["Psychic-Witch"] = "Bonnie Bennett",
}

-- Pre-sort generic replacements: skip identity mappings, sort by key length (longest first)
local SortedReplacements = {}
for oldName, newName in pairs(NameReplacements) do
	if oldName ~= newName then
		table.insert(SortedReplacements, {old = oldName, new = newName})
	end
end
table.sort(SortedReplacements, function(a, b)
	return #a.old > #b.old
end)

-- Guard flag to prevent re-entrant processing when we set gui.Text ourselves
local isProcessing = false

local function replaceName(text)
	if typeof(text) ~= "string" then return text end
	if #text == 0 then return text end

	-- Check exact-only replacements first (entire text must match the key)
	local exactMatch = ExactOnlyReplacements[text]
	if exactMatch then
		return exactMatch
	end

	local placeholders = {}
	local count = 0

	-- Apply generic replacements (pre-sorted, longest first)
	-- Only gsub if the string actually contains the key (string.find is much cheaper)
	for _, entry in ipairs(SortedReplacements) do
		if string.find(text, entry.old, 1, true) then
			local ph = "\0G" .. count .. "\0"
			count += 1
			text = text:gsub(entry.old, ph)
			table.insert(placeholders, {ph = ph, new = entry.new})
		end
	end

	-- Resolve all placeholders to their final values
	for _, p in ipairs(placeholders) do
		text = text:gsub(p.ph, p.new)
	end

	return text
end

local function processGuiObject(gui)
	if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox") then
		local originalText = gui.Text
		local newText = replaceName(originalText)
		if newText ~= originalText then
			isProcessing = true
			gui.Text = newText
			isProcessing = false
		end
	end
end

-- Watch for property changes on existing and future GUI objects
local function watchGuiObject(gui)
	if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox") then
		gui:GetPropertyChangedSignal("Text"):Connect(function()
			if not isProcessing then
				processGuiObject(gui)
			end
		end)
	end
end

local PlayerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
if not PlayerGui then return end

PlayerGui.DescendantAdded:Connect(function(descendant)
	processGuiObject(descendant)
	watchGuiObject(descendant)
end)

-- Initial scan + attach watchers
for _, gui in pairs(PlayerGui:GetDescendants()) do
	processGuiObject(gui)
	watchGuiObject(gui)
end

-- Track BillboardGuis in workspace
local function processBillboardGui(descendant)
	if descendant:IsA("BillboardGui") then
		for _, child in pairs(descendant:GetDescendants()) do
			processGuiObject(child)
			watchGuiObject(child)
		end
		descendant.DescendantAdded:Connect(function(child)
			processGuiObject(child)
			watchGuiObject(child)
		end)
	end
end

workspace.DescendantAdded:Connect(processBillboardGui)

-- Defer workspace scan to avoid hitching at startup
task.defer(function()
	for _, descendant in pairs(workspace:GetDescendants()) do
		processBillboardGui(descendant)
	end
end)
