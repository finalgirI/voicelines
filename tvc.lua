local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function normalize(id)
	return tostring(id)
		:gsub("rbxassetid://", "")
		:gsub("%s+", "")
end

local COOLDOWN_TIMEOUT = 30 -- Safety: max seconds a cooldown can be stuck before auto-resetting
local FadingSounds = {}
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
		TweenInfo.new(1),
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

local function configure3DAudio(sound)
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 10
	sound.RollOffMaxDistance = 10000
end

local function findSoundParent(character)
	if not character or not character.Parent then return nil end
	local head = character:FindFirstChild("Head")
	if head then return head end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then return hrp end
	local upperTorso = character:FindFirstChild("UpperTorso")
	if upperTorso then return upperTorso end
	local torso = character:FindFirstChild("Torso")
	if torso then return torso end
	return nil
end

local function parentSoundToBody(sound, character)
	local parent = findSoundParent(character)
	if parent then
		sound.Parent = parent
		parent.Destroying:Connect(function()
			fadeOutSound(sound)
		end)
	elseif character and character.Parent then
		local attachPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
		if attachPart then
			local att = Instance.new("Attachment")
			att.Parent = attachPart
			sound.Parent = att
			att.Destroying:Connect(function() fadeOutSound(sound) end)
		else
			sound:Destroy()
			return false
		end
	end
	return true
end

local function parentSoundForCaster(sound, character, useCasterSoundService)
	if useCasterSoundService and character and character == Players.LocalPlayer.Character then
		-- Caster hears this as 2D audio through SoundService
		sound.Parent = SoundService
		return true
	else
		-- Everyone else hears it as 3D audio on the character body
		configure3DAudio(sound)
		return parentSoundToBody(sound, character)
	end
end

-- ============================================================
-- SOUND REPLACEMENTS
-- Replace one sound ID with another when it plays
-- ============================================================

local SoundReplacements = {
	-- Simple: ["originalSoundId"] = "replacementSoundId",
	-- With options: ["originalSoundId"] = { Replacement = "replacementSoundId", Volume = 2.5, KeepPlayingSound = true, CasterSoundService = true },
	-- Per character: ["originalSoundId"] = { ["CharacterName"] = "replacementSoundId", ["AnotherCharacter"] = "otherSoundId" },
	-- Example:
	["108205653141348"] = "106295827353405",
	["107819644605690"] = {
		["The Almighty"] = "101030536434449",
		Volume = 2,
	}, -- Hope humanity turned off
	-- ["123456789"] = { Replacement = "987654321", Volume = 3.5 },
	-- ["123456789"] = {
	--     ["Character Name"] = "987654321",
	--     ["Another Character"] = "111111111",
	-- },
}

local ReplacedSounds = {} -- Track sounds we've already replaced to avoid duplicates
local fadeOutOverlaySound -- forward declaration (defined later)

local function getSoundCharacterName(sound)

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

local function tryReplaceSound(sound)
	if not sound:IsA("Sound") then return end
	if ReplacedSounds[sound] then return end

	local id = sound.SoundId:gsub("rbxassetid://", "")
	local entry = SoundReplacements[id]

	if not entry then return end

	local replacementId
	if type(entry) == "string" then
		replacementId = entry
	else
		if entry.CharacterRequired then
			local charName, charIsDistFallback = getSoundCharacterName(sound)
			if charName ~= entry.CharacterRequired and not charIsDistFallback then return end
		end

		local charName, charIsDistFallback = getSoundCharacterName(sound)
		if charName and entry[charName] and (not charIsDistFallback or entry.TrustDistanceFallback) then
			replacementId = entry[charName]
		elseif entry.Replacement then
			replacementId = entry.Replacement
		else
			return -- No matching replacement found
		end
	end

	if entry.OncePerLifetime or (type(entry) == "string" and OncePerLifetimePlayed["replace_" .. id]) then
		local key = "replace_" .. id
		if OncePerLifetimePlayed[key] then return end
		OncePerLifetimePlayed[key] = true
	end

	ReplacedSounds[sound] = true

	sound.Volume = 0

	sound:GetPropertyChangedSignal("Volume"):Connect(function()
		if ReplacedSounds[sound] then
			sound.Volume = 0
		end
	end)

	local newSound = Instance.new("Sound")
	newSound.SoundId = "rbxassetid://" .. replacementId
	newSound.Volume = (type(entry) == "table" and entry.Volume) or 2.5
	configure3DAudio(newSound)

	local keepPlaying = false
	if type(entry) == "table" and entry.KeepPlayingSound then
		keepPlaying = true
	end

	local parent = sound.Parent

	if parent == SoundService or (parent and parent:IsA("Model")) then
		parent = nil
	end
	if parent and not parent:IsA("BasePart") and not parent:IsA("Attachment") then
		parent = nil
	end

	if parent then
		newSound.Parent = parent
	else
		local charName = getSoundCharacterName(sound)
		local bodyParent = nil
		if charName then
			for _, player in Players:GetPlayers() do
				if player:GetAttribute("CharacterName") == charName and player.Character then
					bodyParent = findSoundParent(player.Character)
					break
				end
			end
		end
		if not bodyParent then
			local soundPos = nil
			if sound.Parent and sound.Parent:IsA("BasePart") then
				soundPos = sound.Parent.Position
			elseif sound.Parent and sound.Parent:IsA("Attachment") then
				soundPos = sound.Parent.WorldPosition
			end
			if soundPos then
				local bestDist = 100
				for _, player in Players:GetPlayers() do
					if player.Character then
						local hrp = player.Character:FindFirstChild("HumanoidRootPart")
						if hrp then
							local dist = (hrp.Position - soundPos).Magnitude
							if dist < bestDist then
								bestDist = dist
								bodyParent = findSoundParent(player.Character)
							end
						end
					end
				end
			end
		end
		if bodyParent then
			newSound.Parent = bodyParent
			newSound.Ended:Connect(function()
				if newSound and newSound.Parent then newSound:Destroy() end
			end)
		else
			newSound:Destroy()
			ReplacedSounds[sound] = nil
			return
		end
	end

	newSound:Play()

	if keepPlaying then
		parent.Destroying:Connect(function()
			fadeOutSound(newSound)
		end)
	else
		if sound then
			sound.Ended:Connect(function() fadeOutOverlaySound(newSound) end)
			sound.Stopped:Connect(function() fadeOutOverlaySound(newSound) end)
			sound.Destroying:Connect(function()
				fadeOutOverlaySound(newSound)
				ReplacedSounds[sound] = nil
			end)
		end
		if parent and parent ~= SoundService and not parent:IsA("Model") then
			parent.Destroying:Connect(function()
				if newSound and newSound.Parent then
					local tempAtt = Instance.new("Attachment")
					tempAtt.Name = "FadeOutHolder"
					tempAtt.Parent = SoundService
					newSound.Parent = tempAtt
					if not FadingSounds[newSound] then
						fadeOutOverlaySound(newSound)
					end
					newSound.Destroying:Connect(function()
						if tempAtt and tempAtt.Parent then tempAtt:Destroy() end
					end)
				end
			end)
		end
	end

	newSound.Ended:Connect(function()
		newSound:Destroy()
	end)

	sound.Destroying:Connect(function()
		ReplacedSounds[sound] = nil
	end)
end

-- ============================================================
-- SOUND OVERLAYS
-- Play an additional sound on top of an existing sound
-- ============================================================

local SoundOverlays = {
	-- Hope Mikaelson Voicelines:
	["15254260885"] = {
		["The Almighty"] = { Sound = "77919326748641", Volume = 2.5, DelayTime = 0.2 }, -- Lecutio
	},
	-- ["15237665151"] = { Sound = "87969470088924", Volume = 3.5, DelayTime = 0 }, -- Stopping Spell
	-- Witch Abiltiies Voicelines:
	["14518634071"] = {
		["Psychic-Witch"] = { Sound = "118679634918055", Volume = 1.6, DelayTime = 0 }, -- Incendia'd
		["Psychic-Witch-HundredSpirits"] = { Sound = "118679634918055", Volume = 1.6, DelayTime = 0 }, -- Incendia'd
		["Psychic-Expression-Witch"] = { Sound = "118679634918055", Volume = 1.6, DelayTime = 0 }, -- Incendia'd
		["Psychic-Witch-Hundred-Spirit-Expression"] = { Sound = "118679634918055", Volume = 1.6, DelayTime = 0 }, -- Incendia'd
	},
}

local OverlayTracked = {} -- Track sounds we've already overlaid to avoid duplicates
local ActiveOverlaySounds = {} -- Track currently playing overlay Sound IDs to prevent duplicates (e.g. Illusion Attack plays 5x)
local OverlayOriginalDebounce = {} -- Debounce per original sound ID to prevent multiple overlays from duplicate original sounds

fadeOutOverlaySound = function(overlaySound, duration)
	if not overlaySound or not overlaySound.Parent then return end
	if FadingSounds[overlaySound] then return end

	FadingSounds[overlaySound] = true

	local tween = TweenService:Create(
		overlaySound,
		TweenInfo.new(duration or 1),
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
	CasterSoundService = true,
	SimultaneousSounds = true,
	StackCount = true,
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
	if overlayInfo.OncePerLifetime then
		local key = "overlay_" .. overlayInfo.Sound
		if OncePerLifetimePlayed[key] then return end
		OncePerLifetimePlayed[key] = true
	end

	if overlayInfo.CharacterRequired then
		if not charName then
			charName, charIsDistFallback = getSoundCharacterName(sound)
		end
		if charName ~= overlayInfo.CharacterRequired and not charIsDistFallback then return end
	end

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
		local existing = ActiveOverlaySounds[overlayInfo.Sound]
		if existing and existing.Parent and existing.IsPlaying then
			if overlayInfo.KeepPlayingSound then
				existing:Stop()
				existing:Destroy()
				ActiveOverlaySounds[overlayInfo.Sound] = nil
			else
				return
			end
		end
		ActiveOverlaySounds[overlayInfo.Sound] = nil

		local parent = nil
		if capturedCharModel and capturedCharModel.Parent then
			parent = findSoundParent(capturedCharModel)
		end
		if not parent and sound and sound.Parent then
			if sound.Parent:IsA("BasePart") or sound.Parent:IsA("Attachment") then
				parent = sound.Parent
			end
		end
		if parent == SoundService or (parent and parent:IsA("Model")) then
			parent = nil
		end
		if not parent then
			local charName = getSoundCharacterName(sound)
			if charName then
				for _, player in Players:GetPlayers() do
					if player:GetAttribute("CharacterName") == charName and player.Character then
						parent = findSoundParent(player.Character)
						break
					end
				end
			end
		end
		if not parent then
			local soundPos = nil
			if sound and sound.Parent then
				if sound.Parent:IsA("BasePart") then
					soundPos = sound.Parent.Position
				elseif sound.Parent:IsA("Attachment") then
					soundPos = sound.Parent.WorldPosition
				end
			end
			if soundPos then
				local bestDist = 100
				for _, player in Players:GetPlayers() do
					if player.Character then
						local hrp = player.Character:FindFirstChild("HumanoidRootPart")
						if hrp then
							local dist = (hrp.Position - soundPos).Magnitude
							if dist < bestDist then
								bestDist = dist
								parent = findSoundParent(player.Character)
							end
						end
					end
				end
			end
			if not parent then
				return
			end
		end

		if overlayInfo.KeepPlayingSound then
			local existing = ActiveOverlaySounds[overlayInfo.Sound]
			if existing and existing.Parent then
				existing:Stop()
				existing:Destroy()
				ActiveOverlaySounds[overlayInfo.Sound] = nil
			end
		end

		-- Main overlay sound (only if Sound is provided)
		local ov = nil
		if overlayInfo.Sound then
			ov = Instance.new("Sound")
			ov.SoundId = "rbxassetid://" .. overlayInfo.Sound
			ov.Volume = overlayInfo.Volume or 2.5

			if overlayInfo.CasterSoundService and capturedCharModel and capturedCharModel == Players.LocalPlayer.Character then
				ov.Parent = SoundService
			else
				configure3DAudio(ov)
				ov.Parent = parent
			end

			ov:Play()

			ActiveOverlaySounds[overlayInfo.Sound] = ov

			ov.Ended:Connect(function()
				ActiveOverlaySounds[overlayInfo.Sound] = nil
				if ov and ov.Parent then ov:Destroy() end
			end)

			if overlayInfo.KeepPlayingSound then
				if parent and parent ~= SoundService then
					parent.Destroying:Connect(function()
						fadeOutSound(ov)
					end)
				end
			else
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

			ov.Destroying:Connect(function()
				if ActiveOverlaySounds[overlayInfo.Sound] == ov then
					ActiveOverlaySounds[overlayInfo.Sound] = nil
				end
			end)
		end

		-- Play simultaneous sounds (SimultaneousSounds array)
		if overlayInfo.SimultaneousSounds and type(overlayInfo.SimultaneousSounds) == "table" then
			for _, simEntry in ipairs(overlayInfo.SimultaneousSounds) do
				local simSoundId, simDelay, simVolume, simStackCount
				if type(simEntry) == "table" then
					simSoundId = simEntry.Sound
					simDelay = simEntry.DelayTime
					simVolume = simEntry.Volume
					simStackCount = simEntry.StackCount
				else
					simSoundId = simEntry
					simDelay = overlayInfo.DelayTime
					simVolume = overlayInfo.Volume
				end

				if simSoundId and simSoundId ~= "0" and simSoundId ~= 0 then
					local function playSim()
						local simSound = Instance.new("Sound")
						simSound.SoundId = "rbxassetid://" .. normalize(simSoundId)
						simSound.Volume = simVolume or overlayInfo.Volume or 2.5

						if overlayInfo.CasterSoundService and capturedCharModel and capturedCharModel == Players.LocalPlayer.Character then
							simSound.Parent = SoundService
						else
							configure3DAudio(simSound)
							simSound.Parent = parent
						end

						simSound:Play()

						-- Stack extra copies for extreme loudness (since Volume is clamped 0-10)
						local stackCount = simStackCount or 1
						if stackCount > 1 then
							for i = 2, stackCount do
								local stackSound = Instance.new("Sound")
								stackSound.SoundId = "rbxassetid://" .. normalize(simSoundId)
								stackSound.Volume = simVolume or overlayInfo.Volume or 2.5
								if overlayInfo.CasterSoundService and capturedCharModel and capturedCharModel == Players.LocalPlayer.Character then
									stackSound.Parent = SoundService
								else
									configure3DAudio(stackSound)
									stackSound.Parent = parent
								end
								stackSound:Play()
								stackSound.Ended:Connect(function()
									if stackSound and stackSound.Parent then stackSound:Destroy() end
								end)
							end
						end

						simSound.Ended:Connect(function()
							if simSound and simSound.Parent then simSound:Destroy() end
						end)

						if not overlayInfo.KeepPlayingSound and sound then
							sound.Ended:Connect(function() fadeOutOverlaySound(simSound, overlayInfo.FadeOutDuration) end)
							sound.Stopped:Connect(function() fadeOutOverlaySound(simSound, overlayInfo.FadeOutDuration) end)
						end
					end

					if simDelay and simDelay > 0 then
						task.delay(simDelay, playSim)
					else
						playSim()
					end
				end
			end
		end
	end

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
		local played = false
		local conn
		conn = sound.Played:Connect(function()
			played = true
			if conn then conn:Disconnect() end
			doPlay()
		end)
		task.delay(2, function()
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

	local id = sound.SoundId:gsub("rbxassetid://", "")
	local entry = SoundOverlays[id]
	if not entry then return end

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

	if entry.Overlays then
		for _, overlayInfo in ipairs(entry.Overlays) do
			playSingleOverlay(sound, overlayInfo, charName, isDistanceFallback)
		end
		return
	end

	if hasOverlayCharOverrides(entry) then
		if charName and entry[charName] and (not isDistanceFallback or entry.TrustDistanceFallback) then
			playSingleOverlay(sound, entry[charName], charName, isDistanceFallback)
		elseif entry.Sound then
			playSingleOverlay(sound, entry, charName, isDistanceFallback)
		end
		return
	end

	if entry.Sound then
		playSingleOverlay(sound, entry, charName, isDistanceFallback)
	end
end

-- ============================================================
-- ANIMATION SOUNDS (animation -> voiceline overlay system)
-- Plays a sound (optionally per-character) whenever a matching
-- animation ID plays on a character's Animator
-- ============================================================

local AnimationSounds = {
	-- Bonnie Bennett Voicelines:
	["80427699313810"] = { Sound = "92032872036108", Volume = 2.5, DelayTime = 0 }, -- Bone Break Combo
	["73624875116274"] = { Sound = "114365880784490", Volume = 2.5, DelayTime = 0 }, -- Bone Break Combo
	["104295734346426"] = { Sound = "124351638860466", Volume = 2.5, DelayTime = 0, SimultaneousSounds = {
		{ Sound = "87772546771617", DelayTime = 0.6, Volume = 2.5 }, -- TODO: fill in sound ID and delay
	} }, -- Bone Break Combo
	["101308466912854"] = { Sound = "137607417360952", Volume = 2, DelayTime = 0 }, -- Vados
	["140372654256422"] = { Sound = "89008760309144", Volume = 1.3, DelayTime = 0 }, -- Throat Rip Counter
	["93352379786638"] = { Sound = "93142367750982", Volume = 1.9, DelayTime = 0 }, -- Fire Trail
	["97786686878401"] = { Sound = "127540876994519", Volume = 2.5, DelayTime = 3.1 }, -- Locator Spell 
	["72721507985289"] = { Sound = "86468772377379", Volume = 2.5, DelayTime = 1 }, -- Expression Activate
	["129292930175405"] = { Sound = "128129073465076", Volume = 1.8, DelayTime = 0 }, -- Petrification
	["118804989222729"] = { Sound = "86003332339956", Volume = 2.5, DelayTime = 0.3 }, -- Resurrection
	["130471440959620"] = { Sound = "85824220736554", Volume = 2, DelayTime = 0 }, -- Enraged Combo
	["90980258389989"] = { Sound = "83135931611364", Volume = 1.9, DelayTime = 5 }, -- Psychic Bond
	["81766391141675"] = { Sound = "92261254633713", Volume = 2.1, DelayTime = 7.4 }, -- Incantation after contacting Emily 
	["110210471124945"] = { Sound = "107707284471446", Volume = 2.2, DelayTime = 0.2 }, -- Psychic Blast
	["121445238427652"] = {
		["Psychic-Witch"] = { Sound = "124711584528671", Volume = 2.2, DelayTime = 0 }, -- Barrier Spell
		["Psychic-Witch-HundredSpirits"] = { Sound = "124711584528671", Volume = 2.2, DelayTime = 0 }, -- Barrier Spell
		["Psychic-Expression-Witch"] = { Sound = "124711584528671", Volume = 2.2, DelayTime = 0 }, -- Barrier Spell
		["Psychic-Witch-Hundred-Spirit-Expression"] = { Sound = "124711584528671", Volume = 2.2, DelayTime = 0 }, -- Barrier Spell
	},
	["79178970449204"] = { Sound = "137483430640044", Volume = 1.6, DelayTime = 3.5 }, -- Rage Mode start
	-- Dark Josie Voicelines:
	["15939296269"] = { Sound = "128384006543303", Volume = 2.5, DelayTime = 0 }, -- Memory Purge
	["9941864692"] = { Sound = "90115515174277", Volume = 1.5, DelayTime = 0 }, -- Fiante Fulguris
	["126435728163733"] = { Sound = "125049316050755", Volume = 2, DelayTime = 0 }, -- Ignalusa
	["110353551012574"] = { Sound = "106472065593828", Volume = 2, DelayTime = 0 }, -- Resistus Meladi
	["101255716611899"] = { Sound = "89077023905632", Volume = 2.5, DelayTime = 0 }, -- Mass Fire
	["75036250327303"] = { Sound = "104679432448093", Volume = 2.5, DelayTime = 0 }, -- Heart Crush
	["118615570624038"] = { Sound = "74786986821079", Volume = 2.5, DelayTime = 6.2 }, -- Sandclock Break
	["96184651878906"] = { Sound = "113987498545129", Volume = 3.8, DelayTime = 0, KeepPlayingSound = true, SimultaneousSounds = {
		{ Sound = "137913527086296", DelayTime = 0, Volume = 3.8 },
	} }, -- Autem
	-- Hope Mikaelson Voicelines:
	-- ["71469143872702"] = {
	---["The Almighty"] = { Sound = "77919326748641", Volume = 2.5, DelayTime = 0.2 }, -- Lecutio
	-- },
	["14930919924"] = { Sound = "104028506433231", Volume = 1.4, DelayTime = 0 }, -- Bruciare 
	["14608474948"] = { Sound = "129937487508844", Volume = 1.9, DelayTime = 2.3 }, -- Vitris
	["15081444800"] = { Sound = "72404882318303", Volume = 2, DelayTime = 0 }, -- Ventus
	["78282468450513"] = { Sound = "80220227468095", Volume = 2, DelayTime = 5.1 }, -- Head Decapitation
	["14221130422"] = {
		["The Almighty"] = { SimultaneousSounds = {
			{ Sound = "73928896867445", DelayTime = 0, Volume = 9, StackCount = 8 },
			{ Sound = "140630563136815", DelayTime = 0, Volume = 4 },
		}, Volume = 2.5, DelayTime = 0 }, -- Hope's Repulse
	},
	-- Freya Mikaelson Voicelines:
	["97940902404327"] = { Sound = "139978653240699", Volume = 2.5, DelayTime = 0 }, -- Illusionary Stun
	["74423482356879"] = { Sound = "96559138398231", Volume = 2.5, DelayTime = 0, SimultaneousSounds = {
		{ Sound = "102648181914291", DelayTime = 4 },
	} }, -- Astral Projection
	["71235179156196"] = { Sound = "117773239376878", Volume = 2, DelayTime = 0, CutOffWithAnimation = true }, -- Delfan Start
	["71928771227244"] = { Sound = "125415751867268", Volume = 2, DelayTime = 0, CutOffWithAnimation = true }, -- Delfan Loop
	["99046910970478"] = { Sound = "134739394157385", Volume = 2, DelayTime = 0 }, -- Delfan End
	["117868722364419"] = { Sound = "89137940149599", Volume = 1.8, DelayTime = 0 }, -- Sigil
	["71380116918113"] = { Sound = "76305636990854", Volume = 2.5, DelayTime = 0.3 }, -- Menedek Qual Surentaa (Area Snap)
	["121798883557428"] = { Sound = "108401043112433", Volume = 3, DelayTime = 0 }, -- Neck Snap (Enough)
	["114133688342040"] = { Sound = "132530506633345", Volume = 2.5, DelayTime = 0 }, -- Summon Davina
	["98020982912130"] = { Sound = "89639338294496", Volume = 3.2, DelayTime = 0, KeepPlayingSound = true, SimultaneousSounds = {
		{ Sound = "106691313379398", DelayTime = 0, Volume = 3.2 },
		{ Sound = "113820074623121", DelayTime = 9.6, Volume = 1.2 },
	} }, -- Ancestral Hijack
	["121343995300360"] = { Sound = "121470032291906", Volume = 2.5, DelayTime = 0 }, -- Advanced Pain Infliction
	["116216933265867"] = { Sound = "105913987460965", Volume = 5, DelayTime = 0 }, -- Brain Melt
	["98448216504564"] = { Sound = "125000907792622", Volume = 3, DelayTime = 0 }, -- Brain Melt (Far Range)
	["85444212414085"] = { Sound = "129676323948552", Volume = 2, DelayTime = 0, KeepPlayingSound = true, SimultaneousSounds = {
		{ Sound = "115581020820485", DelayTime = 0, Volume = 2 },
		{ Sound = "112555794145085", DelayTime = 15, Volume = 1.5 },
	} }, -- Original Reversal (all three play together)
	["95661493993334"] = { SimultaneousSounds = {
		{ Sound = "111630588301632", DelayTime = 0, Volume = 1.5 },
		{ Sound = "136529550796252", DelayTime = 0, Volume = 1.5 },
		{ Sound = "102938095768537", DelayTime = 4.5, Volume = 1.5 },
	}, Volume = 2.5, DelayTime = 0, CutOffWithAnimation = true }, -- Anchor Spell
	["92641535427787"] = { Sound = "130866724589573", Volume = 2, DelayTime = 0 }, -- Pendant Trap
	["0"] = { Sound = "0", Volume = 2.5, DelayTime = 0 }, -- 
	-- Lizzie Saltzman Voicelines:
	["76457218213945"] = { Sound = "94711938117202", Volume = 25, DelayTime = 0 }, -- Dissulta
	-- Cleo Sowande Voicelines:
	["74751237006227"] = { Sound = "92404277403294", Volume = 2.5, DelayTime = 0 }, -- Ohun
	["72961444125693"] = { Sound = "91217804264943", Volume = 2.5, DelayTime = 0 }, -- Pada
	-- Vincent Griffith Voicelines:
	["131307324807651"] = { SimultaneousSounds = {
		{ Sound = "106687843187704", DelayTime = 0 },
		{ Sound = "73332613180468", DelayTime = 5 },
	}, Volume = 2.5, DelayTime = 0 }, -- Ancestral Pain
	-- Death Voicelines
	["120852912003486"] = {
		["Psychic-Witch"] = { Sound = "128677013682522", Volume = 1.6, DelayTime = 0 }, -- Bonnie Death Voiceline
		["Psychic-Witch-HundredSpirits"] = { Sound = "128677013682522", Volume = 1.6, DelayTime = 0 }, -- Bonnie Death Voiceline
		["Psychic-Expression-Witch"] = { Sound = "128677013682522", Volume = 1.6, DelayTime = 0 }, -- Bonnie Death Voiceline
		["Psychic-Witch-Hundred-Spirit-Expression"] = { Sound = "128677013682522", Volume = 1.6, DelayTime = 0 }, -- Bonnie Death Voiceline
	},
	-- Stomp Voicelines:
	["134388403697828"] = {
		["The Almighty"] = { Sound = "87248564786741", Volume = 2, DelayTime = 0 }, -- Hope Stomp
		["Dark Siphoner"] = { Sound = "124488865501193", Volume = 1.8, DelayTime = 0 }, -- Josie Stomp
	},
	["0"] = { Sound = "0", Volume = 2.5, DelayTime = 0 }, -- 
	["0"] = { Sound = "0", Volume = 2.5, DelayTime = 0 }, -- 
	["0"] = { Sound = "0", Volume = 2.5, DelayTime = 0 }, -- 
	["0"] = { Sound = "0", Volume = 2.5, DelayTime = 0 }, -- 
	["0"] = { Sound = "0", Volume = 2.5, DelayTime = 0 }, -- 
	["0"] = { Sound = "0", Volume = 2.5, DelayTime = 0 }, -- 
	["0"] = { Sound = "0", Volume = 2.5, DelayTime = 0 }, -- 
	["0"] = { Sound = "0", Volume = 2.5, DelayTime = 0 }, -- 
	["0"] = { Sound = "0", Volume = 2.5, DelayTime = 0 }, -- 
	["0"] = { Sound = "0", Volume = 2.5, DelayTime = 0 }, -- 
}

local AnimSoundCooldowns = {}
local AnimSoundCycleIndex = {}
local ANIM_SOUND_COOLDOWN = 1 -- seconds between same animation sound to prevent spam

local AnimSoundKnownKeys = {
	Sound = true,
	Sounds = true,
	Volume = true,
	KeepPlayingSound = true,
	DelayTime = true,
	FadeOutDuration = true,
	CutOffWithAnimation = true,
	SimultaneousSound = true,
	SimultaneousSounds = true,
	ChatText = true,
	OncePerLifetime = true,
	StackCount = true,
	CasterSoundService = true,
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

	if not soundInfo then return end

	local soundId
	local chatText = nil

	if soundInfo.Sounds then
		local cycleKey = animId .. "_" .. (charName or "unknown")
		local index = AnimSoundCycleIndex[cycleKey] or 1
		local sndEntry = soundInfo.Sounds[index]
		if type(sndEntry) == "table" then
			soundId = sndEntry.Sound
			chatText = sndEntry.ChatText
		else
			soundId = sndEntry
		end
		AnimSoundCycleIndex[cycleKey] = (index % #soundInfo.Sounds) + 1
	else
		soundId = soundInfo.Sound
		chatText = soundInfo.ChatText
	end

	if not soundId and not soundInfo.SimultaneousSounds and not soundInfo.SimultaneousSound then return end

	if soundInfo.OncePerLifetime then
		local key = "anim_" .. (soundId or animId)
		if OncePerLifetimePlayed[key] then return end
		OncePerLifetimePlayed[key] = true
	end

	local key, cooldownTime
	if entry.GroupCooldown then
		key = animId .. "_group" -- shared key so any character blocks all others
		cooldownTime = entry.GroupCooldown
	else
		key = animId .. "_" .. (charName or "unknown")
		cooldownTime = ANIM_SOUND_COOLDOWN
	end
	if AnimSoundCooldowns[key] then return end
	AnimSoundCooldowns[key] = true
	task.delay(cooldownTime, function()
		AnimSoundCooldowns[key] = nil
	end)

	local function doPlay()
		if soundInfo.CutOffWithAnimation and track and not track.IsPlaying then
			AnimSoundCooldowns[key] = nil
			return
		end

		local sound = nil
		if soundId then
			sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://" .. normalize(soundId)
			sound.Volume = soundInfo.Volume or 2.5
			sound:SetAttribute("IsLocalVoiceline", true)

			local parentResult = parentSoundForCaster(sound, character, soundInfo.CasterSoundService or entry.CasterSoundService)
			if parentResult == false then
				AnimSoundCooldowns[key] = nil
				return
			end

			sound:Play()

			-- Stack extra copies for extreme loudness (since Volume is clamped 0-10)
			local stackCount = soundInfo.StackCount or entry.StackCount or 1
			if stackCount > 1 then
				for i = 2, stackCount do
					local stackSound = Instance.new("Sound")
					stackSound.SoundId = "rbxassetid://" .. normalize(soundId)
					stackSound.Volume = soundInfo.Volume or 2.5
					stackSound:SetAttribute("IsLocalVoiceline", true)
					parentSoundForCaster(stackSound, character, soundInfo.CasterSoundService or entry.CasterSoundService)
					stackSound:Play()
					stackSound.Ended:Connect(function()
						if stackSound and stackSound.Parent then stackSound:Destroy() end
					end)
				end
			end
		end

		-- Show chat bubble if ChatText is provided
		if chatText and character and character.Parent then
			game:GetService("Chat"):Chat(character, chatText, Enum.ChatColor.White)
		end

		-- Helper to play a single simultaneous sound
		-- simEntry can be a string (sound ID) or a table: { Sound = "id", DelayTime = 0, Volume = nil }
		local function playSimSound(simEntry, fallbackDelay)
			-- Resolve entry to fields
			local simSoundId, simDelay, simVolume
			if type(simEntry) == "table" then
				simSoundId = simEntry.Sound
				simDelay = simEntry.DelayTime
				simVolume = simEntry.Volume
			else
				simSoundId = simEntry
				simDelay = fallbackDelay
			end

			if not simSoundId or simSoundId == "0" or simSoundId == 0 then return end
			local simSound = Instance.new("Sound")
			simSound.SoundId = "rbxassetid://" .. normalize(simSoundId)
			simSound.Volume = simVolume or soundInfo.Volume or 2.5
			simSound:SetAttribute("IsLocalVoiceline", true)

			parentSoundForCaster(simSound, character, soundInfo.CasterSoundService or entry.CasterSoundService)

			local function startSimSound()
				if simSound and simSound.Parent then
					simSound:Play()
				end
			end

			if simDelay and simDelay > 0 then
				task.delay(simDelay, startSimSound)
			else
				startSimSound()
			end

			-- Stack extra copies for extreme loudness (since Volume is clamped 0-10)
			local stackCount = (type(simEntry) == "table" and simEntry.StackCount) or 1
			if stackCount > 1 then
				for i = 2, stackCount do
					local stackSound = Instance.new("Sound")
					stackSound.SoundId = "rbxassetid://" .. normalize(simSoundId)
					stackSound.Volume = simVolume or soundInfo.Volume or 2.5
					stackSound:SetAttribute("IsLocalVoiceline", true)
					parentSoundForCaster(stackSound, character, soundInfo.CasterSoundService or entry.CasterSoundService)

					local function startStackSound()
						if stackSound and stackSound.Parent then
							stackSound:Play()
						end
					end

					if simDelay and simDelay > 0 then
						task.delay(simDelay, startStackSound)
					else
						startStackSound()
					end

					if soundInfo.CutOffWithAnimation and track then
						track.Ended:Connect(function()
							if stackSound and stackSound.Parent then
								fadeOutOverlaySound(stackSound, soundInfo.FadeOutDuration)
							end
						end)
					else
						stackSound.Ended:Connect(function()
							if stackSound and stackSound.Parent then
								stackSound:Destroy()
							end
						end)
					end
				end
			end

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

		-- Play multiple simultaneous sounds (SimultaneousSounds array)
		-- Each entry can be a plain string ID or a table: { Sound = "id", DelayTime = 0, Volume = 3 }
		if soundInfo.SimultaneousSounds and type(soundInfo.SimultaneousSounds) == "table" then
			for _, simEntry in ipairs(soundInfo.SimultaneousSounds) do
				playSimSound(simEntry, nil)
			end
		elseif soundInfo.SimultaneousSound then
			playSimSound(soundInfo.SimultaneousSound, soundInfo.DelayTime)
		end

		if soundId then
			if soundInfo.CutOffWithAnimation and track then
				track.Ended:Connect(function()
					if sound and sound.Parent then
						fadeOutOverlaySound(sound, soundInfo.FadeOutDuration)
					end
					AnimSoundCooldowns[key] = nil
				end)
			elseif soundInfo.KeepPlayingSound then
			else
				sound.Ended:Connect(function()
					if sound and sound.Parent then
						sound:Destroy()
					end
					AnimSoundCooldowns[key] = nil
				end)
			end
		end

		task.delay(COOLDOWN_TIMEOUT, function()
			AnimSoundCooldowns[key] = nil
		end)
	end

	if soundInfo.DelayTime and soundInfo.DelayTime > 0 then
		task.delay(soundInfo.DelayTime, doPlay)
	else
		doPlay()
	end
end

local function getAnimCharName(character)
	if character then
		local name = character:GetAttribute("CharacterName")
		if name then return name end
	end
	for _, player in Players:GetPlayers() do
		if player.Character == character then
			return character:GetAttribute("CharacterName")
		end
	end
	return nil
end

local checkCombosForAnimation -- forward declaration (defined later)

local hookedAnimators = {} -- Track which Animators we've already hooked

local function hookAnimator(animator, character)
	if hookedAnimators[animator] then return end
	hookedAnimators[animator] = true

	animator.AnimationPlayed:Connect(function(track)
		local anim = track.Animation
		if not anim then return end

		local animId = normalize(anim.AnimationId)
		if animId == "" or animId == "0" then return end

		local charName = getAnimCharName(character)
		playAnimSound(animId, character, charName, track)

		if checkCombosForAnimation then
			checkCombosForAnimation(animId, character, charName, track)
		end
	end)

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
			local conn
			conn = humanoid.ChildAdded:Connect(function(child)
				if child:IsA("Animator") then
					if conn then conn:Disconnect() end
					hookAnimator(child, character)
				end
			end)
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
		local conn
		conn = character.ChildAdded:Connect(function(child)
			if child:IsA("Humanoid") then
				if conn then conn:Disconnect() end
				tryHook(child)
			end
		end)
		task.delay(5, function()
			if conn then conn:Disconnect() end
			local h = character:FindFirstChildOfClass("Humanoid")
			if h then
				tryHook(h)
			end
		end)
	end
end

Players.LocalPlayer.CharacterAdded:Connect(function()
	OncePerLifetimePlayed = {}
end)

Players.LocalPlayer.CharacterAdded:Connect(hookCharacterAnimations)
if Players.LocalPlayer.Character then
	hookCharacterAnimations(Players.LocalPlayer.Character)
end

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

-- ============================================================
-- SOUND COMBOS
-- Detect when a specific animation and sound play close together
-- in time, then play a combo sound
-- ============================================================

local AnimationSoundCombos = {
	["StoppingSpell"] = {
		AnimationId = "14509237380",
		SoundId = "15237665151",
		["The Almighty"] = "87969470088924",
		Volume = 3.5,
		KeepPlayingSound = true,
		DelayTime = 0,
		WindowTime = 0.5,
	}
}

local ComboKnownKeys = {
	AnimationId = true,
	SoundId = true,
	Sound = true,
	Volume = true,
	DelayTime = true,
	KeepPlayingSound = true,
	CutOffWithAnimation = true,
	CharacterRequired = true,
	WindowTime = true,
	CasterSoundService = true,
}

local function hasComboCharOverrides(info)
	for key in pairs(info) do
		if type(key) == "string" and not ComboKnownKeys[key] then
			return true
		end
	end
	return false
end

local RecentAnimPlays = {}
local RecentSoundPlays = {}

local ComboCooldowns = {}
local COMBO_COOLDOWN = 1 -- seconds between same combo triggering

local function playComboSound(comboEntry, character, charName, track)
	local soundInfo
	if hasComboCharOverrides(comboEntry) then
		if charName and comboEntry[charName] then
			soundInfo = comboEntry[charName]
		else
			return -- No matching character override
		end
	else
		soundInfo = comboEntry
	end

	if type(soundInfo) == "string" then
		soundInfo = { Sound = soundInfo }
	end

	if soundInfo ~= comboEntry then
		for _, key in ipairs({"Volume", "KeepPlayingSound", "DelayTime", "CutOffWithAnimation", "FadeOutDuration"}) do
			if soundInfo[key] == nil and comboEntry[key] ~= nil then
				soundInfo[key] = comboEntry[key]
			end
		end
	end

	if not soundInfo or not soundInfo.Sound then return end

	if soundInfo.CharacterRequired then
		if charName ~= soundInfo.CharacterRequired then return end
	end

	local cooldownKey = (comboEntry.AnimationId or "") .. "_" .. (comboEntry.SoundId or "") .. "_" .. (charName or "unknown")
	if ComboCooldowns[cooldownKey] then return end
	ComboCooldowns[cooldownKey] = true
	task.delay(COMBO_COOLDOWN, function()
		ComboCooldowns[cooldownKey] = nil
	end)

	local function doPlay()
		if soundInfo.CutOffWithAnimation and track and not track.IsPlaying then
			ComboCooldowns[cooldownKey] = nil
			return
		end

		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. normalize(soundInfo.Sound)
		sound.Volume = soundInfo.Volume or 2.5
		sound:SetAttribute("IsLocalVoiceline", true)

		parentSoundForCaster(sound, character, soundInfo.CasterSoundService or comboEntry.CasterSoundService)

		sound:Play()

		if soundInfo.CutOffWithAnimation and track then
			track.Ended:Connect(function()
				if sound and sound.Parent then
					fadeOutOverlaySound(sound, soundInfo.FadeOutDuration)
				end
				ComboCooldowns[cooldownKey] = nil
			end)
		elseif soundInfo.KeepPlayingSound then
		else
			sound.Ended:Connect(function()
				if sound and sound.Parent then
					sound:Destroy()
				end
				ComboCooldowns[cooldownKey] = nil
			end)
		end

		task.delay(COOLDOWN_TIMEOUT, function()
			ComboCooldowns[cooldownKey] = nil
		end)
	end

	if soundInfo.DelayTime and soundInfo.DelayTime > 0 then
		task.delay(soundInfo.DelayTime, doPlay)
	else
		doPlay()
	end
end

checkCombosForAnimation = function(animId, character, charName, track)
	if not RecentAnimPlays[character] then
		RecentAnimPlays[character] = {}
	end
	RecentAnimPlays[character][animId] = { time = tick(), track = track }

	for _, comboEntry in pairs(AnimationSoundCombos) do
		if normalize(comboEntry.AnimationId) == animId then
			local soundId = normalize(comboEntry.SoundId)
			local windowTime = comboEntry.WindowTime or 0.5

			local soundPlays = RecentSoundPlays[character]
			if soundPlays and soundPlays[soundId] then
				local elapsed = tick() - soundPlays[soundId].time
				if elapsed <= windowTime then
					playComboSound(comboEntry, character, charName, track)
				end
			end
		end
	end
end

local function checkCombosForSound(soundId, character, charName, soundInstance)
	if not RecentSoundPlays[character] then
		RecentSoundPlays[character] = {}
	end
	RecentSoundPlays[character][soundId] = { time = tick(), sound = soundInstance }

	for _, comboEntry in pairs(AnimationSoundCombos) do
		if normalize(comboEntry.SoundId) == soundId then
			local animId = normalize(comboEntry.AnimationId)
			local windowTime = comboEntry.WindowTime or 0.5

			local animPlays = RecentAnimPlays[character]
			if animPlays and animPlays[animId] then
				local elapsed = tick() - animPlays[animId].time
				if elapsed <= windowTime then
					playComboSound(comboEntry, character, charName, animPlays[animId].track)
				end
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(5)
		local now = tick()
		for char, anims in pairs(RecentAnimPlays) do
			if not char or not char.Parent then
				RecentAnimPlays[char] = nil
			else
				for animId, data in pairs(anims) do
					if now - data.time > 3 then
						anims[animId] = nil
					end
				end
			end
		end
		for char, sounds in pairs(RecentSoundPlays) do
			if not char or not char.Parent then
				RecentSoundPlays[char] = nil
			else
				for soundId, data in pairs(sounds) do
					if now - data.time > 3 then
						sounds[soundId] = nil
					end
				end
			end
		end
	end
end)

-- ============================================================
-- BOOTSTRAP
-- Hook every existing sound + every future sound for
-- replacement/overlay handling
-- ============================================================

for _, desc in game:GetDescendants() do
	tryReplaceSound(desc)
	tryOverlaySound(desc)
end

game.DescendantAdded:Connect(function(desc)
	tryReplaceSound(desc)
	tryOverlaySound(desc)

	-- Fix: When sounds replicate from the server, DescendantAdded can fire
	-- before SoundId is set. Wait for SoundId before retrying replacement/overlay.
	if desc:IsA("Sound") and desc.SoundId == "" then
		local conn
		conn = desc:GetPropertyChangedSignal("SoundId"):Connect(function()
			if conn then conn:Disconnect() end
			if desc.SoundId ~= "" then
				tryReplaceSound(desc)
				tryOverlaySound(desc)
			end
		end)
		task.delay(5, function()
			if conn then conn:Disconnect() end
		end)
	end
end)

-- ============================================================
-- SOUND COMBO OVERLAY HOOK
-- Override tryOverlaySound to also check for sound combos
-- ============================================================

local originalTryOverlaySound = tryOverlaySound
tryOverlaySound = function(sound)
	if not sound:IsA("Sound") then return end
	if OverlayTracked[sound] then return end

	originalTryOverlaySound(sound)

	local id = sound.SoundId:gsub("rbxassetid://", "")
	if id == "" then return end

	local character = nil
	local current = sound.Parent
	while current do
		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
			for _, player in Players:GetPlayers() do
				if player.Character == current then
					character = current
					break
				end
			end
			if character then break end
		end
		current = current.Parent
	end

	if character then
		local charName = getAnimCharName(character)
		checkCombosForSound(id, character, charName, sound)
	end
end

-- ============================================================
-- NPC SPAWN SOUNDS
-- Play a sound when a specific NPC model spawns in the map
-- ============================================================

local NpcSpawnSounds = {
	["Witch NPC"] = { Sound = "75051140424637", Volume = 4, DelayTime = 0 }, -- Davina Summoned by Freya
}

local playedNpcSpawnSounds = {} -- Track which NPC instances we've already played sounds for

local function playNpcSpawnSound(npcModel)
	if not npcModel or not npcModel.Parent then return end
	if playedNpcSpawnSounds[npcModel] then return end
	playedNpcSpawnSounds[npcModel] = true

	local entry = NpcSpawnSounds[npcModel.Name]
	if not entry then return end

	local function doPlay()
		if not npcModel or not npcModel.Parent then return end

		local parent = findSoundParent(npcModel)
		if not parent then
			parent = npcModel:FindFirstChild("HumanoidRootPart") or npcModel:FindFirstChildWhichIsA("BasePart")
		end
		if not parent then return end

		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. normalize(entry.Sound)
		sound.Volume = entry.Volume or 2.5
		configure3DAudio(sound)
		sound.Parent = parent
		sound:Play()

		sound.Ended:Connect(function()
			if sound and sound.Parent then sound:Destroy() end
		end)

		npcModel.Destroying:Connect(function()
			playedNpcSpawnSounds[npcModel] = nil
			if sound and sound.Parent then
				fadeOutSound(sound)
			end
		end)
	end

	if entry.DelayTime and entry.DelayTime > 0 then
		task.delay(entry.DelayTime, doPlay)
	else
		doPlay()
	end
end

local function checkNpcSpawn(descendant)
	if descendant:IsA("Model") and NpcSpawnSounds[descendant.Name] then
		playNpcSpawnSound(descendant)
	end
end

for _, desc in workspace:GetDescendants() do
	checkNpcSpawn(desc)
end

workspace.DescendantAdded:Connect(checkNpcSpawn)
