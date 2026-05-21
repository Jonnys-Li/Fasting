//
//  FSTPlan+Persistence.h
//  Fasting
//
//  FSTPlan 与 NSDictionary 互转，供 NSUserDefaults 持久化使用。
//  独立成 Category 是为了把"数据声明"和"持久化策略"物理分离。
//

#import "FSTPlan.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTPlan (Persistence)

/// 从字典反序列化。优先按 `name` 在 +defaultDailyPlans 中匹配；找不到时按字段回退构造。
+ (nullable instancetype)fst_planWithDictionary:(NSDictionary *)dictionary;

/// 序列化为字典。装饰用的颜色不参与持久化（重读时由默认计划恢复）。
- (NSDictionary *)fst_dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
