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

2. **Single state authority: `FSTSessionManager`** (`Core/Services/Session/`) — singleton owns plan, activeStartDate, activeEndOverride, scheduledReady, eatingWindow anchor, one-shot tokens, prefs. All mutations go through its public API (`startFastingWithPlan:`, `editActiveStartDate:alignWithPlan:`, `finishFastingWithRecord:`, …). Mutations auto-persist + post `FSTSessionDidChangeNotification`. Implementation is delegated to three services (`FSTSessionPersistenceService` / `FSTSessionLifecycleService` / `FSTNextFastService`) which are the only files allowed to import `FSTSessionManager+Internal.h`.

3. **Centralized navigation: `FSTAppRouter`** (`Common/Routing/`) — every push/present is a one-liner like `[FSTAppRouter pushActiveFastingFrom:self promptForStartTime:YES animated:YES]`. VCs do not alloc/init/configure peer VCs themselves. When adding a new navigation entry, extend `FSTAppRouter` rather than open-coding it in the caller.

4. **Theme umbrella: `FSTTheme.h`** (`Common/Theme/`) — single import that pulls in `UIColor+FST` (semantic color tokens like `fst_primaryGreen`), `UIButton+FST` / `UILabel+FSTStyle` factories, `UIView+FSTLayout` (`fst_pinEdgesToSuperview`, `fst_addSubviews:`, `fst_containerWithBackground:radius:`), base VCs, font helpers (`FSTFontBold(28)`), spacing/radius constants (`FSTSpacingM`, `FSTRadiusCard`), date formatters (`FSTFormatHHMMSS`, `FSTFormatRelativeDay`). **Business files import only `FSTTheme.h`** — do not re-import `UIColor+FST.h` etc.

5. **Generic modal base: `FSTBaseModalViewController`** (`Common/Base/`) — backs `FSTModalDialogViewController` (alert-style confirmation), `FSTTimeEditorSheetViewController` (bottom wheel-picker with Align chip), `FSTShareCardViewController`. New modals subclass this rather than rolling their own dimming background.

### Category placement rule

- **Generic UIKit behavior** (`UIView+FSTLayout`, `UIButton+FST`) → `Common/Categories/`
- **Visual tokens** (`UIColor+FST`) → `Common/Theme/` (lives with the tokens, NOT in Categories)
- **Class-specific or feature-specific** (`FSTFastingRecord+Persistence`, `FSTSessionManager+Internal`, `UIViewController+FSTTimeEditor`) → **next to the class/feature they extend**, not in generic Categories

### Persistence

Both session state and record lists live in `NSUserDefaults`. Session keys are centralized in `FSTSessionPersistenceService.m`; record dictionary arrays are managed by `FSTRecordsRepository`. Meal photos go to `Documents/meal-images/{UUID}.jpg` (JPEG 0.82). Notifications: `FSTSessionDidChangeNotification` (subscribed by Idle + Active VCs), `FSTRecordsDidChangeNotification` (Timeline / History / MealDiary).

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

### R3. UIView 子类一律用 `initWithFrame:` + `setupSubviews` + `setupConstraints` 标准模板

不要自己造带一堆参数的 designated init（`initWithLeftButton:rightButtons:centerContent:contentHeight:`）。配置参数通过 property setter 在 init 之后再设。

**✅ 标准模板：**

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

**附加：不要保留注释掉的旧代码。** 要删就彻底删,不要留 `//- (instancetype)initWithXxx:...` 这种几十行注释残留来"留个底"——git 已经存了。

### R4. block 回调不要写成单行花括号

**❌ 不要这么写：**

```objc
self.readyView.onChangePlanTapped = ^{ [weakSelf handleSoftChangePlanTapped]; };
self.pickerView.onPlanPicked = ^(FSTPlan *picked) { [weakSelf handlePlanTapped:picked]; };
```

**✅ 一律展开多行：**

```objc
self.readyView.onChangePlanTapped = ^{
    [weakSelf handleSoftChangePlanTapped];
};

self.pickerView.onPlanPicked = ^(FSTPlan *picked) {
    [weakSelf handlePlanTapped:picked];
};
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

---

## When adding files

- Follow existing folder placement (see ARCHITECTURE.md §三 module conventions): a new InputCard belongs in `Modules/Shared/AddRecord/.../InputCards/`; a new Session helper in `Core/Services/Session/`.
- Keep architectural files (`FSTSessionManager`, `FSTTheme`, services, base controllers) commented for design intent; routine View/Card classes need no copyright header.
- Do not rename or relocate existing files without a clear reason.
