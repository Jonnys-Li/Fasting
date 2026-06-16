# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this app is

iOS intermittent-fasting tracker. **UIKit + Objective-C**, iOS 17+, single third-party dependency (Masonry for Auto Layout DSL). Three-tab UI: Daily / Fasting / Explore.

## Build & test

```bash
pod install                     # required after first clone (installs Masonry)
open Fasting.xcworkspace        # always open the workspace, NOT the xcodeproj
```

In Xcode: ⌘R runs, ⌘U runs `FastingTests`.

Run tests from CLI:

```bash
xcodebuild -workspace Fasting.xcworkspace -scheme Fasting \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test -only-testing:FastingTests
```

To run a single test: append `/FSTRecordsRepositoryTests/testMethodName` to `-only-testing`.

`FastingTests/FSTRecordsRepositoryTests.m` `#import`s the source `.m` files directly (e.g. `"../Fasting/Core/Services/RecordsRepository/FSTRecordsRepository.m"`), so adding new tests does not require fiddling with the test target's compile sources.

## Authoritative docs (read these first)

- **`README.md`** — feature modules table, interaction flows (A–E), persistence strategy, refactor history. Note: the "功能模块" table is slightly stale; trust `ARCHITECTURE.md` for current folder layout.
- **`Fasting/ARCHITECTURE.md`** — current folder layout (post Fasting/Idle rename + Plan split), "where do I find X" lookup, domain vocabulary (Idle / BreakingFast / EatingWindow / Autophagy / scheduledReady / NextFast / tasteLevel-feelingLevel).

## Big-picture architecture

Four-layer split inside `Fasting/`:

- **App/** — `AppDelegate` / `SceneDelegate` / `main`. Don't touch for business work.
- **Common/** — cross-cutting infra: base VCs, UIKit categories, theme, routing, generic modals.
- **Core/** — `Models/` (records, plan) + `Services/` (Session, RecordsRepository). **No UIKit business screens.**
- **Modules/** — feature screens. Subdivided as `Daily/` (Timeline, FastingHistory, MealDiary), `Fasting/` (Idle, Active), `Explore/` (Plan), `Root/` (TabBar), `Shared/` (AddRecord, MealDetail, WeightInput).

Xcode uses **synchronized groups**: disk folders == project structure. Moving/adding folders does NOT require editing `.pbxproj`. Obj-C `#import "X.h"` uses the header map and ignores file location.

### Five load-bearing patterns (deviate at your peril)

1. **VC ↔ RootView split** — every screen has `FSTXxxRootView` (UIView). VC declares `@property (nonatomic, strong) FSTXxxRootView *rootView;`, alloc/inits it in `viewDidLoad`, and adds it as a subview of `self.view` with pinned constraints. **Do NOT override `loadView` to replace `self.view`, and do NOT write a cast getter — see 开发约束规则 R1.** RootView holds its direct subviews + Masonry + exposes `on*Tapped` block callbacks; VC binds callbacks + pushes data to subviews via setters. **RootViews must not import SessionManager or hold models. RootView 只管自身布局，VC 不得做 `self.rootView.xxView.yyProperty = …` 的链式穿透赋值 — 见 R2。**

2. **Single state authority: `FSTSessionManager`** (`Core/Services/Session/`) — singleton owns plan, activeStartDate, activeEndOverride, scheduledReady, eatingWindow anchor, one-shot tokens, prefs. All mutations go through its public API (`startFastingWithPlan:`, `editActiveStartDate:alignWithPlan:`, `finishFastingWithRecord:`, …). Mutations auto-persist. **There is NO session-change notification** — Idle/Active VCs pull fresh state via `FSTBaseViewController`'s 1-second refresh timer + `viewWillAppear` re-read (in-screen edits call `refreshUI` directly in the action handler). The 1s timer is load-bearing regardless: the countdown UI (ring / elapsed / remaining / percent / stage) is derived from `now - startDate` and must re-render every second even when no state mutates. Implementation is delegated to three services (`FSTSessionPersistenceService` / `FSTSessionLifecycleService` / `FSTNextFastService`) which are the only files allowed to import `FSTSessionManager+Internal.h`.

3. **Centralized navigation: `FSTAppRouter`** (`Common/Routing/`) — every push/present is a one-liner like `[FSTAppRouter pushActiveFastingFrom:self promptForStartTime:YES animated:YES]`. VCs do not alloc/init/configure peer VCs themselves. When adding a new navigation entry, extend `FSTAppRouter` rather than open-coding it in the caller.

4. **Theme umbrella: `FSTTheme.h`** (`Common/Theme/`) — single import that pulls in `UIColor+FST` (semantic color tokens like `fst_primaryGreen`), `UIButton+FST` / `UILabel+FSTStyle` factories, `UIView+FSTLayout` (`fst_pinEdgesToSuperview`, `fst_addSubviews:`, `fst_containerWithBackground:radius:`), base VCs, font helpers (`FSTFontBold(28)`), spacing/radius constants (`FSTSpacingM`, `FSTRadiusCard`), date formatters (`FSTFormatHHMMSS`, `FSTFormatRelativeDay`). **Business files import only `FSTTheme.h`** — do not re-import `UIColor+FST.h` etc.

5. **Generic modal base: `FSTBaseModalViewController`** (`Common/Base/`) — backs `FSTModalDialogViewController` (alert-style confirmation), `FSTTimeEditorSheetViewController` (bottom wheel-picker with Align chip), `FSTShareCardViewController`. New modals subclass this rather than rolling their own dimming background.

### Category placement rule

- **Generic UIKit behavior** (`UIView+FSTLayout`, `UIButton+FST`) → `Common/Categories/`
- **Visual tokens** (`UIColor+FST`) → `Common/Theme/` (lives with the tokens, NOT in Categories)
- **Class-specific or feature-specific** (`FSTFastingRecord+Persistence`, `FSTSessionManager+Internal`, `UIViewController+FSTTimeEditor`) → **next to the class/feature they extend**, not in generic Categories

### Persistence

Both session state and record lists live in `NSUserDefaults`. Session keys are centralized in `FSTSessionPersistenceService.m`; record dictionary arrays are managed by `FSTRecordsRepository`. Meal photos go to `Documents/meal-images/{UUID}.jpg` (JPEG 0.82). Notifications: only `FSTRecordsDidChangeNotification` (records add/delete; subscribed by Timeline / FastingHistory / MealDiary). **Session state changes are NOT broadcast** — Idle/Active VCs refresh via `FSTBaseViewController`'s 1s timer + `viewWillAppear` re-read + `UIApplicationWillEnterForegroundNotification` (see load-bearing pattern #2).

## Project-specific gotchas

1. **Don't name Masonry-attribute properties** `bottomAnchor` / `topAnchor` / `leadingAnchor` etc. on UIView subclasses — they collide with `NSLayoutYAxisAnchor` and produce confusing warnings/runtime issues.
2. **`userInteractionEnabled = NO`** on subviews inside a `UIControl` is intentional — it lets touches pass through to the control. Don't strip "redundant" `NO` assignments without checking parent type.
3. **Don't merge "similar" colors** in `UIColor+FST` — visually-close tokens are deliberate per-stage / per-semantic distinctions.
4. **No compatibility shims** — this is a test app, losing prior `NSUserDefaults` data is acceptable. Prefer clean code over migration logic.

## 开发约束规则（持续扩充）

这一节是项目级硬约束，违反任何一条都需要在 PR 描述里明确解释。新规则会在后续 commit review 里持续追加；既有规则不要悄悄废弃，要废就单独提出来讨论。

### R1. 禁止 `loadView` + cast getter 的 RootView 安装模板

**❌ 不要这么写：**

```objc
- (void)loadView {
    self.view = [FSTFastingHistoryRootView new];
}

- (FSTFastingHistoryRootView *)rootView {
    return (FSTFastingHistoryRootView *)self.view;
}
```

**✅ 正确写法：** `rootView` 作为 VC 的明确 property，在 `viewDidLoad` 里 alloc/init 并 addSubview 到 `self.view`，约束铺满。不要把 `self.view` 直接顶替成 rootView。

```objc
@interface FSTFastingHistoryViewController ()
@property (nonatomic, strong) FSTFastingHistoryRootView *rootView;
@end

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootView = [[FSTFastingHistoryRootView alloc] init];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
```

### R2. RootView 只管「自身布局」，禁止 VC 链式穿透到孙子视图

RootView 的职责是**摆放自己直接持有的子视图**；子视图内部内容（label 文案、timeline 起止时间、按钮配色等）由那个子视图自己暴露 setter 管理。VC 推数据到**直接子视图**，不要透过 RootView 反复 chain 三级以上属性访问。

**❌ 不要这么写：**

```objc
- (void)refreshPlanLabels {
    self.rootView.titleLabel.text = self.plan.name;
    NSDate *startDate = self.selectedStartDate ?: [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:self.plan.fastingHours * 3600.0];
    self.rootView.timelineView.startDate = startDate;
    self.rootView.timelineView.endDate   = endDate;
}
```

**✅ 正确做法：** 让 `timelineView` 自己暴露一个语义化 setter（如 `- (void)applyPlan:startDate:` 或 `model` property），由 VC 一次推入；或者让 RootView 暴露聚合 setter 把数据再往内层分发。

**判定 smell 的最简标准：出现 `self.rootView.xxxView.yyyProperty = …` 就是错的。**

### R3. UIView / UIViewController 一律用「最小 init + 配置 property」，不要长参 init

适用范围：**UIView 子类 + UIViewController 子类**。原则：**init 只接「对象身份必需的参数」（model / record / plan / snapshot 等"没有就无法识别这个对象"的东西）；其余「配置 / 展示 / 回调」类参数全部走 property setter，在 init 之后再设。**

判定 smell：如果你想给 init 加第 3 个参数、或者参数是 title / message / handlers / callbacks / colors / 显示开关之类「这个对象长成什么样」的描述，就属于配置，不该塞 init。

#### UIView 子类的标准模板

```objc
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviews { /* alloc + addSubview */ }
- (void)setupConstraints { /* Masonry */ }
```

**一次性建视图/约束的方法统一命名 `setupSubviews` / `setupConstraints`，不要用 `buildSubviews` 等别名。** 它对应 R10 初始化顺序里的「子视图 / 布局」两步；务必与系统的 `layoutSubviews` 区分——后者每次布局自动调、只做定位（见 R8、R10），不能把一次性建视图塞进去。

caller 端用 `[[Foo alloc] init]` + 一串 `.xxx = ...` 设配置（无参 init 写法见 R7）。**不要自造 `initWithLeftButton:rightButtons:centerContent:contentHeight:` 这种带一堆参数的 designated init。**

#### UIViewController 子类的对应做法

```objc
// .h
@interface FSTXxxViewController : UIViewController
// 身份参数（如有）通过 init 传：
- (instancetype)initWithRecord:(FSTFastingRecord *)record;
// 配置走 property：
@property (nonatomic, copy, nullable) NSString *titleText;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, copy, nullable) FSTActionHandler primaryHandler;
// ...
@end

// .m：viewDidLoad 里读 property 推到子视图
- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildContentView];
}
```

caller 端：

```objc
FSTXxxViewController *vc = [FSTXxxViewController new];     // 或 [[... alloc] initWithRecord:r]
vc.titleText = @"Hello";
vc.message   = @"...";
vc.primaryHandler = ^{ ... };
[self presentViewController:vc animated:YES completion:nil];
```

**❌ 反例**（FSTModalDialogViewController R6 阶段还残留的形态——8 参 init，绝大多数是配置）：

```objc
- (instancetype)initWithIconKind:(FSTModalDialogIconKind)iconKind
                        iconName:(nullable NSString *)iconName
                           title:(NSString *)title
                         message:(NSString *)message
                    primaryTitle:(NSString *)primaryTitle
                  secondaryTitle:(nullable NSString *)secondaryTitle
                  primaryHandler:(nullable FSTModalDialogActionHandler)primaryHandler
                secondaryHandler:(nullable FSTModalDialogActionHandler)secondaryHandler;
```

**✅ 正例**（同一个类的当前形态）：

```objc
@property (nonatomic, assign) FSTModalDialogIconKind iconKind;
@property (nonatomic, copy, nullable) NSString *iconName;
@property (nonatomic, copy, nullable) NSString *titleText;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, copy, nullable) NSString *primaryTitle;
@property (nonatomic, copy, nullable) NSString *secondaryTitle;
@property (nonatomic, copy, nullable) FSTModalDialogActionHandler primaryHandler;
@property (nonatomic, copy, nullable) FSTModalDialogActionHandler secondaryHandler;
```

#### 附加规则

**不要保留注释掉的旧代码。** 要删就彻底删，不要留 `//- (instancetype)initWithXxx:...` 这种几十行注释残留来"留个底"——git 已经存了。

#### R3 与 R6 的关系

R6 处理的是「两份并列长 init 仅首参数前缀不同」的细分 smell（用 enum 合并）。R3 是上位原则——即便 R6 合并完，单 init 仍 ≥3 参且大多是配置，就该按 R3 继续 property 化。本规则覆盖 R6 残留的"合并后仍过长"情况。

### R4. block 字面量不要写成单行花括号（含回调与 Masonry 约束 block）

适用于一切 block 字面量——回调赋值、Masonry `mas_makeConstraints:` 等都算。最初只约束回调，后在清理中发现单行 Masonry block 与多行写法混排破坏扫读一致性，遂扩展为全量 block。

**❌ 不要这么写：**

```objc
self.readyView.onChangePlanTapped = ^{ [weakSelf handleSoftChangePlanTapped]; };
self.pickerView.onPlanPicked = ^(FSTPlan *picked) { [weakSelf handlePlanTapped:picked]; };
[iconLabel mas_makeConstraints:^(MASConstraintMaker *make) { make.center.equalTo(iconBox); }];
```

**✅ 一律展开多行：**

```objc
self.readyView.onChangePlanTapped = ^{
    [weakSelf handleSoftChangePlanTapped];
};

self.pickerView.onPlanPicked = ^(FSTPlan *picked) {
    [weakSelf handlePlanTapped:picked];
};

[iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(iconBox);
}];
```

### R5. 单例初始化副作用放 `-init`，禁止 `+sharedManager` 二段式装配

**❌ 不要这么写：**

```objc
+ (instancetype)sharedManager {
    static FSTSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [FSTSessionManager new];
        [manager loadFromDefaults];   // ❌ 二段式装配
    });
    return manager;
}

- (void)loadFromDefaults {
    [FSTSessionPersistenceService loadSession:self];
}
```

**✅ load 放进 `-init`，`+sharedManager` 只做 `[ClassName new]`：**

```objc
+ (instancetype)sharedManager {
    static FSTSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [FSTSessionManager new];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [FSTSessionPersistenceService loadSession:self];
    }
    return self;
}
```

### R6. 仅"同语义不同来源"的参数差异 → 用 enum 分类合并 init，禁止并列长 init

判定 smell：两个 init selector **仅首参数前缀不同、其余完全镜像**（同 component 数、同顺序、同类型），就属于本规则范围。要么用 `NS_ENUM` 把"来源/种类"编进类型 + 单一 init，要么走 property setter；不要并列两份只差一个词的长 selector。读 caller 时不应该需要数到 selector 的某个位置才能区分调了哪个版本。

**❌ 不要这么写：**

```objc
- (instancetype)initWithIconSystemName:(nullable NSString *)systemName
                                  title:(NSString *)title
                                message:(NSString *)message
                           primaryTitle:(NSString *)primaryTitle
                         secondaryTitle:(nullable NSString *)secondaryTitle
                         primaryHandler:(nullable FSTModalDialogActionHandler)primaryHandler
                       secondaryHandler:(nullable FSTModalDialogActionHandler)secondaryHandler;

- (instancetype)initWithIconImageName:(nullable NSString *)imageName
                                 title:(NSString *)title
                               message:(NSString *)message
                          primaryTitle:(NSString *)primaryTitle
                        secondaryTitle:(nullable NSString *)secondaryTitle
                        primaryHandler:(nullable FSTModalDialogActionHandler)primaryHandler
                      secondaryHandler:(nullable FSTModalDialogActionHandler)secondaryHandler;
```

**✅ 正确写法：** 用 enum 编码"种类"，合并为单一 init。

```objc
typedef NS_ENUM(NSInteger, FSTModalDialogIconKind) {
    FSTModalDialogIconKindNone = 0,
    FSTModalDialogIconKindSystemSymbol,
    FSTModalDialogIconKindAssetImage,
};

- (instancetype)initWithIconKind:(FSTModalDialogIconKind)iconKind
                        iconName:(nullable NSString *)iconName
                           title:(NSString *)title
                         message:(NSString *)message
                    primaryTitle:(NSString *)primaryTitle
                  secondaryTitle:(nullable NSString *)secondaryTitle
                  primaryHandler:(nullable FSTModalDialogActionHandler)primaryHandler
                secondaryHandler:(nullable FSTModalDialogActionHandler)secondaryHandler;
```

caller 端可读性对比：第一行立即明示种类（`FSTModalDialogIconKindAssetImage` / `FSTModalDialogIconKindSystemSymbol`），不需要扫到 selector 中段去分辨 `SystemName` vs `ImageName`。

注：R6 处理的是"并列重复"问题。即便合并后 init 仍参数较多，也是单独决定要不要进一步转 property setter；不要混入本规则。

### R7. 无参 init 统一用 `[[Foo alloc] init]`，禁用 `[Foo new]`

虽然 `[Foo new]` 与 `[[Foo alloc] init]` 在 NSObject 层完全等价，但项目统一用 `[[Foo alloc] init]` 形式：

- **视觉对称**：与有参 init `[[Foo alloc] initWithXxx:...]` 写法一致，不需要在脑内做 `new ≡ alloc/init` 的二次映射
- **一致性**：多 init 并存时（默认 init + 带身份参 init）扫读不出现风格切换

适用范围：所有 `.m` / `.h`，包括 Modules / Common / Core / FastingTests。

**❌ 不要这么写：**

```objc
FSTModalDialogViewController *dialog = [FSTModalDialogViewController new];
self.scrollView = [UIScrollView new];
```

**✅ 要这么写：**

```objc
FSTModalDialogViewController *dialog = [[FSTModalDialogViewController alloc] init];
self.scrollView = [[UIScrollView alloc] init];
```

带参 init 形式不受影响：`[[FSTPlanConfirmViewController alloc] initWithPlan:plan]` 写法不变。

### R8. `layoutSubviews` 只做布局，禁止在其中刷新数据 / 做一次性配置

`layoutSubviews` 每次 bounds 变化都会被调用，只允许做「依赖最终 bounds 的布局」——CALayer.frame、贝塞尔路径、marker 锚点等（例：`FSTRingProgressView` / `FSTFastingRingPanelView` 在此更新环形 layer，是正确用法）。数据驱动的尺寸（按宽高比排布的图片列表等）用 Auto Layout 约束表达，让约束自然解析。

判定 smell：`layoutSubviews` 里出现 `reloadData` / 数据赋值 / 用 width-size 缓存标志（`lastLaidOutWidth` 之类）去 gate 一次刷新。

**❌ 不要这么写：**

```objc
@property (nonatomic, assign) CGFloat lastLaidOutWidth;

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.tableView.bounds);
    if (fabs(width - self.lastLaidOutWidth) > 0.5) {
        self.lastLaidOutWidth = width;
        [self.tableView reloadData];   // ❌ 在 layoutSubviews 里刷数据
    }
}
```

**✅ 正确做法：** 用约束表达尺寸（如 `make.height.equalTo(imageView.mas_width).multipliedBy(aspect)`），删掉 `layoutSubviews` 与缓存宽度标志，让 Auto Layout 自己解析。

### R9. 用 enum / type / index 表达身份与分支，禁止拿字符串 name / 控件 title 做判断

展示文案（model 的 `name`、按钮的 `title`、label 的 `text`）会改、会本地化，不该承担「身份」职责。模型层加 `NS_ENUM` type 字段；视图选中态用 `selectedIndex` / 持有选中引用 / `button.tag`。

判定 smell：`plan.name isEqualToString:` 区分方案、`button.currentTitle isEqualToString:` 判断选中、`label.text` 反推状态。

**❌ 不要这么写：**

```objc
for (FSTPlan *plan in [self defaultDailyPlans]) {
    if ([plan.name isEqualToString:name]) return plan;   // ❌ 拿展示名当身份
}

if ([chip.currentTitle isEqualToString:selectedTitle]) { // ❌ 拿 title 当选中态
    [self applySelectedStyle:chip];
}
```

**✅ 正确写法：**

```objc
typedef NS_ENUM(NSInteger, FSTPlanType) { FSTPlanTypeCustom = 0, FSTPlanType1410, FSTPlanType168, /* … */ };

if (plan.type == storedType) return plan;        // ✅ 按 type 匹配
if (chip == self.selectedChip) { … }             // ✅ 按状态/引用判断选中
```

（R6 用 enum 合并 init 是本规则的特例；R9 上位到「一切身份 / 状态判断」。）

### R10. UIView / UIControl 子类重写 `initWithFrame:`，禁止重写无参 `-init`；初始化顺序「数据 → 子视图 → 布局/刷新」

两条：

1. **重写 `initWithFrame:`，不要重写 `-init`。** `initWithFrame:` 是 UIView/UIControl 的 designated initializer。`[[Foo alloc] init]` 会自动路由到 `initWithFrame:CGRectZero`，所以 caller 写法不变（仍按 R7 用 `alloc/init`）。只重写 `-init` 时，一旦有人显式带 frame 创建就会漏掉装配，是脆弱写法。
2. **init 内部顺序：** 先备好数据 / 常量 → 再 `alloc` + `addSubview` 建子视图 → 最后 Masonry 布局 + 首次刷新。不要把「准备数据」散落到建视图、布局之后。

**❌ 不要这么写：**

```objc
- (instancetype)init {                       // ❌ UIView 子类重写无参 init
    if ((self = [super init])) {
        [self buildSubviews];
    }
    return self;
}
```

**✅ 正确写法：**

```objc
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self prepareData];      // 数据
        [self setupSubviews];    // 子视图
        [self setupConstraints]; // 布局/刷新
    }
    return self;
}
```

（与 R3 关系：R3 给的 UIView 模板正是 `initWithFrame:`；R10 把「必须 `initWithFrame:`、禁用 `-init`」显式化，并补充初始化顺序约束。UIViewController / 服务 / 单例的无参 `-init` 不受影响。）

### R11. 没有 cornerRadius、内容不溢出，就不要设 `clipsToBounds` / `masksToBounds`

要圆角就 `cornerRadius` + 裁剪**配套**设；不要圆角就两个都别加。给 `ScaleAspectFit` 的 `UIImageView` 单设 `clipsToBounds = YES` 却不设 `cornerRadius`——内容既不溢出、又没有圆角可裁——是「裁了个寂寞」，还可能盖掉资源本身自带的圆角。

**❌ 不要这么写：**

```objc
imageView.contentMode = UIViewContentModeScaleAspectFit;
imageView.clipsToBounds = YES;               // ❌ 没设 cornerRadius，纯多余
```

**✅ 正确写法：** 不需要圆角就删掉 `clipsToBounds`；需要圆角则

```objc
imageView.layer.cornerRadius = FSTRadiusCard;
imageView.clipsToBounds = YES;               // ✅ 与 cornerRadius 配套
```

### R12. 避免不必要的嵌套滚动视图

`UIScrollView` 里再塞 `UITableView` / `UICollectionView` / `UIScrollView`（哪怕内层 `scrollEnabled = NO`）就是 smell。静态、数量固定的内容用 `UIStackView` 承载；整页滚动只保留一层 scroll。嵌套滚动除了徒增手势 / 复用 / 高度计算复杂度，还常逼出 `layoutSubviews` 里手动 reload（见 R8）。

**❌ 不要这么写：** 外层竖直 `UIScrollView` → `contentView` → 一个 `scrollEnabled = NO` 的 `UITableView`（4 个固定 cell）。

**✅ 正确做法：** 外层 `UIScrollView` → `contentView` → `UIStackView`（4 个 image view，用宽高比约束撑高）。单一滚动层。

（注：本规则只针对「滚动视图嵌套」这一窄问题，不重提此前被回退的 RootView / 容器 autolayout 范式。）

### R13. 持久化模型的「身份」字段用 enum type，不要用展示名字符串（R9 在模型层的延伸）

R9 管「运行时判断别拿 name / title 字符串」；R13 把同一原则推到**持久化数据模型的存储**：一个 record / model 要表达「它是哪个方案 / 哪个类别」时，身份存 `XxxType` 枚举；展示名 `name` 只作展示，且**仅当存在自定义项、名字无法从枚举反推时才保留**。

判定 smell：model 里出现 `NSString *xxxName` 承担「是哪一个」的身份职责（如 `FSTFastingRecord` 早期只存 `planName=@"16-8"`）。展示名会改、会本地化、不可拓展，不该当身份。

范例（已是正确形态）：`FSTPlan`（`type` 身份 / `name` 仅展示）、`FSTMealRecord`（`mealCategory` / `dietType` 枚举 + `FSTMealCategoryDisplayName()` / `FSTDietTypeDisplayName()` 派生展示名）。

**❌ 不要这么写：**

```objc
@property (nonatomic, copy, nullable) NSString *planName;   // 既当展示又当身份
```

**✅ 正确写法：**

```objc
@property (nonatomic, assign) FSTPlanType planType;         // 身份（持久化为整数；缺省 0 = Custom，兜底旧数据）
@property (nonatomic, copy, nullable) NSString *planName;   // 仅展示（自定义方案名用户任取，故保留）
```

持久化时身份与展示名都写（`dictionary[@"planType"] = @(self.planType);`），读回时身份缺省落 `FSTXxxTypeCustom`。

### R14. 单例 / 服务的状态字段收敛进数据 model，manager 只持有并转发

判定 smell：一个 manager / service 顶部挂着一长串状态 property（plan、各种 date、各种 flag），想确认「这个状态到底存在哪」要在 manager 里翻；持久化映射又散在另一处。

正确：把这组状态字段定义进 `Core/Models/` 下的一个**纯数据 model**（如 `FSTSessionState`），manager 持有一个实例并把公开 getter / setter **转发**给它——字段定义集中、易找、易持久化、易单测；manager 只做编排（生命周期、派生计算、委托 service），不再是字段仓库。两条配套约束：

- **层级方向**：model 属 `Core/Models`，**不得反向 import 任何 Service**；相关 domain enum（如 `FSTScheduledReadySource`）随字段一起挪进 model 头文件，manager 头 `#import` 该 model 头以转发枚举与方法签名（外部引用零改动）。
- **初始化顺序**：manager `-init` 必须**先建好 model 实例再 load / 装配**——否则转发 setter 在 model 为 nil 时 message nil 静默丢值。

**❌ 不要这么写：**

```objc
// FSTSessionManager 上平铺 9 个状态 property，散落难找，持久化映射又在另一个文件
@property (nonatomic, strong, readonly, nullable) FSTPlan *currentPlan;
@property (nonatomic, strong, readonly, nullable) NSDate *activeStartDate;
// … 另外 7 个
```

**✅ 正确写法：**

```objc
// 字段集中定义在 FSTSessionState（model）；manager 私有持有 state 并转发：
@property (nonatomic, strong) FSTSessionState *state;   // class extension 私有

- (FSTPlan *)currentPlan {
    return self.state.currentPlan;
}
- (void)setCurrentPlan:(FSTPlan *)currentPlan {
    self.state.currentPlan = currentPlan;
}
```

公开 API 形状不变（仍是只读 property），故所有 VC / Service 调用方零改动；持久化 service 经转发属性收发，亦不感知。

---

## When adding files

- Follow existing folder placement (see ARCHITECTURE.md §三 module conventions): a new InputCard belongs in `Modules/Shared/AddRecord/.../InputCards/`; a new Session helper in `Core/Services/Session/`.
- Keep architectural files (`FSTSessionManager`, `FSTTheme`, services, base controllers) commented for design intent; routine View/Card classes need no copyright header.
- Do not rename or relocate existing files without a clear reason.
