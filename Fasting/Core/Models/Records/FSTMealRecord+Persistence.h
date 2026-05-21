//
//  FSTMealRecord+Persistence.h
//  Fasting
//
//  FSTMealRecord 与 NSDictionary 互转，供 NSUserDefaults 持久化使用。
//  独立成 Category 是为了把"数据声明"和"持久化策略"物理分离。
//

#import "FSTFastingRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealRecord (Persistence)

/// 从字典反序列化。容错：兼容旧 key `dateTI` / `mealSlot` / `detailText`。
+ (instancetype)fst_recordWithDictionary:(NSDictionary *)dictionary;

/// 序列化为字典，使用当前 key 形式。
- (NSDictionary *)fst_dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
