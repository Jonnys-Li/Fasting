# Fasting — Intermittent Fasting Tracker (iOS)

一款用 **UIKit + Objective-C** 写的间歇性断食追踪 App。底部 TabBar 三页（Daily / Fasting / Explore），围绕「选计划 → 开始断食 → 进行中倒计时 → 结束填记录 → 历史查看 / 食物日记」一条主线。

> 仓库经过 8 个 Stage（Stage 1–8）+ 1 次 MVC 重构（Phase A–E）+ 多轮 code review（收敛出 R1–R12 项目硬约束）打磨。代码风格强调四件事：**VC ↔ RootView 拆分**、**单一状态权威（FSTSessionManager）**、**主题伞文件（FSTTheme）**、**导航集中（FSTAppRouter）**。

---

## 目录

- [快速开始](#快速开始)
- [功能模块](#功能模块)
- [架构分层](#架构分层)
- [关键设计模式](#关键设计模式)
- [主要交互流](#主要交互流)
- [次级交互](#次级交互)
- [持久化与刷新](#持久化与刷新)
- [测试](#测试)
- [开发约定](#开发约定)
- [代码审查规则（R1–R12）](#代码审查规则r1r12)
- [重构历程时间线](#重构历程时间线)

---

## 快速开始

```bash
pod install                     # 第一次拉代码后必须，安装 Masonry
open Fasting.xcworkspace         # 用 workspace 打开（而非 xcodeproj）
# 在 Xcode 中：
#   ⌘R     —— 跑模拟器 / 真机
#   ⌘U     —— 跑 FastingTests
```

**部署目标**：iOS 26.2（见工程设置 `IPHONEOS_DEPLOYMENT_TARGET`）。

**依赖**：仅 [Masonry](https://github.com/SnapKit/Masonry) 一个第三方（Auto Layout DSL），用 CocoaPods 管理。

---

## 功能模块

业务屏都在 `Fasting/Modules/` 下，按「Tab / 角色」分组（详见下方[架构分层](#架构分层)）。下表按分组列入口 VC：

| 分组 / 路径 | 入口 VC | 作用 |
|---|---|---|
| **Root** `Modules/Root/` | `FSTRootTabBarController` | 底部 TabBar（Daily / Fasting / Explore）。Explore 点击被拦截，改弹 Plan 浏览流 |
| **Fasting · Idle** `Modules/Fasting/Idle/` | `FSTFastingIdleViewController` | Fasting Tab 主页（未在断食态）：选方案 / 进食窗口 / 倒计时可开始 / 刚破戒。含 Picker、Ready（圆环 + 时间行 + CTA）、BreakingFastCard |
| **Fasting · Active** `Modules/Fasting/Active/` | `FSTActiveFastingViewController` | 进行中断食主页：圆环倒计时 + 血糖阶段卡 + 时间编辑 + Tips + Stop |
| **Fasting · SendFeedback** `…/Active/SendFeedback/` | `FSTSendFeedbackViewController` | 反馈页（chips + 文本 + 添加图片；UI only） |
| **Fasting · Share** `…/Active/Share/` | `FSTShareCardViewController` | 断食成果分享卡（圆环截图 + 品牌行；UI only） |
| **Explore · PlanSelect** `Modules/Explore/Plan/PlanSelect/` | `FSTPlanSelectViewController` | Modal 弹出的「Choose Plan」（Tag 筛选 + 4 选 1） |
| **Explore · PlanConfirm** `Modules/Explore/Plan/PlanConfirm/` | `FSTPlanConfirmViewController` | 选定 plan 后的确认页，预选 startDate + 时间线预览 |
| **Daily · Timeline** `Modules/Daily/Timeline/` | `FSTTimelineViewController` | Daily Tab 主页：最近一条断食卡 + 最近一条饮食卡 |
| **Daily · FastingHistory** `Modules/Daily/FastingHistory/` | `FSTFastingHistoryViewController` | 断食历史列表；顶栏跟随滚动改 Today / Yesterday / 月日 |
| **Daily · MealDiary** `Modules/Daily/MealDiary/` | `FSTMealDiaryViewController` | 全部饮食记录的时间线列表 |
| **Shared · AddRecord** `Modules/Shared/AddRecord/AddRecord/` | `FSTAddRecordViewController` | 结束断食后的填写表单：Time / Feeling / Weight / Note |
| **Shared · QuickAdd** `…/AddRecord/QuickAdd/` | `FSTQuickAddRecordViewController` | 快速补录：仅 start/end 时间，跳过表单 |
| **Shared · MealDetail** `Modules/Shared/MealDetail/` | `FSTMealDetailViewController` | 新建 / 编辑饮食记录（拍照、备注、味觉等级、饮食类型） |
| **Shared · WeightInput** `Modules/Shared/WeightInput/` | `FSTWeightInputViewController` | 体重输入弹窗（kg/lb 切换 + 数字键盘） |

> 命名注意：Fasting Tab 主页历史上叫 `FSTDailyPlanViewController`，现已更名为 `FSTFastingIdleViewController`（"Idle" = 未在断食），其 Ready 视图相应为 `FSTFastingIdleReadyView`。`Plan` 模块只保留真正的"选 / 确认方案"，归入 `Explore/`。

---

## 架构分层

```
Fasting/
├─ App/                       — 启动入口（AppDelegate / SceneDelegate / main）
│
├─ Common/                    — 跨模块复用基建
│   ├─ Base/                  — FSTBaseViewController（含 1s 刷新定时器）/ FSTBaseModalViewController
│   ├─ Categories/
│   │   ├─ Helpers/           — UIView+FSTLayout / UINavigationController+FSTHelpers / UIImage+FSTHelpers
│   │   └─ Styling/           — UIButton+FST / UILabel+FSTStyle
│   ├─ ModalDialog/           — FSTModalDialogViewController + FSTModalDialogContentView
│   ├─ TimeEditor/            — FSTTimeEditorSheetViewController + ContentView + UIViewController+FSTTimeEditor
│   ├─ Restoration/           — FSTSceneStateRestoration（场景状态恢复）
│   ├─ Routing/               — FSTAppRouter（全局导航集中）
│   ├─ Theme/                 — FSTTheme.h（伞文件）+ UIColor+FST
│   └─ Views/                 — FSTRingProgressView（Core Graphics 圆环）/ FSTFastingTopBar /
│                               FSTFastingTimesRow / FSTVerticalCardStackView
│
├─ Core/                      — 领域层：只有 Models 和 Services，不含任何 UIKit 业务屏
│   ├─ Models/
│   │   ├─ FSTWeightUnit.h
│   │   └─ Records/           — FSTFastingRecord（同文件声明 FSTMealRecord）/ FSTPlan + 各自 +Persistence
│   └─ Services/
│       ├─ RecordsRepository/ — FSTRecordsRepository（记录读写仓库 + FSTRecordsDidChangeNotification）
│       └─ Session/           — FSTSessionManager 主类 + 3 个 Service + FSTFastingRecordBuilder
│
└─ Modules/                   — 业务模块（详见上表），按 Tab / 角色分组
    ├─ Daily/                 — Timeline / FastingHistory / MealDiary（各 Controllers/ + Views/）
    ├─ Explore/               — Plan/ → PlanConfirm/、PlanSelect/
    ├─ Fasting/               — Idle/（Picker、Ready）、Active/（RingPanel、InfoSections、SendFeedback、Share）、Shared/
    ├─ Root/                  — FSTRootTabBarController
    └─ Shared/                — AddRecord/（AddRecord/InputCards、QuickAdd）、MealDetail/、WeightInput/
```

### 四层职责

1. **App** — 启动 / 场景管理，几乎不动业务。
2. **Common** — 跨模块「样式 + 通用 UI 组件 + 导航 + 主题 + 基类」。**业务侧只需 `#import "FSTTheme.h"`** 即得整套 UIColor / UIButton / UILabel / UIView 扩展（伞文件）。
3. **Core** — 业务模型 + 状态服务。可被 Modules 调用，但**自身不依赖 Modules、不含 UIKit 业务屏**。
4. **Modules** — 业务页面。每个模块只依赖 Common + Core + 同模块内部，不跨模块互相 import。

> Xcode 使用 synchronized groups：磁盘文件夹结构即工程结构，新增 / 移动文件夹无需手动改 `.pbxproj`。Obj-C `#import "X.h"` 经 header map 解析，与文件所在文件夹无关。

---

## 关键设计模式

### 1. VC ↔ RootView 拆分（见 R1 / R2）

每个业务 VC 都对应一个 `XxxRootView`（继承 UIView）。RootView 作为 VC 的明确 property，在 `viewDidLoad` 里 `alloc/init` 并 `addSubview` 到 `self.view`，约束铺满：

```objc
@interface FSTFastingIdleViewController ()
@property (nonatomic, strong) FSTFastingIdleRootView *rootView;
@end

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootView = [[FSTFastingIdleRootView alloc] init];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
```

**职责切分**：
- **RootView** — 持直接子视图（label / button / cardView）+ Masonry 约束 + 暴露 `on*Tapped` block 回调。只管自身布局，不持 model、不调 SessionManager。
- **ViewController** — 持业务状态（plan、startDate、displayMode…）+ 装 topBar + `bindRootViewCallbacks`（把 block 接到 VC 方法）+ `refreshUI`（一处推导、一处下发到 rootView 字段）。

> ⚠️ 不要用 `loadView` 把 `self.view` 顶替成 RootView + cast getter（**R1 禁止**）；也不要 `self.rootView.xxView.yyProperty = …` 链式穿透到孙子视图（**R2 禁止**），数据由直接子视图暴露语义化 setter 接收。

### 2. 单一状态权威：FSTSessionManager

`Core/Services/Session/FSTSessionManager.{h,m}` 单例，持有所有 session 状态：plan / activeStartDate / activeEndOverride / scheduledReady / eatingWindow anchor / 一次性 token / 偏好。

业务侧 mutation 走 SessionManager 公开 API（`startFastingWithPlan:startDate:`、`finishFastingWithRecord:`、`editActiveStartDate:alignWithPlan:`、`markScheduledReadyWithSource:anchorDate:` 等），mutation 自动持久化。单例初始化副作用放 `-init`（**R5**）。

### 3. SessionManager 三件套 Service（拆分实现细节）

SessionManager.m 只持字段，具体业务委托给三个 service（仅它们可 import `FSTSessionManager+Internal.h`）：

| Service | 职责 |
|---|---|
| `FSTSessionPersistenceService` | NSUserDefaults 读写、所有 key 常量、`saveAllForSession:` |
| `FSTSessionLifecycleService` | 所有 mutation（start / cancel / finish / clear / switch / edit / schedule） |
| `FSTNextFastService` | 推导下一次断食起点（override → records → anchor 优先级） |

另有 `FSTFastingRecordBuilder`（C 函数 `FSTBuildFastingRecord(...)`），供 AddRecord / QuickAdd 复用地构造 `FSTFastingRecord`。

### 4. 导航集中：FSTAppRouter

`Common/Routing/FSTAppRouter.{h,m}` — 全局静态导航类，把各 VC 里的「alloc + init + push/present + hidesBottomBar + modalStyle」样板抽出来。本类不持状态、不引用 Session，仅做导航编排：

```objc
+ (void)presentPlanBrowserFrom:(UIViewController *)vc;                       // Explore tab 浏览 Plan 完整流
+ (void)presentPlanPickerFrom:(UIViewController *)vc onPick:(void(^)(FSTPlan *))onPick;
+ (void)pushActiveFastingFrom:(UIViewController *)vc promptForStartTime:(BOOL)prompt;
+ (void)pushAddRecordFrom:(UIViewController *)vc startDate:(NSDate *)s endDate:(NSDate *)e;
+ (void)pushAddRecordFrom:(UIViewController *)vc editingRecord:(FSTFastingRecord *)record;
+ (void)pushQuickAddRecordFrom:(UIViewController *)vc;
+ (void)pushFastingHistoryFrom:(UIViewController *)vc;
+ (void)pushMealDiaryFrom:(UIViewController *)vc;
+ (void)pushMealDetailFrom:(UIViewController *)vc record:(FSTMealRecord *)record returnsToTimeline:(BOOL)flag;
+ (void)pushFeedbackFrom:(UIViewController *)vc;
+ (void)presentShareFrom:(UIViewController *)vc ringSnapshot:(UIImage *)snapshot;
+ (void)presentWeightInputFrom:(UIViewController *)vc weightKg:(CGFloat)kg onSave:(void(^)(CGFloat))onSave;
+ (void)finishFlowFrom:(UIViewController *)vc updates:(dispatch_block_t)updates fallback:(dispatch_block_t)fb;
+ (void)showAlertFrom:(UIViewController *)vc title:(NSString *)t message:(NSString *)m buttonTitle:(NSString *)b;
```

业务 VC 只调一行 `[FSTAppRouter pushXxxFrom:self …]`，不必自己 alloc / configure / push。

### 5. 主题伞文件：FSTTheme.h

`Common/Theme/FSTTheme.h` 集中 import：
- `UIColor+FST` — 语义色 token（`fst_primaryGreen` / `fst_textPrimary` / …）
- `UIButton+FST` — 按钮工厂（pill / nav circle / nav plain）
- `UILabel+FSTStyle` — Label 工厂（title / subtitle / body / 全参数版）
- `UIView+FSTLayout` — 容器样式 + Masonry 速记（`fst_pinEdgesToSuperview` / `fst_addSubviews:` / `fst_containerWithBackground:radius:`）
- `FSTBaseViewController` / `FSTBaseModalViewController` 基类

同时暴露：字体函数（`FSTFontBold(28)` / `FSTFontSubhead()`）、间距 / 圆角常量（`FSTSpacingM` / `FSTRadiusCard`）、时间格式化（`FSTFormatHHMMSS` / `FSTFormatRelativeDay` …）。业务文件只 `#import "FSTTheme.h"` 一行就够。

### 6. 通用居中 / 底部 Modal：FSTBaseModalViewController

`Common/Base/FSTBaseModalViewController.{h,m}` — 提供半透明背景 + 居中卡片 / 底部 sheet 两种 `containerStyle`。被复用于：
- `FSTModalDialogViewController`（图标 + 标题 + 文案 + 1~2 按钮）— 用户提示 / 确认
- `FSTTimeEditorSheetViewController`（底部 wheel picker + Align chip）— 编辑各种 NSDate
- `FSTShareCardViewController`（圆环截图 + Save/Share）

### 7. RefreshUI 一处推导（无 session 通知，靠定时器拉）

「state → UI」走 VC 的 `refreshUI`（Active）/ `refreshReadyState`（Idle）：读 SessionManager 当前状态、推导出全部派生字段（ringState、targetReached、displayedPercent、各文案），一次性下发到 `rootView` 的直接子视图。

触发源（**注意：session 字段 mutation 不发任何通知**，没有 `FSTSessionDidChangeNotification`）：
1. `FSTBaseViewController` 的 **1 秒刷新定时器** → `refreshTimerDidFire`（子类重写：Active→`refreshUI`，Idle→`refreshReadyState`）；
2. `viewWillAppear` 重新读 session（Idle 在此判断 `hasActiveFasting`，是则自动重定向 push 到 Active 页）；
3. Active 额外监听 `UIApplicationWillEnterForegroundNotification` → `refreshUI`。

> 历史上曾有独立的 `FSTActiveFastingDisplayState` / `FSTDailyPlanReadyDisplayState` 类做推导，Phase B2 已 inline 到 VC，去掉一层 wrapping。

---

## 主要交互流

### A. 断食起点（首次进入）

```
Root TabBar (Fasting Tab)
  → FSTFastingIdleViewController (Picker 态)
    → 用户点 plan 卡片
      → FSTPlanConfirmViewController (预选 startDate + Timeline)
        → 点 Start
          → FSTSessionManager.startFastingWithPlan:startDate:
          → FSTAppRouter.pushActiveFastingFrom:promptForStartTime:YES
            → FSTActiveFastingViewController (首次进入弹 TimeEditorSheet 让用户调 startTime)
```

未来时间的 startDate：进入 scheduledReady 态，回退到 Idle 的 `FSTFastingIdleReadyView`，等到 startDate 到达时由 `refreshReadyState` 自动 startFasting + push ActiveFasting。

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
      → FSTAppRouter.finishFlowFrom:updates:fallback: (Tab 模式下切 Timeline，否则普通 pop)
```

### C. 快速补录（Eating Time 态）

```
FSTFastingIdleViewController (Ready 态，吃窗口中)
  → 点 "Add new record"
    → FSTAppRouter.pushQuickAddRecordFrom:
      → FSTQuickAddRecordViewController (仅 startRow + endRow + duration label)
        → 点 Save → FSTBuildFastingRecord(...) → finishFastingWithRecord: → finishFlowFrom:…
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
          - 点击 row → FSTAppRouter.pushAddRecordFrom:editingRecord: 进编辑态
```

### E. 食物日记

```
Root TabBar (Daily Tab)
  → FSTTimelineViewController (mealModule)
    ├─ 点 chevron "→" → FSTAppRouter.pushMealDiaryFrom: → FSTMealDiaryViewController (全部 meal)
    ├─ 点 "+" → FSTAppRouter.pushMealDetailFrom:record:nil… (新建)
    └─ 点条目 → FSTAppRouter.pushMealDetailFrom:record:latest… (编辑)
```

---

## 次级交互

### Active Fasting 编辑 Start/End（Align Mode 状态机）

`FSTActiveFastingViewController` 的编辑入口走 `[self fst_presentTimeEditorWithTitle:…alignMode:…]`（`UIViewController+FSTTimeEditor`）。`FSTTimeEditorSheetViewController` 内部用 `FSTTimeEditorAlignMode` 枚举驱动 Align chip 行为：

| Mode | 默认 chip 态 | 重新启用条件 | 点击后跳到 |
|---|---|---|---|
| `FSTTimeEditorAlignModeStartFast` | **绿色可点** | 改 picker 后重新可点 | `now - alignDurationSeconds` |
| `FSTTimeEditorAlignModeEndFast` | **灰色禁用** | 改 picker 后才启用 | `alignReferenceDate + alignDurationSeconds` |
| `FSTTimeEditorAlignModeReferencePlusDuration` | **绿色可点** | 同 StartFast | 同 EndFast 计算 |

行为：点 Align chip → picker 跳到 targetDate、chip 变灰 → 滚动 picker → chip 按 mode 重新亮起 → Save 回调 `(picker.date, alignApplied)`，VC 据此调 `editActiveStartDate:alignWithPlan:`。

### Breaking Fast（Eating Time 态）

`FSTFastingIdleReadyView` 的 Breaking fast cell 点击 → `FSTModalDialogViewController` 弹「Breaking fast / Your fast is over… / Got it」。

### Share / Feedback / WeightInput

- **Share**：Active 左上 share 图标 → 拿圆环截图 → `FSTAppRouter.presentShareFrom:ringSnapshot:` → `FSTShareCardViewController`（Save / Share 当前 **UI only**）。
- **Feedback**：Active 底部「Send feedback」→ `FSTAppRouter.pushFeedbackFrom:` → `FSTSendFeedbackViewController`（Submit / AddPicture **UI only**）。
- **WeightInput**：`FSTAddRecordWeightCardView` 铅笔 → `FSTAppRouter.presentWeightInputFrom:weightKg:onSave:` → `FSTWeightInputViewController`（kg/lb 切换 + 数字键盘）。

---

## 持久化与刷新

| 数据 | 存储 | 维护方 |
|---|---|---|
| Session 状态（plan、active dates、scheduledReady、preferredUnit） | `NSUserDefaults` — key 集中在 `FSTSessionPersistenceService.m` | `FSTSessionPersistenceService` |
| 断食 + 饮食记录列表 | `NSUserDefaults` — 序列化为字典数组 | `FSTRecordsRepository` 单例 |
| Meal 图片 | `Documents/meal-images/{UUID}.jpg`（JPEG 0.82 压缩） | inline 在 `FSTMealDetailViewController` |

**刷新机制（重要）**：
- **records 增删** → `FSTRecordsRepository` 发 `FSTRecordsDidChangeNotification`；订阅方：Timeline / FastingHistory / MealDiary。
- **session 字段变化** → **不发任何通知**；UI 靠 [关键设计模式 §7](#7-refreshui-一处推导无-session-通知靠定时器拉) 的 1s 定时器 + `viewWillAppear` 重读 + 前台通知拉取最新状态。

---

## 测试

```bash
xcodebuild -workspace Fasting.xcworkspace -scheme Fasting \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test -only-testing:FastingTests
```

`FastingTests/FSTRecordsRepositoryTests.m` 当前覆盖：fasting record 的 upsert（更新 endDate 后顺序变化）/ 删除；meal record 排序 + `latestMealDate` 推导 / 删除。

测试用 `#import "../Fasting/.../Xxx.m"` 直接编译源文件，新增测试无需改 target 的 compile sources。

---

## 开发约定

来自历次踩坑总结（**结构化的项目硬约束见下方 [R1–R12](#代码审查规则r1r12) 与 `CLAUDE.md`**）：

1. **UIKit anchor 命名避坑** — UIView 子类暴露 Masonry attribute property 时不要命名为 `bottomAnchor` / `topAnchor` / `leadingAnchor` 等系统已有名（与 `NSLayoutYAxisAnchor` 冲突）。
2. **`userInteractionEnabled` 不可盲删** — 默认 YES，但 UIControl 内的子视图设为 NO 是为让 touch 穿透到 UIControl 上响应；删除会破坏点击。
3. **颜色合并需审慎** — `UIColor+FST` 里不少肉眼相近的色 token 是设计稿刻意区分（不同 stage / 不同语义），不要为省色号合并。
4. **无需兼容性** — 测试 App，旧数据丢失可接受；代码干净优先于迁移逻辑。

文件结构：新文件按现有目录约定放；不重命名 / 不挪动已有文件；普通 View/Card 类的版权头可省略，架构类（SessionManager / FSTTheme / Services / 基类）的设计意图注释必须保留。

---

## 代码审查规则（R1–R12）

历经多轮 code review 收敛出的项目级硬约束。**完整带例正文见 `CLAUDE.md` 的「开发约束规则」小节**，这里只列要点 + 落地 commit（违反任一条需在 PR 描述里解释）：

| 规则 | 要点（一句话） | 落地 commit |
|---|---|---|
| **R1** | RootView 用 property + `viewDidLoad` 内 `alloc/init` + `addSubview` + 铺满约束安装；禁止 `loadView` 顶替 self.view + cast getter | `ca4cfbd` |
| **R2** | RootView 只管自身布局；VC 禁止 `self.rootView.xx.yy = …` 链式穿透到孙子视图 | `ca4cfbd` |
| **R3** | 最小 init（只接身份参数）+ 配置走 property setter；一次性建视图方法统一命名 `setupSubviews` / `setupConstraints` | `ca4cfbd` · VC 扩展 `889dc7e` · 命名 `9cd1713` |
| **R4** | block 回调、单行函数体一律展开多行花括号，不写单行 `{ … }` | `ca4cfbd` · 收尾 `6d13315` `146566d` |
| **R5** | 单例初始化副作用放 `-init`，禁止 `+sharedManager` 二段式装配 | `ca4cfbd` |
| **R6** | 仅「同语义不同来源」的并列长 init → 用 `NS_ENUM` 编码种类合并为单一 init | `11b25d1` |
| **R7** | 无参 init 统一 `[[Foo alloc] init]`，禁用 `[Foo new]` | `4e95e86` |
| **R8** | `layoutSubviews` 只做布局，禁止刷数据 / 用缓存宽度 gate 一次刷新 | `2722f6f` |
| **R9** | 用 enum / type / index 表达身份与选中态，禁止拿 name / title 字符串判断 | `843f2df` |
| **R10** | UIView / UIControl 子类重写 `initWithFrame:`（非 `-init`）；init 顺序「数据 → 子视图 → 布局/刷新」 | `9aaf5d0` |
| **R11** | 没 cornerRadius、内容不溢出，就不要设 `clipsToBounds` / `masksToBounds` | `2722f6f` |
| **R12** | 避免不必要的嵌套滚动视图；静态固定内容用 `UIStackView` 承载 | `2722f6f` |

---

## 重构历程时间线

| Stage / Phase | Commit | 主题 |
|---|---|---|
| Initial | `de01579` | Fasting project 雏形 |
| Stage 1 | `a1373e9` | record 数据完整性 + Photos AddOnly 权限 |
| Stage 2 | `31ad8c8` | 导航 helper 统一 + Share 复用 BaseModal + 圆环切换瞬切 |
| Stage 3 | `7d0c7aa` | 抽 FSTRecordsRepository，SessionManager 只管 session 字段 |
| Stage 4 | `34ab23f` | 主题硬编码清扫，业务模块走 FSTTheme / UIColor+FST |
| Stage 5 | `91bc703` | Abort Plan 行为对齐设计意图，统一回到 Plan Picker |
| Stage 6 | `ecc467b` | 清理 FSTPlan / UIColor+FST 死代码 |
| Stage 7 | `f4b0c57` | DisplayState 下沉 Active / Idle VC 残留业务逻辑 |
| Stage 8 | `1f14640` | 抽 FSTTimeRowView 子组件 + 补 UILabel factory |
| Phase A–E | `571309b` | MVC refactor：smart revert + real consolidation + Align mode |
| Code review R1–R5 | `ca4cfbd` | CLAUDE.md 新增 R1–R5 + 全量违规清零 |
| Code review R6 | `11b25d1` | FSTModalDialogViewController 并列长 init → enum 合并 |
| Code review R3↑ | `889dc7e` | R3 扩到 UIViewController：最小 init + property |
| Code review R7 | `4e95e86` | 全量 `[X new]` → `[[X alloc] init]` |
| Code review R8–R12（文档） | `2be7284` | CLAUDE.md 追加 R8–R12 |
| Code review R9 | `843f2df` | FSTPlan 加 `type`，身份判断去字符串化 |
| Code review R8/R11/R12 | `2722f6f` | FSTPlanSelectListView 去嵌套 TableView 改竖直 stack |
| Code review R10 | `9aaf5d0` | 21 个 UIView / UIControl 子类统一 `initWithFrame:` |
| Code review R4 收尾 | `6d13315` `146566d` | 单行函数体花括号统一展开多行 |

---

## License

私有项目。
