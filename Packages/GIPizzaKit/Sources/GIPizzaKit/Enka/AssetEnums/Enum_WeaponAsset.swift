// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

// MARK: - WeaponAsset

/// 原神名片清单，按照 Yatta.moe 网页陈列顺序排列。
public enum WeaponAsset: Int, CaseIterable {
    case DullBlade = 11101
    case SilverSword = 11201
    case CoolSteel = 11301
    case HarbingerOfDawn = 11302
    case TravelersHandySword = 11303
    case DarkIronSword = 11304
    case FilletBlade = 11305
    case SkyriderSword = 11306
    case FavoniusSword = 11401
    case TheFlute = 11402
    case SacrificialSword = 11403
    case RoyalLongsword = 11404
    case LionsRoar = 11405
    case PrototypeRancour = 11406
    case IronSting = 11407
    case BlackcliffLongsword = 11408
    case TheBlackSword = 11409
    case TheAlleyFlash = 11410
    case SwordOfDescension = 11412
    case FesteringDesire = 11413
    case AmenomaKageuchi = 11414
    case CinnabarSpindle = 11415
    case KagotsurubeIsshin = 11416
    case SapwoodBlade = 11417
    case XiphosMoonlight = 11418
    case ToukabouShigure = 11422
    case WolfFang = 11424
    case FinaleOfTheDeep = 11425
    case FleuveCendreFerryman = 11426
    case TheDockhandsAssistant = 11427
    case SwordOfNarzissenkreuz = 11428
    case SturdyBone = 11430
    case FluteOfEzpitzal = 11431
    case AquilaFavonia = 11501
    case SkywardBlade = 11502
    case FreedomSworn = 11503
    case SummitShaper = 11504
    case PrimordialJadeCutter = 11505
    case MistsplitterReforged = 11509
    case HaranGeppakuFutsu = 11510
    case KeyOfKhajNisut = 11511
    case LightOfFoliarIncision = 11512
    case SplendorOfStillWaters = 11513
    case UrakuMisugiri = 11514
    case Absolution = 11515
    case PeakPatrolSong = 11516
    case WasterGreatsword = 12101
    case OldMercsPal = 12201
    case FerrousShadow = 12301
    case BloodtaintedGreatsword = 12302
    case WhiteIronGreatsword = 12303
    case DebateClub = 12305
    case SkyriderGreatsword = 12306
    case FavoniusGreatsword = 12401
    case TheBell = 12402
    case SacrificialGreatsword = 12403
    case RoyalGreatsword = 12404
    case Rainslasher = 12405
    case PrototypeArchaic = 12406
    case Whiteblind = 12407
    case BlackcliffSlasher = 12408
    case SerpentSpine = 12409
    case LithicBlade = 12410
    case SnowTombedStarsilver = 12411
    case LuxuriousSeaLord = 12412
    case KatsuragikiriNagamasa = 12414
    case MakhairaAquamarine = 12415
    case Akuoumaru = 12416
    case ForestRegalia = 12417
    case MailedFlower = 12418
    case TalkingStick = 12424
    case TidalShadow = 12425
    case UltimateOverloardsMegaMagicSword = 12426
    case PortablePowerSaw = 12427
    case FruitfulHook = 12430
    case EarthShaker = 12431
    case SkywardPride = 12501
    case WolfsGravestone = 12502
    case SongOfBrokenPines = 12503
    case TheUnforged = 12504
    case RedhornStonethresher = 12510
    case BeaconOfTheReedSea = 12511
    case ConsideredJudgement = 12512
    case FangOfTheMountainKing = 12513
    case BeginnersProtector = 13101
    case IronPoint = 13201
    case WhiteTassel = 13301
    case Halberd = 13302
    case BlackTassel = 13303
    case DragonsBane = 13401
    case PrototypeStarglitter = 13402
    case CrescentPike = 13403
    case BlackcliffPole = 13404
    case Deathmatch = 13405
    case LithicSpear = 13406
    case FavoniusLance = 13407
    case RoyalSpear = 13408
    case DragonspineSpear = 13409
    case KitainCrossSpear = 13414
    case TheCatch = 13415
    case WavebreakersFin = 13416
    case Moonpiercer = 13417
    case MissiveWindspear = 13419
    case BalladOfTheFjords = 13424
    case RightfulReward = 13425
    case DialoguesOfTheDesertSages = 13426
    case ProspectorsDrill = 13427
    case MountainBracingBolt = 13430
    case FootprintOfTheRainbow = 13431
    case StaffOfHoma = 13501
    case SkywardSpine = 13502
    case VortexVanquisher = 13504
    case PrimordialJadeWingedSpear = 13505
    case CalamityQueller = 13507
    case EngulfingLightning = 13509
    case StaffOfTheScarletSands = 13511
    case CrimsonMoonSemblance = 13512
    case LumidouceElegy = 13513
    case ApprenticesNotes = 14101
    case PocketGrimoire = 14201
    case MagicGuide = 14301
    case ThrillingTalesOfDragonSlayers = 14302
    case OtherworldlyStory = 14303
    case EmeraldOrb = 14304
    case TwinNephrite = 14305
    case FavoniusCodex = 14401
    case TheWidsith = 14402
    case SacrificialFragments = 14403
    case RoyalGrimoire = 14404
    case SolarPearl = 14405
    case PrototypeAmber = 14406
    case MappaMare = 14407
    case BlackcliffAgate = 14408
    case EyeOfPerception = 14409
    case WineAndSong = 14410
    case Frostbearer = 14412
    case DodocoTales = 14413
    case HakushinRing = 14414
    case OathswornEye = 14415
    case WanderingEvenstar = 14416
    case FruitOfFulfillment = 14417
    case SacrificialJade = 14424
    case FlowingPurity = 14425
    case BalladOfTheBoundlessBlue = 14426
    case AshGravenDrinkingHorn = 14427
    case RingOfYaxche = 14431
    case SkywardAtlas = 14501
    case LostPrayerToTheSacredWinds = 14502
    case MemoryOfDust = 14504
    case JadefallsSplendor = 14505
    case EverlastingMoonglow = 14506
    case KagurasVerity = 14509
    case AThousandFloatingDreams = 14511
    case TulaytullahsRemembrance = 14512
    case CashflowSupervision = 14513
    case TomeOfTheEternalFlow = 14514
    case CranesEchoingCall = 14515
    case SurfsUp = 14516
    case HuntersBow = 15101
    case SeasonedHuntersBow = 15201
    case RavenBow = 15301
    case SharpshootersOath = 15302
    case RecurveBow = 15303
    case Slingshot = 15304
    case Messenger = 15305
    case FavoniusWarbow = 15401
    case TheStringless = 15402
    case SacrificialBow = 15403
    case RoyalBow = 15404
    case Rust = 15405
    case PrototypeCrescent = 15406
    case CompoundBow = 15407
    case BlackcliffWarbow = 15408
    case TheViridescentHunt = 15409
    case AlleyHunter = 15410
    case FadingTwilight = 15411
    case MitternachtsWaltz = 15412
    case WindblumeOde = 15413
    case Hamayumi = 15414
    case Predator = 15415
    case MouunsMoon = 15416
    case KingsSquire = 15417
    case EndOfTheLine = 15418
    case IbisPiercer = 15419
    case ScionOfTheBlazingSun = 15424
    case SongOfStillness = 15425
    case Cloudforged = 15426
    case RangeGauge = 15427
    case ChainBreaker = 15431
    case SkywardHarp = 15501
    case AmosBow = 15502
    case ElegyForTheEnd = 15503
    case PolarStar = 15507
    case AquaSimulacra = 15508
    case ThunderingPulse = 15509
    case HuntersPath = 15511
    case TheFirstGreatMagic = 15512
    case SilverShowerHeartStrings = 15513
}

extension WeaponAsset {
    public var enkaId: Int { rawValue }

    public var localizedKey: String { "$asset.weapon:" + String(describing: self) }

    public var localized: String { localizedKey.spmLocalized.localizedWithFix }
}

extension WeaponAsset {
    public var officialRawNameInEnglish: String {
        ("$asset.weapon:" + String(describing: self)).i18nSPM("en")
    }

    public var officialSimplifiedChineseName: String {
        ("$asset.weapon:" + String(describing: self)).i18n("zh-Hans")
    }
}

// MARK: DailyMaterialConsumer

extension WeaponAsset: DailyMaterialConsumer {
    public var dailyMaterial: DailyMaterialAsset? {
        switch self {
        case .DullBlade: .weaponDecarabian
        case .SilverSword: .weaponDecarabian
        case .CoolSteel: .weaponDecarabian
        case .HarbingerOfDawn: .weaponBorealWolf
        case .TravelersHandySword: .weaponGladiator
        case .DarkIronSword: .weaponGuyun
        case .FilletBlade: .weaponElixir
        case .SkyriderSword: .weaponAerosiderite
        case .FavoniusSword: .weaponDecarabian
        case .TheFlute: .weaponBorealWolf
        case .SacrificialSword: .weaponGladiator
        case .RoyalLongsword: .weaponDecarabian
        case .LionsRoar: .weaponGuyun
        case .PrototypeRancour: .weaponElixir
        case .IronSting: .weaponAerosiderite
        case .BlackcliffLongsword: .weaponGuyun
        case .TheBlackSword: .weaponBorealWolf
        case .TheAlleyFlash: .weaponDecarabian
        case .SwordOfDescension: .weaponBorealWolf
        case .FesteringDesire: .weaponGladiator
        case .AmenomaKageuchi: .weaponDistantSea
        case .CinnabarSpindle: .weaponDecarabian
        case .KagotsurubeIsshin: .weaponKijinMask
        case .SapwoodBlade: .weaponTalisman
        case .XiphosMoonlight: .weaponTalisman
        case .ToukabouShigure: .weaponNarukami
        case .WolfFang: .weaponDecarabian
        case .FinaleOfTheDeep: .weaponDewdrop
        case .FleuveCendreFerryman: .weaponAncientChord
        case .TheDockhandsAssistant: .weaponDewdrop
        case .SwordOfNarzissenkreuz: .weaponAncientChord
        case .SturdyBone: .weaponSacrificialHeart.available(since: .specify(day: 9, month: 10, year: 2024))
        case .FluteOfEzpitzal: .weaponSacrificialHeart
        case .AquilaFavonia: .weaponDecarabian
        case .SkywardBlade: .weaponBorealWolf
        case .FreedomSworn: .weaponGladiator
        case .SummitShaper: .weaponGuyun
        case .PrimordialJadeCutter: .weaponElixir
        case .MistsplitterReforged: .weaponDistantSea
        case .HaranGeppakuFutsu: .weaponNarukami
        case .KeyOfKhajNisut: .weaponTalisman
        case .LightOfFoliarIncision: .weaponTalisman
        case .SplendorOfStillWaters: .weaponDewdrop
        case .UrakuMisugiri: .weaponDistantSea
        case .Absolution: .weaponAncientChord
        case .PeakPatrolSong: .weaponNightWind.available(since: .specify(day: 9, month: 10, year: 2024))
        case .WasterGreatsword: .weaponBorealWolf
        case .OldMercsPal: .weaponBorealWolf
        case .FerrousShadow: .weaponDecarabian
        case .BloodtaintedGreatsword: .weaponBorealWolf
        case .WhiteIronGreatsword: .weaponGladiator
        case .DebateClub: .weaponElixir
        case .SkyriderGreatsword: .weaponAerosiderite
        case .FavoniusGreatsword: .weaponGladiator
        case .TheBell: .weaponDecarabian
        case .SacrificialGreatsword: .weaponBorealWolf
        case .RoyalGreatsword: .weaponGladiator
        case .Rainslasher: .weaponElixir
        case .PrototypeArchaic: .weaponAerosiderite
        case .Whiteblind: .weaponGuyun
        case .BlackcliffSlasher: .weaponElixir
        case .SerpentSpine: .weaponAerosiderite
        case .LithicBlade: .weaponGuyun
        case .SnowTombedStarsilver: .weaponDecarabian
        case .LuxuriousSeaLord: .weaponAerosiderite
        case .KatsuragikiriNagamasa: .weaponNarukami
        case .MakhairaAquamarine: .weaponScorchingMight
        case .Akuoumaru: .weaponDistantSea
        case .ForestRegalia: .weaponTalisman
        case .MailedFlower: .weaponGladiator
        case .TalkingStick: .weaponOasisGarden
        case .TidalShadow: .weaponPristineSea
        case .UltimateOverloardsMegaMagicSword: .weaponPristineSea
        case .PortablePowerSaw: .weaponPristineSea
        case .FruitfulHook: .weaponNightWind.available(since: .specify(day: 9, month: 10, year: 2024))
        case .EarthShaker: .weaponSacrificialHeart
        case .SkywardPride: .weaponBorealWolf
        case .WolfsGravestone: .weaponGladiator
        case .SongOfBrokenPines: .weaponDecarabian
        case .TheUnforged: .weaponElixir
        case .RedhornStonethresher: .weaponNarukami
        case .BeaconOfTheReedSea: .weaponScorchingMight
        case .ConsideredJudgement: .weaponAncientChord
        case .FangOfTheMountainKing: .weaponSacredLord
        case .BeginnersProtector: .weaponGladiator
        case .IronPoint: .weaponGladiator
        case .WhiteTassel: .weaponGuyun
        case .Halberd: .weaponElixir
        case .BlackTassel: .weaponAerosiderite
        case .DragonsBane: .weaponElixir
        case .PrototypeStarglitter: .weaponAerosiderite
        case .CrescentPike: .weaponGuyun
        case .BlackcliffPole: .weaponElixir
        case .Deathmatch: .weaponBorealWolf
        case .LithicSpear: .weaponAerosiderite
        case .FavoniusLance: .weaponGladiator
        case .RoyalSpear: .weaponElixir
        case .DragonspineSpear: .weaponBorealWolf
        case .KitainCrossSpear: .weaponKijinMask
        case .TheCatch: .weaponKijinMask
        case .WavebreakersFin: .weaponKijinMask
        case .Moonpiercer: .weaponOasisGarden
        case .MissiveWindspear: .weaponBorealWolf
        case .BalladOfTheFjords: .weaponPristineSea
        case .RightfulReward: .weaponPristineSea
        case .DialoguesOfTheDesertSages: .weaponTalisman
        case .ProspectorsDrill: .weaponAncientChord
        case .MountainBracingBolt: .weaponSacredLord.available(since: .specify(day: 9, month: 10, year: 2024))
        case .FootprintOfTheRainbow: .weaponSacredLord
        case .StaffOfHoma: .weaponAerosiderite
        case .SkywardSpine: .weaponGladiator
        case .VortexVanquisher: .weaponAerosiderite
        case .PrimordialJadeWingedSpear: .weaponGuyun
        case .CalamityQueller: .weaponElixir
        case .EngulfingLightning: .weaponKijinMask
        case .StaffOfTheScarletSands: .weaponOasisGarden
        case .CrimsonMoonSemblance: .weaponPristineSea
        case .LumidouceElegy: .weaponPristineSea
        case .ApprenticesNotes: .weaponDecarabian
        case .PocketGrimoire: .weaponDecarabian
        case .MagicGuide: .weaponDecarabian
        case .ThrillingTalesOfDragonSlayers: .weaponBorealWolf
        case .OtherworldlyStory: .weaponGladiator
        case .EmeraldOrb: .weaponGuyun
        case .TwinNephrite: .weaponElixir
        case .FavoniusCodex: .weaponDecarabian
        case .TheWidsith: .weaponBorealWolf
        case .SacrificialFragments: .weaponGladiator
        case .RoyalGrimoire: .weaponDecarabian
        case .SolarPearl: .weaponGuyun
        case .PrototypeAmber: .weaponElixir
        case .MappaMare: .weaponAerosiderite
        case .BlackcliffAgate: .weaponGuyun
        case .EyeOfPerception: .weaponElixir
        case .WineAndSong: .weaponBorealWolf
        case .Frostbearer: .weaponGladiator
        case .DodocoTales: .weaponBorealWolf
        case .HakushinRing: .weaponDistantSea
        case .OathswornEye: .weaponDistantSea
        case .WanderingEvenstar: .weaponOasisGarden
        case .FruitOfFulfillment: .weaponOasisGarden
        case .SacrificialJade: .weaponGuyun
        case .FlowingPurity: .weaponDewdrop
        case .BalladOfTheBoundlessBlue: .weaponBorealWolf
        case .AshGravenDrinkingHorn: .weaponNightWind
        case .RingOfYaxche: .weaponSacredLord
        case .SkywardAtlas: .weaponBorealWolf
        case .LostPrayerToTheSacredWinds: .weaponGladiator
        case .MemoryOfDust: .weaponAerosiderite
        case .JadefallsSplendor: .weaponGuyun
        case .EverlastingMoonglow: .weaponDistantSea
        case .KagurasVerity: .weaponKijinMask
        case .AThousandFloatingDreams: .weaponOasisGarden
        case .TulaytullahsRemembrance: .weaponScorchingMight
        case .CashflowSupervision: .weaponPristineSea
        case .TomeOfTheEternalFlow: .weaponDewdrop
        case .CranesEchoingCall: .weaponElixir
        case .SurfsUp: .weaponSacrificialHeart
        case .HuntersBow: .weaponBorealWolf
        case .SeasonedHuntersBow: .weaponBorealWolf
        case .RavenBow: .weaponDecarabian
        case .SharpshootersOath: .weaponBorealWolf
        case .RecurveBow: .weaponGladiator
        case .Slingshot: .weaponGuyun
        case .Messenger: .weaponElixir
        case .FavoniusWarbow: .weaponGladiator
        case .TheStringless: .weaponDecarabian
        case .SacrificialBow: .weaponBorealWolf
        case .RoyalBow: .weaponGladiator
        case .Rust: .weaponGuyun
        case .PrototypeCrescent: .weaponElixir
        case .CompoundBow: .weaponAerosiderite
        case .BlackcliffWarbow: .weaponGuyun
        case .TheViridescentHunt: .weaponDecarabian
        case .AlleyHunter: .weaponGladiator
        case .FadingTwilight: .weaponAerosiderite
        case .MitternachtsWaltz: .weaponDecarabian
        case .WindblumeOde: .weaponGladiator
        case .Hamayumi: .weaponNarukami
        case .Predator: .weaponNarukami
        case .MouunsMoon: .weaponNarukami
        case .KingsSquire: .weaponScorchingMight
        case .EndOfTheLine: .weaponScorchingMight
        case .IbisPiercer: .weaponTalisman
        case .ScionOfTheBlazingSun: .weaponScorchingMight
        case .SongOfStillness: .weaponAncientChord
        case .Cloudforged: .weaponAerosiderite
        case .RangeGauge: .weaponAncientChord
        case .ChainBreaker: .weaponNightWind
        case .SkywardHarp: .weaponBorealWolf
        case .AmosBow: .weaponGladiator
        case .ElegyForTheEnd: .weaponBorealWolf
        case .PolarStar: .weaponKijinMask
        case .AquaSimulacra: .weaponGuyun
        case .ThunderingPulse: .weaponNarukami
        case .HuntersPath: .weaponScorchingMight
        case .TheFirstGreatMagic: .weaponAncientChord
        case .SilverShowerHeartStrings: .weaponDewdrop
        }
    }
}

// MARK: Identifiable

extension WeaponAsset: Identifiable {
    public var fileName: String { "gi_weapon_\(id)" }
    public var id: Int { rawValue }
}
