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
	PhasmatosIncendia = {
		Sound = "91016794551142",
		Icon = "18630281578"
	},

	ChannelAncestorsBonnie = {
		Sound = "104749000603361",
		Icon = "18630281775",
		Volume = 3,
		DelayTime = 4,
		FadeOut = true,
	},

	ExpressionSpell = {
		Sound = "15601121759",
		Icon = "18630089477",
		DelayTime = 3,
	},

	PsychicDimension = {
		Sound = "130322652559089",
		Icon = "18630089689",
	},

	IHaveEveryMagic = {
		Sound = "123232609831917",
		Icon = "18630089477",
		DelayTime = 16,
	},

	WoundInfliction = {
		Sound = "135485148941488",
		Icon = "18630282534",
	},

	OriginalKillingSpell = {
		Sound = "15174394937",
		Icon = "18630281752",
		FadeOut = true,
	},

	PhasmatosTribumNasExVeras = {
		Sound = "15631194386",
		Icon = "18630089507",
	},

	SuctusIncendia = {
		Sound = "15325084064",
		Icon = "18630089076",
	},

	PsychicRestraint = {
		Sound = "117198514953604",
		Icon = "18630089765",
		Volume = 3,
	},

	LifeLinking = {
		Sound = "102024711113477",
		Icon = "18630089409",
		DelayTime = 7.5,
	},

	BonnieTurnToStone = {
		Sound = "14556366203",
		Icon = "18630281954",
	},

	AleoraSubsitos = {
		Sound = "15237076338",
		Icon = "18630089347",
		DelayTime = 4,
		FadeOut = true,
	},

	Vados = {
		Sound = "127725225837213",
		Icon = "18630282009",
	},

	PsychicBlast = {
		Sound = "130316188399085",
		Icon = "18630089212",
	},

	PhasmatosRavarosOnAnimum = {
		Sound = "15254480460",
		Icon = "18630089343",
	},

	Autem = {
		Sound = "13203446447",
		Icon = "18630087239",
	},

	Harae = {
		Sound = "70767045237007",
		Icon = "18630087278",
		Volume = 0.8,
		FadeOut = true,
	},

	DarkMagicBolts = {
		Sounds = {"86892327341853", "102408304337752", "85681111856011"},
		Icon = "18630088083",
	},

	FianteFulguris = {
		Sound = "81277472991928",
		Icon = "18630088248",
	},

	Ascendo = {
		Sound = "78053223963040",
		Icon = "18630087176",
		FadeOut = true,
	},

	SandClock = {
		Sound = "102769052580596",
		Icon = "18630281373",
		DelayTime = 4.3,
	},

	OutfitChangeJosie = {
		Sound = "77485734102576",
		Icon = "18630087095",
		DelayTime = 0.6,
	},

	ISaidHey = {
		Sound = "101203984671407",
		Icon = "116482478049852",
		Volume = 0.8,
		FadeOut = true,
	},

	Stellabunde = {
		Sound = "132802121953563",
		Icon = "92704345603128",
	},

	Dissulta = {
		Sound = "134481306386869",
		Icon = "128909320385582",
	},

	IgnisTempestas = {
		Sound = "95468563095334",
		Icon = "18630089900",
		Volume = 1,
		DelayTime = 0.4,
	},

	AvitaExari = {
		Sound = "16118919066",
		Icon = "18630090107",
		DelayTime = 1.3,
		FadeOut = true,
	},

	VenenumCorpus = {
		Sound = "81126580655893",
		Icon = "18630090246",
	},

	QetTurnToStone = {
		Sound = "16838696298",
		Icon = "18630282217",
	},

	DestroyOtherSide = {
		Sound = "16767898955",
		Icon = "18630090397",
	},

	QetBrainFry = {
		Sound = "105550543421825",
		Icon = "18630089944",
		DelayTime = 0.1,
		FadeOut = true,
	},

	AhShaLana = {
		Sound = "81639278311000",
		Icon = "18630090331",
		FadeOut = true,
	},

	SpiritualCleanse = {
		Sound = "16326825053",
		Icon = "18630090458",
	},

	TalismanChannelQet = {
		Sound = "78867379826047",
		Icon = "18630090442",
		FadeOut = true,
	},

	QetResurrection = {
		Sound = "96414682813420",
		Icon = "18630282468",
		DelayTime = 7,
	},

	CureCreation = {
		Sound = "16479305722",
		Icon = "18630090139",
		DelayTime = 15,
	},

	TelekAttack = {
		Sound = "94965672679001",
		Icon = "135639275617447",
	},

	TelekSubmission = {
		Sound = "128304384560357",
		Icon = "109520694042246",
	},

	BloodChoke = {
		Sound = "97911663035904",
		Icon = "100807331974657",
		Volume = 2,
	},

	BloodBoil = {
		Sound = "73829700677752",
		Icon = "113848119444432",
	},

	NecksnapLift = {
		Sound = "79984922909048",
		Icon = "93803135163081",
		FadeOut = true,
	},

	SoulBind = {
		Sound = "109441100680596",
		Icon = "72761138794898",
		FadeOut = true,
	},

	LightningStrike = {
		Sound = "123620176154825",
		Icon = "98292882529833",
	},

	GoldenDagger = {
		Sound = "130386408505459",
		Icon = "75282755890383",
		DelayTime = 2.3,
		FadeOut = true,
	},

	DavinaMagicRegen = {
		Sound = "82826752361269",
		Icon = "127086238458899",
		DelayTime = 8,
		FadeOut = true,
	},

	Somnus = {
		Sound = "95823566800088",
		Icon = "109870855790839",
		Volume = 9,
	},

	BoneBreakCombo = {
		Sound = "128387089253440",
		Icon = "126319455693987",
	},

	BrainFryFreya = {
		Sound = "137442198052809",
		Icon = "122841911569776",
		Volume = 4,
		FadeOut = true,
	},

	AstralProjection = {
		Sound = "97414512710914",
		Icon = "84884940636467",
		DelayTime = 4.2,
		FadeOut = true,
	},

	FreyaMagicShield = {
		Sound = "74460096162653",
		Icon = "110401705087848",
		Volume = 3.3,
		PlayOnEquipped = true,
		AddOnEquipTime = 34,
	},

	MenedekQualSurentaFreya = {
		Sound = "117507162492846",
		Icon = "88472118739491",
	},

	FreyaCrowTurning = {
		Sound = "105913987460965",
		Icon = "80792862263655",
		Volume = 10,
	},

	PendantTrapFreya = {
		Sound = "110211317792165",
		Icon = "121864956252192",
		FadeOut = true,
		Volume = 1.3,
	},

	CardiacArrest = {
		Sound = "138819760805849",
		Icon = "134948394386315",
		FadeOut  = true,
	},

	AncestorAttackEndFreya = {
		Sound = "113820074623121",
		Icon = "90735917034092",
		DelayTime = 17.5,
	},

	MassCrowsFreya = {
		Sound = "100950296033969",
		Icon = "89861435390266",
		Volume = 4,
		FadeOut = true,
	},

	Sigil = {
		Sound = "106151236422771",
		Icon = "83085294584462",
	},

	Aneurysm = {
		Sound = "132015776882851",
		Icon = "82552464417064",
		FadeOut  = true,
	},

	InsanityHex = {
		Sound = "114599395160541",
		Icon = "118013678786620",
		Volume = 5,
	},

	NeedleOfSorrows = {
		Sound = "97437123423899",
		Icon = "107370676731191",
		FadeOut = true,
		Volume = 4.8,
	},

	GenevieveAsh = {
		Sound = "93111269287330",
		Icon = "82815418211348",
		Volume = 3,
	},

	JosephineViolin = {
		Sound = "89550767660084",
		Icon = "113547517379895",
		Volume = 6.5,
	},

	PapaTundeBlade = {
		Sound = "139735291592382",
		Icon = "100016320723838",
		FadeOut = true,
	},

	AncestralPain = {
		Icon = "83837051753013",
		["Genevieve"] = "80082176187338",
		["Agnes"] = "121671824051694",
		["Josephine LaRue"] = "79538024543328",
		["Bastianna Natale"] = "70512941919646",
		["Papa Tunde"] = "74362949998012",
		Volume = 3.2,
		FadeOut = true,
	},

	Ohun = {
		Sound = "92404277403294",
		Icon = "98499345224483",
		PlayOnEquipped = true,
		AddOnEquipTime = 23,
	},

	Pada = {
		Sound = "91217804264943",
		Icon = "98499345224483",
	},

	Sunbeam = {
		Sound = "95590928220540",
		Icon = "105971657899955",
		Volume = 3.4,
	},

	CleoTeleport = {
		Sound = "122887446534653",
		Icon = "125340898573455",
	},

	TelekExplosionCleo = {
		Sound = "123217650248442",
		Icon = "112113802501534",
	},

	OoNiLeSoro = {
		Sound = "90131739908048",
		Icon = "81226717447746",
	},

	Inspire = {
		Sound = "131047658678353",
		Icon = "130742776637140",
		DelayTime = 2,
	},

	MudGolem = {
		Sound = "74072970288534",
		Icon = "106682862771573",
		DelayTime = 0.3,
		Volume = 1.5,
	},

	HopeLecutio = {
		Icon = "18630086622",
		["Hope Mikaelson"] = "131807122245438",
	},

	WolfTransformation = {
		Icon = "18630084635",
		["Hope Mikaelson"] = "76431177526410",
	},

	Sol = {
		Icon = "18630084767",
		["Hope Mikaelson"] = "85082904537308",
	},

	LightBall = {
		Icon = "18630087916",
		FadeOut = true,
		["Hope Mikaelson"] = "100313110940795",
	},

	HopeExplosion = {
		Sound = "104028506433231",
		Icon = "18630088744",
		Volume = 1.4,
		FadeOut = true,
	},

	HopesRepulse = {
		Sound = "17471844257",
		Icon = "18630086888",
	},

	GlaceSolidatur = {
		Sound = "99610680956880",
		Icon = "98652212452518",
		FadeOut = true,
	},

	BloodBlade = {
		Sound = "104137817730493",
		Icon = "18630087326",
		FadeOut = true,
		PlayOnEquipped = true,
		AddOnEquipTime = 1,
	},

	HopeVentus = {
		Sound = "72404882318303",
		Icon = "18630086607",
	},

	HopeHeadDecap = {
		Sound = "129988097306628",
		Icon = "18630087727",
		DelayTime = 5,
	},

	HopeTurning = {
		Icon = "18630084447",
		Volume = 3.6,
		["Hope Mikaelson"] = "72373310588316",
	},

	VampReversalEsther = {
		Sound = "18535307514",
		Icon = "135429488486657",
		DelayTime = 1,
	},

	PentagramEsther = {
		Sound = "129460073622144",
		Icon = "87208128166220",
		DelayTime = 5,
	},

	ChainsEsther = {
		Sound = "83942262095667",
		Icon = "79303670793326",
	},

	MagicSteal = {
		Sound = "94787275001396",
		Icon = "75230896040263",
		FadeOut = true,
	},

	BloodSteal = {
		Sound = "74050761219524",
		Icon = "18894843205",
		FadeOut = true,
	},

	EstherWhiteOakSpell = {
		Sound = "139418993300939",
		Icon = "81666997829225",
	},

	TheUltimateWeaponEsther = {
		Sound = "118918239866614",
		Icon = "81666997829225",
		DelayTime = 17,
	},

	EstherOriginalSerum = {
		Sound = "91204949642033",
		Icon = "134112373642550",
		DelayTime = 14,
	},

	StranguloVentus = {
		Icon = "18630087547",
		FadeOut = true,
		["Valerie Tulle"] = "88573986552740",
		["Nora Hildegard"] = "118508173111903",
	},

	HereticJointSpell = {
		Icon = "18630088044",
		DelayTime = 3,
		FadeOut = true,
		["Valerie Tulle"] = "13904360117",
		["Nora Hildegard"] = "13904360117",
		["Mary Louise"] = "13904360117",
	},

	Vido = {
		Icon = "18630281415",
		Volume = 4,
		["Mary Louise"] = "88600853616027",
	},

	IllusionAttack = {
		Icon = "18630090954",
		Sound = "88189755078068",
	},

	OrganLiquify = {
		Icon = "18630090630",
		Sound = "85818992177233",
	},

	Incendia = {
		Icon = "18630085138",
		["Lizzie Saltzman"] = "98540976660149",
		["Hope Mikaelson"] = "88254920355046",
		["Valerie Tulle"] = "134446708409005",
	},

	DelfanEotenCor = {
		Icon = "18630087815",
		["Qetsiyah"] = "132701227107666",
		["Bonnie Bennett"] = "93410039917419",
	},

	AdSomnum = {
		Icon = "18630085451",
		Volume = 3.5,
		["Dark Josie"] = "81204185561575",
		["Josie Saltzman"] = "81204185561575",
		["Freya Mikaelson"] = "94633917213364",
		["Hope Mikaelson"] = "131198089743550",
	},

	VisSeraPortus = {
		Icon = "18630084722",
		["Bonnie Bennett"] = "73245313373983",
		Volume = 3.5,
	},

	Imobiluse = {
		Icon = "18630087000",
		["Dark Josie"] = "105680172999340",
		["Josie Saltzman"] = "105680172999340",
	},

	Aquamalia = {
		Icon = "18630088717",
		Volume = 3.5,
		["Hope Mikaelson"] = "127841579933142",
	},

	ErroxFemus = {
		Icon = "18630085245",
		["Bonnie Bennett"] = "81342092829364",
	},

	Ossox = {
		Icon = "18630281131",
		["Dark Josie"] = "71429766864674",
		["Freya Mikaelson"] = "110410203919763",
	},

	Menedek = {
		Icon = "18630084930",
		["Bonnie Bennett"] = "84898218174575",
		["Davina Claire"] = "109615919605410",

	},

	HeadSiphon = {
		Icon = "18630087581",
		["Malcolm"] = "100864025080028",
		["Dark Josie"] = "139164497000480",
		["Josie Saltzman"] = "139164497000480",
		Volume = 1.4,
		FadeOut = true,
	},

	Ictus = {
		Icon = "18630281256",
		["Davina Claire"] = "76239424251739",
		["Freya Mikaelson"] = "83319807623114",
		["Hope Mikaelson"] = "91081771194142",
	},

	Motus = {
		Icon = "18630084955",
		["Bonnie Bennett"] = "114093297475680",
		["Freya Mikaelson"] = "71400747179829",
		["Nora Hildegard"] = "131259403209726",
		["Hope Mikaelson"] = "136985009471966",
	},

	Invisique = {
		Icon = "18630085006",
		["Valerie Tulle"] = "116763647482749",
		["Nora Hildegard"] = "80580720829811",
	},

	SpineBreak = {
		Icon = "18630085580",
		["Katherine Pierce"] = "14841026112",
		["Klaus Mikaelson"] = "104818873099408",
	},

	HeartRip = {
		Icon = "18630084285",
		["Klaus Mikaelson"] = "116366940781850",
		["Hope Mikaelson"] = "108349443247039",
		["Elijah Mikaelson"] = "106923356211357",
		["Marcel Gerard"] = "110381933492775",
	},

	HeadRip = {
		Icon = "18630084315",
		["Klaus Mikaelson"] = "122787771744632",
		["Elijah Mikaelson"] = "112316220234662",
	},

	SuperPunch = {
		Icon = "18630087742",
		["Elijah Mikaelson"] = "89245420291267",
	},

	SuperSlap = {
		Icon = "73276360094899",
		["Hope Mikaelson"] = "125011735974039",
	},

	SuperKick = {
		Icon = "117025696388944",
		["Rebekah Mikaelson"] = "134363458393409",
		["Hope Mikaelson"] = "117071643793823", 
		Volume = 3.5,
	},

	Choke = {
		Icon = "18630084520",
		["Papa Tunde"] = "120390222103231",
		["Mary Louise"] = "76991721803834",
		["Hope Mikaelson"] = "88024240964591",
	},

	HeelStomp = {
		Icon = "109498239929193",
		Volume = 1.8,
		["Josie Saltzman"] = "91130808414020",
		["Dark Josie"] = "91130808414020",
		["Hope Mikaelson"] = "114218115884187",
	},

	ArmBreak = {
		Icon = "71180787516661",
		["Klaus Mikaelson"] = "98249961626855",
		["Hope Mikaelson"] = "112336295176021",
	},

	SnapNeck = {
		Icon = "18630087942",
		["Hope Mikaelson"] = "126809683102566",
		["Elijah Mikaelson"] = "99500998724165",
		["Kol Mikaelson"] = "130612995488285",
	},

	HarvestDaggerBastianna = {
		Sounds = {
			{Sound = "113939339508982", ChatText = "To be reborn, we must sacrifise."},
		},
		Icon = "83531657472792",
		CharacterRequired = "Bastianna Natale",
	},

	HandOfGlory = {
		["Davina Claire"] = "128323150668520",
		Icon = "138635686089866",
		FadeOut = true,
	},
}

-- Mass Compulsion action-specific sounds
-- Each action (Faint, Attack, Suffer, Freeze) gets its own sound
-- Replace the "0" placeholders with actual sound IDs
local CompulsionActionSounds = {
	["Faint"] = {
		Sound = "17560602849",
		Volume = 2.5,
	},
	["Attack"] = {
		Sound = "17560606672",
		Volume = 2.5,
	},
	["Suffer"] = {
		Sound = "17560604010",
		Volume = 2.5,
	},
	["Freeze"] = {
		Sound = "17560600778",
		Volume = 2.5,
	},
}

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

	-- Parent to the character for 3D positional audio so the sound comes from the player's model.
	local character = Players.LocalPlayer.Character
	local head = character and character:FindFirstChild("Head")
	if head then
		sound.Parent = head
		-- Always reparent to SoundService if the parent is destroyed, so the sound can still play
		head.Destroying:Connect(function()
			if sound and sound.Parent then
				sound.Parent = SoundService
			end
		end)
	else
		sound.Parent = SoundService
	end

	local oldSound = ActiveSounds[abilityName]
	if oldSound and oldSound ~= sound then
		if info.FadeOut then
			fadeOutSound(oldSound)
		else
			oldSound:Stop()
			oldSound:Destroy()
		end
	end

	ActiveSounds[abilityName] = sound

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

		-- Parent to the character for 3D positional audio (same logic as main sound)
		local character = Players.LocalPlayer.Character
		local head = character and character:FindFirstChild("Head")
		if head then
			simSound.Parent = head
			if info.KeepPlayingSound then
				head.Destroying:Connect(function()
					if simSound and simSound.IsPlaying then
						simSound.Parent = SoundService
					end
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
						if info.FadeOut then
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

			if sound and info and info.FadeOut == true then
				ActiveSounds[abilityName] = nil
				fadeOutSound(sound)
			end

			-- Always reset cooldown so the ability can play again next time
			Cooldowns[abilityName] = false
		end
	end
end

-- PlayOnEquipped: Play sound when ability is equipped/selected
-- Maps ability enum names to Data entries that should play on equip
-- MUST be defined before the event listeners below
local EquipSoundMap = {
	["Ohun Pada"] = {"Ohun"},
	["Magic Shield"] = {"FreyaMagicShield"},
	["Blood Blade"] = {"BloodBlade"},
}

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

				if sound and info and info.FadeOut == true then
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
do
	local WholeScreenComp = MainInterface:FindFirstChild("WholeScreenComponents")

	local function hookCompulsionButton(button)
		if not button:IsA("TextButton") then return end

		button.Activated:Connect(function()
			local actionName = button.Text
			if not actionName or actionName == "" then return end

			local actionInfo = CompulsionActionSounds[actionName]
			if not actionInfo then return end

			local key = "MassCompulsion_" .. actionName
			if not Cooldowns[key] then
				Cooldowns[key] = true
				task.spawn(function()
					local ok, err = pcall(playAbilitySound, actionInfo, key)
					if not ok then
						warn("Voiceline error for", key, err)
						Cooldowns[key] = false
					end
				end)
			end
		end)
	end

	local function hookCompulsionList(frame)
		for _, desc in ipairs(frame:GetDescendants()) do
			hookCompulsionButton(desc)
		end
		frame.DescendantAdded:Connect(function(desc)
			hookCompulsionButton(desc)
		end)
	end

	if WholeScreenComp then
		WholeScreenComp.DescendantAdded:Connect(function(desc)
			if desc:IsA("Frame") and desc.Name == "compulsionList" then
				task.wait(0.1)
				hookCompulsionList(desc)
			end
		end)

		for _, desc in ipairs(WholeScreenComp:GetDescendants()) do
			if desc:IsA("Frame") and desc.Name == "compulsionList" then
				hookCompulsionList(desc)
			end
		end
	end
end

-- Notification-based sounds
-- Plays a sound when specific notification messages appear
-- Only triggers for the required character (if specified)
local NotificationSounds = {
	["You're no longer channeled"] = {
		Sound = "138445942157113",
		Volume = 2.5,
		CharacterRequired = "Esther Mikaelson",
	},
}

-- Pattern-based notification sounds
-- For messages with variable parts (e.g. "Klaus Mikaelson is tracking you..")
-- Uses Lua string patterns to match
local NotificationPatternSounds = {
	{ Pattern = "is tracking you%.%.", Sound = "133908186403397", Volume = 3, CharacterRequired = "Davina Claire" },
}

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
	["90326993393737"] = "15325084064", -- Phasmatos Immortale
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
	local current = sound.Parent
	while current do
		if current:IsA("Player") then
			return current:GetAttribute("CharacterName")
		end
		local charName = current:GetAttribute("CharacterName")
		if charName then
			return charName
		end
		current = current.Parent
	end
	current = sound.Parent
	while current do
		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
			for _, player in Players:GetPlayers() do
				if player.Character == current then
					return player:GetAttribute("CharacterName")
				end
			end
		end
		current = current.Parent
	end
	-- Fallback: find nearest player character by 3D distance
	-- This handles sounds in VFX parts that aren't parented to any character
	local soundPos = nil
	if sound:IsA("Sound") and sound.Parent and sound.Parent:IsA("BasePart") then
		soundPos = sound.Parent.Position
	elseif sound.Parent and sound.Parent:IsA("Attachment") then
		soundPos = sound.Parent.WorldPosition
	end
	if soundPos then
		local bestDist = 30 -- max distance to consider a match
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
		if bestName then return bestName end
	end
	return nil
end

local function isLocalPlayerSound(sound)
	local localCharacter = Players.LocalPlayer.Character
	if not localCharacter then return false end
	local current = sound.Parent
	while current do
		if current == localCharacter then
			return true
		end
		current = current.Parent
	end
	return false
end

local function tryReplaceSound(sound)
	if not sound:IsA("Sound") then return end
	if ReplacedSounds[sound] then return end

	-- Skip replacements for sounds from the local player's character
	-- (the ability transparency system already handles voicelines for the local player)
	if isLocalPlayerSound(sound) then return end -- Already handled this sound

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
			local charName = getSoundCharacterName(sound)
			if charName ~= entry.CharacterRequired then return end
		end

		-- Check character-specific keys (like Data table pattern)
		local charName = getSoundCharacterName(sound)
		if charName and entry[charName] then
			replacementId = entry[charName]
		elseif entry.Replacement then
			replacementId = entry.Replacement
		else
			return -- No matching replacement found
		end
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
	newSound.Parent = sound.Parent or SoundService
	newSound:Play()

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
	["18246473564"] = { Sound = "18246464798", Volume = 2.5, DelayTime = 0 }, -- Wound Infliction
	["120250468841070"] = {
		Overlays = {
			{ Sound = "15601121759", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Expression Grimoire
			{ Sound = "123232609831917", Volume = 2.5, DelayTime = 13, KeepPlayingSound = true }, -- I Have Every Magic
		},
	},
    ["104782720464668"] = {
		["Bonnie Bennett"] = { Sound = "14523220272", Volume = 2.5, DelayTime = 0 }, -- Phasmatos Incendia
	},
	["98210016679472"] = { Sound = "15237076338", Volume = 2.5, DelayTime = 0, CharacterRequired = "Bonnie Bennett" }, -- Aleoras Subsitos
	["15174840611"] = { Sound = "104749000603361", Volume = 2.5, DelayTime = 4, CharacterRequired = "Bonnie Bennett", KeepPlayingSound = true }, -- Channel Ancestors Bonnie
	["15561340625"] = { Sound = "102024711113477", Volume = 2.5, DelayTime = 7.5, CharacterRequired = "Bonnie Bennett", KeepPlayingSound = true }, -- Life Linking
	["8806156863"] = { Sound = "117198514953604", Volume = 2.5, DelayTime = 0, CharacterRequired = "Bonnie Bennett" }, -- Psychic Restraint
	["15773458898"] = { Sound = "127725225837213", Volume = 2.5 }, -- Vados
	-- Freya Mikaelson :
	["132899449516141"] = {
		["Freya Mikaelson"] = { Sound = "137442198052809", Volume = 2.5, DelayTime = 0 }, -- Brain Fry
		["Qetsiyah"] = { Sound = "105550543421825", Volume = 2.5, DelayTime = 0 }, -- Brain Fry
	},
	["15174800421"] = { Sound = "97414512710914", Volume = 2.5, DelayTime = 0, CharacterRequired = "Freya Mikaelson", KeepPlayingSound = true }, -- Astral Projection
	["111801255101409"] = { Sound = "74460096162653", Volume = 2.5, DelayTime = 0 }, -- Magic Shield
	["83787551804971"] = { Sound = "105913987460965", Volume = 2.5, DelayTime = 0 }, -- Starling Burst
	["105485478849117"] = { Sound = "113820074623121", Volume = 2.5, DelayTime = 3 }, -- Ancestor Attack End
	["105558064418066"] = { Sound = "100950296033969", Volume = 2.5, DelayTime = 0 }, -- Firstborn Devastation
	["122386959547514"] = { Sound = "106151236422771", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Sigil
	["112911054571877"] = { Sound = "132015776882851", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Aneurysm
	["118057080289155"] = { Sound = "110211317792165", Volume = 2.5, DelayTime = 0 }, -- Pendant Trap
	["78739455755729"] = { Sound = "138819760805849", Volume = 2.5, DelayTime = 0 }, -- Cardiac Arrest
	-- Qetsiyah :
	["16208954441"] = { Sound = "95468563095334", Volume = 2.5, DelayTime = 0 }, -- Ignis Tempestas
	["98210016679472"] = {
		["Qetsiyah"] = { Sound = "16118919066", Volume = 2.5, DelayTime = 0 }, -- Avita Exari
	},
	["104782720464668"] = {
		["Qetsiyah"] = { Sound = "81126580655893", Volume = 2.5, DelayTime = 0 }, -- Venom Blast
	},
	["16449297928"] = { Sound = "16838696298", Volume = 2.5, DelayTime = 0 }, -- Turn To Stone Qetsiyah
	["112458851193845"] = { Sound = "16767898955", Volume = 2.5, DelayTime = 0 }, -- Destroy Purgatory
	["101281556370554"] = { Sound = "81639278311000", Volume = 2.5, DelayTime = 0 }, -- Ah Sha Lana
	["74468391415531"] = { Sound = "16326825053", Volume = 2.5, DelayTime = 0 }, -- Walk Through
	["16327076834"] = { Sound = "78867379826047", Volume = 2.5, DelayTime = 0 }, -- Channel Talisman
	["16554249588"] = { Sound = "96414682813420", Volume = 2.5, DelayTime = 3, KeepPlayingSound = true }, -- Qet Res
	["13577599585"] = { Sound = "16479305722", Volume = 2.5, DelayTime = 15, KeepPlayingSound = true }, -- Cure Creation
	-- Davina Claire :
	["120261058970428"] = { Sound = "94965672679001", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Telek Attack
	["82029037414223"] = { Sound = "128304384560357", Volume = 2.5, DelayTime = 0 }, -- Telek Submission
	["17253625700"] = {
		["Davina Claire"] = { Sound = "97911663035904", Volume = 2, DelayTime = 0 }, -- Blood Choke 
	},
	["77367953274523"] = { Sound = "73829700677752", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Blood Boil
	["103830069988568"] = { Sound = "79984922909048", Volume = 2.5, DelayTime = 0 }, -- NecksnapLift
	["106982949473166"] = { Sound = "109441100680596", Volume = 2.5, DelayTime = 0 }, -- Soul Bind
	["107029347506027"] = { Sound = "123620176154825", Volume = 2.5, DelayTime = 0 }, -- Lightning Strike
	["82939375129525"] = { Sound = "82826752361269", Volume = 2.5, DelayTime = 0 }, -- Davina Magic Regen
	["10512733733"] = {
		["Davina Claire"] = { Sound = "128387089253440", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Bone Break Combo
	},
	["13154602444"] = {
		["Davina Claire"] = { Sound = "95823566800088", Volume = 8, DelayTime = 0 }, -- Somnus
		["Dark Josie"] = { Sound = "77485734102576", Volume = 2.5, DelayTime = 0 }, -- Outfit Change
	},
	-- Hope Mikaelson :
	["12181508903"] = {
		["Hope Mikaelson"] = { Sound = "85082904537308", Volume = 2.5, DelayTime = 0 }, -- Sol
	},
	["97485998367353"] = { Sound = "104028506433231", Volume = 1.4, DelayTime = 0 }, -- Bruciare
	["89008508391784"] = { Sound = "17471844257", Volume = 2.5, DelayTime = 0 }, -- Repulse
	["104555655233957"] = { Sound = "99610680956880", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Glace Solidatur
	["12934765027"] = { Sound = "72404882318303", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Ventus
	["13780865276"] = { Sound = "129988097306628", Volume = 2.5, DelayTime = 5, KeepPlayingSound = true }, -- Telek Head Rip
	["14813650927"] = {
		["Hope Mikaelson"] = { Sound = "127841579933142", Volume = 2.5, DelayTime = 0 }, -- Aquamalia
	},
	-- Esther Mikaelson :
	["18535374166"] = { Sound = "18535307514", Volume = 2.5, DelayTime = 0.5 }, -- Vamp Reversal
	["82322000387474"] = { Sound = "129460073622144", Volume = 2.5, DelayTime = 5 }, -- Pentagram
	["75802267645216"] = { Sound = "83942262095667", Volume = 2.5, DelayTime = 0 }, -- Chains
	["133379296605385"] = { Sound = "94787275001396", Volume = 2.5, DelayTime = 0 }, -- Magic Steal
	["18699314575"] = { Sound = "74050761219524", Volume = 2.5, DelayTime = 0 }, -- Blood Steal 
	["135718833680425"] = { Sound = "139418993300939", Volume = 2.5, DelayTime = 0 }, -- White Oak Spell
	["91745299864148"] = { Sound = "118918239866614", Volume = 2.5, DelayTime = 0 }, -- Ultimate Weapon
	["18902201212"] = { Sound = "91204949642033", Volume = 2.5, DelayTime = 0 }, -- Orgiinal Serum
	-- Dark Josie :
	["105998583954931"] = { Sound = "70767045237007", Volume = 2.5, DelayTime = 0 }, -- Harae Tamae
	["14400859135"] = {
		["Dark Josie"] = { Sound = "86892327341853", Volume = 2.5, DelayTime = 0 }, -- Dark Magic Blast
	},
	["116348909990770"] = { Sound = "78053223963040", Volume = 2.5, DelayTime = 0 }, -- Ascendo
	["115788596173476"] = { Sound = "101203984671407", Volume = 0.8 , DelayTime = 0, KeepPlayingSound = true }, -- I said hey
	-- Cleo Sowande :
	["91395570209508"] = { Sound = "95590928220540", Volume = 2.5, DelayTime = 0 }, -- Sunbeam
	["85094625219939"] = { Sound = "122887446534653", Volume = 2.5, DelayTime = 0 }, -- Muse Teleport
	["124779869136393"] = { Sound = "123217650248442", Volume = 2.5, DelayTime = 0 }, -- Telek Explosion
	["89539286902417"] = {
	    ["Cleo Sowande"] = { Sound = "90131739908048", Volume = 2.5, DelayTime = 0 }, -- Mass Silence
    },
	["90347973452829"] = { Sound = "92404277403294", Volume = 2.5, DelayTime = 0 }, -- Ohun
	["138866821877856"] = { Sound = "91217804264943", Volume = 2.5, DelayTime = 0 }, -- Pada
	["86985539781391"] = { Sound = "131047658678353", Volume = 2.5, DelayTime = 0 }, -- Inspire
	["133109898520847"] = { Sound = "74072970288534", Volume = 2.5, DelayTime = 0.3 }, -- Mud Golem
	-- Silas :
	["17253212200"] = { Sound = "88189755078068", Volume = 2.5, DelayTime = 0, DebounceTime = 50 }, -- Illusion Attack
	-- Heretics :
	["13008144854"] = {
		["Nora Hildegard"] = { Sound = "118508173111903", Volume = 2.5, DelayTime = 0 }, -- Strangulo Ventus
		["Valerie Tulle"] = { Sound = "88573986552740", Volume = 2.5, DelayTime = 0 }, -- Strangulo Ventus
	},
	["12180424093"] = {
		["Valerie Tulle"] = { Sound = "134446708409005", Volume = 2.5, DelayTime = 0 }, -- Incendia
		["Lizzie Saltzman"] = { Sound = "98540976660149", Volume = 2.5, DelayTime = 0 }, -- Incendia
		["Hope Mikaelson"] = { Sound = "88254920355046", Volume = 2.5, DelayTime = 0 }, -- Incendia
	},
	["14043844852"] = {
		["Valerie Tulle"] = { Sound = "13904360117", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- HereticJointSpell
		["Mary Louise"] = { Sound = "13904360117", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- HereticJointSpell
		["Nora Hildegard"] = { Sound = "13904360117", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- HereticJointSpell
	},
	["13577599585"] = {
		["Mary Louise"] = { Sound = "88600853616027", Volume = 2.5, DelayTime = 0 }, -- Vido
	},
	-- Witch Abilities :
	["10318171092"] = {
		["Qetsiyah"] = { Sound = "132701227107666", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- DelfanEotenCor
		["Bonnie Bennett"] = { Sound = "93410039917419", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- DelfanEotenCor
	},
	["12190650809"] = {
			["Nora Hildegard"] = { Sound = "131259403209726", Volume = 2.5, DelayTime = 0 }, -- Motus
			["Bonnie Bennett"] = { Sound = "114093297475680", Volume = 2.5, DelayTime = 0 }, -- Motus
	},
	["8806156863"] = {
		["Nora Hildegard"] = { Sound = "80580720829811", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Invisique
		["Valerie Tulle"] = { Sound = "116763647482749", Volume = 2.5, DelayTime = 0, KeepPlayingSound = true }, -- Invisique
	},
	-- Elder Witches :
	["84319099882038"] = {
		["Bastianna Natale"] = { Sound = "70512941919646", Volume = 3, DelayTime = 0 }, -- Ancestral Pain
		["Josephine LaRue"] = { Sound = "79538024543328", Volume = 3, DelayTime = 0 }, -- Ancestral Pain
		["Genevieve"] = { Sound = "80082176187338", Volume = 3, DelayTime = 0 }, -- Ancestral Pain
		["Papa Tunde"] = { Sound = "70512941919646", Volume = 3, DelayTime = 0 }, -- Ancestral Pain
		["Agnes"] = { Sound = "121671824051694", Volume = 2, DelayTime = 0 }, -- Ancestral Pain
	},
	["137137104978289"] = { Sound = "114599395160541", Volume = 5, DelayTime = 0 }, -- Insanity Hex
	["15980142966"] = {
		["Agnes"] = { Sound = "97437123423899", Volume = 1.5, DelayTime = 0 }, -- Agnes Needle of Sorrows
	},
	["129498686293958"] = { Sound = "93111269287330", Volume = 6.5, DelayTime = 0 }, -- Violin
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
}

local function hasOverlayCharOverrides(info)
	for key in pairs(info) do
		if type(key) == "string" and not OverlayKnownKeys[key] then
			return true
		end
	end
	return false
end

local function playSingleOverlay(sound, overlayInfo, charName)
	if overlayInfo.CharacterRequired then
		if not charName then charName = getSoundCharacterName(sound) end
		if charName ~= overlayInfo.CharacterRequired then return end
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
		local existing = ActiveOverlaySounds[overlayInfo.Sound]
		if existing and existing.Parent and existing.IsPlaying then return end
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
			-- Always reparent (not just when IsPlaying) to avoid the overlay being destroyed
			-- with its parent during timing gaps
			if parent and parent ~= SoundService then
				parent.Destroying:Connect(function()
					if ov and ov.Parent then
						ov.Parent = SoundService
					end
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

	-- Skip overlays for sounds from the local player's character
	-- (the ability transparency system already handles voicelines for the local player)
	if isLocalPlayerSound(sound) then return end

	-- Also skip if the sound belongs to the same character as the local player
	-- (handles cases where the sound is in a VFX part, not directly in the character model)
	local localCharName = Players.LocalPlayer:GetAttribute("CharacterName")
	if localCharName then
		local soundCharName = getSoundCharacterName(sound)
		if soundCharName == localCharName then
			OverlayTracked[sound] = true
			return
		end
	end

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
	local charName = getSoundCharacterName(sound)

	-- Multiple overlays that all play (Overlays array)
	if entry.Overlays then
		for _, overlayInfo in ipairs(entry.Overlays) do
			playSingleOverlay(sound, overlayInfo, charName)
		end
		return
	end

	-- Per-character overlays (character name keys)
	if hasOverlayCharOverrides(entry) then
		if charName and entry[charName] then
			playSingleOverlay(sound, entry[charName], charName)
		elseif entry.Sound then
			playSingleOverlay(sound, entry, charName)
		end
		return
	end

	-- Simple overlay (Sound key, optional CharacterRequired)
	if entry.Sound then
		playSingleOverlay(sound, entry, charName)
	end
end

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

do
	local FusionStatesFolder = ReplicatedStorage:FindFirstChild("Bindables")
		and ReplicatedStorage.Bindables:FindFirstChild("FusionStates")

	if FusionStatesFolder then
		local SetNotification = FusionStatesFolder:FindFirstChild("SetNotification")
		if SetNotification and SetNotification:IsA("BindableEvent") then
			SetNotification.Event:Connect(function(message)
				if type(message) ~= "string" then return end

				-- Exact match
				local notifInfo = NotificationSounds[message]
				if notifInfo then
					if notifInfo.CharacterRequired then
						local charName = Players.LocalPlayer:GetAttribute("CharacterName")
						if charName ~= notifInfo.CharacterRequired then return end
					end

					local key = "Notif_" .. message
					if not Cooldowns[key] then
						Cooldowns[key] = true
						task.spawn(function()
							playAbilitySound(notifInfo, key)
						end)
					end
					return
				end

				-- Pattern match
				for _, patternInfo in ipairs(NotificationPatternSounds) do
					if string.match(message, patternInfo.Pattern) then
						if patternInfo.CharacterRequired then
							local charName = Players.LocalPlayer:GetAttribute("CharacterName")
							if charName ~= patternInfo.CharacterRequired then return end
						end

						local key = "NotifPat_" .. patternInfo.Pattern
						if not Cooldowns[key] then
							Cooldowns[key] = true
							task.spawn(function()
								playAbilitySound(patternInfo, key)
							end)
						end
						return
					end
				end
			end)
		end
	end
end
