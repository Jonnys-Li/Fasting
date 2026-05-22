//
//  FSTWeightUnit.h
//  Fasting
//

#import <Foundation/Foundation.h>

/// Weight unit — affects UI display only; persistence always uses kg.
typedef NS_ENUM(NSInteger, FSTWeightUnit) {
    FSTWeightUnitKg = 0,
    FSTWeightUnitLb,
};
