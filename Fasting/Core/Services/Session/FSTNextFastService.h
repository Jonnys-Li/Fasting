//
//  FSTNextFastService.h
//  Fasting
//
//  推导下一次断食起点（基于 records + plan + override）。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FSTSessionManager;

@interface FSTNextFastService : NSObject

+ (NSDate *_Nullable)nextStartDateForSession:(FSTSessionManager *)session;

@end

NS_ASSUME_NONNULL_END
