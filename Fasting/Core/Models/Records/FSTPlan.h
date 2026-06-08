//
//  FSTPlan.h
//  Fasting
//
//  断食方案数据模型 + 内置默认方案工厂。
//  持久化由 +Persistence category 负责 NSDictionary 互转。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// NOTE:plan用type分类（R9）
typedef NS_ENUM(NSInteger, FSTPlanType) {
    FSTPlanTypeCustom = 0,  ///< 非内置方案（自定义 / 历史脏数据兜底）
    FSTPlanType1410,        ///< 14-10
    FSTPlanType168,         ///< 16-8
    FSTPlanType186,         ///< 18-6
    FSTPlanType204,         ///< 20-4
};

@interface FSTPlan : NSObject

@property (nonatomic, assign) FSTPlanType type;          ///< 方案身份（区分内置方案用它，不要用 name）
@property (nonatomic, copy) NSString *name;             ///< 展示名 "14-10" / "16-8" / "18-6" / "20-4"（仅展示，非身份）
@property (nonatomic, assign) NSInteger fastingHours;    ///< 断食小时数
@property (nonatomic, assign) NSInteger eatingHours;     ///< 吃窗口小时数，与 fastingHours 之和 = 24
@property (nonatomic, assign) NSInteger difficultyLevel; ///< 难度 1~4

/// 返回 4 个内置 daily plan（14-10 / 16-8 / 18-6 / 20-4）。每次调用返回新对象。
+ (NSArray<FSTPlan *> *)defaultDailyPlans;

@end

@interface FSTPlan (Persistence)
+ (nullable instancetype)fst_planWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)fst_dictionaryRepresentation;
@end

NS_ASSUME_NONNULL_END
