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
- Dependencies/GachaMIMTServer/Sources/GachaMIMTServer/Resources/sb.lproj/Localizable.strings
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

### 角色更新

> 角色更新添加素材（下1、2）添加时间定义为开卡池前几日（官方公众号等会给出素材），而非版本更新日

1. 在`MaterialChoices`中添加角色素材、卡池配套武器相应内容

### 版本更新

> 不需要等正式版本更新就可以加入，但是不暴露出来

1. 角色两张证件照（请洽下文「证件照处理方法」）、技能图标、名片背景、角色名字的翻译

2. 武器（使用突破后图标）、武器素材

3. 新增的名片及其名字，在`BackgroundOptions`中添加相应内容（一般正式版发布后才有各语言翻译的名片名称，所以这个可以不急）

4. 圣遗物图标

5. 翻译

### 证件照处理方法

原始照片所在矩形是 256x256。拿到原始照片之后：

- 如果原始照片宽度不足 256 的话，则得手动将照片的鼻子与照片正中纵线对齐。

- 如果原始照片高度不足 256 的话，则贴「底」对齐、让躯干部分紧贴矩形底部。

做完这个处理之后，再用 AI 换算成 512x512。

> 目前的方法是用 Pixelmator Pro 的 AI Super Resolution 换算。**当然，要是有更好的技术的话，也可以用。**


$ EOF.