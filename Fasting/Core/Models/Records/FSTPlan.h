//
//  FSTPlan.h
//  Fasting
//
//  断食方案数据模型 + 内置默认方案工厂。
//  持久化由 +Persistence category 负责 NSDictionary 互转。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTPlan : NSObject

@property (nonatomic, copy) NSString *name;             ///< "14-10" / "16-8" / "18-6" / "20-4"
@property (nonatomic, assign) NSInteger fastingHours;    ///< 断食小时数
@property (nonatomic, assign) NSInteger eatingHours;     ///< 吃窗口小时数，与 fastingHours 之和 = 24
@property (nonatomic, assign) NSInteger difficultyLevel; ///< 难度 1~4
@property (nonatomic, assign) uint32_t cardBackgroundHex;
@property (nonatomic, assign) uint32_t accentBoltHex;

/// 返回 4 个内置 daily plan（14-10 / 16-8 / 18-6 / 20-4）。每次调用返回新对象。
+ (NSArray<FSTPlan *> *)defaultDailyPlans;

@end

@interface FSTPlan (Persistence)
+ (nullable instancetype)fst_planWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)fst_dictionaryRepresentation;
@end

NS_ASSUME_NONNULL_END
