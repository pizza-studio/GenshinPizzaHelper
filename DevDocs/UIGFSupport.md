# 关于原神披萨小助手的 UIGF 格式支持

截至原披助手 v4.2.4 版为止，原披助手一直仅支持 UIGF v2.2 标准。虽然看似有尝试支持过 UIGF  的 v2.3 与 v3.0 标准（后者倒是成功了，因为仅涉及集录祈愿），但是**在原披助手 v4.2.4 为止**一直没被正确处理或完整支持过的内容如下：

- **UIGF v2.3 要求的 `item_id` 从未被正确处理过**，一直以为抓到的原始 itemID 是可以用的。其实抓到的都是空字串。
- **UIGF v2.3 - v3.x 要求的 `lang` 特性一直没被完整支持过**，一直都只能导出简体中文、只用简体中文来保存抓到的抽卡记录资料。
    - 这其实是个塞翁失马焉知非福的事情，极大地简化了 `item_id` 的复原工作手续。
- **UIGF v2.4 要求的 `region_time_zone` 时区特性一直没被支持过**。虽然原则上来讲可以用 UID 倒推伺服器时区，但可能有其他 App 允许用户以除此之外的时区来导出 UIGF 资料格式、影响每一笔资料的时间呈现……所以 UIGF 委员会目前对这个字段有严格的实作要求。

在继续下文之前，先定义一下本文的术语。

- **抽卡物品（GachaItem）**：抽卡（祈愿、跃迁）抽到的武器或角色。
- **GIGF 格式**：Genshin Interchangable Gacha Format，特指 UIGF v3.x 及更旧版的 UIGF 格式，因为这些格式仅支持对原神的抽卡资料的处理。UIGF 委员会目前尚未使用 GIGF 这个称呼。

作为对穹披助手那一侧的 UIGF v4 标准的支持的实作成果的承袭延续，原神披萨助手从内部版本 v4.2.5 开始（公开发布的 App 版本号定为 v4.3.0）对整个 App 的 UIGF 支持做了大翻修：

- 引入了订制的 GachaMetaDB 专门用来根据给定的抽卡物品（武器或角色）的已翻译名称（包括简体中文）反向查询其正确的 `item_id`。
- App 内部所有涉及 UIGF 的 JSON 处理均以 UIGF v4 为基准。特别地：App 允许用户继续导入 GIGF 格式的 JSON 抽卡记录，但 App 有下述 JSON 处理套路：
    - GIGF JSON 的内容会在导入的时候被自动转换为 UIGF v4、再走 UIGF v4 资料的导入流程。
    - GIGF JSON 的内容在被解码的那一刻，会自动尝试修复自身的任何无效的 ItemID。
- App 内部涉及 GIGF 的 Excel 试算簿处理时的套路：
    - 因为 Excel 格式的 GIGF 最高版本仅到 v2.2，所以 App 会在语言侦测失败时**默认每一笔资料都是简体中文写的**。
    - App 会根据表格中不同的 UID 与不同的 `lang` 将所有的资料行拆分成好几套 GIGF JSON Profile，然后修复他们内部的物品当中的任何无效的 ItemID，再全部升级转换到 UIGF v4 Profile，再统一更新语言为简体中文，再按照 UID 的不同来融合成尽可能少的 UIGF v4 Profile，最后组装成 UIGF v4 档案来读入。
        - 这个过程可能会因为原始资料的任何乱填而中断。**这个中断机制可以有效地防止用户将垃圾资料读入 App 来污染 App 自身的 CoreData 资料库**。
    - GIGF v2 对 `id` 栏位有硬性要求，请勿乱填。
    - GIGF v2 所有的时区都是伺服器时区，可以用 UID 逆向推算得出。

以上是主要改动，不提及包括用户交互在内的一些细节。

$ EOF.
