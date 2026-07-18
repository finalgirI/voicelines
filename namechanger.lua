local Players = game:GetService("Players")

-- ============================================
-- ORIGINAL NAME REPLACEMENTS (character names, etc.)
-- ============================================
local NameReplacements = {
	-- Witches
	["Attic Witch"] = "Davina Claire",
	["Lost Sister"] = "Freya Mikaelson",
	["Town Witch"] = "Bonnie Bennett",
	["Ancient Witch"] = "Qetsiyah",
	["Original Witch"] = "Esther Mikaelson",
	["Ancestral Guardian"] = "Vincent Griffith",
	["Coven Ancestor"] = "Genevieve",
	["Ritual Leader"] = "Bastianna Natale",
	["Fortune Teller"] = "Agnes",
	["Regent"] = "Josephine LaRue",
	["Voodoo King"] = "Papa Tunde",
	["The Doctor"] = "Josette 'Jo' Parker",
	["The Muse"] = "Cleo Sowande",
	["Dark Siphoner"] = "Dark Josie",
	["Lost Twin"] = "Olivia Parker",
	["Popular Girl"] = "Alyssa Chang",
	["The Sacrifice"] = "Monique Deveraux",
	["Protective Twin"] = "Luke Parker",
	["Quarter Witch"] = "Sophie Deveraux",
	["Siphoner Twin"] = "Lizzie Saltzman",
	["Cousin"] = "Lucy Bennett",
	["Grandmother"] = "Sheila Bennett",
	["Absent Mother"] = "Abby Bennett",
	["The Sociopath"] = "Malachi 'Kai' Parker",
	["Vengeful Spirit"] = "Celeste Dubois",
	["Siphoner Witch"] = "Josie Saltzman",
	["The Miracle"] = "Hope Mikaelson",
	["Burned Witch"] = "Emily Bennett",

	-- Vampires
	["The Control Freak"] = "Caroline Forbes",
	["The Nerd"] = "Milton 'MG' Greasley",
	["The Lover"] = "Sage",
	["Enzo St. John"] = "Lorenzo 'Enzo' St. John",
	["The Merciless"] = "Sebastian The Merciless",
	["The Firstborn"] = "Lucien Castle",
	["The Assassin"] = "Aya Al-Rashid",
	["The Unhinged"] = "Aurora De Martel",
	["The Leader"] = "Tristan De Martel",
	["The Selfish"] = "Isobel Flemming",
	["The Imposter"] = "Katherine Pierce",
	["The Dragon"] = "Kaleb Hawkins",
	["The Fierce Protector"] = "Pearl Zhu",
	["The Mentor"] = "Alexia Branson",
	["Adoptive Mother"] = "Lily Salvatore",
	["The Charmer"] = "Lorenzo \'Enzo\' St. John",
	["The King"] = "Marcel Gerard",
	["The Runaway"] = "Rose",
	["The Ripper"] = "Stefan Salvatore",
	["The Rebellious"] = "Annabelle Zhu",
	["The Sarcastic"] = "Damon Salvatore",
	["The Traveler"] = "Nadia Petrova",
	["Troubled Girl"] = "Vicki Donovan",
	["The Loyal"] = "Joshua 'Josh' Rosza",

	-- Originals
	["Deranged Brother"] = "Kol Mikaelson",
	["Viking Warrior"] = "Mikael Mikaelson",
	["Noble Brother"] = "Elijah Mikaelson",
	["Loyal Sister"] = "Rebekah Mikaelson",
	["Outcast Brother"] = "Finn Mikaelson",
	["The Hybrid"] = "Klaus Mikaelson",
	["Crescent Queen"] = "Hayley Marshall-Kenner",
	["Quarterback"] = "Tyler Lockwood",

	-- Heretics / Bloodwitches
	["Silent Bloodwitch"] = "Beau",
	["First Bloodwitch"] = "Valerie Tulle",
	["Devious Bloodwitch"] = "Mary Louise",
	["Arrogant Bloodwitch"] = "Nora Hildegard",
	["Carefree Bloodwitch"] = "Oscar",
	["Vengeful Bloodwitch"] = "Malcolm",

	-- Heretics (new names since Bloodwitches are now Heretics)
	["Silent Heretic"] = "Beau",
	["First Heretic"] = "Valerie Tulle",
	["Devious Heretic"] = "Mary Louise",
	["Arrogant Heretic"] = "Nora Hildegard",
	["Carefree Heretic"] = "Oscar",
	["Vengeful Heretic"] = "Malcolm",

	-- Realms / Titles
	["Purgatory"] = "Other Side",
	["Raw Magic"] = "Expression",
	["raw magic"] = "expression",
	["Raw magic"] = "Expression",
	["Moonlight Creek"] = "Mystic Falls",
	["Moonlight"] = "Mystic",
	["Supernatural Academy"] = "Salvatore School",
	["academy"] = "Salvatore School",
	["Moonlight Falls"] = "Mystic Falls",

	-- Items
	["Sacrificial Dagger"] = "Harvest Dagger",
	["Sacrificial dagger"] = "Harvest dagger",
	["Sacrificial ritual"] = "Harvest ritual",
	["Ivory Stake"] = "White Oak Stake",
	["Ivory oak stake"] = "White oak stake",
	["Ivory Oak stake"] = "White Oak stake",
	["Ivory tree"] = "White Oak tree",
	["Indestructible Ivory Stake"] = "Indestructible White Oak Stake",
	["Crimson Oak Stake"] = "Red Oak Stake",
	["Crimson Oak tree"] = "Red Oak tree",
	["Crimson oak tree"] = "Red oak tree",
	["Frost Arrow"] = "Golden Arrow",
	["Vampite"] = "Vervain",
	["Hunters Ring"] = "Gilbert Ring",

	-- Werewolves
	["Charismatic Wolf"] = "Rafael Waithe",
	["Shy Wolf"] = "Aiden",
	["Smart Wolf"] = "Keelin Malraux",
	["Deceptive Wolf"] = "Mason Lockwood",
	["Fearful Wolf"] = "Finch Tarrayo",
	["Arrogant Wolf"] = "Jules",
	["Alpha Wolf"] = "Jackson Kenner",
	["Confident Wolf"] = "Jed",

	-- Mortals / Humans
	["The Therapist"] = "Camille OConnor",
	["The Guardian"] = "Jenna Sommers",
	["The Mayor"] = "Carol Lockwood",
	["The Headmaster"] = "Alaric Saltzman",
	["The Hunter"] = "Jeremy Gilbert",
	["The Friend"] = "Matt Donovan",
	["The Sheriff"] = "Liz Forbes",
	["The Doppelganger"] = "Elena Gilbert",

	-- Other supernaturals
	["The Phoenix"] = "Landon Kirby",
	["The Trickster"] = "Silas",
	["The Anchor"] = "Amara",
	["The Obsessed"] = "Roman",
	["Manipulative Father"] = "Jonas Martin",
	["The Pawn"] = "Luca Martin",

	-- Species
	["Bloodwitch"] = "Heretic",
	["bloodwitches"] = "Heretics",
	["Triblood"] = "Tribrid",
	["Firstblood"] = "Original",
	["Ancestor Witch"] = "Elder Witch",
	["Ancestor  witches"] = "Elder witches",
	["this Ancestor"] = "this Elder",
	["This Ancestor"] = "This Elder",
	["ancestor witches"] = "elder witches",

	-- Abilities (identity mappings removed — they wasted CPU for zero effect)
	["Mind Control"] = "Compulsion",
	["Fire Blast"] = "Incendia",
	["Silence"] = "Silencio",
	["Invisibility"] = "Invisique",
	["Water Stream"] = "Aquamalia",
	["Telekinetic Blast"] = "Motus",
	["Telekinetic Shove"] = "Ictus",
	["Stopping Spell"] = "Immobilus",
	["Fall Asleep"] = "Ad Somnum",
	["Telekinetic Neck Snap"] = "Ossox",
	["Bone Break"] = "Errox Femus",
	["Mass Vampire Snap"] = "Menedek Qual Surenta",
	["Sunlight Ring"] = "Phasmatos Tribum Solaris Circulum",
	["Tomb Opening"] = "Phasmatos Veras Nos Ex Malon",
	["Blind"] = "Sol",
	["Barrier Spell"] = "Vis Sera Portus",
	["Ball of Light"] = "Post Tenebras Spero Lucem",
	["Telekinetic Heart Rip"] = "Delfan Eoten Cor",
	["Fire Circle"] = "Phasmatos Motus Incendiamos",
	["Draw Fire"] = "Phasmatos Incendia",
	["Temporary Immortality Reversal"] = "Phasmatos Impetum Immortale",
	["Flame Tracking"] = "Phasmatos Nos Ex Veras",
	["Building Explosion"] = "Ex Spiritum In Tacullum",
	["Turn to Stone"] = "Duratus Vita",
	["Heal Wounds"] = "Sanitas Est Vitalis",
	["Fire Cleanse"] = "Suctus Incendia",
	["Self Resurrection"] = "Vitas Ad Animum Vitas Et Corporus",
	["Telekinetic Strangle"] = "Strangulo Ventus",
	["Explosion Ritual"] = "Confuso Fatina, Ignos Et Ignos Mortifina",
	["Pull"] = "Vido",
	["Grant Invisibility"] = "Invisique Confero",
	["Wind Blast"] = "Ventus",
	["Explosion"] = "Bruciare Supe Terram, Faciendo Ignis Ga Praemium",
	["Electric Strike"] = "Lecutio Maxima",
	["Magic Scream"] = "Hope's Scream",
	["Magic Repulse"] = "Hope's Repulse",
	["Blinding Blast"] = "Solaris Impulsus",
	["Fire Stream"] = "Ignis Infernum",
	["Fire Storm"] = "Ignis Tempestas",
	["Knife Throw"] = "Volare Scalpere",
	["Heart Freeze"] = "Avita Exari",
	["Cure Creation"] = "Immortale Remedium",
	["Living Fossil"] = "Petram Aeternum",
	["Venom Blast"] = "Venenum Corpus",
	["Draw Blue Fire"] = "Phasmatos Incendia Caerulus",
	["Outfit Change"] = "Vestis Mutatio",
	["Earthquake"] = "Autem",
	["Memory Purge"] = "Harae Tamae Kioku Yomiguerashi Tamae",
	["Telekinetic Grab"] = "Ascendo",
	["Mass Fire"] = "Ignis Ubique",
	["Summon Lightning"] = "Fiante Fulguris",
	["Heart Stopping"] = "Aleora Subsitos",
	["Kinetic Burst"] = "Vados",
	["Life Linking"] = "Phasmatos Tribum, Melan veras raddiam",
	["Summon Vines"] = "Vitem Tenaci",
	["Destroy Purgatory"] = "Regnum Confractus",
	["Organ Liquify"] = "Ventrum Liquidis",
	["Intense Pain"] = "Dolore Sanguinis",
	["Flame Projectile"] = "Incendium",
	["Wind Storm"] = "Vis Ventorum",
	["Spear Throw"] = "Volare Hasta",
	["Magic Steal"] = "Osculum Tenebris",
	["Blood Steal"] = "Vita Essentia Extractum",
	["Telekinetic Lift"] = "Motus Corporis",
	["Vampirism Reversal"] = "Solvere Tenebris Sanguinis",
	["Fire Pentagram"] = "Incendias Decipula",
	["Wolf Binding"] = "Animan Markamas Caristi Voka",
	["Moonlight Ring"] = "Matere Lunare Tua Vi'rtuse",
	["Indestructible Stake Creation"] = "Asgaris Distotus Tominto",
	["Light Repulse"] = "Ohun Pada",
	["Immobilizing Burst"] = "Fo Yato Si",
	["Mass Silence"] = "Oo Ni Le Soro",
	["Dark Teleport"] = "Dark Josie Teleport",
	-- Freeze moved to ExactOnlyReplacements (was corrupting descriptions)
	["Explosive Blast"] = "Dissulta",
	["Tripping Spell"] = "Stellabunde",
	["Mass Sleep"] = "Somnus",
	["Firstblood Reversal"] = "Original Reversal",
	["Enhanced Snap"] = "Menedek Qual Surenta",
	["Original Serum"] = "Fortis Salutis Ex Sanguinis",

}

-- Exact-only replacements: only replace when the ENTIRE text matches the key.
-- Use this for short/common words that would corrupt descriptions if replaced as substrings.
local ExactOnlyReplacements = {
	["Freeze"] = "Glace Solidatur",
	["Pain Infliction"] = "Poena Doloris",
	["Qetsiyah is severing your link to purgatory"] = "Qetsiyah is severing your link to the Other Side",
}

-- Exact description replacements copied from AbilityDataWITHVOICELINES.
-- These only activate when the entire displayed description matches.
local DescriptionReplacements = {
	["Resurrect a spirit from Purgatory and bring another player back to life"] = "Resurrect a spirit from the other side and bring another player back to life.", -- PhasmatosRavarosOnAnimum
	["Release a powerful burst of mental energy, knocking back all targets in a radius"] = "Release a powerful burst of mental energy, knocking back all targets in a radius.", -- PsychicBlast / AhShaLana
	["A deadly bite fueled with the venom of 7 Wolf Packs, this bite is a death sentence to all Vampires, including Firstbloods"] = "A deadly bite fueled with the venom of the 7 Wolf Packs, this bite is a death sentence to all Vampires, including Originals.", -- UpgradedBite
	["Delivers a quick slap to an enemy, dealing moderate damage"] = "Delivers a quick slap to an enemy, dealing moderate damage.", -- Slap
	["Unleash your dragon side, breathing fire at your foes. All targets hit are set ablaze and will take damage over time"] = "Kaleb unleashes his dragon side, breathing fire at his foes. All targets hit are set ablaze and will take damage over time.", -- DragonBreath
	["Requires 3 Bloodwitchs. A ritual spell that release fire explosions in a radius around the casters"] = "Requires 3 Heretics. A ritual spell that release fire explosions in a radius around the casters.", -- HereticJointSpell
	["Rips a platform from the ground lifting you into the air while simultaneously creating a devastating earthquake, dealing damage and incapacitating anyone in the vicinity"] = "Rips a platform from the ground allowing Josie to lift into the air, while simultaneously creating a devastating earthquake, dealing damage and incapacitating anyone in the vicinity", -- Autem
	["Utilizing the full potential of dark magic, you are able to teleport herself a short distance to gain ground on your enemies"] = "Utilizing the full potential of the dark magic, Josie is able to teleport herself a short distance to gain ground on her enemies", -- DarkJosieTeleport
	["Channels dark magic to allow you to levitate, at a cost of great magic consumption"] = "Channels the dark magic to allow Josie to levitate, at a cost of great magic consumption", -- Levitate
	["Summon forth strikes of red lightning in the surrounding area for a short period"] = "Fiante Fulguris", -- FianteFulguris
	["Release forth a stream of water that can extinguish flames from another person"] = "Puts out anyone on fire/affected by a fire spell", -- Aquamalia
	["Telekinetically shove your opponent, throwing them a significant distance"] = "Telekinetically push your opponent, throwing them a significant distance", -- Ictus
	["A powerful spell used to seal the Vampire tomb. This spell can only be casted by certain witches of a powerful bloodline"] = "A powerful spell used to seal the Vampire tomb under the old Church. This spell can only be casted by a Witch from the Bennett bloodline", -- PhasmatosVerasNosExMalon
	["Create a Sunlight ring for a Vampire to protect them from the sun"] = "Create a daylight ring for a Vampire to protect them from the sun", -- PhasmatosTribumSolarisCirculum
	["Allows you to harness the magic of witches in your vicinity"] = "Allows Esther to harness the magic of witches in her vicinity", -- FuranturPotentia
	["Create a potion that will turn the one who drinks it into an original"] = "Create a potion that will turn the one who drinks it into an original.", -- AeternumImmortalitas
	["Creates a moonlight ring for Werewolves, allowing them to transform at will"] = "Creates a moonlight ring for Werewolves, allowing them to transform at will.", -- ApparaitreApparebis
	["Summons swarm of crows to attack an individual, dealing damage over duration of the spell"] = "Summons swarm of crows to attack an individual, dealing damage over duration of the spell.", -- CorvusExamen
	["breaks the bones of everyone (except Mortals) in the vicinity"] = "breaks the bones of everyone (except Mortals) in the vicinity.", -- ErroxConfractus
	["Take control of the targets mind, allowing you to control their movements and speech"] = "Dahlia takes control of the targets mind, allowing her to control their movements and speech.", -- MentisImperium
	["Destroys the Sunlight ring of any Vampires in the vicinity"] = "Destroys the daylight ring of any Vampires in the vicinity.", -- CirculumPerdere
	["Snap the neck of weaker witches"] = "Snap Neck of weaker witches.", -- EstherNeckSnap
	["Teleport to targeted location"] = "Teleport to targeted location.", -- DhaliaTeleport
	["Explode the targets head"] = "Explode the targets head.", -- CerebraPerdere
	["Channel your energy to draw a line of fire, setting ablaze anyone who steps in its path"] = "Channel your energy to draw a line of fire, setting ablaze anyone who steps in its path.", -- PhasmatosIncendia
	["Unleash a wave of psychic power which overwhelms the minds of nearby targets, paralyzing them in their tracks"] = "Unleash a wave of psychic power which overwhelms the minds of nearby targets, paralyzing them in their tracks.", -- PsychicRestraint
	["Channeling raw power enables you to explode a nearby building in a burst of flame"] = "Channeling the raw power of expression enables you to explode a nearby building in a burst of flame.", -- ExSpiritumInTacullum
	["Drains the life force from another target, turning their body to stone"] = "Drains the life force from another target, turning their body to stone.", -- DuratusVita
	["[Requires Salt Circle]\nConnect with the spirits of your ancestors, calling on their aid to restore your magic energy"] = "[Requires Salt Circle] Connect with the spirits of your ancestors, calling on their aid to restore your magic energy.", -- ChannelAncestors
	["[Requires Salt Circle]\nChannel raw magic to unlock powerful new abilities"] = "[Requires Salt Circle] Channel the dark power of Expression to unlock powerful new abilities.", -- DarkGrimoire
	["Create devastating wounds in the victim\'s body. Can reveal psychic illusions"] = "Bonnie forces a target to feel the pain she once felt, creating devastating rips in the victim's body. Can reveal psychic illusions.", -- WoundInfliction
	["This counter-spell negates the effects of any fire damage, transferring the flames from your body to any targets in a radius around you"] = "This counter-spell negates the effects of any fire damage, transferring the flames from your body to any targets in a radius around you.", -- SuctusIncendia
	["An explosive spell which flings multiple targets in a burst of kinetic energy"] = "An explosive spell which flings multiple targets in a burst of kinetic energy.", -- Vados
	["Call upon the power of the spirits to bend nature to your will, summoning a powerful tornado and raging winds"] = "Call upon the power of the spirits to bend nature to your will, summoning a powerful tornado and raging winds.", -- WindTornado
	["Bind souls with a target, binding their life to yours. Once linked, if one person dies the other will share their fate"] = "Bind souls with a target, binding their life to yours. Once linked, if one person dies the other will share their fate.", -- LifeLink
	["Linking hands with a target, draw on your immense psychic power to escape to another dimension"] = "Linking hands with a target, draw on your immense psychic power to escape to another dimension.", -- PsychicDimension
	["The power gifted by your Ancestors. Channel their combined magic to temporarily reverse a targets immortality, leaving them vulnerable to death for a short duration, but damaging yourself in the process"] = "The power gifted by your Ancestors. Channel their combined magic to temporarily reverse a targets immortality, leaving them vulnerable to death for a short duration, but damaging yourself in the process.", -- PhasmatosImpetumImmortale
	["Channel the dark power of raw magic throughout your body to mend your wounds"] = "Channel the dark power of expression throughout your body to mend your wounds.", -- SanitasEstVitalis
	["[Requires Salt Circle]\nFocus your magic to track another player, drawing a line of fire from your location to theirs"] = "[Requires Salt Circle] Focus your magic to track another player, drawing a line of fire from your location to theirs.", -- PhasmatosNosExVeras
	["Grasp your targets heart in their chest and stop it from working, causing any mortal to die and any vampire to desiccate"] = "Allows Qetsiyah to grasp her targets heart in their chest and stop it from working, causing any mortal to die, and causing any vampire to desiccate", -- AvitaExari
	["Creates a large fire storm, forming a protective circle that will burn and fling back anyone who gets too close"] = "Creates a large fire storm around Qetsiyah, forming a protective circle that will burn and fling back anyone who gets too close.", -- IgnisTempestas
	["Fry the targets brain using advanced magic, causing incapacitation and temporary memory loss"] = "Qetsiyah uses her advanced knowledge of magic to fry the targets brain, causing incapacitation and temporary memory loss.", -- BrainFry
	["[Requires 1 Heart]\nUsing the blood of your enemies, channel ancient magic to create a single cure for immortality"] = "[Required 1 Heart] Using the blood of her enemies, Qetsiyah can channel her ancient magic to create a single cure for immortality.", -- ImmortaleRemedium
	["Turn your victim into a living fossil"] = "Allows Qetsiyah to turn her victim into a living fossil.", -- PetramAeternum
	["Manifest knives into reality and telekinetically launch them at your enemies, dealing damage"] = "Allows Qetsiyah to manifest knives into reality and telekinetically launch them at her enemies.", -- VolareScalpere
	["Throws a projectile of pure wolf venom which infects any target with a vampire side"] = "Throws a projectile of pure wolf venom which infects any target with a vampire side.", -- VenenumCorpus
	["Create a large fire tornado, sucking in enemies and igniting them on impact"] = "Landon uses his unique Phoenix abilities to create a huge fire tornado, sucking in enemies and igniting them on impact", -- InfernalTwister
	["Punch your opponent with a fist augmented by flame, throwing them back and simultaneously setting them ablaze"] = "Punch your opponent with a fist augmented by flame, throwing them back and simultaneously setting them ablaze.", -- FlamePunch
	["Channel intense heat through your hands to unleash a torrent of flames. Scorch enemies in its fiery path"] = "Phoenix channels intense heat through their hands, unleashing a torrent of flames. Scorch enemies in its fiery path", -- FlameThrower
	["Grants another player invisibility for a short period"] = "Grants another player invisibility for 25 seconds", -- InvisiqueConfero
	["Produces a large fiery explosion effect on the floor at your mouse position. Everyone hit by the effect are set on fire and thrown away in a radius"] = "Produces a large fiery explosion effect on the floor at your mouse position. Everyone hit by the effect are set on fire and thrown away in a radius.", -- HopeExplosion
	["A powerful sonic blast. This raw power will fry any opponents brain in the vicinity, incapacitating them for a short time"] = "A powerful sonic blast projected by Hope's scream. This raw power will fry any opponents brain in the vicinity, incapacitating them for a short time", -- HopesScream
	["A magical scratch channeling your Werewolf nature which injects wolf venom into your victim"] = "A magical scratch imitating that of her Werewolf nature", -- TelekineticScratch
	["An uncontrolled burst of powerful magic that incapacitates any opponent in it\'s radius"] = "An uncontrolled burst of powerful magic that incapacitates any opponent in it's radius", -- HopesRepulse
	["A glass-like blade made from congealed blood manipulated by telekinesis. This creates a melee weapon to use against enemies. Fatal to Phoenix species"] = "A glass-like blade made from congealed blood manipulated by telekinesis. This creates a melee weapon for Hope to use against her enemies", -- BloodBlade
	["Summon a powerful projectile of blinding light, knocking out any opponents hit by the blast"] = "A projectile spell, Hope summons a ball of light in her hand and throws it", -- SolarisImpulsus
	["Siphon the ground, draining the energy of all opponents in a radius whilst simultaneously refilling your own magic"] = "Siphon the ground, draining the energy of all opponents in a radius whilst simultaneously refilling your own magic.", -- MassSiphon
	["Channel raw telekinetic magic to slam enemies to the ground, causing significant damage"] = "Allows Kai to channel raw telekinetic magic to slam his enemies to the ground, causing significant damage", -- TelekineticSlam
	["Channel kinetic energy into a radius surrounding you, pushing anyone away"] = "cool ability that pushes ppl away from u", -- Arcanosphere
	["As a last resort, whilst in Purgatory, grab a living player to \226\128\156cross over\226\128\157 to the afterlife. Doing so will inflict the pain of your death onto the living player, causing them heavy damage and knocking them unconscious for a short period"] = "As a last resort, whilst on the Other Side, Qetsiyah can grab a living player to “cross over” to the afterlife. Doing so will inflict the pain of her death onto the living player, causing them heavy damage and knocking them unconscious for a short period.", -- SpiritualCleanse
	["Channel an ancient bone Talisman to quickly regenerate magic"] = "Allows Qetsiyah to channel her ancient bone Talisman to quickly regenerate her magic", -- ChannelTalisman
	["Using your advanced knowledge of Herbology, manipulate vines to restrain enemies for a short period, dealing damage over time"] = "Qetsiyah can use her advanced knowledge of Herbology to manipulate vines to restrain her enemies around her for a short period, dealing damage over time.", -- VitemTenaci
	["As the creator of Purgatory, you have the ability to pull yourself back once per lifetime, providing another chance at life"] = "As the creator of the Other Side, Qetsiyah has the ability to pull herself back from the Other Side once per lifetime.", -- VitasAdAnimumVitasEtCorporus
	["Rip the veil between the living and the dead. Once casted, any spirits residing in Purgatory will be sucked into a void and sent back to the main menu"] = "Allows Qetsiyah to take down the Other Side. Once casted, any spirits residing on the Other Side will be sucked into a void and sent back to the main menu.", -- RegnumConfractus
	["Channel ancient magic to inflict intense pain on your target"] = "Silas channels ancient magic to inflict intense pain on his target", -- Excrucio
	["Use illusions to immaterialize yourself and re-appear in another position"] = "Silas uses illusions to immaterialize himself and re-appear in another position", -- PsychicTeleport
	["Summon forth a projectile of flames which track your opponent, causing significant burn damage"] = "Allows Silas to fire projectile flames in a wide vicinity, causing significant damage to his enemies", -- Incendium
	["Your mental torture knows no bounds. Use illusions to appear behind a single target and seemingly stab them in the back, incapacitating the victim for a short period"] = "Silas' mental torture knows no bounds. Allows Silas to appear behind a single target and seemingly stab them in the back, incapacitating the victim for a short period", -- Trickster
	["Manipulate the climate to create a protective wind storm around yourself. Anyone who approaches the wind storm will be pulled into it, taking damage over time"] = "Silas can manipulate the climate to create a protective wind storm around him. Anyone who approaches the wind storm will be pulled into it, taking damage over time", -- VisVentorum
	["Use psychic illusions to change your physical appearance into another character"] = "Allows Silas to change his physical appearance into another character", -- Disguise
	["Psychic mind control used to control the minds of all victims surrounding you"] = "Vampiric mind control used to control your victims next action", -- MassCompulsion
	["Use advanced psychic powers to taunt a single target, appearing in bursts around them until you are close enough to knock them unconscious with a heavy punch"] = "Silas uses his advanced psychic power to taunt a single target, appearing in bursts around them until he is close enough to knock them unconscious with a heavy punch.", -- IllusionAttack
	["An ancient spell passed down through generations, this spell is the key to finding the cure for vampirism"] = "An ancient spell passed down through generations, this spell is the key to finding the first Immortal", -- SilasTombSpell
	["Temporarily drain all the magic from anyone in a vicinity whilst simultaneously boosting your own magic, leaving your opponents powerless for a short period of time"] = "Allows Esther to temporarily drain all the magic from anyone in a vicinity whilst simultaneously boosting her own magic, leaving her opponents powerless for 30 seconds", -- OsculumTenebris
	["As the witch who cast the spell to create Vampires, you also have the power to undo it.\n(Requires the target to be under 50% health)"] = "As the witch who cast the spell to create Vampires, Esther also has the power to undo it.\n(Requires the target to be under 50% health)", -- SolvereTenebrisSanguinis
	["Inflict intense pain on your enemies"] = "Esther has the power to inflict intense pain on her enemies", -- DoloreSanguinis
	["Creates a protective pentagram of fire around you and your allies. Attempting to enter may prove fatal to the weak"] = "Allows Esther to create a protective pentagram around her and her allies. Attempting to enter may prove fatal to the weak.", -- IncendiasDecipula
	["Bind a victims werewolf side to the moonstone, denying them access to their werewolf nature"] = "Esther can bind her victims werewolf side to the moonstone, denying them access to their werewolf nature", -- AnimanMarkamasCaristiVoka
	["Transform yourself into a starling, allowing you to temporarily fly around at great speed"] = "Allows Esther to leave her body and spawn her consciousness in a flying bird model. She can then fly around as the Starling to spy on her enemies. Her body will be vulnerable during this time, and if she is attacked then the ability will be cancelled and she will transfer back to her own body", -- StarlingTransformation
	["Summon flying birds to attack a single target, dealing damage over time while the target is forced to try and get the starlings off them"] = "Esther can summon flying birds to attack a single target, dealing damage over time while the target is forced to try and get the starlings off them", -- StarlingSwarm
	["While in Purgatory, your spirit can possess a weaker person, assuming complete control of the host and allowing you to return to the world of the living"] = "While on the Other Side, Esther can possess another person, assuming complete control of the host and allowing her to return to the world of the living", -- BodyJump
	["Bind the magic of the Hunters Ring to the Ivory oak stake, rendering it indestructible"] = "Allows Esther to bind the magic of the Gilbert ring to the white oak stake, rendering it indestructible.", -- AsgarisDistotusTominto
	["Tap into ancient dark magic to create a potion capable of turning the consumer into an Firstblood Vampire"] = "Esther can tap into ancient dark magic to create a potion capable of turning the consumer into an Original Vampire", -- FortisSalutisExSanguinis
	["Hidden wooden stakes in knuckle gloves, delivering punches to dispatch enemies up close"] = "hidden stakes", -- ConcealedStakes
	["Focus your magical ability to boil your enemy\'s blood, dealing damage over time."] = "Focus your magical ability to boil your enemy's blood, dealing damage over time.", -- BloodBoil
	["Causes the target to choke on their own blood, dealing damage over time and draining thirst"] = "Causes the target to choke on their own blood, dealing damage", -- BloodChoke
	["Bind a rare material to the mystical silver dagger to create a weapon capable of taking down any character with \'Thirst\' stat"] = "Bind a rare material to the mystical silver dagger to create a weapon capable of taking down any character with 'Thirst' stat", -- GoldenDaggerCreation
	["Channel immense power to see visions of the future. This power radiates outwards, causing an earthquake that incapacitates all targets within the area"] = "As an Oracle, Cleo can channel immense power to see visions of the future. This power radiates outwards, causing an earthquake that incapacitates all targets within the area.", -- Earthquake Cleo
	["Inflict pain on multiple opponents with one wave of your hand"] = "Enables Josie to pain inflict multiple opponents with one wave of her hand", -- I said hey
	["A powerful spell used to seal the Vampire tomb. This spell can only be casted by certain witches of a powerful bloodline"] = "A powerful spell used to seal the Vampire tomb under the old Church. This spell can only be casted by a Witch from the Bennett bloodline", -- Tomb Spell
}

-- Check the surrounding ability card for a specific icon.
-- This distinguishes abilities that share the same displayed name or description.
local function guiHasAbilityIcon(gui, imageId)
	local current = gui.Parent
	for _ = 1, 6 do
		if not current then break end
		for _, item in ipairs(current:GetDescendants()) do
			if (item:IsA("ImageLabel") or item:IsA("ImageButton"))
				and item.Image == imageId then
				return true
			end
		end
		current = current.Parent
	end
	return false
end

-- Image replacements: swap ability icons on the client
local ImageReplacements = {
	["rbxassetid://95661653372903"] = "rbxassetid://87044034729093", -- Channel Bloodline
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

	-- Replace complete ability descriptions before applying generic word/name changes.
	local descriptionMatch = DescriptionReplacements[text]
	if descriptionMatch then
		return descriptionMatch
	end

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
		local newText
		if originalText == "Telekinetically snap the bones of your opponent, incapacitating them for a short time"
			and guiHasAbilityIcon(gui, "rbxassetid://126319455693987") then
			newText = "Telekinetically snap the bones of your opponent"
		elseif originalText == "Resurrection"
			and guiHasAbilityIcon(gui, "rbxassetid://18630089343") then
			newText = "Phasmatos Ravaros On Animum"
		elseif originalText == "Mass Pain Infliction"
			and guiHasAbilityIcon(gui, "rbxassetid://18630090331") then
			newText = "Ah Sha Lana"
		else
			newText = replaceName(originalText)
		end
		if newText ~= originalText then
			isProcessing = true
			gui.Text = newText
			isProcessing = false
		end
	elseif gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
		local newImage = ImageReplacements[gui.Image]
		if newImage then
			isProcessing = true
			gui.Image = newImage
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
	elseif gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
		gui:GetPropertyChangedSignal("Image"):Connect(function()
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
