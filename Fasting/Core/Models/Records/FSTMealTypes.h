//
//  FSTMealTypes.h
//  Fasting
//
//  餐食记录的类别 / 饮食类型枚举与展示映射（R9：身份用 enum，展示名只做映射输出）。
//  持久化存 rawValue 整数，见 FSTMealRecord+Persistence。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 餐次类别。
typedef NS_ENUM(NSInteger, FSTMealCategory) {
    FSTMealCategoryMeal = 0,   ///< 正餐（默认）
    FSTMealCategorySnack,      ///< 零食
};

/// 饮食类型。rawValue 顺序 == Diet 卡片展示行顺序，行选中可直接 `row.tag == dietType` 比对。
typedef NS_ENUM(NSInteger, FSTDietType) {
    FSTDietTypeKeto = 0,       ///< 生酮
    FSTDietTypeLowCarb,        ///< 低碳
    FSTDietTypeMixed,          ///< 均衡
    FSTDietTypeHighCarb,       ///< 高碳
    FSTDietTypeNotSure,        ///< 不确定（默认；注意 raw 非 0，FSTMealRecord -init 里显式设置）
};

/// 餐次类别 → 展示名。
static inline NSString *FSTMealCategoryDisplayName(FSTMealCategory category) {
    return category == FSTMealCategorySnack ? @"Snack" : @"Meal";
}

/// 餐次类别 → emoji 图标文本。
static inline NSString *FSTMealCategoryIconText(FSTMealCategory category) {
    return category == FSTMealCategorySnack ? @"🍎" : @"🍽️";
}

/// 饮食类型 → 展示名。
static inline NSString *FSTDietTypeDisplayName(FSTDietType dietType) {
    switch (dietType) {
        case FSTDietTypeKeto:     return @"Keto";
        case FSTDietTypeLowCarb:  return @"Low-carb";
        case FSTDietTypeMixed:    return @"Mixed";
        case FSTDietTypeHighCarb: return @"High-carb";
        case FSTDietTypeNotSure:  return @"Not sure";
    }
    return @"Not sure";
}

NS_ASSUME_NONNULL_END
