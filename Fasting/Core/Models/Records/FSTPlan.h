//
//  FSTPlan.h
//  Fasting
//
//  断食方案的纯数据模型 + 内置默认方案工厂。
//  - 角色：定义一种"几小时断食 + 几小时吃窗"的搭配；颜色随 Plan 一起携带是为了让 PlanSelect 卡片配色可配置。
//  - 写入路径：[FSTPlan defaultDailyPlans] 提供 4 个内置选项；用户通过 PlanSelect 页选定后写入 sessionManager.currentPlan。
//  - 读取路径：几乎全 App 都在读 currentPlan — Plan/ActiveFasting/AddRecord 页都靠它决定 UI 与计算。
//  - 持久化：FSTPlan+Persistence 负责 NSDictionary 互转；存的是字段快照，不存自定义 plan（当前只有 4 个内置）。
//  - 与 FSTFastingRecord 的关系：开始断食时把 plan.name / plan.fastingHours 拷贝到 Record，
//    历史 Record 不依赖 plan 是否还存在（plan 改名/删除不影响历史）。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTPlan : NSObject

/// 方案名（"14-10" / "16-8" / "18-6" / "20-4"）。
/// 用户视角：显示在 ChipPill、PlanSelect 卡片、ActiveFasting 圆环胶囊上。
/// 系统视角：被拷贝到 FSTFastingRecord.planName；也作为字符串 key 在 PlanConfirm 等页面的内置文案查找中使用。
@property (nonatomic, copy) NSString *name;

/// 断食小时数 + 吃窗口小时数。两者相加应 = 24（内置 4 plan 都遵守）。
/// fastingHours 决定 Active Fasting 的 targetDurationSeconds（× 3600）；
/// eatingHours 决定吃窗口长度（FSTEatingWindowService 用它推导 remainingSeconds）。
@property (nonatomic, assign) NSInteger fastingHours;
@property (nonatomic, assign) NSInteger eatingHours;

/// 难度等级 1~4，与 defaultDailyPlans 的顺序对应（14-10=1 / 16-8=2 / 18-6=3 / 20-4=4）。
/// 写入方：仅在 +defaultDailyPlans 构造时赋值；非内置 plan 暂无场景。
/// 读取方：FSTPlanSelectListView 显示难度标签；FSTFastingRecord.difficultyLevel 通过 fastingHours 反查到此值。
@property (nonatomic, assign) NSInteger difficultyLevel;

/// 该方案卡片的背景色。
/// 读取方：FSTPlanChipPillView（小胶囊）、FSTPlanSelectListView（大卡片）的背景；
///         与 accentBoltColor 配对形成视觉层次。
@property (nonatomic, strong) UIColor *cardBackgroundColor;

/// 该方案"闪电"图标的强调色（PlanSelect 卡片上的小图标）。
/// 与 cardBackgroundColor 同色系但更饱和；当前 4 个 plan 各对应一组配色。
@property (nonatomic, strong) UIColor *accentBoltColor;

/// 工厂：返回 4 个内置 daily plan（14-10 / 16-8 / 18-6 / 20-4，难度 1~4 升序）。
/// 调用方：FSTPlanSelectListView 在加载时填充列表；FSTDailyPlanPickerView 也会用作首次引导态的选项源。
/// 注意：每次调用返回新对象数组（非缓存单例），改动返回值不会影响别处。
+ (NSArray<FSTPlan *> *)defaultDailyPlans;

@end

NS_ASSUME_NONNULL_END
