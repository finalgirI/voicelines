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

	Invisique = {
		Icon = "18630085006",
		["Valerie Tulle"] = "116763647482749",
		["Nora Hildegard"] = "80580720829811",
	},

	Motus = {
		Icon = "18630084955",
		["Bonnie Bennett"] = "114093297475680",
		["Nora Hildegard"] = "131259403209726",
		["Davina Claire"] = "109348032177998",
	},

	PhasmatosIncendia = {
		Sound = "91016794551142",
		Icon = "18630281578"
	},

	Somnus = {
		Sound = "95823566800088",
		Icon = "109870855790839",
		Volume = 9,
	},

	Incendia = {
		Icon = "18630085138",
		["Bonnie Bennett"] = "74863711273747",
		--["Lizzie Saltzman"] = "98540976660149",
		--["Hope Mikaelson"] = "88254920355046",
		--["Valerie Tulle"] = "134446708409005",
	},

	--Harae = {
	--	Sound = "70767045237007",
	--	Icon = "18630087278",
	--	Volume = 0.8,
	--	FadeOut = true,
	--},


	--ChannelAncestorsBonnie = {
	--	Sound = "104749000603361",
	--	Icon = "18630281775",
	--	Volume = 3,
	--	DelayTime = 4,
	--	FadeOut = true,
	--},

	--ExpressionSpell = {
	--	Sound = "15601121759",
	--	Icon = "18630089477",
	--	DelayTime = 3,
	--},

	--PsychicDimension = {
	--	Sound = "130322652559089",
	--	Icon = "18630089689",
	--},

	--IHaveEveryMagic = {
	--	Sound = "123232609831917",
	--	Icon = "18630089477",
	--	DelayTime = 16,
	--},

	--WoundInfliction = {
	--	Sound = "135485148941488",
	--	Icon = "18630282534",
	--},

	--OriginalKillingSpell = {
	--	Sound = "15174394937",
	--	Icon = "18630281752",
	--	FadeOut = true,
	--},

	--PhasmatosTribumNasExVeras = {
	--	Sound = "15631194386",
	--	Icon = "18630089507",
	--},

	--SuctusIncendia = {
	--	Sound = "15325084064",
	--	Icon = "18630089076",
	--},

	--PsychicRestraint = {
	--	Sound = "117198514953604",
	--	Icon = "18630089765",
	--	Volume = 3,
	--},

	--LifeLinking = {
	--	Sound = "102024711113477",
	--	Icon = "18630089409",
	--	DelayTime = 7.5,
	--},

	--BonnieTurnToStone = {
	--	Sound = "14556366203",
	--	Icon = "18630281954",
	--},

	--AleoraSubsitos = {
	--	Sound = "15237076338",
	--	Icon = "18630089347",
	--	DelayTime = 4,
	--	FadeOut = true,
	--},

	--Vados = {
	--	Sound = "127725225837213",
	--	Icon = "18630282009",
	--},

	--PsychicBlast = {
	--	Sound = "130316188399085",
	--	Icon = "18630089212",
	--},

	--PhasmatosRavarosOnAnimum = {
	--	Sound = "15254480460",
	--	Icon = "18630089343",
	--},

	--Autem = {
	--	Sound = "13203446447",
	--	Icon = "18630087239",
	--},

	--DarkMagicBolts = {
	--	Sounds = {"86892327341853", "102408304337752", "85681111856011"},
	--	Icon = "18630088083",
	--},

	--FianteFulguris = {
	--	Sound = "90115515174277",
	--	Icon = "18630088248",
	--},

	--Ascendo = {
	--	Sound = "78053223963040",
	--	Icon = "18630087176",
	--	FadeOut = true,
	--},

	--SandClock = {
	--	Sound = "74786986821079",
	--	Icon = "18630281373",
	--	DelayTime = 4.3,
	--},

	--OutfitChangeJosie = {
	--	Sound = "77485734102576",
	--	Icon = "18630087095",
	--	DelayTime = 0.6,
	--},

	--ISaidHey = {
	--	Sound = "101957577374614",
	--	Icon = "116482478049852",
	--	Volume = 0.8,
	--	FadeOut = true,
	--},

	--Stellabunde = {
	--	Sound = "132802121953563",
	--	Icon = "92704345603128",
	--},

	--Dissulta = {
	--	Sound = "134481306386869",
	--	Icon = "128909320385582",
	--},

	--IgnisTempestas = {
	--	Sound = "95468563095334",
	--	Icon = "18630089900",
	--	Volume = 1,
	--	DelayTime = 0.6,
	--},

	--AvitaExari = {
	--	Sound = "16118919066",
	--	Icon = "18630090107",
	--	DelayTime = 1.3,
	--	FadeOut = true,
	--},

	--VenenumCorpus = {
	--	Sound = "81126580655893",
	--	Icon = "18630090246",
	--},

	--QetTurnToStone = {
	--	Sound = "16838696298",
	--	Icon = "18630282217",
	--},

	--DestroyOtherSide = {
	--	Sound = "16767898955",
	--	Icon = "18630090397",
	--},

	--QetBrainFry = {
	--	Sound = "105550543421825",
	--	Icon = "18630089944",
	--	DelayTime = 0.1,
	--	FadeOut = true,
	--},

	--AhShaLana = {
	--	Sound = "81639278311000",
	--	Icon = "18630090331",
	--	FadeOut = true,
	--},

	--SpiritualCleanse = {
	--	Sound = "16326825053",
	--	Icon = "18630090458",
	--},

	--TalismanChannelQet = {
	--	Sound = "78867379826047",
	--	Icon = "18630090442",
	--	FadeOut = true,
	--},

	--QetResurrection = {
	--	Sound = "96414682813420",
	--	Icon = "18630282468",
	--	DelayTime = 7,
	--},

	--CureCreation = {
	--	Sound = "16479305722",
	--	Icon = "18630090139",
	--	DelayTime = 15,
	--},
	
	--TelekAttack = {
	--	Sound = "94965672679001",
	--	Icon = "135639275617447",
	--},

	--LocatorSpell = {
	--	Icon = "87004194847894",
	--	["Freya Mikaelson"] = "107779666764444",
 --       DelayTime = 5.4,
	--},

	--TelekSubmission = {
	--	Sound = "128304384560357",
	--	Icon = "109520694042246",
	--},

	--BloodChoke = {
	--	Sound = "97911663035904",
	--	Icon = "100807331974657",
	--	Volume = 2,
	--},

	--BloodBoil = {
	--	Sound = "73829700677752",
	--	Icon = "113848119444432",
	--},

	--NecksnapLift = {
	--	Sound = "79984922909048",
	--	Icon = "93803135163081",
	--	FadeOut = true,
	--},

	--SoulBind = {
	--	Sound = "109441100680596",
	--	Icon = "72761138794898",
	--	FadeOut = true,
	--},

	--LightningStrike = {
	--	Sound = "123620176154825",
	--	Icon = "98292882529833",
	--},

	--GoldenDagger = {
	--	Sound = "130386408505459",
	--	Icon = "75282755890383",
	--	DelayTime = 2.3,
	--	FadeOut = true,
	--},

	--DavinaMagicRegen = {
	--	Sound = "82826752361269",
	--	Icon = "127086238458899",
	--	DelayTime = 8,
	--	FadeOut = true,
	--},

	--BoneBreakCombo = {
	--	Sound = "128387089253440",
	--	Icon = "126319455693987",
	--},

	--BrainFryFreya = {
	--	Sound = "137442198052809",
	--	Icon = "122841911569776",
	--	Volume = 4,
	--	FadeOut = true,
	--},

	--VampReversalFreya = {
	--	Sound = "129676323948552",
	--	Icon = "116098716846924",
	--	DelayTime = 0.3,
	--	FadeOut = true,
	--},

	--VampReversalFreya2 = {
	--	Sound = "94259360187031",
	--	Icon = "116098716846924",
	--	DelayTime = 0.3,
	--	FadeOut = true,
	--},

	--AstralProjection = {
	--	Sound = "97414512710914",
	--	Icon = "84884940636467",
	--	DelayTime = 4.2,
	--	FadeOut = true,
	--},

	--FreyaMagicShield = {
	--	Sound = "74460096162653",
	--	Icon = "110401705087848",
	--	Volume = 3.3,
	--	PlayOnEquipped = true,
	--	AddOnEquipTime = 34,
	--},

	--MenedekQualSurentaFreya = {
	--	Sound = "117507162492846",
	--	Icon = "88472118739491",
	--},

	--FreyaCrowTurning = {
	--	Sound = "105913987460965",
	--	Icon = "80792862263655",
	--	Volume = 10,
	--},

	--PendantTrapFreya = {
	--	Sound = "110211317792165",
	--	Icon = "121864956252192",
	--	FadeOut = true,
	--	Volume = 1.3,
	--},

	--CardiacArrest = {
	--	Sound = "138819760805849",
	--	Icon = "134948394386315",
	--	FadeOut  = true,
	--},

	--AncestorAttackEndFreya = {
	--	Sound = "113820074623121",
	--	Icon = "90735917034092",
	--	DelayTime = 17.5,
	--},

	--MassCrowsFreya = {
	--	Sound = "100950296033969",
	--	Icon = "89861435390266",
	--	Volume = 4,
	--	FadeOut = true,
	--},

	--Sigil = {
	--	Sound = "106151236422771",
	--	Icon = "83085294584462",
	--},

	--Aneurysm = {
	--	Sound = "132015776882851",
	--	Icon = "82552464417064",
	--	FadeOut  = true,
	--},

	--InsanityHex = {
	--	Sound = "114599395160541",
	--	Icon = "118013678786620",
	--	Volume = 5,
	--},

	--NeedleOfSorrows = {
	--	Sound = "97437123423899",
	--	Icon = "107370676731191",
	--	FadeOut = true,
	--	Volume = 4.8,
	--},

	--GenevieveAsh = {
	--	Sound = "119504583819814",
	--	Icon = "82815418211348",
	--	Volume = 3,
	--},

	--JosephineViolin = {
	--	Sound = "89550767660084",
	--	Icon = "113547517379895",
	--	Volume = 6.5,
	--},

	--PapaTundeBlade = {
	--	Sound = "139735291592382",
	--	Icon = "100016320723838",
	--	FadeOut = true,
	--},

	--AncestralPain = {
	--	Icon = "83837051753013",
	--	["Genevieve"] = "80082176187338",
	--	["Agnes"] = "121671824051694",
	--	["Josephine LaRue"] = "79538024543328",
	--	["Bastianna Natale"] = "70512941919646",
	--	["Papa Tunde"] = "74362949998012",
	--	Volume = 3.2,
	--	FadeOut = true,
	--},

	--Ohun = {
	--	Sound = "92404277403294",
	--	Icon = "98499345224483",
	--	PlayOnEquipped = true,
	--	AddOnEquipTime = 23,
	--},

	--Pada = {
	--	Sound = "91217804264943",
	--	Icon = "98499345224483",
	--},

	--Sunbeam = {
	--	Sound = "95590928220540",
	--	Icon = "105971657899955",
	--	Volume = 3.4,
	--},

	--CleoTeleport = {
	--	Sound = "122887446534653",
	--	Icon = "125340898573455",
	--},

	--TelekExplosionCleo = {
	--	Sound = "123217650248442",
	--	Icon = "112113802501534",
	--},

	--OoNiLeSoro = {
	--	Sound = "90131739908048",
	--	Icon = "81226717447746",
	--},

	--Inspire = {
	--	Sound = "131047658678353",
	--	Icon = "130742776637140",
	--	DelayTime = 2,
	--},

	--MudGolem = {
	--	Sound = "74072970288534",
	--	Icon = "106682862771573",
	--	DelayTime = 0.3,
	--	Volume = 1.5,
	--},

	--HopeLecutio = {
	--	Icon = "18630086622",
	--	["Hope Mikaelson"] = "131807122245438",
	--},

	--WolfTransformation = {
	--	Icon = "18630084635",
	--	["Hope Mikaelson"] = "76431177526410",
	--},

	--Sol = {
	--	Icon = "18630084767",
	--	["Hope Mikaelson"] = "85082904537308",
	--},

	--LightBall = {
	--	Icon = "18630087916",
	--	FadeOut = true,
	--	["Hope Mikaelson"] = "100313110940795",
	--},

	--HopeExplosion = {
	--	Sound = "104028506433231",
	--	Icon = "18630088744",
	--	Volume = 1.4,
	--	FadeOut = true,
	--},

	--HopesRepulse = {
	--	Sound = "17471844257",
	--	Icon = "18630086888",
	--},

	--GlaceSolidatur = {
	--	Sound = "99610680956880",
	--	Icon = "98652212452518",
	--	FadeOut = true,
	--},

	--BloodBlade = {
	--	Sound = "104137817730493",
	--	Icon = "18630087326",
	--	FadeOut = true,
	--	PlayOnEquipped = true,
	--	AddOnEquipTime = 1,
	--},

	--HopeVentus = {
	--	Sound = "72404882318303",
	--	Icon = "18630086607",
	--},

	--HopeHeadDecap = {
	--	Sound = "129988097306628",
	--	Icon = "18630087727",
	--	DelayTime = 5,
	--},

	--HopeTurning = {
	--	Icon = "18630084447",
	--	Volume = 3.6,
	--	["Hope Mikaelson"] = "72373310588316",
	--},

	--VampReversalEsther = {
	--	Sound = "18535307514",
	--	Icon = "135429488486657",
	--	DelayTime = 1,
	--},

	--PentagramEsther = {
	--	Sound = "129460073622144",
	--	Icon = "87208128166220",
	--	DelayTime = 5,
	--},

	--ChainsEsther = {
	--	Sound = "83942262095667",
	--	Icon = "79303670793326",
	--},

	--MagicSteal = {
	--	Sound = "94787275001396",
	--	Icon = "75230896040263",
	--	FadeOut = true,
	--},

	--BloodSteal = {
	--	Sound = "74050761219524",
	--	Icon = "18894843205",
	--	FadeOut = true,
	--},

	--EstherWhiteOakSpell = {
	--	Sound = "139418993300939",
	--	Icon = "81666997829225",
	--},

	--TheUltimateWeaponEsther = {
	--	Sound = "118918239866614",
	--	Icon = "81666997829225",
	--	DelayTime = 17,
	--},

	--EstherOriginalSerum = {
	--	Sound = "91204949642033",
	--	Icon = "134112373642550",
	--	DelayTime = 14,
	--},

	--StranguloVentus = {
	--	Icon = "18630087547",
	--	FadeOut = true,
	--	["Valerie Tulle"] = "88573986552740",
	--	["Nora Hildegard"] = "118508173111903",
	--},

	--HereticJointSpell = {
	--	Icon = "18630088044",
	--	DelayTime = 3,
	--	FadeOut = true,
	--	["Valerie Tulle"] = "13904360117",
	--	["Nora Hildegard"] = "13904360117",
	--	["Mary Louise"] = "13904360117",
	--},

	--Vido = {
	--	Icon = "18630281415",
	--	Volume = 4,
	--	["Mary Louise"] = "88600853616027",
	--},

	--IllusionAttack = {
	--	Icon = "18630090954",
	--	Sound = "88189755078068",
	--},

	--OrganLiquify = {
	--	Icon = "18630090630",
	--	Sound = "85818992177233",
	--},

	--DelfanEotenCor = {
	--	Icon = "18630087815",
	--	["Qetsiyah"] = "132701227107666",
	--	["Bonnie Bennett"] = "93410039917419",
	--	["Freya Mikaelson"] = "129158847870610",
	--},

	--AdSomnum = {
	--	Icon = "18630085451",
	--	Volume = 3.5,
	--	["Dark Josie"] = "81204185561575",
	--	["Josie Saltzman"] = "81204185561575",
	--	["Freya Mikaelson"] = "94633917213364",
	--	["Hope Mikaelson"] = "131198089743550",
	--},

	--VisSeraPortus = {
	--	Icon = "18630084722",
	--	["Bonnie Bennett"] = "73245313373983",
	--	Volume = 3.5,
	--},

	--Imobiluse = {
	--	Icon = "18630087000",
	--	["Dark Josie"] = "105680172999340",
	--	["Josie Saltzman"] = "105680172999340",
	--},

	--Aquamalia = {
	--	Icon = "18630088717",
	--	Volume = 2.5,
	--	["Hope Mikaelson"] = "127841579933142",
	--},

	--ErroxFemus = {
	--	Icon = "18630085245",
	--	["Bonnie Bennett"] = "81342092829364",
	--},

	--Ossox = {
	--	Icon = "18630281131",
	--	["Dark Josie"] = "71429766864674",
	--	["Freya Mikaelson"] = "110410203919763",
	--},

	--Menedek = {
	--	Icon = "18630084930",
	--	["Bonnie Bennett"] = "84898218174575",
	--	["Davina Claire"] = "109615919605410",

	--},

	--HeadSiphon = {
	--	Icon = "18630087581",
	--	["Malcolm"] = "100864025080028",
	--	["Dark Josie"] = "139164497000480",
	--	["Josie Saltzman"] = "139164497000480",
	--	Volume = 1.4,
	--	FadeOut = true,
	--},

	--Ictus = {
	--	Icon = "18630281256",
	--	["Davina Claire"] = "76239424251739",
	--	["Freya Mikaelson"] = "83319807623114",
	--	["Hope Mikaelson"] = "91081771194142",
	--},

	--SpineBreak = {
	--	Icon = "18630085580",
	--	["Katherine Pierce"] = "14841026112",
	--	["Aurora De Martel"] = "97908940377337",
	--},

	--ThroatRip = {
	--	Icon = "18630281055",
	--	["Katherine Pierce"] = "14841026112",
	--	["Aurora De Martel"] = "91514318555989",
	--},

	--HeartRip = {
	--	Icon = "18630084285",
	--	["Aurora De Martel"] = "71870170081183",
	--	["Hope Mikaelson"] = "108349443247039",
	--	["Rebekah Mikaelson"] = "89688396603399",
	--	["Marcel Gerard"] = "110381933492775",
	--},

	--HeadRip = {
	--	Icon = "18630084315",
	--	["Klaus Mikaelson"] = "122787771744632",
	--	["Elijah Mikaelson"] = "112316220234662",
	--},

	--SuperPunch = {
	--	Icon = "18630087742",
	--	["Elijah Mikaelson"] = "89245420291267",
	--},

	--SuperSlap = {
	--	Icon = "73276360094899",
	--	["Hope Mikaelson"] = "125011735974039",
	--	["Rebekah Mikaelson"] = "73616559992744", 
	--},

	--SuperKick = {
	--	Icon = "117025696388944",
	--	["Rebekah Mikaelson"] = "134363458393409",
	--	["Hope Mikaelson"] = "117071643793823", 
	--	Volume = 3.5,
	--},

	--Choke = {
	--	Icon = "18630084520",
	--	["Rebekah Mikaelson"] = "135260624293276",
	--	["Mary Louise"] = "76991721803834",
	--	["Hope Mikaelson"] = "88024240964591",
	--},

	--ChokeOut = {
	--	Icon = "136852406200956",
	--	["Rebekah Mikaelson"] = "103359391224128",
	--	["Klaus Mikaelson"] = "110962212419680",
	--},

	--HeelStomp = {
	--	Icon = "109498239929193",
	--	Volume = 1.8,
	--	["Josie Saltzman"] = "91130808414020",
	--	["Dark Josie"] = "91130808414020",
	--	["Hope Mikaelson"] = "114218115884187",
	--},

	--ArmBreak = {
	--	Icon = "71180787516661",
	--	["Aurora De Martel"] = "111039547177303",
	--	["Hope Mikaelson"] = "112336295176021",
	--	["Rebekah Mikaelson"] = "95161950033776",
	--},

	--SnapNeck = {
	--	Icon = "18630087942",
	--	["Hope Mikaelson"] = "126809683102566",
	--	["Elijah Mikaelson"] = "99500998724165",
	--	["Kol Mikaelson"] = "130612995488285",
	--},
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
local LastTransparency = {}
local LastIcon = {}
local ActiveSounds = {}
local FadingSounds = {}
local LastEquipPlayTime = {}
local EquipPlayLock = {}
local SoundCycleIndex = {}  -- Tracks which sound to play next for abilities with multiple sounds
local KeepPlayingSounds = {} -- Tracks sounds that should keep playing even when replaced

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
		if charName ~= info.CharacterRequired then return end
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

	if not soundId then return end  -- no character match and no default, skip

	-- Record play time so VoicelinesForEveryone can skip overlays/replacements for local player
	-- Only set this AFTER all validation passes, so it only stamps when a sound actually plays
	Players.LocalPlayer:SetAttribute("VoicelinesLastPlayTime", tick())

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. normalize(soundId)
	sound.Volume = info.Volume or 2.5

	sound.Parent = SoundService

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

	if info.KeepPlayingSound then
		KeepPlayingSounds[sound] = true
	end

	-- Play simultaneous sound if provided
	if simultaneousSoundId then
		local simSound = Instance.new("Sound")
		simSound.SoundId = "rbxassetid://" .. normalize(simultaneousSoundId)
		simSound.Volume = info.Volume or 2.5
		simSound.Parent = SoundService

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
		local abilities = IconMap[currentImage]
		if not abilities then return end

		for _, abilityName in ipairs(abilities) do
			local info = Data[abilityName]

			-- For PlayOnEquipped abilities: stop sound when used (cooldown is set in playEquipSoundIfReady)
			if info and info.PlayOnEquipped then
				-- Stop the sound if it's playing
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
			else
				Cooldowns[abilityName] = false
			end
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
							playAbilitySound(info, abilityName)
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
			task.wait(0.01)
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
					playAbilitySound(actionInfo, key)
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
	{ Pattern = "is tracking you%.%.", Sound = "128623140442224", Volume = 3, CharacterRequired = "Davina Claire" },
}



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
