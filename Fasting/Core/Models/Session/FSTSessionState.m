//
//  FSTSessionState.m
//  Fasting
//
//  纯数据模型，无逻辑——所有字段为自动合成属性，默认零值即等价于"全新无会话"状态
//  （scheduledReadySource=None、preferredWeightUnit=0、各 BOOL=NO、各 NSDate=nil），
//  由 FSTSessionPersistenceService.loadSession: 从 NSUserDefaults 覆盖。
//

#import "FSTSessionState.h"

@implementation FSTSessionState

@end
