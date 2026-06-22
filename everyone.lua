local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local LOCAL_VOICELINES_ENABLED = true -- Set to true to hear your own ability voicelines again

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
		TweenInfo.new(0.4),
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
	CasterSoundService = true,
}

local function hasCharacterOverrides(info)
	for key in pairs(info) do
		if type(key) == "string" and not KnownKeys[key] then
			return true
		end
	end
	return false
end

local function playAbilitySound(info, abilityName)

	if not LOCAL_VOICELINES_ENABLED then
		Cooldowns[abilityName] = false
		return
	end

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

	local character = Players.LocalPlayer.Character
	if not parentSoundForCaster(sound, character, info.CasterSoundService) then
		Cooldowns[abilityName] = false
		return
	end

	local oldSound = ActiveSounds[abilityName]
	if oldSound and oldSound ~= sound then
		if KeepPlayingSounds[oldSound] then
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

	task.delay(COOLDOWN_TIMEOUT, function()
		if Cooldowns[abilityName] then
			Cooldowns[abilityName] = false
		end
	end)

	if simultaneousSoundId then
		local simSound = Instance.new("Sound")
		simSound.SoundId = "rbxassetid://" .. normalize(simultaneousSoundId)
		simSound.Volume = info.Volume or 2.5
		simSound:SetAttribute("IsLocalVoiceline", true)

		local character = Players.LocalPlayer.Character
		parentSoundForCaster(simSound, character, info.CasterSoundService)

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
		local delayedSound = sound
		task.delay(info.DelayTime, function()
			if ActiveSounds[abilityName] == delayedSound and delayedSound.Parent then
				delayedSound:Play()
			else
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

local SoundReplacements = {
	["105594719818558"] = "15366096625", -- Psychic Blast
	["122372982294729"] = "15174394937", -- Phasmatos Immortale
	["90326993393737"] = "15325084064", -- Suctus Incendia
	["118411956384669"] = { Replacement = "15254480460", Volume = 4.5 }, -- Phasmatos Ravaros
	["80430541489576"] = "14556366203", -- Turn To Stone
	["132884184474189"] = "15631194386", -- Phasmatos Tribum Nas Ex Veras
	["105998583954931"] = { Replacement = "13441892676", Volume = 3.5 }, -- Harae
	["14043844852"] = { Replacement = "13904360117", Volume = 4.5 }, -- Heretic Joint Spell
	["74468391415531"] = { Replacement = "16326825053", KeepPlayingSound = true }, -- Spiritual Cleanse
	["116235007511881"] = "13203446447", -- Autem
	["89008508391784"] = "17471844257", -- Hope's Repulse
	["101281556370554"] = "81639278311000", -- Ah Sha Lana
	["132899449516141"] = { ["Qetsiyah"] = "15981291789", KeepPlayingSound = true }, -- Brain Fry Qetsiyah only
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

local function isLocalPlayerSound(sound)
	local localCharacter = Players.LocalPlayer.Character
	if not localCharacter then return false, false end

	local current = sound.Parent
	while current do
		if current == localCharacter then
			return true, false -- isLocal, isDistanceFallback
		end
		current = current.Parent
	end

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
			newSound:Play()
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

local SoundOverlays = {
	["120250468841070"] = {
		Overlays = {
			{ Sound = "15601121759", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Expression Grimoire
			{ Sound = "123232609831917", Volume = 2.5, DelayTime = 13, KeepPlayingSound = true }, -- I Have Every Magic
		},
	},
	["111801255101409"] = { Sound = "74460096162653", Volume = 2.5, DelayTime = 0 }, -- Magic Shield
	["105558064418066"] = { Sound = "100950296033969", Volume = 2.5, DelayTime = 0 }, -- Firstborn Devastation
	["16208954441"] = { Sound = "95468563095334", Volume = 2.5, DelayTime = 0 }, -- Ignis Tempestas
	["16449297928"] = { Sound = "16838696298", Volume = 2.5, DelayTime = 0 }, -- Turn To Stone Qetsiyah
	["16327076834"] = { Sound = "78867379826047", Volume = 2.5, DelayTime = 0 }, -- Channel Talisman

	["82029037414223"] = { Sound = "128304384560357", Volume = 2.5, DelayTime = 0 }, -- Telek Submission 
	["112458851193845"] = { Sound = "16767898955", Volume = 2.5, DelayTime = 0 }, -- Destroy Purgatory
	["10006479564"] = {
		["Davina Claire"] = { Sound = "112486710306576", Volume = 2, DelayTime = 0.2 }, -- Hand Of Glory
	},
	["103830069988568"] = { Sound = "79984922909048", Volume = 2.5, DelayTime = 0 }, -- NecksnapLift
	["107029347506027"] = { Sound = "123620176154825", Volume = 2.5, DelayTime = 0 }, -- Lightning Strike
	["82939375129525"] = { Sound = "82826752361269", Volume = 1.5, DelayTime = 0 }, -- Davina Magic Regen
	["97485998367353"] = { Sound = "104028506433231", Volume = 1.4, DelayTime = 0 }, -- Bruciare
	["12934765027"] = { Sound = "72404882318303", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Ventus
	["13780865276"] = { Sound = "129988097306628", Volume = 2.5, DelayTime = 5, KeepPlayingSound = true }, -- Telek Head Rip
	["82322000387474"] = { Sound = "129460073622144", Volume = 2.5, DelayTime = 4 }, -- Pentagram
	["133379296605385"] = { Sound = "94787275001396", Volume = 2.5, DelayTime = 0 }, -- Magic Steal
	["13154602444"] = {
		["Dark Josie"] = { Sound = "77485734102576", Volume = 2.5, DelayTime = 0 }, -- Outfit change
	},
	["14123511526"] = { Sound = "90115515174277", Volume = 2, DelayTime = 0 }, -- Fiante Fulguris
	["116348909990770"] = { Sound = "78053223963040", Volume = 2, DelayTime = 0, KeepPlayingSound = true }, -- Ascendo
	["115788596173476"] = { Sound = "101957577374614", Volume = 0.8 , DelayTime = 0, KeepPlayingSound = true }, -- I said hey
	["85094625219939"] = { Sound = "122887446534653", Volume = 2.5, DelayTime = 0 }, -- Muse Teleport
	["90347973452829"] = { Sound = "92404277403294", Volume = 6, DelayTime = 0 }, -- Ohun
	["138866821877856"] = { Sound = "91217804264943", Volume = 6, DelayTime = 0 }, -- Pada
	["86985539781391"] = { Sound = "131047658678353", Volume = 2.5, DelayTime = 0.2 }, -- Inspire
	["133109898520847"] = { Sound = "74072970288534", Volume = 2.5, DelayTime = 0.2 }, -- Mud Golem 
	["13008144854"] = {
		["Nora Hildegard"] = { Sound = "118508173111903", Volume = 2.5, DelayTime = 0 }, -- Strangulo Ventus
		["Valerie Tulle"] = { Sound = "88573986552740", Volume = 2.5, DelayTime = 0 }, -- Strangulo Ventus
		["Mary Louise"] = { Sound = "79541636928372", Volume = 6, DelayTime = 0 }, -- Strangulo Ventus
	},
	["89539286902417"] = {
		["Lizzie Saltzman"] = { Sound = "132802121953563", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Stellabunde
		["Cleo Sowande"] = { Sound = "90131739908048", Volume = 2.5, DelayTime = 0 }, -- Mass Silence
		TrustDistanceFallback = true,
	},
	["15980142966"] = {
		["Agnes"] = { Sound = "97437123423899", Volume = 1.5, DelayTime = 0 }, -- Agnes Needle of Sorrows
	},
	["135718833680425"] = {
		Overlays = {
			{ Sound = "139418993300939", Volume = 2.5, DelayTime = 0 }, -- White Oak Spell
			{ Sound = "118918239866614", Volume = 2.5, DelayTime = 17, KeepPlayingSound = true }, -- White Oak Hunter
		},
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
		TweenInfo.new(duration or 0.4),
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

		local ov = Instance.new("Sound")
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

local AnimationSounds = {
	["13570229994"] = {
		["Mary Louise"] = { Sound = "88600853616027", Volume = 3, DelayTime = 0 }, -- Vido
	},
	["109154468000797"] = {
		["Qetsiyah"] = {
			Overlays = {
				{ Sound = "106974700127215", Volume = 5, DelayTime = 0, KeepPlayingSound = true }, -- Map Tracking Qetsiyah P1
				{ Sound = "123232609831917", Volume = 5, DelayTime = 8.2, KeepPlayingSound = true }, -- Map Tracking Qetsiyah P2
			},
		},
		["Freya Mikaelson"] = { Sound = "107779666764444", Volume = 3, DelayTime = 0, KeepPlayingSound = true }, -- LocatorSpell
	},
	["12171371908"] = {
		["Dark Josie"] = { Sound = "86892327341853", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Dark Magic Blast
		["Josie Saltzman"] = { Sound = "86892327341853", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Dark Magic Blast
	},
	["16549443461"] = { Sound = "121910418466989", Volume = 3, DelayTime = 1 }, -- Qetsiyah Resurrection
	["107144570826196"] = {
		["Bastianna Natale"] = { Sounds = {
			{Sound = "96452201447795", ChatText = "To be reborn, you must sacrifise"},
			{Sound = "79362032592167", ChatText = "Do you have faith in the harvest?"},
			{Sound = "113939339508982", ChatText = "To be reborn, we must sacrifise"},
			{Sound = "71834991545131", ChatText = "To be reborn, we must have faith!"},
		}, Volume = 4.5, DelayTime = 0 }, -- Harvest Dagger
	},
	["13302728573"] = { Sound = "13203446447", Volume = 7.3, DelayTime = 0 }, -- Autem
	["16587640939"] = { Sound = "16775370366", Volume = 2.5, DelayTime = 0 }, -- Venom Blast
	["16455033835"] = { Sound = "93083659221700", Volume = 3.2, DelayTime = 0 }, -- Vines
	["18967414922"] = { Sound = "83942262095667", Volume = 2.5, DelayTime = 0 }, -- Chains
	["133379296605385"] = { Sound = "94787275001396", Volume = 2.5, DelayTime = 0 }, -- Magic Steal
	["18535689569"] = { Sound = "74050761219524", Volume = 2.5, DelayTime = 0 }, -- Blood Steal 
	["18894484105"] = { Sound = "91204949642033", Volume = 2.5, DelayTime = 14 }, -- Orginal Serum
	["119520470649737"] = { Sound = "128387089253440", Volume = 2.5, DelayTime = 0 }, -- Bone Break Combo
	["82703548119759"] = { Sound = "97911663035904", Volume = 2, DelayTime = 0 }, -- Blood Choke 
	["75121459355526"] = { Sound = "73829700677752", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Blood Boil
	["98624816078661"] = { Sound = "94965672679001", Volume = 2.5, DelayTime = 0 }, -- Telek Attack
	["72314048009672"] = { Sound = "89550767660084", Volume = 3.5, DelayTime = 0 }, -- Violin
	["15809657465"] = { Sound = "15237076338", Volume = 2.5, DelayTime = 4, CutOffWithAnimation = true }, -- Aleoras Subsitos
	["15619485183"] = { Sound = "95435320218587", Volume = 5.5, DelayTime = 0 }, -- Building On Fire
	["15835470076"] = { 
		["Bonnie Bennett"] = { Sound = "104749000603361", Volume = 4, DelayTime = 0, KeepPlayingSound = true }, -- Channel Ancestors
	},
	["15834801673"] = { Sound = "117198514953604", Volume = 2.5, DelayTime = 0 }, -- Psychic Restraint
	["16409600440"] = { Sound = "16118919066", Volume = 2.5, DelayTime = 0, CutOffWithAnimation = true }, -- Avita Exari
	["16404267626"] = { Sound = "16479305722", Volume = 2.5, DelayTime = 15, KeepPlayingSound = true }, -- Cure Creation
	["15823927339"] = { Sound = "127725225837213", Volume = 2.5 }, -- Vados
	["17770724861"] = { Sound = "135485148941488", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Wound Infliction
	["13046802143"] = {
		["Josie Saltzman"] = { Sound = "74786986821079", Volume = 2.5, DelayTime = 4.5 }, -- Sandclock
	},
	["113177696607441"] = {
		CasterSoundService = true,
		["Valerie Tulle"] = { Sound = "134446708409005", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Incendia
		["Lizzie Saltzman"] = { Sound = "98540976660149", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Incendia
		["Hope Mikaelson"] = { Sound = "88254920355046", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Incendia
		["Bonnie Bennett"] = { Sound = "74863711273747", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Incendia
	},
	["131550349409770"] = {
		["Hope Mikaelson"] = { Sound = "127841579933142", Volume = 2, DelayTime = 0 }, -- Aquamalia
	},
	["14065674638"] = {
		["Hope Mikaelson"] = { Sound = "131807122245438", Volume = 2.5, DelayTime = 0 }, -- Lecutio
	},
	["71157109677249"] = {
		["Hope Mikaelson"] = { Sound = "117071643793823", Volume = 2.5, DelayTime = 0 }, -- Super Kick
	},
	["13721687618"] = {
		["Mary Louise"] = { Sound = "101738888339389", Volume = 5, DelayTime = 0 }, -- Super Punch
	},
	["16794479576"] = {
		["Hope Mikaelson"] = { Sound = "99427264222969", Volume = 5, DelayTime = 0 }, -- Force Cure Hope
	},
	["12940089696"] = {
		["Hope Mikaelson"] = { Sound = "104137817730493", Volume = 6, DelayTime = 0 }, -- Vitris
	},
	["15052194152"] = {
		["Freya Mikaelson"] = { Sound = "97414512710914", Volume = 2.5, DelayTime = 5 }, -- Astral Projection
	},
	["12363733313"] = {
		["Hope Mikaelson"] = { Sound = "100313110940795", Volume = 2.5, DelayTime = 0 }, -- Light Ball
	},
	["14589451404"] = {
		["Hope Mikaelson"] = { Sound = "131198089743550", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Ad Somnum
		["Freya Mikaelson"] = { Sound = "94633917213364", Volume = 2.5, DelayTime = 0 }, -- Ad Somnum
	},
	["103809123106748"] = {
		["Any1"] = { Sound = "87795617159364", Volume = 2.5, DelayTime = 0 }, -- Immobilus
	},
	["87900706821607"] = {
		["Freya Mikaelson"] = { Sound = "117507162492846", Volume = 2, DelayTime = 0 }, -- Menedek Qual Surenta
	}, 
	["80761083713462"] = {
		["Freya Mikaelson"] = { Sound = "117507162492846", Volume = 2, DelayTime = 0 }, -- Menedek Qual Surenta
		["Bonnie Bennett"] = { Sound = "135858003613789", Volume = 6, DelayTime = 0 }, -- Menedek Qual Surenta
	}, 
	["126225947243763"] = { Sound = "110211317792165", Volume = 1.9, DelayTime = 0 }, -- Pendant Trap
	["93680619177939"] = { Sound = "113820074623121", Volume = 2.5, DelayTime = 17, KeepPlayingSound = true }, -- Ancestor Attack End
	["82237064082144"] = { Sound = "105913987460965", Volume = 2.5, DelayTime = 0 }, -- Starling Burst
	["76457128360909"] = { Sound = "137442198052809", Volume = 2.5, DelayTime = 0, CutOffWithAnimation = true }, -- Brain Fry
	["12955966256"] = {
		["Dark Josie"] = { Sound = "139164497000480", Volume = 2.5, DelayTime = 0 }, -- Head siphon
		["Malcolm"] = { Sound = "100864025080028", Volume = 2.5, DelayTime = 0 }, -- Head siphon
	},
	["80991149841796"] = { Sound = "135953039500242", Volume = 10, DelayTime = 0.2, StackCount = 10 }, -- Freya Resurrection (stacked for extreme loudness)
	["76942479045558"] = { Sound = "106151236422771", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Sigil
	["93301034042480"] = { Sound = "132015776882851", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true, CutOffWithAnimation = true }, -- Aneurysm
	["77225088768312"] = { Sound = "138819760805849", Volume = 2.5, DelayTime = 0 }, -- Cardiac Arrest
	["136980766359708"] = { Sound = "129676323948552", Volume = 4, DelayTime = 0, KeepPlayingSound = true, CutOffWithAnimation = true, SimultaneousSound = "94259360187031" }, -- Original Reversal (both play together)
	["71385376638963"] = { Sound = "94711938117202", Volume = 25, DelayTime = 0 }, -- Dissulta
	["13632446588"] = {
		["Qetsiyah"] = { Sound = "132701227107666", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- DelfanEotenCor
		["Bonnie Bennett"] = { Sound = "93410039917419", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- DelfanEotenCor
		["Freya Mikaelson"] = { Sound = "129158847870610", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true, CutOffWithAnimation = true }, -- DelfanEotenCor
	},
	["137419559387884"] = { Sound = "123217650248442", Volume = 2.5, DelayTime = 0 }, -- Telek Explosion
	["119991086161247"] = { Sound = "95590928220540", Volume = 2.5, DelayTime = 0 }, -- Sunbeam
	["12307447494"] = {
		["Katherine Pierce"] = { Sound = "14841026112", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Spine Break
		["Aurora De Martel"] = { Sound = "97908940377337", Volume = 3.5, DelayTime = 0, KeepPlayingSound = true }, -- Spine Break
		["Mary Louise"] = { Sound = "72478658775676", Volume = 8, DelayTime = 0, KeepPlayingSound = true }, -- Spine Break
		["Klaus Mikaelson"] = { Sound = "74404353258021", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Spine Break
	},
	["10748431894"] = {
		["Aurora De Martel"] = { Sound = "91514318555989", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Throat Rip
		["Caroline Forbes"] = { Sound = "106117879767037", Volume = 4.5, DelayTime = 0, KeepPlayingSound = true }, -- Throat Rip
		["Mary Louise"] = { Sound = "79352381719423", Volume = 6, DelayTime = 0, KeepPlayingSound = true }, -- Throat Rip
	},
	["10748435391"] = {
		["Bonnie Bennett"] = { Sound = "136482218783790", Volume = 1.5, DelayTime = 0, CutOffWithAnimation = true }, -- Throat Rip Protection
		["Dark Josie"] = { Sound = "86892327341853", Volume = 2.5, DelayTime = 1.3 }, -- Throat Rip Protection
	},
	["81743171989186"] = {
		["Rebekah Mikaelson"] = { Sound = "73616559992744", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Super Slap
		["Hope Mikaelson"] = { Sound = "125011735974039", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Super Slap
	},
	["125965536527103"] = {
		["Aurora De Martel"] = { Sound = "111039547177303", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Arm Break
		["Rebekah Mikaelson"] = { Sound = "95161950033776", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Arm Break
		["Hope Mikaelson"] = { Sound = "112336295176021", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Arm Break
		["Caroline Forbes"] = { Sound = "96995867234659", Volume = 5, DelayTime = 0, KeepPlayingSound = true }, -- Arm Break
		["Marcel Gerard"] = { Sound = "125972157691262", Volume = 7, DelayTime = 0, KeepPlayingSound = true }, -- Arm Break 
		["Mary Louise"] = { Sound = "134606267442356", Volume = 5, DelayTime = 0, KeepPlayingSound = true }, -- Arm Break
	}, 
	["95988116850782"] = {
		["Hope Mikaelson"] = { Sound = "114218115884187", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Heel Stomp
		["Dark Josie"] = { Sound = "91130808414020", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Heel Stomp
		["Caroline Forbes"] = { Sound = "82935740630457", Volume = 4.5, DelayTime = 0, KeepPlayingSound = true }, -- Heel Stomp
	},
	["72224780755559"] = {
		["Klaus Mikaelson"] = { Sound = "110962212419680", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Choke Out
		["Rebekah Mikaelson"] = { Sound = "103359391224128", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Choke Out
		["Marcel Gerard"] = { Sound = "134565387051180", Volume = 7, DelayTime = 0, KeepPlayingSound = true }, -- Choke Out 
	},
	["12308726489"] = {
		["Aurora De Martel"] = { Sound = "71870170081183", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Heart Rip
		["Rebekah Mikaelson"] = { Sound = "89688396603399", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Heart Rip
		["Marcel Gerard"] = { Sound = "110930423196956", Volume = 7, DelayTime = 0, KeepPlayingSound = true }, -- Heart Rip 
		["Klaus Mikaelson"] = { Sound = "86539828788238", Volume = 3.5, DelayTime = 0, KeepPlayingSound = true }, -- Heart Rip
	},
	["12308000578"] = {
		["Rebekah Mikaelson"] = { Sound = "135260624293276", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Choke
		["Hope Mikaelson"] = { Sound = "88024240964591", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Choke
		["Mary Louise"] = { Sound = "105517213066097", Volume = 5, DelayTime = 0, KeepPlayingSound = true }, -- Choke
		["Caroline Forbes"] = { Sound = "134442581136768", Volume = 5, DelayTime = 0, KeepPlayingSound = true }, -- Choke
		["Marcel Gerard"] = { Sound = "80192436290512", Volume = 7, DelayTime = 0, KeepPlayingSound = true }, -- Choke
	},
	["109730789965953"] = {
		["Bastianna Natale"] = { Sound = "83432170862902", Volume = 3, DelayTime = 0, KeepPlayingSound = true }, -- Ancestral Pain
		["Josephine LaRue"] = { Sound = "79538024543328", Volume = 3, DelayTime = 0, KeepPlayingSound = true }, -- Ancestral Pain
		["Genevieve"] = { Sound = "80082176187338", Volume = 3, DelayTime = 0, KeepPlayingSound = true }, -- Ancestral Pain
		["Papa Tunde"] = { Sound = "74362949998012", Volume = 3, DelayTime = 0, KeepPlayingSound = true }, -- Ancestral Pain
		["Agnes"] = { Sound = "121671824051694", Volume = 2, DelayTime = 0, KeepPlayingSound = true }, -- Ancestral Pain
	},
	["133624249365350"] = { Sound = "135570080925664", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Blade
	["12955990988"] = {
		["Dark Josie"] = { Sound = "139164497000480", Volume = 2.5, DelayTime = 0 }, -- Head siphon
		["Malcolm"] = { Sound = "100864025080028", Volume = 2.5, DelayTime = 0 }, -- Head siphon
	},

	["99248832146292"] = { Sound = "114599395160541", Volume = 5, DelayTime = 0, KeepPlayingSound = true }, -- Insanity Hex
	["138457929259080"] = { Sound = "99610680956880", Volume = 2.2, DelayTime = 0, CutOffWithAnimation = true }, -- Glace Solidatur
	["12363700089"] = {
		["Hope Mikaelson"] = { Sound = "85082904537308", Volume = 2.5, DelayTime = 0 }, -- Sol
	},
	["14427195564"] = {
		["Hope Mikaelson"] = { Sound = "131906914556971", Volume = 4.3, DelayTime = 0 }, -- Red Oak protection
	},
	["14571834582"] = {
		["Lizzie Saltzman"] = { Sound = "80948803279616", Volume = 6, DelayTime = 0, OncePerLifetime = true }, -- BloodBags
	},
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

	if not soundId then return end

	if soundInfo.OncePerLifetime then
		local key = "anim_" .. soundId
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

		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. normalize(soundId)
		sound.Volume = soundInfo.Volume or 2.5
		sound:SetAttribute("IsLocalVoiceline", true)

		parentSoundForCaster(sound, character, soundInfo.CasterSoundService or entry.CasterSoundService)

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

		-- Show chat bubble if ChatText is provided
		if chatText and character and character.Parent then
			game:GetService("Chat"):Chat(character, chatText, Enum.ChatColor.White)
		end

		if soundInfo.SimultaneousSound then
			local simSound = Instance.new("Sound")
			simSound.SoundId = "rbxassetid://" .. normalize(soundInfo.SimultaneousSound)
			simSound.Volume = soundInfo.Volume or 2.5
			simSound:SetAttribute("IsLocalVoiceline", true)

			parentSoundForCaster(simSound, character, soundInfo.CasterSoundService or entry.CasterSoundService)

			if soundInfo.DelayTime and soundInfo.DelayTime > 0 then
				task.delay(soundInfo.DelayTime, function()
					if simSound and simSound.Parent then
						simSound:Play()
					end
				end)
			else
				simSound:Play()
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
	for _, player in Players:GetPlayers() do
		if player.Character == character then
			return player:GetAttribute("CharacterName")
		end
	end
	return nil
end

local hookedAnimators = {} -- Track which Animators we've already hooked

local checkCombosForAnimation -- forward declaration (defined later)
local checkCompulsionProtectionForAnimation -- forward declaration (defined later)

local function hookAnimator(animator, character)
	if hookedAnimators[animator] then return end
	hookedAnimators[animator] = true

	animator.AnimationPlayed:Connect(function(track)
		local anim = track.Animation
		if not anim then return end

		local animId = normalize(anim.AnimationId)
		if animId == "" or animId == "0" then return end

		if character == Players.LocalPlayer.Character and not LOCAL_VOICELINES_ENABLED then
			return
		end

		local charName = getAnimCharName(character)
		playAnimSound(animId, character, charName, track)

		if checkCombosForAnimation then
			checkCombosForAnimation(animId, character, charName, track)
		end
		if checkCompulsionProtectionForAnimation then
			checkCompulsionProtectionForAnimation(animId, character, charName, track)
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

local ChatVoicelineSounds = {
	["Forget to breathe"] = "98703979367465",
}

local ChatVoicelineCooldown = {}
local recordCompulsionChat -- forward declaration (defined later)

local function onChatMessageReceived(textChatMessage)
	if not textChatMessage then return end

	local textSource = textChatMessage.TextSource
	local player = nil
	local userId = nil

	if textSource then
		userId = textSource.UserId
		player = Players:GetPlayerByUserId(userId)
	end

	-- Fallback: if TextSource is missing (can happen for other players' messages),
	-- try to identify the player from the message prefix (e.g. "[PlayerName]: message")
	if not player then
		local msgText = textChatMessage.Text
		if msgText then
			local colonPos = msgText:find(":")
			if colonPos and colonPos < 30 then
				local possibleName = msgText:sub(1, colonPos - 1):match("^%s*(.-)%s*$")
				-- Strip rich text / bracket wrappers like [PlayerName]
				possibleName = possibleName:gsub("[%[%]]", "")
				for _, p in Players:GetPlayers() do
					if p.Name == possibleName or p.DisplayName == possibleName then
						player = p
						userId = p.UserId
						break
					end
				end
			end
		end
	end

	if not player then return end

	local msg = textChatMessage.Text
	if not msg then return end

	-- Strip player name prefix if present (e.g. "PlayerName: Forget to breathe" -> "Forget to breathe")
	local colonPos = msg:find(":")
	if colonPos and colonPos < 30 then
		local prefix = msg:sub(1, colonPos - 1):match("^%s*(.-)%s*$")
		-- Only strip if the prefix looks like a player name (no spaces, or wrapped in brackets)
		if not prefix:find("%s") or prefix:match("^%[.*%]$") then
			msg = msg:sub(colonPos + 1):match("^%s*(.-)%s*$")
		end
	end
	msg = msg:match("^%s*(.-)%s*$")

	-- Compulsion Protection: record if this chat message is a compulsion trigger
	recordCompulsionChat(player, msg)

	local soundId = nil
	local matchedKey = nil
	local chatEntry = nil
	for key, entry in pairs(ChatVoicelineSounds) do
		if msg:sub(1, #key):lower() == key:lower() then
			matchedKey = key
			chatEntry = entry
			break
		end
	end
	if not chatEntry then return end

	local charName = player:GetAttribute("CharacterName")
	if type(chatEntry) == "string" then
		soundId = chatEntry
	elseif type(chatEntry) == "table" then
		if charName and chatEntry[charName] then
			soundId = chatEntry[charName]
		elseif chatEntry.Sound then
			soundId = chatEntry.Sound
		end
	end
	if not soundId then return end

	local cooldownKey = tostring(userId or 0) .. "_" .. matchedKey
	if ChatVoicelineCooldown[cooldownKey] then return end
	ChatVoicelineCooldown[cooldownKey] = true
	task.delay(5, function() ChatVoicelineCooldown[cooldownKey] = nil end)

	local character = player.Character
	if not character then return end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. soundId
	sound.Volume = 2.5
	sound:SetAttribute("IsLocalVoiceline", true)

	local useCasterSS = type(chatEntry) == "table" and chatEntry.CasterSoundService or false
	parentSoundForCaster(sound, character, useCasterSS)

	sound:Play()
	sound.Ended:Connect(function()
		if sound and sound.Parent then sound:Destroy() end
	end)
end

TextChatService.MessageReceived:Connect(onChatMessageReceived)

local MassCompulsionSounds = {
	["Faint"] = { Sound = "17560602849", Volume = 2.5, ChatText = "Everybody faint" },
	["Suffer"] = { Sound = "17560604010", Volume = 2.5, ChatText = "Suffer" },
	["Attack"] = { Sound = "17560606672", Volume = 2.5, ChatText = "Attack" },
	["Freeze"] = { Sound = "17560600778", Volume = 2.5, ChatText = "Nobody move" },
	["Forget to breathe"] = { Sound = "98703979367465", Volume = 2.5, ChatText = "Forget to breathe" },
}

local MassCompulsionCooldown = {}
local LastMassCompulsionCaster = nil -- tracked from the 'effect' event

local function onMassCompulsionAction(casterPlayer, actionName)
	if not actionName then return end
	if not casterPlayer then return end

	local soundInfo = MassCompulsionSounds[actionName]
	if not soundInfo then return end

	local casterCharName = casterPlayer:GetAttribute("CharacterName")
	if casterCharName and soundInfo[casterCharName] then
		soundInfo = soundInfo[casterCharName]
	end

	local cooldownKey = tostring(casterPlayer.UserId) .. "_" .. actionName
	if MassCompulsionCooldown[cooldownKey] then return end
	MassCompulsionCooldown[cooldownKey] = true
	task.delay(15, function() MassCompulsionCooldown[cooldownKey] = nil end)

	local character = casterPlayer.Character
	if not character then return end

	local chatText = soundInfo.ChatText
	if not chatText then
		local topLevelInfo = MassCompulsionSounds[actionName]
		if topLevelInfo and topLevelInfo.ChatText then
			chatText = topLevelInfo.ChatText
		end
	end


	local function doPlay()
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. soundInfo.Sound
		sound.Volume = soundInfo.Volume or 2.5
		sound:SetAttribute("IsLocalVoiceline", true)

		parentSoundForCaster(sound, character, soundInfo.CasterSoundService)

		sound:Play()
		sound.Ended:Connect(function()
			if sound and sound.Parent then sound:Destroy() end
		end)
	end

	if soundInfo.DelayTime and soundInfo.DelayTime > 0 then
		task.delay(soundInfo.DelayTime, doPlay)
	else
		doPlay()
	end
end

local ReplicatedAbilityEffect = ReplicatedStorage:FindFirstChild("Remotes")
	and ReplicatedStorage.Remotes:FindFirstChild("AbilityService")
	and ReplicatedStorage.Remotes.AbilityService:FindFirstChild("ToClient")
	and ReplicatedStorage.Remotes.AbilityService.ToClient:FindFirstChild("ReplicatedAbilityEffect")

if ReplicatedAbilityEffect then
	ReplicatedAbilityEffect.OnClientEvent:Connect(function(abilityName, methodName, ...)
		if abilityName ~= "Mass Compulsion" then return end

		if methodName == "effect" then
			local _, casterPlayer = ...
			if casterPlayer and casterPlayer:IsA("Player") then
				LastMassCompulsionCaster = casterPlayer
			end
		elseif methodName == "applyAction" then
			local actionName = ...
			local caster = LastMassCompulsionCaster

			if not caster then
				for _, player in Players:GetPlayers() do
					if player.Character then
						local head = player.Character:FindFirstChild("Head")
						if head and head:FindFirstChild("CasterAttachment") then
							caster = player
							break
						end
					end
				end
			end

			if caster then
				onMassCompulsionAction(caster, actionName)
			end
		end
	end)
end

local ParticleSounds = {

	["AdSomnumSleep"] = {
		["Hope Mikaelson"] = { Sound = "113991042230113", Volume = 3, DelayTime = 1, KeepPlayingSound = true },
	},

	["LinkBeam"] = {
		["Bonnie Bennett"] = { Sound = "102024711113477", Volume = 2.5, DelayTime = 7.5, KeepPlayingSound = true },
	},

	["MotusShockWave"] = {
		["Bonnie Bennett"] = { Sound = "114093297475680", Volume = 2.5, DelayTime = 7.5, KeepPlayingSound = true },
		["Nora Hildegard"] = { Sound = "131259403209726", Volume = 2.5, DelayTime = 7.5, KeepPlayingSound = true },
		["Davina Claire"] = { Sound = "109348032177998", Volume = 2.5, DelayTime = 7.5, KeepPlayingSound = true },
	},

	["ImmobilusSpiral"] = { Sound = "0", Volume = 2.5 }, -- placeholder ID, replace with actual sound

	["PoenaDolorisVictim"] = { Sound = "0", Volume = 2.5 }, -- placeholder ID, replace with actual sound
}

local ActiveParticleSounds = {} -- [particle] = soundInstance
local ParticleDebounce = {} -- [particleName_characterName] = true

local function getCharacterFromParticle(particle)
	local current = particle.Parent
	while current do
		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
			return current
		end
		current = current.Parent
	end
	if particle.Parent and particle.Parent:IsA("BasePart") then
		local partParent = particle.Parent.Parent
		if partParent and partParent:IsA("Model") and partParent:FindFirstChildOfClass("Humanoid") then
			return partParent
		end
	end
	return nil
end

local function getCharacterNameFromModel(model)
	for _, player in Players:GetPlayers() do
		if player.Character == model then
			return player:GetAttribute("CharacterName")
		end
	end
	return nil
end

local function tryPlayParticleSound(particle)
	if not particle:IsA("ParticleEmitter") then return end
	if not particle.Enabled then return end
	if ActiveParticleSounds[particle] then return end

	local entry = ParticleSounds[particle.Name]
	if not entry and particle.Parent then
		entry = ParticleSounds[particle.Parent.Name]
	end
	if not entry then return end

	local character = getCharacterFromParticle(particle)
	if not character then return end


	local charName = getCharacterNameFromModel(character)
	local resolvedEntry = nil

	if type(entry) == "table" then
		if charName and entry[charName] then
			resolvedEntry = entry[charName]
		elseif entry.Sound then
			resolvedEntry = entry
		end
	else
		return -- Invalid format
	end

	if not resolvedEntry then return end

	if resolvedEntry.CasterRequired then
		local victimHRP = character:FindFirstChild("HumanoidRootPart")
		if not victimHRP then return end
		local foundCaster = false
		for _, player in Players:GetPlayers() do
			if player:GetAttribute("CharacterName") == resolvedEntry.CasterRequired and player.Character then
				local casterHRP = player.Character:FindFirstChild("HumanoidRootPart")
				if casterHRP and (casterHRP.Position - victimHRP.Position).Magnitude <= 80 then
					foundCaster = true
					break
				end
			end
		end
		if not foundCaster then return end
	end

	local debounceKey = particle.Name .. "_" .. (charName or "unknown")
	if resolvedEntry.DebounceTime and ParticleDebounce[debounceKey] then return end

	local function doPlay()
		if not particle or not particle.Parent then return end -- particle was removed during delay
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. resolvedEntry.Sound
		sound.Volume = resolvedEntry.Volume or 2.5
		sound:SetAttribute("IsLocalVoiceline", true)

		local parentResult = parentSoundForCaster(sound, character, resolvedEntry.CasterSoundService or entry.CasterSoundService)
		if parentResult == false then return end

		sound:Play()
		ActiveParticleSounds[particle] = sound

		local keepPlaying = resolvedEntry.KeepPlayingSound or false

		if keepPlaying then
			sound.Ended:Connect(function()
				if sound and sound.Parent then sound:Destroy() end
				ActiveParticleSounds[particle] = nil
			end)
		else
			particle:GetPropertyChangedSignal("Enabled"):Connect(function()
				if not particle.Enabled and ActiveParticleSounds[particle] then
					fadeOutSound(sound)
					ActiveParticleSounds[particle] = nil
				end
			end)
			particle.Destroying:Connect(function()
				if ActiveParticleSounds[particle] == sound then
					fadeOutSound(sound)
					ActiveParticleSounds[particle] = nil
				end
			end)
		end

		sound.Ended:Connect(function()
			if ActiveParticleSounds[particle] == sound then
				ActiveParticleSounds[particle] = nil
			end
		end)
	end

	if resolvedEntry.DebounceTime and resolvedEntry.DebounceTime > 0 then
		ParticleDebounce[debounceKey] = true
		task.delay(resolvedEntry.DebounceTime, function() ParticleDebounce[debounceKey] = nil end)
	end

	if resolvedEntry.DelayTime and resolvedEntry.DelayTime > 0 then
		task.delay(resolvedEntry.DelayTime, doPlay)
	else
		doPlay()
	end
end

local AnimationSoundCombos = {
	["Somnus"] = {
		AnimationId = "6713148336",
		SoundId = "13154602444",
		["Davina Claire"] = "95823566800088",
		Volume = 9,
		KeepPlayingSound = true,
		DelayTime = 0,
		WindowTime = 0.5,
	},
	["ErroxFemus"] = {
		AnimationId = "6713148336",
		SoundId = "10512733733",
		["Bonnie Bennett"] = "74008013885006",
		Volume = 4.5,
		KeepPlayingSound = true,
		DelayTime = 0,
		WindowTime = 0.5,
	},
	["PhasmatosIncendia"] = {
		AnimationId = "8118882336",
		SoundId = "10512733733",
		["Bonnie Bennett"] = "14523220272",
		Volume = 3.5,
		KeepPlayingSound = true,
		DelayTime = 0,
		WindowTime = 0.5,
	},
	["SoulBind"] = {
		AnimationId = "91593895077311",
		SoundId = "106982949473166",
		Sound = "109441100680596",
		Volume = 2.5,
		KeepPlayingSound = true,
		DelayTime = 0,
		WindowTime = 0.5,
	},
	["VampReversal"] = {
		AnimationId = "18534994939",
		SoundId = "18535374166",
		Sound = "18535307514",
		Volume = 2.5,
		KeepPlayingSound = true,
		DelayTime = 0.2,
		WindowTime = 0.6,
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

-- Compulsion Protection Combo System
-- When someone says "Listen," (compulsion) near a witch, and that witch plays
-- the protection animation, a character-specific voiceline plays from the witch.
-- The chat comes from the COMPULSION CASTER, the animation plays on the PROTECTOR.
local CompulsionProtectionCombos = {
	["CompulsionProtectionBonnie"] = {
		AnimationId = "6900156131", -- TODO: fill in the protection animation ID
		ChatText = "Listen,",
		WindowTime = 2, -- max seconds between chat and animation
		MaxDistance = 30, -- max studs between caster and protector
		Volume = 2.5,
		KeepPlayingSound = true,
		["Bonnie Bennett"] = { Sound = "89027389474979", Volume = 2.5 }, -- TODO: fill in sound ID
	},
	["CompulsionProtectionQetsiyah"] = {
		AnimationId = "12189974108", -- TODO: fill in the protection animation ID
		ChatText = "Listen,",
		WindowTime = 2, -- max seconds between chat and animation
		MaxDistance = 30, -- max studs between caster and protector
		Volume = 2.5,
		KeepPlayingSound = true,
		["Qetsiyah"] = { Sound = "105035246772721", Volume = 2.5 }, -- TODO: fill in sound ID
	},
	["CompulsionProtectionEsther"] = {
		AnimationId = "128623651867501", -- TODO: fill in the protection animation ID
		ChatText = "Listen,",
		WindowTime = 2, -- max seconds between chat and animation
		MaxDistance = 30, -- max studs between caster and protector
		Volume = 2.5,
		KeepPlayingSound = true,
		["Esther Mikaelson"] = { Sound = "83942262095667", Volume = 2.5 }, -- TODO: fill in sound ID
	},
	["CompulsionProtectionCleo"] = {
		AnimationId = "6900156131", -- TODO: fill in the protection animation ID
		ChatText = "Listen,",
		WindowTime = 2, -- max seconds between chat and animation
		MaxDistance = 30, -- max studs between caster and protector
		Volume = 2.5,
		KeepPlayingSound = true,
		["Cleo Sowande"] = { Sound = "81915770841744", Volume = 2.5 }, -- TODO: fill in sound ID
	},
	["CompulsionProtectionDavina"] = {
		AnimationId = "6900156131", -- TODO: fill in the protection animation ID
		ChatText = "Listen,",
		WindowTime = 2, -- max seconds between chat and animation
		MaxDistance = 30, -- max studs between caster and protector
		Volume = 2.5,
		KeepPlayingSound = true,
		["Davina Claire"] = { Sound = "109348032177998", Volume = 2.5 }, -- TODO: fill in sound ID
	},
	["CompulsionProtectionJosie"] = {
		AnimationId = "128623651867501", -- TODO: fill in the protection animation ID
		ChatText = "Listen,",
		WindowTime = 2, -- max seconds between chat and animation
		MaxDistance = 30, -- max studs between caster and protector
		Volume = 2.5,
		KeepPlayingSound = true,
		["Dark Josie"] = { Sound = "91130808414020", Volume = 2.5 }, -- TODO: fill in sound ID
	},
}

local RecentCompulsionChats = {} -- [player] = { time = tick(), position = Vector3 }
local CompulsionProtectionCooldowns = {}
local COMPU_PROT_COOLDOWN = 1

local CompulsionProtKnownKeys = {
	AnimationId = true,
	ChatText = true,
	WindowTime = true,
	MaxDistance = true,
	Volume = true,
	KeepPlayingSound = true,
	DelayTime = true,
	FadeOutDuration = true,
	CutOffWithAnimation = true,
	CasterSoundService = true,
}

local function hasCompulsionProtCharOverrides(info)
	for key in pairs(info) do
		if type(key) == "string" and not CompulsionProtKnownKeys[key] then
			return true
		end
	end
	return false
end

local function playCompulsionProtectionSound(comboEntry, character, charName, track)
	local soundInfo
	if hasCompulsionProtCharOverrides(comboEntry) then
		if charName and comboEntry[charName] then
			soundInfo = comboEntry[charName]
		else
			return
		end
	else
		return
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

	local cooldownKey = (comboEntry.AnimationId or "") .. "_" .. (comboEntry.ChatText or "") .. "_" .. (charName or "unknown")
	if CompulsionProtectionCooldowns[cooldownKey] then return end
	CompulsionProtectionCooldowns[cooldownKey] = true
	task.delay(COMPU_PROT_COOLDOWN, function()
		CompulsionProtectionCooldowns[cooldownKey] = nil
	end)

	local function doPlay()
		if soundInfo.CutOffWithAnimation and track and not track.IsPlaying then
			CompulsionProtectionCooldowns[cooldownKey] = nil
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
				CompulsionProtectionCooldowns[cooldownKey] = nil
			end)
		elseif soundInfo.KeepPlayingSound then
			-- Sound keeps playing until it ends naturally
		else
			sound.Ended:Connect(function()
				if sound and sound.Parent then
					sound:Destroy()
				end
				CompulsionProtectionCooldowns[cooldownKey] = nil
			end)
		end

		task.delay(COOLDOWN_TIMEOUT, function()
			CompulsionProtectionCooldowns[cooldownKey] = nil
		end)
	end

	if soundInfo.DelayTime and soundInfo.DelayTime > 0 then
		task.delay(soundInfo.DelayTime, doPlay)
	else
		doPlay()
	end
end

checkCompulsionProtectionForAnimation = function(animId, character, charName, track)
	for _, comboEntry in pairs(CompulsionProtectionCombos) do
		if normalize(comboEntry.AnimationId) == animId then
			local windowTime = comboEntry.WindowTime or 2
			local maxDistance = comboEntry.MaxDistance or 30
			local now = tick()

			local charHRP = character:FindFirstChild("HumanoidRootPart")
			if not charHRP then return end

			for player, chatData in pairs(RecentCompulsionChats) do
				-- Make sure the caster is a different character from the protector
				if player.Character ~= character then
					local elapsed = now - chatData.time
					if elapsed <= windowTime then
						local dist = (charHRP.Position - chatData.position).Magnitude
						if dist <= maxDistance then
							playCompulsionProtectionSound(comboEntry, character, charName, track)
							break -- only play once per animation
						end
					end
				end
			end
		end
	end
end

recordCompulsionChat = function(player, chatText)
	for _, comboEntry in pairs(CompulsionProtectionCombos) do
		if comboEntry.ChatText and chatText:lower():sub(1, #comboEntry.ChatText) == comboEntry.ChatText:lower() then
			local character = player.Character
			if character then
				local hrp = character:FindFirstChild("HumanoidRootPart")
				if hrp then
					RecentCompulsionChats[player] = { time = tick(), position = hrp.Position }
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
		for player, chatData in pairs(RecentCompulsionChats) do
			if not player or not player.Parent then
				RecentCompulsionChats[player] = nil
			elseif now - chatData.time > 5 then
				RecentCompulsionChats[player] = nil
			end
		end
	end
end)

-- hookAnimator override removed: combo and protection checks are now in the original hookAnimator via forward declarations

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

for _, desc in game:GetDescendants() do
	tryReplaceSound(desc)
	tryOverlaySound(desc)
	tryPlayParticleSound(desc)
end

game.DescendantAdded:Connect(function(desc)
	tryReplaceSound(desc)
	tryOverlaySound(desc)
	tryPlayParticleSound(desc)
end)

game.DescendantAdded:Connect(function(desc)
	if desc:IsA("ParticleEmitter") then
		desc:GetPropertyChangedSignal("Enabled"):Connect(function()
			if desc.Enabled then
				tryPlayParticleSound(desc)
			end
		end)
	end
end)
