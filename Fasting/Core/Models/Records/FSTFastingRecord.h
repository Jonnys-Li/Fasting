//
//  FSTFastingRecord.h
//  Fasting
//
//  断食记录与餐食记录的纯数据模型。
//  持久化由 +Persistence category 负责 NSDictionary 互转。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// ───────────────────────────────────────────────
// MARK: - FSTFastingRecord
// ───────────────────────────────────────────────

@interface FSTFastingRecord : NSObject

@property (nonatomic, copy) NSString *recordID;       ///< UUID 主键
@property (nonatomic, copy) NSString *planName;        ///< 断食时使用的计划名（如 "16-8"）
@property (nonatomic, assign) NSInteger fastingHours;  ///< 目标时长（小时），写入时 = FSTPlan.fastingHours
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) CGFloat weightKg;        ///< 当次结束时的体重（kg）
@property (nonatomic, assign) CGFloat initialWeightKg;
@property (nonatomic, assign) CGFloat targetWeightKg;
@property (nonatomic, assign) BOOL appleHealthEnabled; ///< 预留字段，当前未接入 HealthKit
@property (nonatomic, assign) NSInteger feelingLevel;  ///< 0=有点难, 1=还可以, 2=简单
@property (nonatomic, copy) NSString *note;

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

@interface FSTMealRecord : NSObject

@property (nonatomic, copy) NSString *recordID;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *mealCategory;      ///< "正餐" / "零食"
@property (nonatomic, copy) NSString *dietType;           ///< "生酮饮食" / "低碳饮食" / …
@property (nonatomic, assign) NSInteger tasteLevel;       ///< 0=糟糕, 1=还可以, 2=美味
@property (nonatomic, copy) NSString *detailDescription;
@property (nonatomic, copy) NSString *imagePath;          ///< "MealImages/{UUID}.jpg"

@end

@interface FSTMealRecord (Persistence)
+ (instancetype)fst_recordWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)fst_dictionaryRepresentation;
@end

NS_ASSUME_NONNULL_END
