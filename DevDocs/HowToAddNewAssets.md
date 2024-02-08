### 版本更新

> 注意：从原神 v4.3 版正式对外开放起，原神披萨助手的研发仓库也开源、曝露给公众。因此，原则上来讲：
> 1. 新版本的角色肖像不适合在各个角色的「天外卫星通信」官方文章刊出之前上传。
> 2. 除此类型之外的新版本素材（包括角色的名片）不适合在版本前瞻特别节目之前上传。其中：名片可以用自制假素材代替、方便相关的程序功能提前实作。
> 本段内容的解释优先权凌驾于下文所述的内容之上。

- 角色更新以米游社官方「天外卫星通信」为基准。比如说：4.1 版正式发布的时候，官方就借由天外卫星通信发布了关于 4.2 版的新角色「[芙宁娜](https://www.miyoushe.com/ys/article/43753949)」与「[夏洛蒂](https://www.miyoushe.com/ys/article/43754059)」的情报。**此时可以添加角色素材，但不能添加角色每日素材情报、不能添加名片、不能添加武器（直至官方微信公众号等给出素材为止）。**
    - **如果已经添加这些内容的话，需要做一些处理、使其在 App 当中不显示。**
        - 名片的话，将要屏蔽的名片放到 `Namecard.blacklist` 当中。
        - 新角色的每日素材：`CharacterAsset.dailyMaterial` 当中将对应的内容设为 nil。
        - 新武器的每日素材：`WeaponAsset.dailyMaterial` 当中将对应的内容设为 nil。
        - 新武器：添加了也无妨，只要每日素材填 nil 就行、直到官方正式公布。这样就可以防止新武器提前在 App 内显示出来。
- 新情报与新图片素材的**正式服版本**优先从 Ambr.Top 获取。
    - 从 2024 年 2 月 8 日起，任何针对原神新版本做的提前适配**均得使用自制 PS 素材、直至该版本正式开服才可以换上官方素材**。
    - 角色证件照片的前期替代版本可由米游社官方「天外卫星通信」文章当中的插图剪裁制作。
- 虽然现在已经有了 Enka 资料的本地寄存机制，但也请勿忘更新 `gi.pizzastudio.org` 伺服器当中的各种 JSON 档案。
    - 也得更新 GIPizzaKit 这个 Swift Package 内部的 Assets 资料夹下的已经存在的 JSON 档案。这些档案是垫底档案、用来在下载的 JSON 出现损毁时就地救援。
- 本文提到的所有 Asset Enum 及其本地化翻译资料都位于 GIPizzaKit 这个 Swift Package 内。
    - 然而，这个 Package 并不管理图片 Asset 素材档案本身。

#### 1. 年度大版本更新的情况。

这一部分主要是指武器突破素材与角色天赋素材，也是用 Enum 半自动管理的。相关说明等回头再更新。

此外，还有新的神瞳。

#### 2. 每四十五天左右的小版本原神游戏更新的情况。

##### 1. 名片。

- 名片更新的时机在新版本发布前几天，官方会借由微信公众号等社群媒体途径公式相关内容。
- 注意：名片档案的名称无法推断，请以 Ambr.Top 下载来的原始素材档案名称为准（以 `_P` 结尾）。
- 名片素材请放到 `Assets -> bgNamecards` 内。
    - 名片素材尺寸必须是 **420x200 **，否则 ActivityKit View 会拒绝载入之。
    - **素材格式一律 JPEG**，否则 ActivityKit View 会崩溃（至少 HEIC 一定会崩）。
- 名片一律在 NameCard 这个 enum 内登记：
    - case 名称填写名片的图片档案名称，以 `_P` 结尾；
    - RawValue 填写名片的 Enka ID。
- 如果提前加入了名片，则请注意不要比官方更提前地公开名片。此时请善用 `Namecard.blacklist`。以白术为例、责令其在所属版本开放之前的那个纪行的结束日起再加两天再开放：
    ```
    public static var blacklist: [NameCard] {
        [
            .UI_NameCardPic_Baizhuer_P.release(since: .Specify(day: 11, month: 4, year: 2023)),
        ].compactMap { $0 }
    }
    ```
- 名片名称翻译 Key："$asset.nameCard:\(名片的图片档案名称)"。例：`"$asset.nameCard:UI_NameCardPic_0_P"`。

##### 2. 角色

1. 全专案搜寻 `enum CharacterAsset` ，找到这个 Enum 之后、在末端添入 `case Tadokoro = 10114514` 这种格式的新角色情报。数字对应该角色的 Enka Character ID。
2. 之后 Xcode 会报错、引导你填写一些其他内容：
    1. `CharacterAsset.frontPhotoFileName` 变数需要你填入新角色的正面肖像（证件照）的档案名称。该肖像档案放置在 `Assets-NoWatch` 当中的对应目录内即可。Ambr.Top 也好、Snap Genshin 也好，原始素材必须得是正方形、而不是 HoneyHunterWorld 那种擅自去掉空白边的东西（否则会在 App 内产生对齐故障）。拿到原始素材 256x256 之后，请用 Waifu2x 等 AI 手段放大至 512x512（可保证 iPad Pro 高清显示）、再存为 HEIC。详情请洽下文「证件照处理方法」。
    2. `CharacterAsset.namecard` 变数需要你填入新角色的名片。这里按照真实情况填写即可。
    3. `CharacterAsset.possibleProfilePictureIdentifiers` 用来填写每个角色对应的 profilePicture 编号。每个角色可能拥有多个编号。请依照 [ProfilePictureExcelConfigData.json](https://gitlab.com/Dimbreath/AnimeGameData/-/blob/master/ExcelBinOutput/ProfilePictureExcelConfigData.json) 的内容查询到新角色对应的 profilePicture 编号（不超过五位数）。
3. `CharacterAsset.dailyMaterial` 指定其每日材料之种类。不想泄密的内容一律填 nil、或者用 `.available(since:.Specify(day:month:year:))` 限时封印： 
    ```
    case .Baizhu:
      return .talentGold.available(since: .Specify(day: 11, month: 4, year: 2023))
    ```
4. 角色名称翻译 Key："$asset.character:\(case 名称)"。例：`"$asset.character:Keqing"`。
5. 角色的技能图示：直接从 Ambr.top 将技能图示 png 自浏览器拖到本地，然后转成 HEIC。

##### 3. 武器

1. 全专案搜寻 `enum WeaponAsset` ，找到这个 Enum 之后、在末端添入 `case Tsurugi = 10001` 这种格式的新角色情报。数字对应该武器的 Enka Character ID。
2. 之后 Xcode 会报错、引导你填写一些其他内容：
    1. `WeaponAsset.fileNameNotAwaken` 变数需要你填入「尚未觉醒的武器档案名称」。
        1. 对应的素材则为觉醒过的武器图片，放置在 `Assets-NoWatch` 当中的对应目录即可。Ambr.Top 也好、Snap Genshin 也好，原始素材必须得是正方形、而不是 HoneyHunterWorld 那种擅自去掉空白边的东西（否则会在 App 内产生对齐故障）。拿到原始素材 256x256 之后，请转换格式至 HEIC。
    2. `WeaponAsset.dailyMaterial` 指定其每日材料之种类。不想泄密的内容一律填 nil、或者用 `.available(since:.Specify(day:month:year:))` 限时封印： 
    ```
    case .JadefallsSplendor: 
      return .weaponGuyun.available(since: .Specify(day: 11, month: 4, year: 2023))
    ```
3. 武器名称翻译 Key："$asset.weapon:\(case 名称)"。例：`"$asset.weapon:DullBlade"`。

##### 4. 其他内容

1. 圣遗物图标。该内容今后也会用 Asset 管理。

### 证件照处理方法

原始照片所在矩形是 256x256。拿到原始照片之后**直接用 Waifu2x 换算成 512x512**（有更优秀的算法的话也可以）。

> 为什么要这样处理呢？这是为了保证在最高清的 iPad Pro 大尺寸机种上「没有模糊感」。

⚠️注意：如果导入素材时暂时没有手段使用 Waifu2x 等 AI 放大手段的话，可以直接上传原始 256x256 档案，但必须开 issue 备忘。

请一定从 SnapGenshin 或 Ambr.Top 获取照片，因为这些照片的图像尺寸是正方形、不会造成排版上的故障。**当且仅当您怎样知道编辑 HoneyHunterWorld 的素材、使之不会出现跑版的问题的时候，HoneyHunterWorld 的素材可以临时一用。**

$ EOF.
