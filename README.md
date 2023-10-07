# 原神披萨小助手

## 开发规范

- 报联商：报告、联络、商谈。

- **鉴于各位对 SwiftUI 以及 Combine Concurrency 的开发经验可能不多，为了提高程序代码品质，保证程序水准，各位可以参考这一份[Swift / SwiftUI开发代码规范](https://github.com/Bill-Haku/wiki/wiki/SwiftUI-Coding-Standards )**。但这份规范当中对格式的规范的效力权重低于 `make lint; make format` 这两道命令处理之后的效果。

- 请注意尽量重复利用代码，这也是为编译器减负。该 extract 的 method，就 extract 出来，这尤其可以防止 SwiftUI 代码编译时的便秘故障。

- 其他例如Android开发等也有许多相似的经验和习惯，可以参考。

### 其他的一些注意事项

- 请在每一个文件的头部自动生成的注释的最后一行补充说明该文件内的代码的主要内容和目的，以便其他开发者了解阅读。

- Xcode左侧各文件夹内的文件已经按照字典序排列，在新添加文件时，请保持该顺序。

- 有关注释的使用等，再次不再赘述。可以参考前面提到的代码规范和其他业内习惯。

## Git使用说明

- **本仓库dev分支包含最新的已完成内容，main分支包含最新的已发布内容。dev分支原则上不允许直接Push commit进入；main分支不允许直接Push commit进入。应当使用提出PR的方式合并入dev，再合并入main.** 

- 使用Git时，遵循多Commit，多Branch，多PR的原则。

- PR原则上需要完成Code Review后才能合并。一般不由自己合并。合并的PR原则上应当在远端删除源分支。PR的comment中最好一并关闭相关的已解决的issue.

- 关于Commit和其他的命名和使用规范可以参考[这篇博客](https://jaeger.itscoder.com/dev/2018/09/12/using-git-in-project.html)。

- 每个 PR 在最终合并之前必须 `make lint; make format`，除非已经有这样处理过、或者该 PR 没有修改过任何 Swift 档案、或者该 PR 的所有 commit 均已经这样处理过了。为了正确执行这两道命令，你需要事先安装「Makefile」「[NickLockwood/SwiftFormat](https://github.com/nicklockwood/SwiftFormat)」以及「[Realm/SwiftLint](https://github.com/realm/SwiftLint)」这三款终端工具。

## 关于项目的若干说明

### 版本号

目标版本号由开发组讨论决定。本Project包含3个target，应确保3个target的版本号和构建版本号相同。

### 构建版本号

一般来讲构建版本号应当每一次构建则自动+1，但是Xcode的自动+1的脚本会导致允许莫名其妙取消掉的bug，本项目中构建版本号改为到修改版本号后主分支所有commit的次数。一般来说会在合并到dev分支后再来单独更新构建版本号。

### Tag

在主要的功能完成时可以在最后合并的commit上打上tag. 将要发布测试版和正式版时必须打上Tag标记。Tag的格式为: `v<Version>-<Suffix (Optional)>-<Build>`, 例如:

`v2.0.0-Beta.1-258`: 2.0.0的第1个Beta版，build号为258

`v2.0.0-RC.2-308`: 2.0.0版本的第2个RC版(Release Candidate)，build号为308

`v2.0.0-309`: 2.0.0版本正式版，build号为309

使用Beta版标记或RC版标记提交TF测试的版本。使用RC版标记提交正式版审核的版本。提交正式版审核和TF测试的的版本时Tag中均不包含正式版本的tag。仅当正式版审核通过发布后再在对应的RC版上补上正式版的Tag.

关于版本号的更多标准，请参考这篇[规范](https://semver.org)。

## 关于国际化的若干说明

国际化主要翻译的内容为若干个`*.strings`文件。目前的国际化基于2.0版本的所有需要翻译的条目。

在开发过程中，除非是关键部分的UI测试，原则上不翻译只添加字符串。国际化工作在新版本发布前最后完成。

### 国际化对照表文件说明

- 国际化对照表的基本格式为`"<Original Text>" = "<Localized Text>";`.

- 应当注意分段和使用注释：注释的内容为代码相关的页面或所属的类型。

- 应当保证各语言的对照表文件除了翻译的内容外完全相同。最主要的是行数。应当保证各语言的行数完全一致，避免出现不同语言的漏译。为了便于检查，请保持空行和注释的位置和数量完全一致。

- 对于每个版本的新增的国际化内容，在文件末尾单独添加。使用注释声明接下来的内容的添加时的版本，然后按照第2点所述添加内容。示例如下：

    ``` swift
    // MARK: - 2.0 & above
    // View A
    "" = "";
    // ...
    // View B
    "" = "";
    // 2.0 Contents...
    
    // MARK: - 2.1
    // View A
    "" = "";
    // 2.1 Contents...
    
    // MARK: - 2.2
    // View C
    "" = "";
    // 2.2 Contents...
    ```
    

### 国际化工作流程介绍

1. 开发过程中，不添加国际化相关内容。

2. 版本全部开发结束后，切换测试语言为English，将新增的页面和修改的页面的内容添加到`Localizable(English).strings`文件中，然后复制到其他语言的国际化文件中。

3. 在`Localizable(English).strings`文件中完成英语内容的翻译。

4. 运行测试，检查翻译是否生效。如果是需要项目代码需要做国际化适配，则修改项目代码。如果是国际化对照表出现遗漏或错误，则修改国际化对照表文件。

5. 第4步检查无误后，完成其他语言的国际化翻译对照文件翻译。

6. 全部完成后，切换到对应的语言运行，检查翻译是否生效。（此时理论上不会有问题。）检查翻译内容是否有需要优化改进的地方。

### 新增语言时需要新增的档案

假设该语言的略写为「sb」。在发包给第三方翻译者之前，需要准备的档案至少如下：

- AccountIntent/sb.lproj/AccountIntents.strings
- GenshinPizzaHepler/sb.lproj/InfoPlist.strings
- GenshinPizzaHepler/sb.lproj/Localizable.strings
- Settings.bundle/sb.lproj/Settings.strings

## 开源工作备忘录

### 开源工作流程

1. 复制一遍源代码文件夹，删除.git和readme文件

2. 打开 WatchHelper WatchKit Extension/View/ContentView.swift 文件，删除cookie

3. 打开 `./CommonTools/AppConfig` - 修改`homeAPISalt`为「Opensource Secret」

4. 将所有文件移动覆盖到开源仓库文件夹

## 原神版本更新TODO LIST

> 请务必注意不能上传官方未发布的素材
> 
> 全部使用heic格式，压缩为「小」

### 版本更新

- 角色更新以米游社官方「天外卫星通信」为基准。比如说：4.1 版正式发布的时候，官方就借由天外卫星通信发布了关于 4.2 版的新角色「[芙宁娜](https://www.miyoushe.com/ys/article/43753949)」与「[夏洛蒂](https://www.miyoushe.com/ys/article/43754059)」的情报。**此时可以添加角色素材，但不能添加角色每日素材情报、不能添加名片、不能添加武器（直至官方微信公众号等给出素材为止）。**
    - **如果已经添加这些内容的话，需要做一些处理、使其在 App 当中不显示。**
        - 名片的话，将要屏蔽的名片放到 `Namecard.blacklist` 当中。
        - 新角色的每日素材：`CharacterAsset.dailyMaterial` 当中将对应的内容设为 nil。
        - 新武器的每日素材：`WeaponAsset.dailyMaterial` 当中将对应的内容设为 nil。
        - 新武器：添加了也无妨，只要每日素材填 nil 就行、直到官方正式公布。这样就可以防止新武器提前在 App 内显示出来。
- 新情报与新图片素材优先从 Ambr.Top 获取。SnapGenshin 也可以。

#### 1. 年度大版本更新的情况。

这一部分主要是指武器突破素材与角色天赋素材，也是用 Enum 管理的。相关说明等回头再更新。

#### 2. 每四十五天左右的小版本原神游戏更新的情况。

##### 1. 名片。

- 名片更新的时机在新版本发布前几天，官方会借由微信公众号等社群媒体途径公式相关内容。
- 注意：名片档案的名称无法推断，请以 Ambr.Top 下载来的原始素材档案名称为准（以 `_P` 结尾）。
- 名片素材请放到 `Assets -> bgNamecards` 内。
    - 名片素材尺寸为 **840x400**，如果过大的话则请调整缩放。
    - **素材格式一律 HEIC**。
- 名片一律在 NameCard 这个 enum 内登记：
    - case 名称填写名片的图片档案名称，以 `_P` 结尾；
    - RawValue 填写名片的 Enka ID。
- 如果提前加入了名片，则请注意不要比官方更提前地公开名片。此时请善用 `Namecard.blacklist`。
- 名片名称翻译 Key："$asset.nameCard:\(名片的图片档案名称)"。例：`"$asset.nameCard:UI_NameCardPic_0_P"`。

##### 2. 角色

1. 全专案搜寻 `enum CharacterAsset` ，找到这个 Enum 之后、在末端添入 `case Tadokoro = 10114514` 这种格式的新角色情报。数字对应该角色的 Enka Character ID。
2. 之后 Xcode 会报错、引导你填写一些其他内容：
    1. `CharacterAsset.frontPhotoFileName` 变数需要你填入新角色的正面肖像（证件照）的档案名称。该肖像档案放置在 `Assets-NoWatch` 当中的对应目录内即可。Ambr.Top 也好、Snap Genshin 也好，原始素材必须得是正方形、而不是 HoneyHunterWorld 那种擅自去掉空白边的东西（否则会在 App 内产生对齐故障）。拿到原始素材 256x256 之后，请用 Waifu2x 等 AI 手段放大至 512x512（可保证 iPad Pro 高清显示）、再存为 HEIC。详情请洽下文「证件照处理方法」。
    2. `CharacterAsset.namecard` 变数需要你填入新角色的名片。这里按照真实情况填写即可。
    3. `CharacterAsset.possibleProfilePictureIdentifiers` 用来填写每个角色对应的 profilePicture 编号。每个角色可能拥有多个编号。请依照 [ProfilePictureExcelConfigData.json](https://gitlab.com/Dimbreath/AnimeGameData/-/blob/master/ExcelBinOutput/ProfilePictureExcelConfigData.json) 的内容查询到新角色对应的 profilePicture 编号（不超过五位数）。
    4. `CharacterAsset.dailyMaterial` 指定其每日材料之种类。不想泄密的内容一律填 nil。
3. 角色名称翻译 Key："$asset.character:\(case 名称)"。例：`"$$asset.character:Keqing"`。

##### 3. 武器

1. 全专案搜寻 `enum WeaponAsset` ，找到这个 Enum 之后、在末端添入 `case Tsurugi = 10001` 这种格式的新角色情报。数字对应该武器的 Enka Character ID。
2. 之后 Xcode 会报错、引导你填写一些其他内容：
    1. `WeaponAsset.fileNameNotAwaken` 变数需要你填入「尚未觉醒的武器档案名称」。
        1. 对应的素材则为觉醒过的武器图片，放置在 `Assets-NoWatch` 当中的对应目录即可。Ambr.Top 也好、Snap Genshin 也好，原始素材必须得是正方形、而不是 HoneyHunterWorld 那种擅自去掉空白边的东西（否则会在 App 内产生对齐故障）。拿到原始素材 256x256 之后，请转换格式至 HEIC。
    2. `WeaponAsset.dailyMaterial` 指定其每日材料之种类。不想泄密的内容一律填 nil。
3. 武器名称翻译 Key："$asset.weapon:\(case 名称)"。例：`"$asset.weapon:DullBlade"`。

##### 4. 其他内容

1. 圣遗物图标。该内容今后也会用 Asset 管理。

### 证件照处理方法

原始照片所在矩形是 256x256。拿到原始照片之后直接用 Waifu2x 换算成 512x512。

⚠️注意：如果导入素材时暂时没有手段使用 Waifu2x 等 AI 放大手段的话，可以直接上传原始 256x256 档案，但必须开 issue 备忘。

请一定从 SnapGenshin 或 Ambr.Top 获取照片，因为这些照片的图像尺寸是正方形、不会造成排版上的故障。

$ EOF.
