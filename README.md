# Fasting — Intermittent Fasting Tracker (iOS)

一款用 **UIKit + Objective-C** 写的间歇性断食追踪 App。底部 TabBar 三页（Daily / Fasting / Explore），围绕「选计划 → 开始断食 → 进行中倒计时 → 结束填记录 → 历史查看 / 食物日记」一条主线。

> 本仓库经过 8 个 Stage（Stage 1–8）+ 1 次 MVC 重构（Phase A–E）打磨，代码风格强调：**VC ↔ RootView 拆分**、**单一状态权威（FSTSessionManager）**、**主题伞文件（FSTTheme）**、**导航集中（FSTAppRouter）**。

---

## 目录

- [快速开始](#快速开始)
- [功能模块](#功能模块)
- [架构分层](#架构分层)
- [关键设计模式](#关键设计模式)
- [主要交互流](#主要交互流)
- [次级交互](#次级交互)
- [持久化策略](#持久化策略)
- [测试](#测试)
- [开发约定](#开发约定)
- [本次重构做了什么（Phase A–E）](#本次重构做了什么phasee)
- [重构历程时间线](#重构历程时间线)

---

## 快速开始

```bash
pod install                    # 第一次拉代码后必须，安装 Masonry
open Fasting.xcworkspace        # 用 workspace 打开（而非 xcodeproj）
# 在 Xcode 中：
#   ⌘R     —— 跑模拟器 / 真机
#   ⌘U     —— 跑 FastingTests
```

**最低 iOS**：iOS 13+（部分代码用 `@available(iOS 13.4, *)` 选择 wheel picker style；iOS 15 之后用 `scrollEdgeAppearance` 配 TabBar）。

**依赖**：仅 [Masonry](https://github.com/SnapKit/Masonry) 一个第三方（Auto Layout DSL）。

---

## 功能模块

`Fasting/Modules/` 下 11 个业务模块，每个模块自成 `Controllers/` + `Views/` 子目录：

| 模块 | 入口 | 作用 |
|---|---|---|
| **Root** | `FSTRootTabBarController` | 底部 TabBar（Daily / Fasting / Explore），Explore 点击拦截弹 PlanSelect |
| **Plan** | `FSTDailyPlanViewController` | 「Fasting」Tab 主页；两态：(a) 未选计划 → PickerView；(b) 已选未开始 → ReadyView（圆环 + 时间行 + CTA） |
| **Plan / PlanConfirm** | `FSTPlanConfirmViewController` | 选定 plan 之后的「确认」页，预选 startDate + 时间线预览 |
| **Plan / PlanSelect** | `FSTPlanSelectViewController` | Modal 弹出的「Choose Plan」（Tag 筛选 + 4 选 1） |
| **ActiveFasting** | `FSTActiveFastingViewController` | 进行中断食主页；圆环倒计时 + 血糖阶段卡 + 时间编辑 + Tips + Stop |
| **AddRecord** | `FSTAddRecordViewController` | 结束断食后的填写表单：感受 / 体重 / 备注 |
| **AddRecord / Quick** | `FSTQuickAddRecordViewController` | 快速补录：仅 start/end 时间，跳过表单 |
| **FastingHistory** | `FSTFastingHistoryViewController` | 「Timeline」入口的历史列表；顶部 header 跟随滚动改 Today/Yesterday/月日 |
| **Timeline** | `FSTTimelineViewController` | 「Daily」Tab 主页；最近一条断食卡 + 最近一条饮食卡 |
| **MealDetail** | `FSTMealDetailViewController` | 新建 / 编辑饮食记录（拍照、备注、味觉等级、饮食类型） |
| **MealDiary** | `FSTMealDiaryViewController` | 全部饮食记录的时间线列表 |
| **Share** | `FSTShareCardViewController` | 断食成果分享卡（圆环截图 + 品牌行；UI only） |
| **SendFeedback** | `FSTSendFeedbackViewController` | 反馈页（chips + 文本 + 添加图片；UI only） |
| **WeightInput** | `FSTWeightInputViewController` | 体重输入弹窗（kg/lb 切换 + 数字键盘） |

---

## 架构分层

```
Fasting/
├─ App/                      — 启动入口
│   ├─ AppDelegate.{h,m}
│   ├─ SceneDelegate.{h,m}
│   └─ main.m
│
├─ Common/                   — 跨模块复用
│   ├─ Base/                 — FSTBaseViewController / FSTBaseModalViewController
│   ├─ Categories/
│   │   ├─ Helpers/          — UIView+FSTLayout, UINavigationController+FSTHelpers,
│   │   │                      UIImage+FSTHelpers, UIViewController+FSTTimeEditor
│   │   └─ Styling/          — UIButton+FST, UILabel+FSTStyle
│   ├─ Controllers/          — FSTModalDialogViewController, FSTTimeEditorSheetViewController
│   ├─ Routing/              — FSTAppRouter（全局导航集中）
│   ├─ Theme/                — FSTTheme.h (umbrella) + UIColor+FST
│   └─ Views/                — FSTFastingTopBar, FSTFastingTimesRow,
│                              FSTVerticalCardStackView, FSTModalDialogContentView,
│                              FSTTimeEditorSheetContentView
│
├─ Core/                     — 跨业务模型 / 服务 / 通用视图
│   ├─ Models/
│   │   ├─ FSTWeightUnit.h
│   │   └─ Records/          — FSTFastingRecord, FSTMealRecord + Persistence
│   ├─ Services/
│   │   ├─ Records/          — FSTRecordsRepository（记录仓库）
│   │   └─ Session/          — FSTSessionManager 主类 + 3 个 Service + RecordBuilder
│   └─ Views/                — FSTRingProgressView（Core Graphics 圆环）
│
└─ Modules/                  — 业务模块（详见上表）
    ├─ Root/
    ├─ Plan/                 ├─ Controllers/    ├─ Views/
    │                                            ├─ DailyStatus/      （ReadyView + Ring + Picker）
    │                                            ├─ PlanConfirm/      （Timeline + PrepCard）
    │                                            └─ PlanSelection/    （List + ChipsBar + Pill）
    ├─ ActiveFasting/        ├─ Controllers/    ├─ Views/
    │                                            ├─ RingPanel/        （圆环 + segment + root）
    │                                            └─ InfoSections/     （PhaseSummary + Tips）
    ├─ AddRecord/            ├─ Controllers/    ├─ Views/
    │                                            ├─ Container/        （Header + RootViews + TimeRow）
    │                                            └─ InputCards/       （Feeling/Time/Weight/Note + Base）
    ├─ FastingHistory/
    ├─ Timeline/
    ├─ MealDetail/
    ├─ MealDiary/
    ├─ Share/
    ├─ SendFeedback/
    └─ WeightInput/
```

### 三层职责

1. **App** — 启动 / 场景管理，几乎不动业务。
2. **Common** — 跨模块「样式 + 通用 UI 组件 + 导航 + 主题」。**业务侧只需 import `FSTTheme.h`** 即得整套 UIColor / UIButton / UILabel / UIView 扩展（伞文件）。
3. **Core** — 业务模型 + 状态服务 + 跨模块视图组件。可以被 Modules 调用，但**自身不依赖 Modules**。
4. **Modules** — 业务页面。每个模块只依赖 Common + Core + 同模块内部，不跨模块互相 import。

---

## 关键设计模式

### 1. VC ↔ RootView 拆分

每个业务 VC 都对应一个 `XxxRootView`（继承 UIView），通过 `loadView` 把 self.view 替换为 RootView：

```objc
- (void)loadView { self.view = [FSTActiveFastingRootView new]; }
- (FSTActiveFastingRootView *)rootView { return (FSTActiveFastingRootView *)self.view; }
```

**职责切分**：
- **RootView** — 持子视图（label/button/cardView）+ Masonry 约束 + 暴露 `on*Tapped` block 回调。
- **ViewController** — 持业务状态（plan、startDate、displayMode…）+ 装 topBar + `bindRootViewCallbacks`（把 block 接到 VC 方法）+ `refreshUI`（一处推导，一处下发到 rootView 字段）。

**约定**：所有页面状态由 VC 推 → RootView 显示；RootView 不持 model，不调 SessionManager。

### 2. 单一状态权威：FSTSessionManager

`Fasting/Core/Services/Session/FSTSessionManager.{h,m}` 单例，持有所有 session 状态：plan / activeStartDate / activeEndOverride / scheduledReady / eatingWindow anchor / 一次性 token / 偏好。

业务侧 mutation 走 SessionManager 公开 API（`startFastingWithPlan:`、`editActiveStartDate:alignWithPlan:` 等），mutation 自动持久化 + 发 `FSTSessionDidChangeNotification`。

### 3. SessionManager 三件套 Service（拆分实现细节）

SessionManager.m 只持字段，具体业务委托：

| Service | 职责 |
|---|---|
| `FSTSessionPersistenceService` | NSUserDefaults 读写、所有 key 常量、`saveAllForSession:` |
| `FSTSessionLifecycleService` | 所有 mutation（start/cancel/finish/clear/switch/edit/schedule） |
| `FSTNextFastService` | 推导下一次断食起点（override → records → anchor 优先级） |

内部接口在 `FSTSessionManager+Internal.h`，**仅这 3 个 service import**，业务侧禁用。

### 4. 导航集中：FSTAppRouter

`Fasting/Common/Routing/FSTAppRouter.{h,m}` — 全局静态导航类，把各 VC 里的「alloc + init + push/present」样板抽出来：

```objc
+ (void)pushActiveFastingFrom:(UIViewController *)vc promptForStartTime:(BOOL)prompt animated:(BOOL)animated;
+ (void)presentPlanPickerFrom:(UIViewController *)vc onPick:(void (^)(FSTPlan *))onPick;
+ (void)pushFastingHistoryFrom:(UIViewController *)vc;
+ (void)pushMealDetailFrom:(UIViewController *)vc record:(FSTMealRecord *)record returnsToTimeline:(BOOL)flag;
+ (void)presentShareFrom:(UIViewController *)vc ringSnapshot:(UIImage *)snapshot;
+ (void)showAlertFrom:(UIViewController *)vc title:msg:buttonTitle:;
// …等等
```

业务 VC 只调一行 `[FSTAppRouter pushXxxFrom:self]` 而不必自己 alloc/configure/push。

### 5. 主题伞文件：FSTTheme.h

`Fasting/Common/Theme/FSTTheme.h` 集中 import：
- `UIColor+FST` — 语义色 token（`fst_primaryGreen` / `fst_textPrimary` / …）
- `UIButton+FST` — 按钮工厂（pill / nav circle / nav plain）
- `UILabel+FSTStyle` — Label 工厂（title / subtitle / body / 全参数版）
- `UIView+FSTLayout` — 容器样式 + Masonry 速记（`fst_pinEdgesToSuperview` / `fst_addSubviews:` / `fst_containerWithBackground:radius:`）
- `FSTBaseViewController` / `FSTBaseModalViewController` 基类

同时暴露：字体函数（`FSTFontBold(28)` / `FSTFontSubhead()`）、间距常量（`FSTSpacingM`）、圆角常量（`FSTRadiusCard`）、时间格式化（`FSTFormatHHMMSS` / `FSTFormatRelativeDateTime` / `FSTFormatRelativeDay`）。

业务文件只 `#import "FSTTheme.h"` 一行就够。

### 6. 通用居中/底部 Modal：FSTBaseModalViewController

`Fasting/Common/Base/FSTBaseModalViewController.{h,m}` — 提供半透明背景 + 居中卡片 / 底部 sheet 两种 `containerStyle`。被复用于：
- `FSTModalDialogViewController`（图标 + 标题 + 文案 + 1~2 按钮）— 用户提示 / 确认
- `FSTTimeEditorSheetViewController`（底部 wheel picker + Align chip）— 编辑各种 NSDate
- `FSTShareCardViewController`（圆环截图 + Save/Share）

### 7. RefreshUI 一处推导

「state → UI」走 VC 的 `refreshUI` 方法（定时器 + 通知触发）。该方法读 SessionManager 当前状态、推导出全部派生字段（ringState、targetReached、displayedPercent、各文案）、一次性下发到 `rootView.ringPanel.xxx` / `rootView.timesRow.xxx`。

之前用独立的 `FSTActiveFastingDisplayState` / `FSTDailyPlanReadyDisplayState` 类做这事，本次 Phase B2 重构把它们直接 inline 到 VC 内，去掉一层 wrapping。

---

## 主要交互流

### A. 断食起点（首次进入）

```
Root TabBar (Fasting Tab)
  → FSTDailyPlanViewController (PickerView 态)
    → 用户点 plan 卡片
      → FSTPlanConfirmViewController (预选 startDate + Timeline)
        → 点 Start
          → FSTSessionManager.startFastingWithPlan:startDate:
          → FSTAppRouter.pushActiveFastingFrom:promptForStartTime:YES
            → FSTActiveFastingViewController (首次进入弹 TimeEditorSheet 让用户调 startTime)
```

未来时间的 startDate：进入 scheduledReady 态，回退到 DailyPlan ReadyView，等到 startDate 到达时 ReadyView 的 `refreshReadyState` 自动 startFasting + push ActiveFasting。

### B. 断食结束

```
FSTActiveFastingViewController
  → 用户点底部 Stop 按钮
    ├─ 已达标（targetReached=YES）→ COMPLETE FASTING（绿底）→ 直接进 AddRecord
    └─ 未达标 → END FASTING（灰底）→ FSTModalDialogViewController 确认
                                      └─ 确认 Yes → 进 AddRecord
  → FSTAddRecordViewController (4 张 InputCard：Time / Feeling / Weight / Note)
    → 点 Save
      → FSTBuildFastingRecord(...) 构造 FSTFastingRecord
      → FSTSessionManager.finishFastingWithRecord:
      → FSTAppRouter.finishFlowFrom: (Tab 模式下切 Timeline，否则普通 pop)
```

### C. 快速补录（Eating Time 态）

```
FSTDailyPlanViewController (ReadyView，吃窗口中)
  → 点 "Add new record"
    → FSTAppRouter.pushQuickAddRecordFrom:
      → FSTQuickAddRecordViewController (仅 startRow + endRow + duration label)
        → 点 Save
          → FSTBuildFastingRecord(...)
          → FSTSessionManager.finishFastingWithRecord:
          → FSTAppRouter.finishFlowFrom:
```

### D. 历史列表（Timeline）

```
Root TabBar (Daily Tab)
  → FSTTimelineViewController (fastingModule + mealModule)
    → 点 "More" on fastingModule
      → FSTAppRouter.pushFastingHistoryFrom:
        → FSTFastingHistoryViewController (UITableView)
          - 滚动时顶部 todayLabel 跟随最顶可见 record 的 startDate
            走 FSTFormatRelativeDay() → "Today" / "Yesterday" / "May 12"
          - 点击 row → FSTAddRecordViewController initWithRecord: 进编辑态
```

### E. 食物日记

```
Root TabBar (Daily Tab)
  → FSTTimelineViewController (mealModule)
    ├─ 点 chevron "→" → FSTAppRouter.pushMealDiaryFrom: → FSTMealDiaryViewController (全部 meal)
    ├─ 点 "+" → FSTAppRouter.pushMealDetailFrom:record:nil (新建)
    └─ 点条目 → FSTAppRouter.pushMealDetailFrom:record:latest (编辑)
```

---

## 次级交互

### Active Fasting 编辑 Start/End（Align Mode 状态机）

`FSTActiveFastingViewController.handleEditActiveStartTapped` / `handleEditActiveEndTapped` 都走 `[self fst_presentTimeEditorWithTitle:...alignMode:...]`。

`FSTTimeEditorSheetViewController` 内部状态机（Phase E 引入，对齐 demo1 设计）：

| Mode | 默认 chip 态 | 重新启用条件 | 点击后跳到 |
|---|---|---|---|
| `StartFast` | **绿色可点** | 改 picker 后重新可点 | `now - alignDurationSeconds` |
| `EndFast` | **灰色禁用** | 改 picker 后才启用 | `alignReferenceDate + alignDurationSeconds` |
| `ReferencePlusDuration` | **绿色可点** | 同 StartFast | 同 EndFast 计算 |

行为：
1. 用户点 Align chip → picker 自动跳到 targetDate，chip 变灰
2. 用户滚动 picker → chip 重新亮起（按 mode 决定）
3. Save 回调 `(picker.date, alignApplied)` — VC 据此调 `editActiveStartDate:alignWithPlan:YES/NO`

### Breaking Fast（Eating Time 态）

`FSTDailyPlanReadyView` 的 Breaking fast cell 点击 → `FSTModalDialogViewController` 弹「Breaking fast / Your fast is over. It's time to replenish... / Got it」。

### Share

`FSTActiveFastingViewController` 左上 share 图标 → `[self.rootView.ringPanel snapshotForSharing]` 拿圆环截图 → `FSTAppRouter.presentShareFrom:ringSnapshot:` → `FSTShareCardViewController` 居中卡片展示。

Save / Share 两按钮当前为 **UI only**（直接 dismiss）。

### Feedback

`FSTActiveFastingViewController` 底部「Send feedback」入口 → `FSTAppRouter.pushFeedbackFrom:` → `FSTSendFeedbackViewController`（6 个 chip + textView + addPicture + submit）。

Submit / AddPicture 当前为 **UI only**（不真传后端、不弹相册）。

### WeightInput

`FSTAddRecordWeightCardView` 铅笔点击 → `FSTAppRouter.presentWeightInputFrom:weightKg:onSave:` → `FSTWeightInputViewController`（kg/lb 切换 + 数字键盘 + 圆点装饰盒子）。

---

## 持久化策略

| 数据 | 存储 | 维护方 |
|---|---|---|
| Session 状态（plan、active dates、scheduledReady、preferredUnit） | `NSUserDefaults` — key 集中在 `FSTSessionPersistenceService.m` | `FSTSessionPersistenceService` |
| 断食 + 饮食记录列表 | `NSUserDefaults` — 序列化为字典数组 | `FSTRecordsRepository` 单例 |
| Meal 图片 | `Documents/meal-images/{UUID}.jpg`（JPEG 0.82 压缩） | inline 在 `FSTMealDetailViewController` |

通知：
- `FSTSessionDidChangeNotification` — session 字段 mutation 时发，订阅方：DailyPlan / ActiveFasting VC
- `FSTRecordsDidChangeNotification` — records 增删时发，订阅方：Timeline / History / MealDiary VC

---

## 测试

```bash
xcodebuild -workspace Fasting.xcworkspace -scheme Fasting \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test -only-testing:FastingTests
```

`FastingTests/FSTRecordsRepositoryTests.m` 当前覆盖：
- Fasting record 的 upsert（更新 endDate 后顺序变化）
- Fasting record 删除
- Meal record 排序 + `latestMealDate` 推导
- Meal record 删除

测试用 `#import "../Fasting/.../Xxx.m"` 直接编译源文件，方便绕过 target 配置。

---

## 开发约定

来自历次踩坑总结：

1. **UIKit anchor 命名避坑** — UIView 子类暴露 Masonry attribute property 时不要命名为 `bottomAnchor` / `topAnchor` / `leadingAnchor` 等系统已有名（会与 NSLayoutYAxisAnchor 冲突，编译警告甚至运行时错）。
2. **`userInteractionEnabled` 不可盲删** — 默认 YES，但 UIControl 内的子视图（如装饰 label / imageView）设为 NO 是为了让 touch 穿透到 UIControl 上响应；删除会破坏点击行为。
3. **颜色合并需审慎** — `UIColor+FST` 里有不少肉眼相近的色 token，是设计稿刻意区分（不同 stage / 不同语义），不要为了"省色号"合并。
4. **无需兼容性** — 当前是测试 App，旧数据丢失可接受；代码干净优先于迁移逻辑。

文件结构：
- 新文件按现有目录约定放（Card → `Modules/AddRecord/Views/InputCards/`；Session helper → `Core/Services/Session/`）
- 不重命名 / 不挪动已有文件
- 普通 View/Card 类的版权头注释可省略；架构类（SessionManager / FSTTheme / Services / Controllers）的设计意图注释必须保留

---

## 本次重构做了什么（Phase A–E）

详见 commit `571309b` 的 message。简要：

**Phase A — 智能回退**  
同事之前的「代码减半」是删注释 + 多行挤一行的作弊手法。Phase A 把 166 个文件 `git checkout HEAD --` 整体回退，只保留真重构（FSTAppRouter / 3 个 Session Service / FastingTests）。

**Phase B — 真重构**  
- B1 扩 helper：`UIView+FSTLayout` 加 `fst_containerWithBackground:radius:` / `fst_pinEdgesToSuperview` / `fst_addSubviews:`；`UILabel+FSTStyle` 加多行支持的 5 参数工厂
- B2 删 DisplayState 目录 → inline 到 ActiveFasting / DailyPlan VC
- B5 大视图 data-driven 化：TipsSection（3 个 sub-card 配置数组）、TimelineCard、SendFeedbackRootView
- B6 删 DomainServices 目录 → inline `FSTEatingWindow` / `FSTFastingTiming` / `FSTMealImage` / `FSTPercentFormatter` 到调用方
- B7 清 15 处冗余 `UIColor+FST.h` import（FSTTheme 已伞 import）

**Phase D — 产品改动**  
- D1 抽 `FSTFastingRecordBuilder`，AddRecord / QuickAdd 复用
- D2 抽 `FSTAddRecordBaseCardView` 给 4 个 InputCard
- D3 Timeline 顶部 Today 改为 scrollViewDidScroll 驱动
- D4 Breaking fast cell 改弹 FSTModalDialogViewController
- D5/D6 SendFeedback / Share 砍真实功能（保留 UI）

**Phase E — Align 按钮重设计**  
参考 `/Users/zjs/Downloads/demo1` 项目的 `FastingTimeEditorSheetViewController`，从 toggle 模型改为「一次性 Apply + pickerWasChanged 追踪」状态机，引入 `FSTTimeEditorAlignMode` 枚举（StartFast / EndFast / ReferencePlusDuration）。

**量化**：纯代码 10403 → 10223 行（-1.7%）；编译 + 测试通过。

> 同事拿到的「代码量减半」KPI 是 hard 数字目标。本次没强行追 -50%，因为：
> 1. codebase 已经历 Stage 1-8 真重构，低垂果实摘完
> 2. 用户明确「干净优先于凑数」，拒绝多 property 挤一行 / 单语句方法挤一行等密度黑魔法
> 3. 同事的「-30% pure code」里约 60% 来自多行挤一行，看起来减了实际可读性大降，本次回退后这些恢复

---

## 重构历程时间线

| Stage / Phase | Commit | 主题 |
|---|---|---|
| Initial | `de01579` | Fasting project 雏形 |
| Stage 1 | `a1373e9` | record 数据完整性 + Photos AddOnly 权限 |
| Stage 2 | `31ad8c8` | 导航 helper 统一 + Share 复用 BaseModal + 圆环切换瞬切 |
| Stage 3 | `7d0c7aa` | 抽 FSTRecordsRepository，SessionManager 只管 session 字段 |
| Stage 4 | `34ab23f` | 主题硬编码清扫，业务模块走 FSTTheme/UIColor+FST |
| Stage 5 | `91bc703` | Abort Plan 行为对齐设计意图，统一回到 Plan Picker |
| Stage 6 | `ecc467b` | 清理 FSTPlan / UIColor+FST 死代码 |
| Stage 7 | `f4b0c57` | DisplayState 下沉 Active/Daily VC 残留业务逻辑 |
| Stage 8 | `1f14640` | 抽 FSTTimeRowView 子组件 + 补 UILabel factory |
| Phase A–E | `571309b` | MVC refactor（本 README 主题；smart revert + real consolidation + align mode） |

---

## License

私有项目。
