local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 30)
if not PlayerGui then return end

local MainInterface = PlayerGui:WaitForChild("MainInterface", 30)
if not MainInterface then return end

-- Wait for React-built UI to be ready (direct dot-access crashes if not loaded yet)
local WholeScreenComponents = MainInterface:WaitForChild("WholeScreenComponents", 30)
local ToolBar = WholeScreenComponents and WholeScreenComponents:WaitForChild("ToolBar", 30)
if not ToolBar then return end

local Data = {
	TEST = {
		Sound = "104818873099408",
		Icon = "18630084620"
	},
}

-- Mass Compulsion action-specific sounds
-- Each action (Faint, Attack, Suffer, Freeze) gets its own sound
-- Replace the "0" placeholders with actual sound IDs
--local CompulsionActionSounds = {
--	["Faint"] = {
--		Sound = "17560602849",
--		Volume = 2.5,
--	},
--	["Attack"] = {
--		Sound = "17560606672",
--		Volume = 2.5,
--	},
--	["Suffer"] = {
--		Sound = "17560604010",
--		Volume = 2.5,
--	},
--	["Freeze"] = {
--		Sound = "17560600778",
--		Volume = 2.5,
--	},
--}

local LOCAL_VOICELINES_ENABLED = true -- Set to true to hear your own ability voicelines again



local function normalize(id)
	return tostring(id)
		:gsub("rbxassetid://", "")
		:gsub("%s+", "")
end

local Cooldowns = {}
local COOLDOWN_TIMEOUT = 30 -- Safety: max seconds a cooldown can be stuck before auto-resetting
local LastTransparency = {}
local LastIcon = {}
local ActiveSounds = {}
local FadingSounds = {}
local LastEquipPlayTime = {}
local EquipPlayLock = {}
local SoundCycleIndex = {}  -- Tracks which sound to play next for abilities with multiple sounds
local KeepPlayingSounds = {} -- Tracks sounds that should keep playing even when replaced
local OncePerLifetimePlayed = {} -- Tracks sounds that should only play once per character life

local function fadeOutSound(sound)
	if not sound or not sound.Parent then
		return
	end

	if FadingSounds[sound] then
		return
	end

	FadingSounds[sound] = true

	local tween = TweenService:Create(
		sound,
		TweenInfo.new(0.8),
		{ Volume = 0 }
	)

	tween:Play()

	tween.Completed:Once(function()
		if sound then
			sound:Stop()
			sound:Destroy()
		end

		FadingSounds[sound] = nil
	end)
end

-- Known property keys that are NOT character overrides
local KnownKeys = {
	Sound = true,
	Sounds = true,
	Icon = true,
	DelayTime = true,
	FadeOut = true,
	Volume = true,
	PlayOnEquipped = true,
	AddOnEquipTime = true,
	CharacterRequired = true,
	ChatText = true,
	SimultaneousSound = true,
	KeepPlayingSound = true,
	TrustDistanceFallback = true,
	OncePerLifetime = true,
}

local function hasCharacterOverrides(info)
	for key in pairs(info) do
		if type(key) == "string" and not KnownKeys[key] then
			return true
		end
	end
	return false
end

-- FIXED FUNCTION
local function playAbilitySound(info, abilityName)

	-- Skip own voicelines if disabled
	if not LOCAL_VOICELINES_ENABLED then
		Cooldowns[abilityName] = false
		return
	end

	-- CharacterRequired check: skip if the player's character doesn't match
	if info.CharacterRequired then
		local charName = Players.LocalPlayer:GetAttribute("CharacterName")
		if charName ~= info.CharacterRequired then
			Cooldowns[abilityName] = false
			return
		end
	end

	local characterName = Players.LocalPlayer:GetAttribute("CharacterName")
	local charSound = characterName and info[characterName]

	local soundId
	local chatText = nil
	local simultaneousSoundId = nil

	-- Cycling sounds support: if info.Sounds is a table, cycle through them
	if info.Sounds and not charSound then
		local index = SoundCycleIndex[abilityName] or 1
		local entry = info.Sounds[index]
		if type(entry) == "table" then
			soundId = entry.Sound
			chatText = entry.ChatText
			simultaneousSoundId = entry.SimultaneousSound
		else
			soundId = entry
		end
		-- Advance to next sound, wrap around after the last one
		SoundCycleIndex[abilityName] = (index % #info.Sounds) + 1
	else
		soundId = charSound or info.Sound
		chatText = info.ChatText
		simultaneousSoundId = info.SimultaneousSound
	end

	if not soundId then
		Cooldowns[abilityName] = false
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. normalize(soundId)
	sound.Volume = info.Volume or 2.5
	sound:SetAttribute("IsLocalVoiceline", true)

	-- Parent to the character for 3D positional audio so the sound comes from the player's model.
	local character = Players.LocalPlayer.Character
	local head = character and character:FindFirstChild("Head")
	if head then
		sound.Parent = head
		-- Reparent to SoundService if the parent is destroyed, so the sound can still play
		head.Destroying:Connect(function()
			pcall(function()
				if sound and sound.Parent then
					sound.Parent = SoundService
				end
			end)
		end)
	else
		sound.Parent = SoundService
	end

	local oldSound = ActiveSounds[abilityName]
	if oldSound and oldSound ~= sound then
		if KeepPlayingSounds[oldSound] then
			-- Don't stop KeepPlayingSound sounds, let them finish naturally
		elseif info.FadeOut then
			fadeOutSound(oldSound)
		else
			oldSound:Stop()
			oldSound:Destroy()
		end
	end

	ActiveSounds[abilityName] = sound
	Players.LocalPlayer:SetAttribute("VoicelinesLastPlayTime", tick())

	if info.KeepPlayingSound then
		KeepPlayingSounds[sound] = true
	end

	-- Safety: auto-reset cooldown after timeout so it can never get permanently stuck
	task.delay(COOLDOWN_TIMEOUT, function()
		if Cooldowns[abilityName] then
			Cooldowns[abilityName] = false
		end
	end)

	-- Play simultaneous sound if provided
	if simultaneousSoundId then
		local simSound = Instance.new("Sound")
		simSound.SoundId = "rbxassetid://" .. normalize(simultaneousSoundId)
		simSound.Volume = info.Volume or 2.5
		simSound:SetAttribute("IsLocalVoiceline", true)

		-- Parent to the character for 3D positional audio (same logic as main sound)
		local character = Players.LocalPlayer.Character
		local head = character and character:FindFirstChild("Head")
		if head then
			simSound.Parent = head
			if info.KeepPlayingSound then
				head.Destroying:Connect(function()
					pcall(function()
						if simSound and simSound.IsPlaying then
							simSound.Parent = SoundService
						end
					end)
				end)
			end
		else
			simSound.Parent = SoundService
		end

		if info.DelayTime then
			task.delay(info.DelayTime, function()
				if simSound and simSound.Parent then
					simSound:Play()
				end
			end)
		else
			simSound:Play()
		end

		simSound.Ended:Connect(function()
			if simSound and simSound.Parent then
				simSound:Destroy()
			end
		end)
	end

	-- Show chat bubble if ChatText is provided
	if chatText then
		local character = Players.LocalPlayer.Character
		if character then
			game:GetService("Chat"):Chat(character, chatText, Enum.ChatColor.White)
		end
	end

	local function cleanup()
		if ActiveSounds[abilityName] == sound then
			ActiveSounds[abilityName] = nil
		end

		Cooldowns[abilityName] = false
		KeepPlayingSounds[sound] = nil

		if sound and sound.Parent and not FadingSounds[sound] then
			sound:Destroy()
		end
	end

	if info.DelayTime then
		-- Capture the sound reference for the closure to avoid variable capture issues
		local delayedSound = sound
		task.delay(info.DelayTime, function()
			if ActiveSounds[abilityName] == delayedSound and delayedSound.Parent then
				delayedSound:Play()
			else
				-- Clean up the delayed sound if it's no longer active
				if delayedSound and delayedSound.Parent and not FadingSounds[delayedSound] then
					delayedSound:Destroy()
				end
				Cooldowns[abilityName] = false
			end
		end)
	else
		sound:Play()
	end

	sound.Ended:Connect(cleanup)

	sound.Destroying:Connect(function()
		if ActiveSounds[abilityName] == sound then
			ActiveSounds[abilityName] = nil
		end

		Cooldowns[abilityName] = false
		KeepPlayingSounds[sound] = nil
	end)
end

local IconMap = {}

for abilityName, info in pairs(Data) do
	local icon = normalize(info.Icon)

	IconMap[icon] = IconMap[icon] or {}
	table.insert(IconMap[icon], abilityName)
end

local function checkAbility(child)
	if not child or not child.Parent then
		return
	end

	local currentImage = normalize(child.Image)
	local transparency = child.ImageTransparency

	local previousTransparency = LastTransparency[child]
	LastTransparency[child] = transparency

	if previousTransparency == nil then
		return
	end

	local becameActive =
		previousTransparency <= 0.01
		and transparency > 0.01

	local becameInactive =
		previousTransparency > 0.01
		and transparency <= 0.01

	if becameActive then
		-- Defer by one frame to check if the Image also changed.
		-- When switching abilities, both Image and transparency change in the same frame.
		-- If Image changed too, this was an ability SWITCH (not a use), so skip the sound.
		local capturedImage = currentImage
		local capturedChild = child

		task.defer(function()
			if not capturedChild or not capturedChild.Parent then return end

			local imageNow = normalize(capturedChild.Image)
			if imageNow ~= capturedImage then
				-- Image changed = ability switch, not a use. Skip.
				return
			end

			local abilities = IconMap[capturedImage]
			if not abilities then return end

			for _, abilityName in ipairs(abilities) do
				local info = Data[abilityName]

				-- For PlayOnEquipped abilities: stop sound when used (cooldown is set in playEquipSoundIfReady)
				if info and info.PlayOnEquipped then
					local sound = ActiveSounds[abilityName]
					if sound then
						ActiveSounds[abilityName] = nil
						if KeepPlayingSounds[sound] then
							-- Don't stop KeepPlayingSound sounds
						elseif info.FadeOut then
							fadeOutSound(sound)
						else
							sound:Stop()
							sound:Destroy()
						end
					end
				elseif info and not Cooldowns[abilityName] then
					Cooldowns[abilityName] = true

					task.spawn(function()
						playAbilitySound(info, abilityName)
					end)
				end
			end
		end)
	end

	-- When ability becomes inactive (icon becomes visible again)
	if becameInactive then
		local abilities = IconMap[currentImage]
		if not abilities then return end

		for _, abilityName in ipairs(abilities) do
			local sound = ActiveSounds[abilityName]
			local info = Data[abilityName]

			-- Note: Magic Shield cooldown is now handled in MainAbilitiesChanged
			-- when switching away from the ability

			if sound and info and info.FadeOut == true and not KeepPlayingSounds[sound] then
				ActiveSounds[abilityName] = nil
				fadeOutSound(sound)
			end

			-- Always reset cooldown so the ability can play again next time
			Cooldowns[abilityName] = false
		end
	end
end

--PlayOnEquipped: Play sound when ability is equipped/selected
--Maps ability enum names to Data entries that should play on equip
--MUST be defined before the event listeners below
local EquipSoundMap = {}

-- Track current ability to detect when switching away from Magic Shield
local CurrentAbility = nil

-- Also detect tool-based ability activations via bindable event
local _playerScripts = Players.LocalPlayer:FindFirstChild("PlayerScripts")
if _playerScripts then
	local _bindables = _playerScripts:FindFirstChild("Bindables")
	if _bindables then
		local _tools = _bindables:FindFirstChild("Tools")
		if _tools then
			local _toolActivated = _tools:FindFirstChild("ToolActivated")
			if _toolActivated and _toolActivated:IsA("BindableEvent") then
				_toolActivated.Event:Connect(function(abilityName)
					local info = Data[abilityName]
					if info and not Cooldowns[abilityName] then
						Cooldowns[abilityName] = true
						task.spawn(function()
							local ok, err = pcall(playAbilitySound, info, abilityName)
							if not ok then
								warn("Voiceline error for", abilityName, err)
								Cooldowns[abilityName] = false
							end
						end)
					end
				end)
			end
		end

		-- Listen for AbilityActivated to set cooldown for PlayOnEquipped abilities
		-- NOTE: Magic Shield is handled separately in becameInactive
		local _abilities = _bindables:FindFirstChild("Abilities")
		if _abilities then
			local _abilityActivated = _abilities:FindFirstChild("AbilityActivated")
			if _abilityActivated and _abilityActivated:IsA("BindableEvent") then
				_abilityActivated.Event:Connect(function(abilityName)
					-- Map ability names to Data keys if needed
					local entries = EquipSoundMap[abilityName]
					if entries then
						for _, name in ipairs(entries) do
							-- Skip Magic Shield - its cooldown is set in becameInactive
							if name ~= "FreyaMagicShield" then
								local info = Data[name]
								if info and info.PlayOnEquipped then
									LastEquipPlayTime[name] = tick()
								end
							end
						end
					else
						-- Skip Magic Shield - its cooldown is set in becameInactive
						if abilityName ~= "FreyaMagicShield" then
							local info = Data[abilityName]
							if info and info.PlayOnEquipped then
								LastEquipPlayTime[abilityName] = tick()
							end
						end
					end
				end)
			end
		end
	end
end

-- Helper function to check cooldown and play sound for PlayOnEquipped abilities
local function playEquipSoundIfReady(dataKey)
	-- Prevent multiple calls in quick succession
	if EquipPlayLock[dataKey] then
		return false
	end

	local info = Data[dataKey]
	if not info or not info.PlayOnEquipped then
		return false
	end

	local lastPlay = LastEquipPlayTime[dataKey] or 0
	local cooldownTime = info.AddOnEquipTime or 0
	local currentTime = tick()

	-- Check if enough time has passed since last use
	if currentTime - lastPlay >= cooldownTime then
		EquipPlayLock[dataKey] = true
		-- Don't set cooldown here for Magic Shield - it's set when switching away (becameInactive)
		-- Ohun's cooldown is set via AbilityActivated

		task.spawn(function()
			playAbilitySound(info, dataKey)
			task.wait(0.5)
			EquipPlayLock[dataKey] = nil
		end)
		return true
	end

	return false
end

do
	local _playerScripts = Players.LocalPlayer:FindFirstChild("PlayerScripts")
	if _playerScripts then
		local _bindables = _playerScripts:FindFirstChild("Bindables")
		if _bindables then
			local _abilities = _bindables:FindFirstChild("Abilities")
			if _abilities then
				local _mainChanged = _abilities:FindFirstChild("MainAbilitiesChanged")
				if _mainChanged and _mainChanged:IsA("BindableEvent") then
					_mainChanged.Event:Connect(function(abilityName)
						if type(abilityName) ~= "string" then return end

						-- MAGIC SHIELD: Set cooldown when SWITCHING AWAY from it
						-- This is the critical fix - detect when we're leaving Magic Shield
						if CurrentAbility == "Magic Shield" and abilityName ~= "Magic Shield" then
							LastEquipPlayTime["FreyaMagicShield"] = tick()
						end

						-- Update current ability tracking
						CurrentAbility = abilityName

						-- Check EquipSoundMap first
						local entries = EquipSoundMap[abilityName]
						if entries then
							for _, name in ipairs(entries) do
								playEquipSoundIfReady(name)
							end
						else
							-- Direct match in Data table
							playEquipSoundIfReady(abilityName)
						end
					end)
				end
			end
		end
	end
end



for _, child in ipairs(ToolBar:GetDescendants()) do
	if child:IsA("ImageLabel") then

		LastTransparency[child] = child.ImageTransparency
		LastIcon[child] = normalize(child.Image)

		child:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
			checkAbility(child)
		end)

		child:GetPropertyChangedSignal("Image"):Connect(function()
			local oldIcon = LastIcon[child]
			local newIcon = normalize(child.Image)

			LastIcon[child] = newIcon
			LastTransparency[child] = child.ImageTransparency

			if not oldIcon or oldIcon == newIcon then
				return
			end

			local abilities = IconMap[oldIcon]
			if not abilities then return end

			for _, abilityName in ipairs(abilities) do
				local sound = ActiveSounds[abilityName]
				local info = Data[abilityName]

				if sound and info and info.FadeOut == true and not KeepPlayingSounds[sound] then
					ActiveSounds[abilityName] = nil
					fadeOutSound(sound)
				end

				Cooldowns[abilityName] = false
			end
		end)
	end
end

-- Mass Compulsion: Detect action selection from CompulsionList UI
-- Watches for the compulsionList frame and hooks into its action buttons
-- Plays the matching sound from CompulsionActionSounds when an action is selected
--do
--	local WholeScreenComp = MainInterface:FindFirstChild("WholeScreenComponents")

--	local function hookCompulsionButton(button)
--		if not button:IsA("TextButton") then return end

--		button.Activated:Connect(function()
--			local actionName = button.Text
--			if not actionName or actionName == "" then return end

--			local actionInfo = CompulsionActionSounds[actionName]
--			if not actionInfo then return end

--			local key = "MassCompulsion_" .. actionName
--			if not Cooldowns[key] then
--				Cooldowns[key] = true
--				task.spawn(function()
--					local ok, err = pcall(playAbilitySound, actionInfo, key)
--					if not ok then
--						warn("Voiceline error for", key, err)
--						Cooldowns[key] = false
--					end
--				end)
--			end
--		end)
--	end

--	local function hookCompulsionList(frame)
--		for _, desc in ipairs(frame:GetDescendants()) do
--			hookCompulsionButton(desc)
--		end
--		frame.DescendantAdded:Connect(function(desc)
--			hookCompulsionButton(desc)
--		end)
--	end

--	if WholeScreenComp then
--		WholeScreenComp.DescendantAdded:Connect(function(desc)
--			if desc:IsA("Frame") and desc.Name == "compulsionList" then
--				task.wait(0.1)
--				hookCompulsionList(desc)
--			end
--		end)

--		for _, desc in ipairs(WholeScreenComp:GetDescendants()) do
--			if desc:IsA("Frame") and desc.Name == "compulsionList" then
--				hookCompulsionList(desc)
--			end
--		end
--	end
--end

-- Notification-based sounds
-- Plays a sound when specific notification messages appear
-- Only triggers for the required character (if specified)
--local NotificationSounds = {
--	["You're no longer channeled"] = {
--		Sound = "138445942157113",
--		Volume = 2.5,
--		CharacterRequired = "Esther Mikaelson",
--	},
--}

-- Pattern-based notification sounds
-- For messages with variable parts (e.g. "Klaus Mikaelson is tracking you..")
-- Uses Lua string patterns to match
--local NotificationPatternSounds = {
--	{ Pattern = "is tracking you%.%.", Sound = "133908186403397", Volume = 3, CharacterRequired = "Davina Claire" },
--}

-- [[ CLIENT-SIDE SOUND REPLACEMENT SYSTEM ]]
-- Replaces sounds played by other players/the server with your own custom sounds.
-- Only YOU hear the replacement. Everyone else still hears the original.
-- Formats:
--   Simple (all characters):  ["original ID"] = "replacement ID"
--   Character-specific only: ["original ID"] = { Replacement = "replacement ID", CharacterRequired = "Nora Hildegard" }
--   Per-character different:  ["original ID"] = { ["Nora Hildegard"] = "id1", ["Bonnie Bennett"] = "id2" }

local SoundReplacements = {
	-- Simple format (applies to all characters):
	["105594719818558"] = "130316188399085", -- Psychic Blast
	["122372982294729"] = "15174394937", -- Phasmatos Immortale
	["90326993393737"] = "15325084064", -- Suctus Incendia
	["118411956384669"] = "15254480460", -- Phasmatos Ravaros
	["80430541489576"] = "14556366203", -- Turn To Stone
	["132884184474189"] = "15631194386", -- Phasmatos Tribum Nas Ex Veras
	["116235007511881"] = "13203446447", -- Autem
	-- Character-specific format (only replaces when Nora Hildegard plays it):
	-- ["original_sound_id"] = { Replacement = "replacement_id", CharacterRequired = "Nora Hildegard" },

	-- Per-character different replacements:
	-- ["original_sound_id"] = { ["Nora Hildegard"] = "id1", ["Bonnie Bennett"] = "id2" },
}

local ReplacedSounds = {} -- Track sounds we've already replaced to avoid duplicates

-- Helper: find which character a sound belongs to
-- 1) Walk up the parent hierarchy for Player/CharacterName attribute
-- 2) Match character model to a player
-- 3) Fallback: find the nearest player character by 3D distance (handles VFX parts)
local function getSoundCharacterName(sound)
	-- Returns: characterName, isDistanceFallback
	-- isDistanceFallback is true when the name was guessed by proximity, not by parent hierarchy.
	-- Distance fallback is unreliable for targeted abilities (sound near the target, not the caster).

	local current = sound.Parent
	while current do
		if current:IsA("Player") then
			return current:GetAttribute("CharacterName"), false
		end
		local charName = current:GetAttribute("CharacterName")
		if charName then
			return charName, false
		end
		current = current.Parent
	end
	current = sound.Parent
	while current do
		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
			for _, player in Players:GetPlayers() do
				if player.Character == current then
					return player:GetAttribute("CharacterName"), false
				end
			end
		end
		current = current.Parent
	end
	-- Fallback: find nearest player character by 3D distance
	-- This handles sounds in VFX parts that aren't parented to any character
	-- Include the local player so their VFX sounds get attributed to them,
	-- which causes the overlay/replace system to correctly skip them.
	local soundPos = nil
	if sound:IsA("Sound") and sound.Parent and sound.Parent:IsA("BasePart") then
		soundPos = sound.Parent.Position
	elseif sound.Parent and sound.Parent:IsA("Attachment") then
		soundPos = sound.Parent.WorldPosition
	end
	if soundPos then
		local bestDist = 50 -- max distance to consider a match (increased for reliability)
		local bestName = nil
		for _, player in Players:GetPlayers() do
			local char = player.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local dist = (hrp.Position - soundPos).Magnitude
					if dist < bestDist then
						bestDist = dist
						bestName = player:GetAttribute("CharacterName")
					end
				end
			end
		end
		if bestName then return bestName, true end
	end
	return nil, false
end

local function isLocalPlayerSound(sound)
	local localCharacter = Players.LocalPlayer.Character
	if not localCharacter then return false, false end

	-- Check: Is the sound parented inside the local player's character?
	local current = sound.Parent
	while current do
		if current == localCharacter then
			return true, false -- isLocal, isDistanceFallback
		end
		current = current.Parent
	end

	-- Fallback: check if the sound is very close to the local player's character
	-- This catches VFX sounds that aren't parented to the character but are still "yours"
	local localHRP = localCharacter:FindFirstChild("HumanoidRootPart")
	if localHRP and localHRP:IsA("BasePart") then
		local soundPos = nil
		if sound.Parent and sound.Parent:IsA("BasePart") then
			soundPos = sound.Parent.Position
		elseif sound.Parent and sound.Parent:IsA("Attachment") then
			soundPos = sound.Parent.WorldPosition
		end
		if soundPos and (localHRP.Position - soundPos).Magnitude < 8 then
			return true, true -- isLocal, isDistanceFallback
		end
	end

	return false, false
end

local function tryReplaceSound(sound)
	if not sound:IsA("Sound") then return end
	if ReplacedSounds[sound] then return end

	-- (Local player sounds are no longer skipped — user wants to hear all replacements for their own sounds too)

	local id = sound.SoundId:gsub("rbxassetid://", "")
	local entry = SoundReplacements[id]

	if not entry then return end

	-- Determine the replacement sound ID based on format
	local replacementId
	if type(entry) == "string" then
		-- Simple format: ["id"] = "replacement_id" (applies to all characters)
		replacementId = entry
	else
		-- Table format: check CharacterRequired first
		if entry.CharacterRequired then
			local charName, charIsDistFallback = getSoundCharacterName(sound)
			-- Only skip if character name is confirmed via parent hierarchy.
			-- Distance fallback is unreliable for targeted abilities (sound near target, not caster).
			if charName ~= entry.CharacterRequired and not charIsDistFallback then return end
		end

		-- Check character-specific keys (like Data table pattern)
		local charName, charIsDistFallback = getSoundCharacterName(sound)
		if charName and entry[charName] and (not charIsDistFallback or entry.TrustDistanceFallback) then
			replacementId = entry[charName]
		elseif entry.Replacement then
			replacementId = entry.Replacement
		else
			return -- No matching replacement found
		end
	end

	-- OncePerLifetime: skip if already played this character life
	if entry.OncePerLifetime or (type(entry) == "string" and OncePerLifetimePlayed["replace_" .. id]) then
		local key = "replace_" .. id
		if OncePerLifetimePlayed[key] then return end
		OncePerLifetimePlayed[key] = true
	end

	ReplacedSounds[sound] = true

	-- Mute the original sound so you don't hear it
	sound.Volume = 0

	-- Also mute it if it was already playing at some volume
	-- (in case the server sets volume after we intercept)
	sound:GetPropertyChangedSignal("Volume"):Connect(function()
		if ReplacedSounds[sound] then
			sound.Volume = 0
		end
	end)

	-- Play your replacement from the same location as the original
	-- so it respects 3D distance (fades with distance from camera)
	local newSound = Instance.new("Sound")
	newSound.SoundId = "rbxassetid://" .. replacementId
	newSound.Volume = 2.5

	-- Determine KeepPlayingSound from the entry (table format only)
	local keepPlaying = false
	if type(entry) == "table" and entry.KeepPlayingSound then
		keepPlaying = true
	end

	local parent = sound.Parent or SoundService

	newSound.Parent = parent
	newSound:Play()

	if keepPlaying then
		-- Reparent to SoundService if the parent is destroyed so the replacement keeps playing
		if parent and parent ~= SoundService then
			parent.Destroying:Connect(function()
				pcall(function()
					if newSound and newSound.Parent then
						newSound.Parent = SoundService
					end
				end)
			end)
		end
	else
		-- Without KeepPlayingSound: fade out the replacement when the original sound ends/stops
		if sound then
			sound.Ended:Connect(function() fadeOutOverlaySound(newSound) end)
			sound.Stopped:Connect(function() fadeOutOverlaySound(newSound) end)
			sound.Destroying:Connect(function()
				fadeOutOverlaySound(newSound)
				ReplacedSounds[sound] = nil
			end)
		end
	end

	newSound.Ended:Connect(function()
		newSound:Destroy()
	end)

	-- If the original sound gets destroyed, clean up our reference
	sound.Destroying:Connect(function()
		ReplacedSounds[sound] = nil
	end)
end

-- [[ CLIENT-SIDE SOUND OVERLAY SYSTEM ]]
-- Plays an additional sound ON TOP of the original (does NOT mute the original).
-- When the original sound stops/ends, the overlay fades out too.
-- Supports DelayTime so the overlay can start after a delay.
-- Supports CharacterRequired to only overlay when a specific character plays the sound.
-- Formats:
--   All characters:  ["original ID"] = { Sound = "overlay ID", Volume = 2.5, DelayTime = 0, FadeOutDuration = 0.8 }
--   Character-specific: ["original ID"] = { Sound = "overlay ID", Volume = 2.5, CharacterRequired = "Nora Hildegard" }

local SoundOverlays = {
	-- Bonnie Bennett:
	["120250468841070"] = {
		Overlays = {
			{ Sound = "15601121759", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Expression Grimoire
			{ Sound = "123232609831917", Volume = 2.5, DelayTime = 13, KeepPlayingSound = true }, -- I Have Every Magic
		},
	},
	["15174800421"] = { 
		["Bonnie Bennett"] = { Sound = "104749000603361", Volume = 2.5, DelayTime = 0 }, -- Channel Ancestors
	},
	-- Freya Mikaelson :
	["111801255101409"] = { Sound = "74460096162653", Volume = 2.5, DelayTime = 0 }, -- Magic Shield
	["105558064418066"] = { Sound = "100950296033969", Volume = 2.5, DelayTime = 0 }, -- Firstborn Devastation
	-- Qetsiyah :
	["16208954441"] = { Sound = "95468563095334", Volume = 2.5, DelayTime = 0 }, -- Ignis Tempestas
	["104782720464668"] = {
		["Qetsiyah"] = { Sound = "16775370366", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Venom Blast
	},
	["16449297928"] = { Sound = "16838696298", Volume = 2.5, DelayTime = 0 }, -- Turn To Stone Qetsiyah
	["112458851193845"] = { Sound = "16767898955", Volume = 2.5, DelayTime = 0 }, -- Destroy Purgatory
	["101281556370554"] = { Sound = "81639278311000", Volume = 2.5, DelayTime = 0 }, -- Ah Sha Lana
	["16327076834"] = { Sound = "78867379826047", Volume = 2.5, DelayTime = 0 }, -- Channel Talisman
	--	["16554249588"] = { Sound = "96414682813420", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true, DebounceTime = 20 }, -- Qet Res
	-- Davina Claire :
	["82029037414223"] = { Sound = "128304384560357", Volume = 2.5, DelayTime = 0 }, -- Telek Submission 
	["10006479564"] = {
		["Davina Claire"] = { Sound = "112486710306576", Volume = 2.5, DelayTime = 0.2 }, -- Hand Of Glory
	},
	["103830069988568"] = { Sound = "79984922909048", Volume = 2.5, DelayTime = 0 }, -- NecksnapLift
	["106982949473166"] = { Sound = "109441100680596", Volume = 2.5, DelayTime = 0 }, -- Soul Bind
	["107029347506027"] = { Sound = "123620176154825", Volume = 2.5, DelayTime = 0 }, -- Lightning Strike
	["82939375129525"] = { Sound = "82826752361269", Volume = 1.5, DelayTime = 0 }, -- Davina Magic Regen
	-- Hope Mikaelson :
	["97485998367353"] = { Sound = "104028506433231", Volume = 1.4, DelayTime = 0 }, -- Bruciare
	["89008508391784"] = { Sound = "17471844257", Volume = 2.5, DelayTime = 0 }, -- Repulse
	["12934765027"] = { Sound = "72404882318303", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Ventus
	["13780865276"] = { Sound = "129988097306628", Volume = 2.5, DelayTime = 5, KeepPlayingSound = true }, -- Telek Head Rip
	-- Esther Mikaelson :
	["82322000387474"] = { Sound = "129460073622144", Volume = 2.5, DelayTime = 4.5 }, -- Pentagram
	["133379296605385"] = { Sound = "94787275001396", Volume = 2.5, DelayTime = 0 }, -- Magic Steal
	-- Dark Josie :
	["13154602444"] = {
		["Dark Josie"] = { Sound = "77485734102576", Volume = 2.5, DelayTime = 0 }, -- Outfit change
	},
	["14123511526"] = { Sound = "90115515174277", Volume = 2.5, DelayTime = 0 }, -- Fiante Fulguris
	["116348909990770"] = { Sound = "78053223963040", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Ascendo
	["115788596173476"] = { Sound = "101957577374614", Volume = 0.8 , DelayTime = 0, KeepPlayingSound = true }, -- I said hey
	-- Cleo Sowande :
	["85094625219939"] = { Sound = "122887446534653", Volume = 2.5, DelayTime = 0 }, -- Muse Teleport
	["90347973452829"] = { Sound = "92404277403294", Volume = 3, DelayTime = 0 }, -- Ohun
	["138866821877856"] = { Sound = "91217804264943", Volume = 3, DelayTime = 0 }, -- Pada
	["86985539781391"] = { Sound = "131047658678353", Volume = 2.5, DelayTime = 0.2 }, -- Inspire
	["133109898520847"] = { Sound = "74072970288534", Volume = 2.5, DelayTime = 0.2 }, -- Mud Golem 
	-- Heretics :
	["13008144854"] = {
		["Nora Hildegard"] = { Sound = "118508173111903", Volume = 2.5, DelayTime = 0 }, -- Strangulo Ventus
		["Valerie Tulle"] = { Sound = "88573986552740", Volume = 2.5, DelayTime = 0 }, -- Strangulo Ventus
	},
	-- Witch Abilities :
	["89539286902417"] = {
		["Lizzie Saltzman"] = { Sound = "132802121953563", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Stellabunde
		["Cleo Sowande"] = { Sound = "90131739908048", Volume = 2.5, DelayTime = 0 }, -- Mass Silence
		TrustDistanceFallback = true,
	},
	["8806156863"] = {
		["Nora Hildegard"] = { Sound = "80580720829811", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Invisique
		["Valerie Tulle"] = { Sound = "116763647482749", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Invisique
	},
	-- Elder Witches :
	["15980142966"] = {
		["Agnes"] = { Sound = "97437123423899", Volume = 1.5, DelayTime = 0 }, -- Agnes Needle of Sorrows
	},
	["129498686293958"] = { Sound = "89550767660084", Volume = 3.5, DelayTime = 0 }, -- Violin
	["105998583954931"] = { Sound = "70767045237007", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Harae Tamae
	["135718833680425"] = {
		Overlays = {
			{ Sound = "139418993300939", Volume = 2.5, DelayTime = 0 }, -- White Oak Spell
			{ Sound = "118918239866614", Volume = 2.5, DelayTime = 17, KeepPlayingSound = true }, -- White Oak Hunter
		},
	},
	["14400859135"] = {
		["Dark Josie"] = { Sound = "86892327341853", Volume = 2.5, DelayTime = 0 }, -- Dark Magic Blast
	},
	["18193005989"] = { Sound = "98703979367465", Volume = 2.5, DelayTime = 0 }, -- Forget to breathe
}

local OverlayTracked = {} -- Track sounds we've already overlaid to avoid duplicates
local ActiveOverlaySounds = {} -- Track currently playing overlay Sound IDs to prevent duplicates (e.g. Illusion Attack plays 5x)
local OverlayOriginalDebounce = {} -- Debounce per original sound ID to prevent multiple overlays from duplicate original sounds

local function fadeOutOverlaySound(overlaySound, duration)
	if not overlaySound or not overlaySound.Parent then return end
	if FadingSounds[overlaySound] then return end

	FadingSounds[overlaySound] = true

	local tween = TweenService:Create(
		overlaySound,
		TweenInfo.new(duration or 0.8),
		{ Volume = 0 }
	)

	tween:Play()

	tween.Completed:Once(function()
		if overlaySound then
			overlaySound:Stop()
			overlaySound:Destroy()
		end
		FadingSounds[overlaySound] = nil
	end)
end

local OverlayKnownKeys = {
	Sound = true,
	Volume = true,
	DelayTime = true,
	FadeOutDuration = true,
	CharacterRequired = true,
	Overlays = true,
	KeepPlayingSound = true,
	DebounceTime = true,
	OncePerLifetime = true,
	TrustDistanceFallback = true,
}

local function hasOverlayCharOverrides(info)
	for key in pairs(info) do
		if type(key) == "string" and not OverlayKnownKeys[key] then
			return true
		end
	end
	return false
end

local function playSingleOverlay(sound, overlayInfo, charName, charIsDistFallback)
	-- OncePerLifetime: skip if already played this character life
	if overlayInfo.OncePerLifetime then
		local key = "overlay_" .. overlayInfo.Sound
		if OncePerLifetimePlayed[key] then return end
		OncePerLifetimePlayed[key] = true
	end

	if overlayInfo.CharacterRequired then
		if not charName then
			charName, charIsDistFallback = getSoundCharacterName(sound)
		end
		-- Only skip if character name is confirmed via parent hierarchy.
		-- Distance fallback is unreliable for targeted abilities (sound near target, not caster).
		if charName ~= overlayInfo.CharacterRequired and not charIsDistFallback then return end
	end

	-- Capture the character model NOW (before any delay) so we can parent the overlay
	-- to the character's body for proper 3D positional audio, even after a delay.
	-- Without this, delayed overlays fall back to SoundService and play globally at full volume.
	local capturedCharModel = nil
	if sound and sound.Parent then
		local current = sound.Parent
		while current do
			if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
				for _, player in Players:GetPlayers() do
					if player.Character == current then
						capturedCharModel = current
						break
					end
				end
				if capturedCharModel then break end
			end
			current = current.Parent
		end
	end

	local function doPlay()
		-- Deduplicate: if this overlay Sound ID is already playing, skip it
		-- EXCEPT for KeepPlayingSound overlays: stop the old one and play fresh
		local existing = ActiveOverlaySounds[overlayInfo.Sound]
		if existing and existing.Parent and existing.IsPlaying then
			if overlayInfo.KeepPlayingSound then
				-- Stop old overlay so the new one plays fresh
				existing:Stop()
				existing:Destroy()
				ActiveOverlaySounds[overlayInfo.Sound] = nil
			else
				return
			end
		end
		-- Clear stale entry if the old overlay is gone
		ActiveOverlaySounds[overlayInfo.Sound] = nil

		-- Parent to the character's Head for 3D positional audio so the overlay
		-- sounds like it comes from the body, not globally.
		-- Falls back to the original sound's parent, then SoundService.
		local parent = nil
		if capturedCharModel and capturedCharModel.Parent then
			local head = capturedCharModel:FindFirstChild("Head")
			if head then
				parent = head
			end
		end
		if not parent then
			parent = (sound and sound.Parent) or SoundService
		end

		-- For KeepPlayingSound: stop any existing overlay with the same ID so the new one plays fresh
		if overlayInfo.KeepPlayingSound then
			local existing = ActiveOverlaySounds[overlayInfo.Sound]
			if existing and existing.Parent then
				existing:Stop()
				existing:Destroy()
				ActiveOverlaySounds[overlayInfo.Sound] = nil
			end
		end

		local ov = Instance.new("Sound")
		ov.SoundId = "rbxassetid://" .. overlayInfo.Sound
		ov.Volume = overlayInfo.Volume or 2.5

		ov.Parent = parent
		ov:Play()

		ActiveOverlaySounds[overlayInfo.Sound] = ov

		-- Self-cleanup when the overlay finishes
		ov.Ended:Connect(function()
			ActiveOverlaySounds[overlayInfo.Sound] = nil
			if ov and ov.Parent then ov:Destroy() end
		end)

		if overlayInfo.KeepPlayingSound then
			-- Reparent to SoundService if the parent is destroyed so the overlay keeps playing
			if parent and parent ~= SoundService then
				parent.Destroying:Connect(function()
					pcall(function()
						if ov and ov.Parent then
							ov.Parent = SoundService
						end
					end)
				end)
			end
		else
			-- Without KeepPlayingSound: fade out the overlay when the original sound ends/stops/is destroyed
			local fadeDur = overlayInfo.FadeOutDuration
			if sound then
				sound.Ended:Connect(function() fadeOutOverlaySound(ov, fadeDur) end)
				sound.Stopped:Connect(function() fadeOutOverlaySound(ov, fadeDur) end)
				sound.Destroying:Connect(function()
					fadeOutOverlaySound(ov, fadeDur)
					OverlayTracked[sound] = nil
				end)
			end
		end

		-- Also clean up ActiveOverlaySounds if the overlay is destroyed unexpectedly
		ov.Destroying:Connect(function()
			if ActiveOverlaySounds[overlayInfo.Sound] == ov then
				ActiveOverlaySounds[overlayInfo.Sound] = nil
			end
		end)
	end

	-- Clean up OverlayTracked when the original sound is destroyed (for KeepPlayingSound overlays)
	if sound and overlayInfo.KeepPlayingSound then
		sound.Destroying:Connect(function()
			OverlayTracked[sound] = nil
		end)
	end

	if overlayInfo.DelayTime and overlayInfo.DelayTime > 0 then
		task.delay(overlayInfo.DelayTime, doPlay)
	elseif sound and sound.IsPlaying then
		doPlay()
	elseif sound then
		-- Sound not playing yet — listen for it to start, with a timeout fallback
		local played = false
		local conn
		conn = sound.Played:Connect(function()
			played = true
			if conn then conn:Disconnect() end
			doPlay()
		end)
		-- Fallback: if the sound starts playing before our listener was set up,
		-- or if Played never fires, check again shortly
		task.delay(0.1, function()
			if conn then conn:Disconnect() end
			if not played and sound and sound.Parent and sound.IsPlaying then
				doPlay()
			end
		end)
	end
end

local function tryOverlaySound(sound)
	if not sound:IsA("Sound") then return end
	if OverlayTracked[sound] then return end

	-- (Local player sounds are no longer skipped — user wants to hear all overlays for their own sounds too)

	local id = sound.SoundId:gsub("rbxassetid://", "")
	local entry = SoundOverlays[id]
	if not entry then return end

	-- Debounce: if we already created an overlay for this original sound ID recently,
	-- skip it. This prevents abilities like Illusion Attack (which creates 5 duplicate
	-- original sounds) from playing the overlay 5 times.
	if OverlayOriginalDebounce[id] then
		OverlayTracked[sound] = true
		return
	end
	local debounceTime = entry.DebounceTime or 1
	OverlayOriginalDebounce[id] = true
	task.delay(debounceTime, function()
		OverlayOriginalDebounce[id] = nil
	end)

	OverlayTracked[sound] = true
	local charName, isDistanceFallback = getSoundCharacterName(sound)

	-- Multiple overlays that all play (Overlays array)
	if entry.Overlays then
		for _, overlayInfo in ipairs(entry.Overlays) do
			playSingleOverlay(sound, overlayInfo, charName, isDistanceFallback)
		end
		return
	end

	-- Per-character overlays (character name keys)
	-- IMPORTANT: Skip if charName came from the distance fallback.
	-- Targeted abilities create sounds near the TARGET, not the caster.
	-- If we trust the distance fallback, we'd play Mary Louise's overlay
	-- when someone else uses Vido ON her — which is wrong.
	-- Only trust the parent hierarchy (isDistanceFallback == false) for character-specific overlays.
	if hasOverlayCharOverrides(entry) then
		if charName and entry[charName] and (not isDistanceFallback or entry.TrustDistanceFallback) then
			playSingleOverlay(sound, entry[charName], charName, isDistanceFallback)
		elseif entry.Sound then
			playSingleOverlay(sound, entry, charName, isDistanceFallback)
		end
		return
	end

	-- Simple overlay (Sound key, optional CharacterRequired)
	if entry.Sound then
		playSingleOverlay(sound, entry, charName, isDistanceFallback)
	end
end

-- [[ ANIMATION-BASED SOUND OVERLAY SYSTEM ]]
-- Plays an additional sound ON TOP of the animation (does NOT mute/replace anything).
-- Uses the same bracket format as SoundOverlays for character-specific entries.
-- Formats:
--   All characters:  ["animation_id"] = { Sound = "sound_id", Volume = 2.5, DelayTime = 0 }
--   Per-character:   ["animation_id"] = { ["Mary Louise"] = { Sound = "id1", Volume = 2.5, DelayTime = 0 }, ["Nora Hildegard"] = { Sound = "id2", Volume = 2.5, DelayTime = 0 } }
--   CutOffWithAnimation: set to true to stop the overlay sound when the animation track ends (default: sound plays to completion)

local AnimationSounds = {
	-- All characters hear the same overlay when this animation plays:
	["13570229994"] = {
		["Mary Louise"] = { Sound = "88600853616027", Volume = 2.5, DelayTime = 0 }, -- Vido
	},
	["18534997521"] = { Sound = "18535307514", Volume = 2.5, DelayTime = 0.5 }, -- Vamp Reversal
	["18967414922"] = { Sound = "83942262095667", Volume = 2.5, DelayTime = 0 }, -- Chains
	["133379296605385"] = { Sound = "94787275001396", Volume = 2.5, DelayTime = 0 }, -- Magic Steal
	["18535689569"] = { Sound = "74050761219524", Volume = 2.5, DelayTime = 0 }, -- Blood Steal 
	["18894484105"] = { Sound = "91204949642033", Volume = 2.5, DelayTime = 14 }, -- Orginal Serum
	["119520470649737"] = { Sound = "128387089253440", Volume = 2.5, DelayTime = 0 }, -- Bone Break Combo
	["82703548119759"] = { Sound = "97911663035904", Volume = 2, DelayTime = 0 }, -- Blood Choke 
	["75121459355526"] = { Sound = "73829700677752", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Blood Boil
	["98624816078661"] = { Sound = "94965672679001", Volume = 2.5, DelayTime = 0 }, -- Telek Attack
	["15809657465"] = { Sound = "15237076338", Volume = 2.5, DelayTime = 4, CutOffWithAnimation = true }, -- Aleoras Subsitos
	["8118882336"] = {
		["Bonnie Bennett"] = { Sound = "91016794551142", Volume = 2.5, DelayTime = 0 }, -- Phasmatos Incendia
	},
	["15834801673"] = { Sound = "117198514953604", Volume = 2.5, DelayTime = 0 }, -- Psychic Restraint
	["16409600440"] = { Sound = "16118919066", Volume = 2.5, DelayTime = 0, CutOffWithAnimation = true }, -- Avita Exari
	["132001244832758"] = { Sound = "16326825053", Volume = 2.5, DelayTime = 0, CutOffWithAnimation = true }, -- Spiritual Cleanse
	["120098338547414"] = { Sound = "16326825053", Volume = 2.5, DelayTime = 0, CutOffWithAnimation = true }, -- Spiritual Cleanse
	["16404267626"] = { Sound = "16479305722", Volume = 2.5, DelayTime = 15, KeepPlayingSound = true }, -- Cure Creation
	["15823927339"] = { Sound = "127725225837213", Volume = 2.5 }, -- Vados
	["17770724861"] = { Sound = "135485148941488", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Wound Infliction
	["15424577510"] = {
		["Bonnie Bennett"] = { Sound = "102024711113477", Volume = 2.5, DelayTime = 7.5 }, -- Life Linking
	},
	-- Per-character (bracket format, same as SoundOverlays):
	["13046802143"] = {
		["Josie Saltzman"] = { Sound = "74786986821079", Volume = 2.5, DelayTime = 4.3 }, -- Sandclock
	},
	["113177696607441"] = {
		["Valerie Tulle"] = { Sound = "134446708409005", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Incendia
		["Lizzie Saltzman"] = { Sound = "98540976660149", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Incendia
		["Hope Mikaelson"] = { Sound = "88254920355046", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Incendia
	},
	["131550349409770"] = {
		["Hope Mikaelson"] = { Sound = "127841579933142", Volume = 2, DelayTime = 0 }, -- Aquamalia
	},
	["14065674638"] = {
		["Hope Mikaelson"] = { Sound = "131807122245438", Volume = 2.5, DelayTime = 0 }, -- Lecutio
	},
	["16794479576"] = {
		["Hope Mikaelson"] = { Sound = "99427264222969", Volume = 5, DelayTime = 0 }, -- Force Cure Hope
	},
	["12940089696"] = {
		["Hope Mikaelson"] = { Sound = "104137817730493", Volume = 6, DelayTime = 0 }, -- Vitris
	},
	["12363733313"] = {
		["Hope Mikaelson"] = { Sound = "100313110940795", Volume = 2.5, DelayTime = 0 }, -- Light Ball
	},
	["14589451404"] = {
		["Hope Mikaelson"] = { Sound = "131198089743550", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Ad Somnum
		["Dark Josie"] = { Sound = "81204185561575", Volume = 2.5, DelayTime = 0 }, -- Ad Somnum
		["Freya Mikaelson"] = { Sound = "94633917213364", Volume = 2.5, DelayTime = 0 }, -- Ad Somnum
	},
	["17253129249"] = { Sound = "123143857916410", Volume = 2.5, DelayTime = 0 }, -- Disguise
	["87900706821607"] = {
		["Freya Mikaelson"] = { Sound = "117507162492846", Volume = 2, DelayTime = 0 }, -- Menedek Qual Surenta
	}, 
	["10512733733"] = {
		["Freya Mikaelson"] = { Sound = "117507162492846", Volume = 2, DelayTime = 0 }, -- Menedek Qual Surenta
	}, 
	["126225947243763"] = { Sound = "110211317792165", Volume = 2.5, DelayTime = 0 }, -- Pendant Trap
	["93680619177939"] = { Sound = "113820074623121", Volume = 2.5, DelayTime = 17, KeepPlayingSound = true }, -- Ancestor Attack End
	["82237064082144"] = { Sound = "105913987460965", Volume = 2.5, DelayTime = 0 }, -- Starling Burst
	["76457128360909"] = { Sound = "137442198052809", Volume = 2.5, DelayTime = 0, CutOffWithAnimation = true }, -- Brain Fry
	-- Qetsiyah's Brain Fry - all animation variants (front + behind)
	["12955966256"] = {
		["Qetsiyah"] = { Sound = "105550543421825", Volume = 2.5, DelayTime = 0 }, -- Brain Fry casterStart
		["Dark Josie"] = { Sound = "139164497000480", Volume = 2.5, DelayTime = 0 }, -- Head siphon
		["Malcolm"] = { Sound = "100864025080028", Volume = 2.5, DelayTime = 0 }, -- Head siphon
	},

	["80991149841796"] = {
		["Freya Mikaelson"] = { Sound = "135953039500242", Volume = 30, DelayTime = 0.2 }, -- Freya Resurrection
	}, 
	["76942479045558"] = { Sound = "106151236422771", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Sigil
    ["93301034042480"] = { Sound = "132015776882851", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true, CutOffWithAnimation = true }, -- Aneurysm
	["77225088768312"] = { Sound = "138819760805849", Volume = 2.5, DelayTime = 0 }, -- Cardiac Arrest
    ["136980766359708"] = { Sound = "129676323948552", Volume = 2.5, DelayTime = 5, KeepPlayingSound = true, CutOffWithAnimation = true, SimultaneousSound = "94259360187031" }, -- Original Reversal (both play together)
	["71385376638963"] = { Sound = "94711938117202", Volume = 25, DelayTime = 0 }, -- Dissulta
	["13632446588"] = {
		["Qetsiyah"] = { Sound = "132701227107666", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- DelfanEotenCor
		["Bonnie Bennett"] = { Sound = "93410039917419", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- DelfanEotenCor
		["Freya Mikaelson"] = { Sound = "129158847870610", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- DelfanEotenCor
	},
	["137419559387884"] = { Sound = "123217650248442", Volume = 2.5, DelayTime = 0 }, -- Telek Explosion
	["119991086161247"] = { Sound = "95590928220540", Volume = 2.5, DelayTime = 0 }, -- Sunbeam
	-- Vampire Abilities :
	["12307447494"] = {
		["Katherine Pierce"] = { Sound = "14841026112", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Spine Break
		["Aurora De Martel"] = { Sound = "97908940377337", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Spine Break
	},
	["17360483345"] = {
		["Aurora De Martel"] = { Sound = "91514318555989", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Throat Rip
	},
	["10748435391"] = {
		["Bonnie Bennett"] = { Sound = "136482218783790", Volume = 2.5, DelayTime = 0, CutOffWithAnimation = true }, -- Throat Rip Protection
		["Dark Josie"] = { Sound = "86892327341853", Volume = 2.5, DelayTime = 1.3 }, -- Throat Rip Protection
	},
    ["140173302204943"] = {
	    ["Hope Mikaelson"] = { Sound = "117071643793823", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Super Kick
    },
	["81743171989186"] = {
		["Rebekah Mikaelson"] = { Sound = "73616559992744", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Super Slap
		["Hope Mikaelson"] = { Sound = "125011735974039", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Super Slap
	},
	["125965536527103"] = {
		["Aurora De Martel"] = { Sound = "111039547177303", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Arm Break
		["Rebekah Mikaelson"] = { Sound = "95161950033776", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Arm Break
	    ["Hope Mikaelson"] = { Sound = "112336295176021", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Arm Break
	},
    ["95988116850782"] = {
	   ["Hope Mikaelson"] = { Sound = "114218115884187", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Heel Stomp
	   ["Dark Josie"] = { Sound = "91130808414020", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Heel Stomp
    },
	["72224780755559"] = {
		["Klaus Mikaelson"] = { Sound = "110962212419680", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Choke Out
		["Rebekah Mikaelson"] = { Sound = "103359391224128", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Choke Out
	},
	["12308763416"] = {
		["Aurora De Martel"] = { Sound = "71870170081183", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Heart Rip
		["Rebekah Mikaelson"] = { Sound = "89688396603399", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Heart Rip
	},
	["12308000578"] = {
		["Rebekah Mikaelson"] = { Sound = "135260624293276", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Choke
		["Hope Mikaelson"] = { Sound = "88024240964591", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Choke
		["Mary Louise"] = { Sound = "76991721803834", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Choke
	},
	-- Elder Witches :
	["109730789965953"] = {
	["Bastianna Natale"] = { Sound = "70512941919646", Volume = 3, DelayTime = 0, KeepPlayingSound = true }, -- Ancestral Pain
	["Josephine LaRue"] = { Sound = "79538024543328", Volume = 3, DelayTime = 0, KeepPlayingSound = true }, -- Ancestral Pain
	["Genevieve"] = { Sound = "80082176187338", Volume = 3, DelayTime = 0, KeepPlayingSound = true }, -- Ancestral Pain
	["Papa Tunde"] = { Sound = "70512941919646", Volume = 3, DelayTime = 0, KeepPlayingSound = true }, -- Ancestral Pain
	["Agnes"] = { Sound = "121671824051694", Volume = 2, DelayTime = 0, KeepPlayingSound = true }, -- Ancestral Pain
	},
	["14004031633"] = {
		["Valerie Tulle"] = { Sound = "13904360117", Volume = 2.5, DelayTime = 1.3, KeepPlayingSound = true }, -- HereticJointSpell
		["Mary Louise"] = { Sound = "13904360117", Volume = 2.5, DelayTime = 1.3, KeepPlayingSound = true }, -- HereticJointSpell
		["Nora Hildegard"] = { Sound = "13904360117", Volume = 2.5, DelayTime = 1.3, KeepPlayingSound = true }, -- HereticJointSpell
	},
	["12955990988"] = {
		["Qetsiyah"] = { Sound = "105550543421825", Volume = 2.5, DelayTime = 0 }, -- Brain Fry casterStartBehind
		["Dark Josie"] = { Sound = "139164497000480", Volume = 2.5, DelayTime = 0 }, -- Head siphon
		["Malcolm"] = { Sound = "100864025080028", Volume = 2.5, DelayTime = 0 }, -- Head siphon
	},
	["77528653756706"] = {
		["Freya Mikaelson"] = { Sound = "107779666764444", Volume = 2.5, DelayTime = 5, KeepPlayingSound = true }, -- LocatorSpell
	},
	["127428104014955"] = { Sound = "97414512710914", Volume = 2.5, DelayTime = 0, CutOffWithAnimation = true }, -- Astral Projection
	["99248832146292"] = { Sound = "114599395160541", Volume = 5, DelayTime = 0, KeepPlayingSound = true }, -- Insanity Hex
    ["138457929259080"] = { Sound = "99610680956880", Volume = 1.2, DelayTime = 0, CutOffWithAnimation = true }, -- Glace Solidatur
	["12363700089"] = {
		["Hope Mikaelson"] = { Sound = "85082904537308", Volume = 2.5, DelayTime = 0 }, -- Sol
	},
	["12189974108"] = {
		["Nora Hildegard"] = { Sound = "131259403209726", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Motus
		["Bonnie Bennett"] = { Sound = "114093297475680", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Motus
		["Davina Claire"] = { Sound = "109348032177998", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Motus
	},
	["14427195564"] = {
		["Hope Mikaelson"] = { Sound = "131906914556971", Volume = 4.3, DelayTime = 0 }, -- Red Oak protection
	},
	["14571834582"] = {
		["Hope Mikaelson"] = { Sound = "72373310588316", Volume = 4, DelayTime = 0, OncePerLifetime = true }, -- BloodBags
		["Lizzie Saltzman"] = { Sound = "80948803279616", Volume = 6, DelayTime = 0, OncePerLifetime = true }, -- BloodBags
	},
}

local AnimSoundCooldowns = {}
local ANIM_SOUND_COOLDOWN = 1 -- seconds between same animation sound to prevent spam

local AnimSoundKnownKeys = {
	Sound = true,
	Volume = true,
	KeepPlayingSound = true,
	DelayTime = true,
	FadeOutDuration = true,
	CutOffWithAnimation = true,
	SimultaneousSound = true,
	OncePerLifetime = true,
}

local function hasAnimCharOverrides(info)
	for key in pairs(info) do
		if type(key) == "string" and not AnimSoundKnownKeys[key] then
			return true
		end
	end
	return false
end

local function playAnimSound(animId, character, charName, track)
	local entry = AnimationSounds[animId]
	if not entry then return end

	-- Determine which sound info to use
	local soundInfo
	if hasAnimCharOverrides(entry) then
		if charName and entry[charName] then
			soundInfo = entry[charName]
		else
			return -- No matching sound for this character
		end
	else
		soundInfo = entry
	end

	if not soundInfo or not soundInfo.Sound then return end

	-- OncePerLifetime: skip if already played this character life
	if soundInfo.OncePerLifetime then
		local key = "anim_" .. soundInfo.Sound
		if OncePerLifetimePlayed[key] then return end
		OncePerLifetimePlayed[key] = true
	end

	-- Debounce to prevent sound spam
	local key = animId .. "_" .. (charName or "unknown")
	if AnimSoundCooldowns[key] then return end
	AnimSoundCooldowns[key] = true
	task.delay(ANIM_SOUND_COOLDOWN, function()
		AnimSoundCooldowns[key] = nil
	end)

	-- Play the overlay sound (plays ON TOP, does NOT mute/replace anything)
	local function doPlay()
		-- If CutOffWithAnimation is on, don't play if the animation already ended
		if soundInfo.CutOffWithAnimation and track and not track.IsPlaying then
			AnimSoundCooldowns[key] = nil
			return
		end

		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. normalize(soundInfo.Sound)
		sound.Volume = soundInfo.Volume or 2.5
		sound:SetAttribute("IsLocalVoiceline", true)

		-- Parent to character head for 3D positional audio
		local head = character and character:FindFirstChild("Head")
		if head then
			sound.Parent = head
			head.Destroying:Connect(function()
				pcall(function()
					if sound and sound.Parent then
						sound.Parent = SoundService
					end
				end)
			end)
		else
			sound.Parent = SoundService
		end

		sound:Play()

		-- Play simultaneous sound if provided
		if soundInfo.SimultaneousSound then
			local simSound = Instance.new("Sound")
			simSound.SoundId = "rbxassetid://" .. normalize(soundInfo.SimultaneousSound)
			simSound.Volume = soundInfo.Volume or 2.5
			simSound:SetAttribute("IsLocalVoiceline", true)

			if head then
				simSound.Parent = head
				head.Destroying:Connect(function()
					pcall(function()
						if simSound and simSound.Parent then
							simSound.Parent = SoundService
						end
					end)
				end)
			else
				simSound.Parent = SoundService
			end

			if soundInfo.DelayTime and soundInfo.DelayTime > 0 then
				task.delay(soundInfo.DelayTime, function()
					if simSound and simSound.Parent then
						simSound:Play()
					end
				end)
			else
				simSound:Play()
			end

			-- CutOffWithAnimation: fade out the simultaneous sound too
			if soundInfo.CutOffWithAnimation and track then
				track.Ended:Connect(function()
					if simSound and simSound.Parent then
						fadeOutOverlaySound(simSound, soundInfo.FadeOutDuration)
					end
				end)
			elseif not soundInfo.KeepPlayingSound then
				simSound.Ended:Connect(function()
					if simSound and simSound.Parent then
						simSound:Destroy()
					end
				end)
			end
		end

		-- CutOffWithAnimation: fade out the overlay when the animation track ends
		if soundInfo.CutOffWithAnimation and track then
			track.Ended:Connect(function()
				if sound and sound.Parent then
					fadeOutOverlaySound(sound, soundInfo.FadeOutDuration)
				end
				AnimSoundCooldowns[key] = nil
			end)
		elseif soundInfo.KeepPlayingSound then
			-- Reparent to SoundService if parent is destroyed so it keeps playing
			if head and head ~= SoundService then
				head.Destroying:Connect(function()
					pcall(function()
						if sound and sound.Parent then
							sound.Parent = SoundService
						end
					end)
				end)
			end
		else
			-- Auto-cleanup after sound ends
			sound.Ended:Connect(function()
				if sound and sound.Parent then
					sound:Destroy()
				end
				AnimSoundCooldowns[key] = nil
			end)
		end

		-- Safety: auto-reset cooldown after timeout
		task.delay(COOLDOWN_TIMEOUT, function()
			AnimSoundCooldowns[key] = nil
		end)
	end

	-- Support DelayTime (same as SoundOverlays)
	if soundInfo.DelayTime and soundInfo.DelayTime > 0 then
		task.delay(soundInfo.DelayTime, doPlay)
	else
		doPlay()
	end
end

local function getAnimCharName(character)
	for _, player in Players:GetPlayers() do
		if player.Character == character then
			return player:GetAttribute("CharacterName")
		end
	end
	return nil
end

local hookedAnimators = {} -- Track which Animators we've already hooked

local function hookAnimator(animator, character)
	if hookedAnimators[animator] then return end
	hookedAnimators[animator] = true

	animator.AnimationPlayed:Connect(function(track)
		local anim = track.Animation
		if not anim then return end

		local animId = normalize(anim.AnimationId)
		if animId == "" or animId == "0" then return end

		-- For local player: skip if local voicelines are disabled
		if character == Players.LocalPlayer.Character and not LOCAL_VOICELINES_ENABLED then
			return
		end

		local charName = getAnimCharName(character)
		playAnimSound(animId, character, charName, track)
	end)

	-- Clean up tracking when animator is destroyed
	animator.Destroying:Connect(function()
		hookedAnimators[animator] = nil
	end)
end

local function hookCharacterAnimations(character)
	if not character then return end

	local function tryHook(humanoid)
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			hookAnimator(animator, character)
		else
			-- Animator might be created later (e.g. after character fully loads)
			local conn
			conn = humanoid.ChildAdded:Connect(function(child)
				if child:IsA("Animator") then
					if conn then conn:Disconnect() end
					hookAnimator(child, character)
				end
			end)
			-- Fallback: try again after a short delay
			task.delay(3, function()
				if conn then conn:Disconnect() end
				local anim = humanoid:FindFirstChildOfClass("Animator")
				if anim then
					hookAnimator(anim, character)
				end
			end)
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		tryHook(humanoid)
	else
		-- Humanoid might not exist yet after respawn — wait for it
		local conn
		conn = character.ChildAdded:Connect(function(child)
			if child:IsA("Humanoid") then
				if conn then conn:Disconnect() end
				tryHook(child)
			end
		end)
		-- Fallback: retry after a short delay
		task.delay(5, function()
			if conn then conn:Disconnect() end
			local h = character:FindFirstChildOfClass("Humanoid")
			if h then
				tryHook(h)
			end
		end)
	end
end

-- Reset OncePerLifetime tracking on respawn
Players.LocalPlayer.CharacterAdded:Connect(function()
	OncePerLifetimePlayed = {}
end)

-- Hook local player's character
Players.LocalPlayer.CharacterAdded:Connect(hookCharacterAnimations)
if Players.LocalPlayer.Character then
	hookCharacterAnimations(Players.LocalPlayer.Character)
end

-- Hook other players' characters
local function onOtherPlayerAdded(player)
	player.CharacterAdded:Connect(hookCharacterAnimations)
	if player.Character then
		hookCharacterAnimations(player.Character)
	end
end

Players.PlayerAdded:Connect(onOtherPlayerAdded)
for _, player in Players:GetPlayers() do
	if player ~= Players.LocalPlayer then
		onOtherPlayerAdded(player)
	end
end

-- [[ CHAT-BASED VOICELINE TRIGGERS ]]
-- Plays a sound when a specific character's chat bubble shows matching text.
-- Watches for BillboardGui chat bubbles on character heads (works with DisplayBubble).

local ChatVoicelineSounds = {
	["Suffer"] = "17560604010",
	["Attack"] = "17560606672",
	["Everybody faint"] = "17560602849",
	["Nobody move"] = "17560600778",
}

local ChatVoicelineCharacter = "Silas"
local ChatVoicelineCooldown = {}

local function getCharNameFromCharacter(character)
	for _, player in Players:GetPlayers() do
		if player.Character == character then
			return player:GetAttribute("CharacterName")
		end
	end
	return nil
end

local function matchChatBubbleText(bubbleGui, character)
	if not bubbleGui or not bubbleGui:IsA("BillboardGui") then return end

	local charName = getCharNameFromCharacter(character)
	if charName ~= ChatVoicelineCharacter then return end

	-- Find the text inside the bubble
	local bubbleText = nil
	for _, desc in bubbleGui:GetDescendants() do
		if desc:IsA("TextLabel") and desc.Text and desc.Text ~= "" then
			bubbleText = desc.Text
			break
		end
	end
	if not bubbleText then return end

	local msg = bubbleText:match("^%s*(.-)%s*$")
	local soundId = nil
	local matchedKey = nil
	for key, id in pairs(ChatVoicelineSounds) do
		if msg:sub(1, #key):lower() == key:lower() then
			soundId = id
			matchedKey = key
			break
		end
	end
	if not soundId then return end

	local player = Players:GetPlayerFromCharacter(character)
	local userId = player and player.UserId or 0
	local key = userId .. "_" .. matchedKey
	if ChatVoicelineCooldown[key] then return end
	ChatVoicelineCooldown[key] = true
	task.delay(5, function() ChatVoicelineCooldown[key] = nil end)

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. soundId
	sound.Volume = 2.5
	sound:SetAttribute("IsLocalVoiceline", true)

	local head = character:FindFirstChild("Head")
	if head then
		sound.Parent = head
		head.Destroying:Connect(function()
			pcall(function()
				if sound and sound.Parent then
					sound.Parent = SoundService
				end
			end)
		end)
	else
		sound.Parent = SoundService
	end

	sound:Play()
	sound.Ended:Connect(function()
		if sound and sound.Parent then sound:Destroy() end
	end)
end

local function hookCharacterChatBubbles(character)
	if not character then return end
	local head = character:FindFirstChild("Head")
	if head then
		head.ChildAdded:Connect(function(child)
			task.defer(function()
				matchChatBubbleText(child, character)
			end)
		end)
	end
	character.ChildAdded:Connect(function(child)
		if child.Name == "Head" then
			child.ChildAdded:Connect(function(grandchild)
				task.defer(function()
					matchChatBubbleText(grandchild, character)
				end)
			end)
		end
	end)
end

-- Hook existing and future player characters
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(hookCharacterChatBubbles)
	if player.Character then
		hookCharacterChatBubbles(player.Character)
	end
end

for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)

-- Catch existing sounds already in the game
for _, desc in game:GetDescendants() do
	tryReplaceSound(desc)
	tryOverlaySound(desc)
end

-- Catch new sounds added during gameplay (from server or other players)
game.DescendantAdded:Connect(function(desc)
	tryReplaceSound(desc)
	tryOverlaySound(desc)
end)
