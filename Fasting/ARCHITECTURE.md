# 项目结构约定（Fasting）

这份文档说明源码的组织约定，目标是：**不深入了解项目也能快速找到东西。**

## 一、组织原则：层 → 功能 → 类型

```
Fasting/
├── App/          应用入口（AppDelegate / SceneDelegate / main）
├── Common/       跨功能共享的基建（基类、UIKit 扩展、主题、路由、共享控件、通用小功能）
├── Core/         领域层 —— 只有 Models 和 Services，不含任何 UIKit 业务屏
└── Modules/      各功能模块，一个功能一个文件夹
```

- **顶层按「层」分**：`Common`（横向复用） / `Core`（领域数据与逻辑） / `Modules`（纵向功能）。
- **`Modules` 内按「功能」分**：`Fasting`（断食 Tab）、`Plan`、`Timeline`、`MealDiary`…
- **功能内按「类型」或「屏幕」分**（见第三节）。

> Xcode 使用 synchronized groups：磁盘上的文件夹结构即工程结构，**新增/移动文件夹无需手动改 `.pbxproj`**。Obj-C 的 `#import "X.h"` 经 header map 解析，与文件所在文件夹无关。

## 二、"要找 X 去哪"速查表

| 我要找… | 去这里 |
|---|---|
| 数据模型 / 持久化（Record、Plan…） | `Core/Models/` |
| 会话状态机、断食生命周期、下次断食推导 | `Core/Services/Session/` |
| 记录读写仓库 | `Core/Services/Records/` |
| 某个**业务屏幕**（VC + 它的视图） | `Modules/<功能>/<屏幕>/` |
| 跨模块复用的控件（TopBar、卡片栈、进度环…） | `Common/Views/` |
| 配色 / 字体 / 圆角等主题 token | `Common/Theme/` |
| 通用 UIKit 扩展（布局、按钮/标签样式…） | `Common/Categories/` |
| 通用小功能（弹窗、时间编辑器 sheet） | `Common/ModalDialog/`、`Common/TimeEditor/` |
| VC 基类 | `Common/Base/` |
| 路由 / 场景恢复 | `Common/Routing/`、`Common/Restoration/` |

## 三、模块内部约定

- **单 VC 模块** → `Module/Controllers/` + `Module/Views/[可选视觉子组]`
  例：`Timeline/`、`MealDiary/`（`Views/` 下的子组只是同一屏内的视觉分组，不是多屏）。
- **多屏 / 多 VC 模块** → **每个屏幕一个子文件夹**，VC 与它专属的视图放在一起；跨屏共享的视图放 `Module/Shared/`。
  例：
  ```
  Modules/Fasting/            断食 Tab（同一个 Tab 的两种状态）
    Idle/      未在断食的主页：FSTFastingIdleViewController + Ready/ReadyRing/Picker + BreakingFastCard
    Active/    正在断食：FSTActiveFastingViewController + InfoSections/ + RingPanel/
  Modules/Plan/               选 / 确认断食方案（名副其实，只管 plan）
    PlanConfirm/  FSTPlanConfirmViewController + RootView/Timeline/PrepCard
    PlanSelect/   FSTPlanSelectViewController + ListView/ChipPill/TagChips
  Modules/AddRecord/
    AddRecord/    完整补录屏：VC + RootView + HeaderView + InputCards/
    QuickAdd/     快速补录屏：VC + RootView + TimeRowView
  ```
  > 命名要名实相符：`Fasting/Idle` 是断食 Tab 主页（不是"计划"），故 VC 叫 `FSTFastingIdleViewController` 而非历史上的 `FSTDailyPlanViewController`；`Plan` 模块只保留真正的"选/确认方案"。

## 四、Category（分类）放哪

| 类型 | 例子 | 放哪 |
|---|---|---|
| 通用 UIKit 行为/布局扩展 | `UIView+FSTLayout`、`UIButton+FST` | `Common/Categories/` |
| 主题视觉 token 扩展（颜色/字体） | `UIColor+FST` | `Common/Theme/`（与 token 同处，不进 Categories） |
| 某个类 / 某个功能专属的扩展 | `FSTFastingRecord+Persistence`、`FSTSessionManager+Internal`、`UIViewController+FSTTimeEditor` | **紧挨它所属的类 / 功能**，不进通用 Categories |

> 准则：**通用行为** → `Categories`；**视觉 token** → `Theme`；**专属某类/某功能** → 跟着那个类/功能走。

## 五、领域命名词汇表

代码里有些命名需要断食领域背景，这里统一解释：

| 命名 | 含义 |
|---|---|
| `Idle`（断食 Tab） | 未在断食的状态：选方案 / 进食窗口 / 倒计时可开始 / 刚破戒，统由 `FSTFastingIdleViewController` 承载 |
| `BreakingFast` | 结束断食、恢复进食（"还原"进食状态） |
| `DailyPlan` | 每日断食方案（`FSTPlan.defaultDailyPlans`：14-10 / 16-8 / 18-6 / 20-4） |
| `DailyPlanReady` / `ScheduledReady` | 当日计划已就绪 / 已预约就绪，可开始断食 |
| `NextFast` | 下一次断食的起点时间（推导自上次进食/结束） |
| `EatingWindow` | 进食窗口（断食之外允许进食的时间段） |
| `Autophagy` | 自噬阶段（长时断食达到的生理阶段） |
| `BloodGlucose stage` | 血糖升高阶段（进食后的生理阶段） |
| `ActiveFasting` | 进行中的断食（主屏） |
| `tasteLevel` / `feelingLevel` | 用户对该餐/该次断食的主观评分（0=Hard / 1=Ok / 2=Easy） |
