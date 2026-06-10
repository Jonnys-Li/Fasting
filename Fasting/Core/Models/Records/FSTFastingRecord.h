//
//  FSTFastingRecord.h
//  Fasting
//
//  断食记录与餐食记录的纯数据模型。
//  持久化由 +Persistence category 负责 NSDictionary 互转。
//

#import <Foundation/Foundation.h>
#import "FSTMealTypes.h"

NS_ASSUME_NONNULL_BEGIN

// ───────────────────────────────────────────────
// MARK: - 体重默认值（kg）
// ───────────────────────────────────────────────

extern const CGFloat FSTDefaultCurrentWeightKg;  ///< 当前体重默认值
extern const CGFloat FSTDefaultInitialWeightKg;  ///< 初始体重默认值
extern const CGFloat FSTDefaultTargetWeightKg;   ///< 目标体重默认值

/// 体重取值守卫：value > 0 取 value，否则取 fallback（避免未设置的 0 值参与展示/计算）。
static inline CGFloat FSTWeightOrDefault(CGFloat value, CGFloat fallback) {
    return value > 0 ? value : fallback;
}

// ───────────────────────────────────────────────
// MARK: - FSTFastingRecord
// ───────────────────────────────────────────────

@interface FSTFastingRecord : NSObject

@property (nonatomic, copy) NSString *recordID;             ///< UUID 主键
@property (nonatomic, copy, nullable) NSString *planName;   ///< 断食时使用的计划名（如 "16-8"）
@property (nonatomic, assign) NSInteger fastingHours;       ///< 目标时长（小时），写入时 = FSTPlan.fastingHours
@property (nonatomic, strong, nullable) NSDate *startDate;
@property (nonatomic, strong, nullable) NSDate *endDate;
@property (nonatomic, assign) CGFloat weightKg;             ///< 当次结束时的体重（kg）
@property (nonatomic, assign) CGFloat initialWeightKg;
@property (nonatomic, assign) CGFloat targetWeightKg;
@property (nonatomic, assign) BOOL appleHealthEnabled;      ///< 预留字段，当前未接入 HealthKit
@property (nonatomic, assign) NSInteger feelingLevel;       ///< 0=有点难, 1=还可以, 2=简单
@property (nonatomic, copy, nullable) NSString *note;

- (NSTimeInterval)durationSeconds;  ///< endDate - startDate
- (NSInteger)difficultyLevel;       ///< 基于 fastingHours 反查 1~4

@end

@interface FSTFastingRecord (Persistence)
+ (instancetype)fst_recordWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)fst_dictionaryRepresentation;
@end

// ───────────────────────────────────────────────
// MARK: - FSTMealRecord
// ───────────────────────────────────────────────

@interface FSTMealRecord : NSObject <NSCopying>

@property (nonatomic, copy) NSString *recordID;
@property (nonatomic, strong, nullable) NSDate *date;
@property (nonatomic, assign) FSTMealCategory mealCategory;        ///< 餐次类别（默认 Meal）
@property (nonatomic, assign) FSTDietType dietType;                ///< 饮食类型（默认 NotSure，-init 显式设置）
@property (nonatomic, assign) NSInteger tasteLevel;                ///< 0=糟糕, 1=还可以, 2=美味
@property (nonatomic, copy, nullable) NSString *detailDescription;
@property (nonatomic, copy, nullable) NSString *imagePath;         ///< "MealImages/{UUID}.jpg"

@end

@interface FSTMealRecord (Persistence)
+ (instancetype)fst_recordWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)fst_dictionaryRepresentation;
@end

NS_ASSUME_NONNULL_END
