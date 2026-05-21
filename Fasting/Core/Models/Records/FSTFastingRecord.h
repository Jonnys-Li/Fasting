//
//  FSTFastingRecord.h
//  Fasting
//
//  断食与餐食历史记录的纯数据模型（FSTFastingRecord + FSTMealRecord）。
//  - 写入路径：
//    · FSTFastingRecord — 用户在 Active Fasting 页 END/COMPLETE → AddRecord 页填表保存 →
//      [FSTSessionManager finishFastingWithRecord:] 持久化到 NSUserDefaults。
//    · FSTMealRecord    — 用户在 Daily Plan 页 LogMeal 或 MealDiary 入口创建 →
//      [FSTSessionManager addOrUpdateMealRecord:] 落盘。
//  - 读取路径：
//    · FSTFastingRecord — FastingHistory 列表、Timeline 顶卡、统计计算（皆通过 sessionManager.allRecords 倒序取出）；
//    · FSTMealRecord    — MealDiary 列表、Timeline 餐食卡（皆通过 allMealRecords 倒序取出）。
//  - 持久化：由 FSTFastingRecord+Persistence 与 FSTMealRecord+Persistence 负责 NSDictionary 互转；
//    本模型保持纯净不含序列化代码。Step 7 已清掉旧 key 兼容分支。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingRecord : NSObject

/// 记录的全局唯一 ID（UUID 字符串）。
/// 创建时：Persistence 层在反序列化或新建时生成；用户从不直接接触。
/// 用途：作为 NSUserDefaults 数组里识别该记录的主键 — updateFastingRecord: / deleteFastingRecord: 按 ID 匹配。
@property (nonatomic, copy) NSString *recordID;

/// 断食发生时使用的计划名（写入快照，例 "14-10"、"16-8"、"18-6"、"20-4"）。
/// 等价于此次断食开始时的 FSTPlan.name；后续即使用户切换 plan 也不会回写。
/// 读取方：FSTFastingTimelineCardView 显示标题；difficultyLevel 反查依赖此字段的命名规则。
@property (nonatomic, copy) NSString *planName;

/// 此次断食的目标时长（小时），写入时 = FSTPlan.fastingHours。
/// 注意：endDate - startDate 可能与此不符，因为用户可以编辑 Ends 偏离 plan 默认对齐。
/// 用于 -difficultyLevel 反查、历史卡片的"目标 vs 实际"对比。
@property (nonatomic, assign) NSInteger fastingHours;

/// 断食开始 / 结束时间。两者都由 SessionManager 在 finishFastingWithRecord: 时确定快照。
/// 读取方：Timeline 卡显示开始/结束时间；durationSeconds 据此计算实际时长。
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

/// 体重快照（kg）。weightKg = 当次结束时的体重；initialWeightKg / targetWeightKg = 起始与目标。
/// 写入方：AddRecord 页 FSTAddRecordWeightCardView（用户每次可调整）。
/// 单位约定：内部恒以 kg 存储；FSTWeightUnitToggleView 切换 lb 只影响 UI，输入会换算回 kg。
@property (nonatomic, assign) CGFloat weightKg;
@property (nonatomic, assign) CGFloat initialWeightKg;
@property (nonatomic, assign) CGFloat targetWeightKg;

/// 是否同步本次记录到 Apple Health。
/// 当前 App 未真正接入 HealthKit；保留字段以便未来开关接入时无需迁移数据。
@property (nonatomic, assign) BOOL appleHealthEnabled;

/// 断食难度反馈（0 / 1 / 2）。
/// 写入方：AddRecord 页 FSTAddRecordFeelingCardView 的 3 个 emoji 按钮（皱眉 / 平脸 / 笑脸）。
/// 读取方：FSTFastingTimelineCardView.configureWithRecord: 把它转成 FSTFastingRating（注意：枚举顺序相反）。
/// 取值：0 = 有点难 😣，1 = 还可以 😐，2 = 简单 😊。
///
/// ⚠️ 与 FSTFastingRating 顺序相反（FSTFastingRating: 0=Easy/1=Ok/2=Hard）。
/// 跨界使用时需要 `2 - feelingLevel` 翻转，详见 FSTFastingTimelineCardView.h 的陷阱注释。
@property (nonatomic, assign) NSInteger feelingLevel;

/// 用户在 AddRecord 页填的备注（FSTAddRecordNoteCardView）。
/// 当前展示场景：FSTFastingTimelineCardView 详情卡的二级显示（待实现）。
@property (nonatomic, copy) NSString *note;

/// 实际断食时长（秒）= endDate - startDate。
/// 不做负数钳制：调用方（FSTFastingTimelineCardView）需自行容错。
/// 与 fastingHours*3600 可能不等（用户编辑了 endDate）。
- (NSTimeInterval)durationSeconds;

/// 基于 fastingHours 反查 FSTPlan 的 difficultyLevel（1~4）。
/// 来由：历史记录只存了 fastingHours、未存 difficulty；这里反推与 FSTPlan 一致的等级。
/// 用途：FSTFastingCardCell 渲染右上角难度色块（4 色对应 4 个内置 plan）。
- (NSInteger)difficultyLevel;

@end

@interface FSTMealRecord : NSObject

/// 全局唯一 ID（UUID）。
/// 用途：addOrUpdateMealRecord: / deleteMealRecord: 按 ID 匹配定位记录。
@property (nonatomic, copy) NSString *recordID;

/// 这餐发生的时间。
/// 写入方：MealDetail 页 FSTMealTimeCardView（默认 now，可手动调整）。
/// 读取方：MealDiary 列表按 date 倒序展示；nextFastingStartDate 推导也参考 latestMealDate。
@property (nonatomic, strong) NSDate *date;

/// 餐次类别 — 字符串作枚举使用。
/// 写入方：MealDetail 页 FSTMealSlotCardView。
/// 取值约定（PropertyCard 与 Persistence 各自硬编码相同字符串）："正餐" / "零食"。
@property (nonatomic, copy) NSString *mealCategory;

/// 饮食类型 — 字符串作枚举使用。
/// 写入方：MealDetail 页 FSTMealDietCardView。
/// 取值约定："生酮饮食" / "低碳饮食" / "混合式饮食" / "高碳饮食" / "我不确定"。
@property (nonatomic, copy) NSString *dietType;

/// 口味评分（0 / 1 / 2）。
/// 写入方：MealDetail 页 FSTMealTasteCardView（3 个 emoji 按钮）。
/// 取值：0 = 糟糕 🤢，1 = 还可以 😐，2 = 美味 😋。
@property (nonatomic, assign) NSInteger tasteLevel;

/// 用户填写的文字描述。
/// 写入方：MealDetail 页 FSTMealDetailContentCardView 的多行输入框。
@property (nonatomic, copy) NSString *detailDescription;

/// 照片相对路径（"MealImages/{UUID}.jpg"），缺省 ""（无图）。
/// 写入方：MealDetail 页选图后由 [FSTMealImageService saveImage:] 返回的相对路径。
/// 读取方：MealDiary / MealDetail 拼上 NSDocumentDirectory 加载图片。
@property (nonatomic, copy) NSString *imagePath;

@end

NS_ASSUME_NONNULL_END
