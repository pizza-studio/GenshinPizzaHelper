//
//  WeaponAssets.swift
//  GenshinPizzaHepler
//
//  Created by ShikiSuen on 2023/10/3.
//

import Foundation

// MARK: - WeaponAsset

/// 原神名片清单，按照 Ambr.top 网页陈列顺序排列。
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
    case SwordOfNarzissenkreuz = 11428 // 原神 4.2
    case AquilaFavonia = 11501
    case SkywardBlade = 11502
    case FreedomSworn = 11503
    case SummitShaper = 11504
    case PrimordialJadeCutter = 11505
    case MistsplitterReforged = 11509
    case HaranGeppakuFutsu = 11510
    case KeyOfKhajNisut = 11511
    case LightOfFoliarIncision = 11512
    case SplendorOfStillWaters = 11513 // 原神 4.2
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
    case PortablePowerSaw = 12427
    case SkywardPride = 12501
    case WolfsGravestone = 12502
    case SongOfBrokenPines = 12503
    case TheUnforged = 12504
    case RedhornStonethresher = 12510
    case BeaconOfTheReedSea = 12511
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
    case ProspectorsDrill = 13427
    case StaffOfHoma = 13501
    case SkywardSpine = 13502
    case VortexVanquisher = 13504
    case PrimordialJadeWingedSpear = 13505
    case CalamityQueller = 13507
    case EngulfingLightning = 13509
    case StaffOfTheScarletSands = 13511
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
    case RangeGauge = 15427
    case SkywardHarp = 15501
    case AmosBow = 15502
    case ElegyForTheEnd = 15503
    case PolarStar = 15507
    case AquaSimulacra = 15508
    case ThunderingPulse = 15509
    case HuntersPath = 15511
    case TheFirstGreatMagic = 15512
}

extension WeaponAsset {
    public var enkaId: Int { rawValue }

    public var localizedKey: String { "$asset.weapon:" + String(describing: self) }

    public var localized: String { localizedKey.localized.localizedWithFix }
}

extension WeaponAsset {
    public var filename: String { filenameNotAwaken + "_Awaken" }

    public var filenameNotAwaken: String {
        switch self {
        case .DullBlade: return "UI_EquipIcon_Sword_Blunt"
        case .SilverSword: return "UI_EquipIcon_Sword_Silver"
        case .CoolSteel: return "UI_EquipIcon_Sword_Steel"
        case .HarbingerOfDawn: return "UI_EquipIcon_Sword_Dawn"
        case .TravelersHandySword: return "UI_EquipIcon_Sword_Traveler"
        case .DarkIronSword: return "UI_EquipIcon_Sword_Darker"
        case .FilletBlade: return "UI_EquipIcon_Sword_Sashimi"
        case .SkyriderSword: return "UI_EquipIcon_Sword_Mitsurugi"
        case .FavoniusSword: return "UI_EquipIcon_Sword_Zephyrus"
        case .TheFlute: return "UI_EquipIcon_Sword_Troupe"
        case .SacrificialSword: return "UI_EquipIcon_Sword_Fossil"
        case .RoyalLongsword: return "UI_EquipIcon_Sword_Theocrat"
        case .LionsRoar: return "UI_EquipIcon_Sword_Rockkiller"
        case .PrototypeRancour: return "UI_EquipIcon_Sword_Proto"
        case .IronSting: return "UI_EquipIcon_Sword_Exotic"
        case .BlackcliffLongsword: return "UI_EquipIcon_Sword_Blackrock"
        case .TheBlackSword: return "UI_EquipIcon_Sword_Bloodstained"
        case .TheAlleyFlash: return "UI_EquipIcon_Sword_Outlaw"
        case .SwordOfDescension: return "UI_EquipIcon_Sword_Psalmus"
        case .FesteringDesire: return "UI_EquipIcon_Sword_Magnum"
        case .AmenomaKageuchi: return "UI_EquipIcon_Sword_Bakufu"
        case .CinnabarSpindle: return "UI_EquipIcon_Sword_Opus"
        case .KagotsurubeIsshin: return "UI_EquipIcon_Sword_Youtou"
        case .SapwoodBlade: return "UI_EquipIcon_Sword_Arakalari"
        case .XiphosMoonlight: return "UI_EquipIcon_Sword_Pleroma"
        case .ToukabouShigure: return "UI_EquipIcon_Sword_Kasabouzu"
        case .WolfFang: return "UI_EquipIcon_Sword_Boreas"
        case .FinaleOfTheDeep: return "UI_EquipIcon_Sword_Vorpal"
        case .FleuveCendreFerryman: return "UI_EquipIcon_Sword_Machination"
        case .TheDockhandsAssistant: return "UI_EquipIcon_Sword_Mechanic"
        case .SwordOfNarzissenkreuz: return "UI_EquipIcon_Sword_Purewill"
        case .AquilaFavonia: return "UI_EquipIcon_Sword_Falcon"
        case .SkywardBlade: return "UI_EquipIcon_Sword_Dvalin"
        case .FreedomSworn: return "UI_EquipIcon_Sword_Widsith"
        case .SummitShaper: return "UI_EquipIcon_Sword_Kunwu"
        case .PrimordialJadeCutter: return "UI_EquipIcon_Sword_Morax"
        case .MistsplitterReforged: return "UI_EquipIcon_Sword_Narukami"
        case .HaranGeppakuFutsu: return "UI_EquipIcon_Sword_Amenoma"
        case .KeyOfKhajNisut: return "UI_EquipIcon_Sword_Deshret"
        case .LightOfFoliarIncision: return "UI_EquipIcon_Sword_Ayus"
        case .SplendorOfStillWaters: return "UI_EquipIcon_Sword_Regalis"
        case .WasterGreatsword: return "UI_EquipIcon_Claymore_Aniki"
        case .OldMercsPal: return "UI_EquipIcon_Claymore_Oyaji"
        case .FerrousShadow: return "UI_EquipIcon_Claymore_Glaive"
        case .BloodtaintedGreatsword: return "UI_EquipIcon_Claymore_Siegfry"
        case .WhiteIronGreatsword: return "UI_EquipIcon_Claymore_Tin"
        case .DebateClub: return "UI_EquipIcon_Claymore_Reasoning"
        case .SkyriderGreatsword: return "UI_EquipIcon_Claymore_Mitsurugi"
        case .FavoniusGreatsword: return "UI_EquipIcon_Claymore_Zephyrus"
        case .TheBell: return "UI_EquipIcon_Claymore_Troupe"
        case .SacrificialGreatsword: return "UI_EquipIcon_Claymore_Fossil"
        case .RoyalGreatsword: return "UI_EquipIcon_Claymore_Theocrat"
        case .Rainslasher: return "UI_EquipIcon_Claymore_Perdue"
        case .PrototypeArchaic: return "UI_EquipIcon_Claymore_Proto"
        case .Whiteblind: return "UI_EquipIcon_Claymore_Exotic"
        case .BlackcliffSlasher: return "UI_EquipIcon_Claymore_Blackrock"
        case .SerpentSpine: return "UI_EquipIcon_Claymore_Kione"
        case .LithicBlade: return "UI_EquipIcon_Claymore_Lapis"
        case .SnowTombedStarsilver: return "UI_EquipIcon_Claymore_Dragonfell"
        case .LuxuriousSeaLord: return "UI_EquipIcon_Claymore_MillenniaTuna"
        case .KatsuragikiriNagamasa: return "UI_EquipIcon_Claymore_Bakufu"
        case .MakhairaAquamarine: return "UI_EquipIcon_Claymore_Pleroma"
        case .Akuoumaru: return "UI_EquipIcon_Claymore_Maria"
        case .ForestRegalia: return "UI_EquipIcon_Claymore_Arakalari"
        case .MailedFlower: return "UI_EquipIcon_Claymore_Fleurfair"
        case .TalkingStick: return "UI_EquipIcon_Claymore_BeastTamer"
        case .TidalShadow: return "UI_EquipIcon_Claymore_Vorpal"
        case .PortablePowerSaw: return "UI_EquipIcon_Claymore_Mechanic"
        case .SkywardPride: return "UI_EquipIcon_Claymore_Dvalin"
        case .WolfsGravestone: return "UI_EquipIcon_Claymore_Wolfmound"
        case .SongOfBrokenPines: return "UI_EquipIcon_Claymore_Widsith"
        case .TheUnforged: return "UI_EquipIcon_Claymore_Kunwu"
        case .RedhornStonethresher: return "UI_EquipIcon_Claymore_Itadorimaru"
        case .BeaconOfTheReedSea: return "UI_EquipIcon_Claymore_Deshret"
        case .BeginnersProtector: return "UI_EquipIcon_Pole_Gewalt"
        case .IronPoint: return "UI_EquipIcon_Pole_Rod"
        case .WhiteTassel: return "UI_EquipIcon_Pole_Ruby"
        case .Halberd: return "UI_EquipIcon_Pole_Halberd"
        case .BlackTassel: return "UI_EquipIcon_Pole_Noire"
        case .DragonsBane: return "UI_EquipIcon_Pole_Stardust"
        case .PrototypeStarglitter: return "UI_EquipIcon_Pole_Proto"
        case .CrescentPike: return "UI_EquipIcon_Pole_Exotic"
        case .BlackcliffPole: return "UI_EquipIcon_Pole_Blackrock"
        case .Deathmatch: return "UI_EquipIcon_Pole_Gladiator"
        case .LithicSpear: return "UI_EquipIcon_Pole_Lapis"
        case .FavoniusLance: return "UI_EquipIcon_Pole_Zephyrus"
        case .RoyalSpear: return "UI_EquipIcon_Pole_Theocrat"
        case .DragonspineSpear: return "UI_EquipIcon_Pole_Everfrost"
        case .KitainCrossSpear: return "UI_EquipIcon_Pole_Bakufu"
        case .TheCatch: return "UI_EquipIcon_Pole_Mori"
        case .WavebreakersFin: return "UI_EquipIcon_Pole_Maria"
        case .Moonpiercer: return "UI_EquipIcon_Pole_Arakalari"
        case .MissiveWindspear: return "UI_EquipIcon_Pole_Windvane"
        case .BalladOfTheFjords: return "UI_EquipIcon_Pole_Shanty"
        case .RightfulReward: return "UI_EquipIcon_Pole_Vorpal"
        case .ProspectorsDrill: return "UI_EquipIcon_Pole_Mechanic"
        case .StaffOfHoma: return "UI_EquipIcon_Pole_Homa"
        case .SkywardSpine: return "UI_EquipIcon_Pole_Dvalin"
        case .VortexVanquisher: return "UI_EquipIcon_Pole_Kunwu"
        case .PrimordialJadeWingedSpear: return "UI_EquipIcon_Pole_Morax"
        case .CalamityQueller: return "UI_EquipIcon_Pole_Santika"
        case .EngulfingLightning: return "UI_EquipIcon_Pole_Narukami"
        case .StaffOfTheScarletSands: return "UI_EquipIcon_Pole_Deshret"
        case .ApprenticesNotes: return "UI_EquipIcon_Catalyst_Apprentice"
        case .PocketGrimoire: return "UI_EquipIcon_Catalyst_Pocket"
        case .MagicGuide: return "UI_EquipIcon_Catalyst_Intro"
        case .ThrillingTalesOfDragonSlayers: return "UI_EquipIcon_Catalyst_Pulpfic"
        case .OtherworldlyStory: return "UI_EquipIcon_Catalyst_Lightnov"
        case .EmeraldOrb: return "UI_EquipIcon_Catalyst_Jade"
        case .TwinNephrite: return "UI_EquipIcon_Catalyst_Phoney"
        case .FavoniusCodex: return "UI_EquipIcon_Catalyst_Zephyrus"
        case .TheWidsith: return "UI_EquipIcon_Catalyst_Troupe"
        case .SacrificialFragments: return "UI_EquipIcon_Catalyst_Fossil"
        case .RoyalGrimoire: return "UI_EquipIcon_Catalyst_Theocrat"
        case .SolarPearl: return "UI_EquipIcon_Catalyst_Resurrection"
        case .PrototypeAmber: return "UI_EquipIcon_Catalyst_Proto"
        case .MappaMare: return "UI_EquipIcon_Catalyst_Exotic"
        case .BlackcliffAgate: return "UI_EquipIcon_Catalyst_Blackrock"
        case .EyeOfPerception: return "UI_EquipIcon_Catalyst_Truelens"
        case .WineAndSong: return "UI_EquipIcon_Catalyst_Outlaw"
        case .Frostbearer: return "UI_EquipIcon_Catalyst_Everfrost"
        case .DodocoTales: return "UI_EquipIcon_Catalyst_Ludiharpastum"
        case .HakushinRing: return "UI_EquipIcon_Catalyst_Bakufu"
        case .OathswornEye: return "UI_EquipIcon_Catalyst_Jyanome"
        case .WanderingEvenstar: return "UI_EquipIcon_Catalyst_Pleroma"
        case .FruitOfFulfillment: return "UI_EquipIcon_Catalyst_Arakalari"
        case .SacrificialJade: return "UI_EquipIcon_Catalyst_Yue"
        case .FlowingPurity: return "UI_EquipIcon_Catalyst_Vorpal"
        case .BalladOfTheBoundlessBlue: return "UI_EquipIcon_Catalyst_DandelionPoem"
        case .SkywardAtlas: return "UI_EquipIcon_Catalyst_Dvalin"
        case .LostPrayerToTheSacredWinds: return "UI_EquipIcon_Catalyst_Fourwinds"
        case .MemoryOfDust: return "UI_EquipIcon_Catalyst_Kunwu"
        case .JadefallsSplendor: return "UI_EquipIcon_Catalyst_Morax"
        case .EverlastingMoonglow: return "UI_EquipIcon_Catalyst_Kaleido"
        case .KagurasVerity: return "UI_EquipIcon_Catalyst_Narukami"
        case .AThousandFloatingDreams: return "UI_EquipIcon_Catalyst_Ayus"
        case .TulaytullahsRemembrance: return "UI_EquipIcon_Catalyst_Alaya"
        case .CashflowSupervision: return "UI_EquipIcon_Catalyst_Wheatley"
        case .TomeOfTheEternalFlow: return "UI_EquipIcon_Catalyst_Iudex"
        case .HuntersBow: return "UI_EquipIcon_Bow_Hunters"
        case .SeasonedHuntersBow: return "UI_EquipIcon_Bow_Old"
        case .RavenBow: return "UI_EquipIcon_Bow_Crowfeather"
        case .SharpshootersOath: return "UI_EquipIcon_Bow_Arjuna"
        case .RecurveBow: return "UI_EquipIcon_Bow_Curve"
        case .Slingshot: return "UI_EquipIcon_Bow_Sling"
        case .Messenger: return "UI_EquipIcon_Bow_Msg"
        case .FavoniusWarbow: return "UI_EquipIcon_Bow_Zephyrus"
        case .TheStringless: return "UI_EquipIcon_Bow_Troupe"
        case .SacrificialBow: return "UI_EquipIcon_Bow_Fossil"
        case .RoyalBow: return "UI_EquipIcon_Bow_Theocrat"
        case .Rust: return "UI_EquipIcon_Bow_Recluse"
        case .PrototypeCrescent: return "UI_EquipIcon_Bow_Proto"
        case .CompoundBow: return "UI_EquipIcon_Bow_Exotic"
        case .BlackcliffWarbow: return "UI_EquipIcon_Bow_Blackrock"
        case .TheViridescentHunt: return "UI_EquipIcon_Bow_Viridescent"
        case .AlleyHunter: return "UI_EquipIcon_Bow_Outlaw"
        case .FadingTwilight: return "UI_EquipIcon_Bow_Fallensun"
        case .MitternachtsWaltz: return "UI_EquipIcon_Bow_Nachtblind"
        case .WindblumeOde: return "UI_EquipIcon_Bow_Fleurfair"
        case .Hamayumi: return "UI_EquipIcon_Bow_Bakufu"
        case .Predator: return "UI_EquipIcon_Bow_Predator"
        case .MouunsMoon: return "UI_EquipIcon_Bow_Maria"
        case .KingsSquire: return "UI_EquipIcon_Bow_Arakalari"
        case .EndOfTheLine: return "UI_EquipIcon_Bow_Fin"
        case .IbisPiercer: return "UI_EquipIcon_Bow_Ibis"
        case .ScionOfTheBlazingSun: return "UI_EquipIcon_Bow_Gurabad"
        case .SongOfStillness: return "UI_EquipIcon_Bow_Vorpal"
        case .RangeGauge: return "UI_EquipIcon_Bow_Mechanic"
        case .SkywardHarp: return "UI_EquipIcon_Bow_Dvalin"
        case .AmosBow: return "UI_EquipIcon_Bow_Amos"
        case .ElegyForTheEnd: return "UI_EquipIcon_Bow_Widsith"
        case .PolarStar: return "UI_EquipIcon_Bow_Worldbane"
        case .AquaSimulacra: return "UI_EquipIcon_Bow_Kirin"
        case .ThunderingPulse: return "UI_EquipIcon_Bow_Narukami"
        case .HuntersPath: return "UI_EquipIcon_Bow_Ayus"
        case .TheFirstGreatMagic: return "UI_EquipIcon_Bow_Pledge"
        }
    }
}
