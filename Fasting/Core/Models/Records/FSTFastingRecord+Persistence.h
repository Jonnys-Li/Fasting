//
//  FSTFastingRecord+Persistence.h
//  Fasting
//
//  FSTFastingRecord 与 NSDictionary 互转，供 NSUserDefaults 持久化使用。
//  独立成 Category 是为了把"数据声明"和"持久化策略"物理分离，
//  Model 自身保持纯净，未来扩展或换持久化方案时只动这个文件。
//

#import "FSTFastingRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingRecord (Persistence)

/// 从字典反序列化。容错：缺失字段使用默认值；兼容旧 key `startTI` / `endTI`。
+ (instancetype)fst_recordWithDictionary:(NSDictionary *)dictionary;

/// 序列化为字典，键名采用新版 `*TimeInterval` 形式。
- (NSDictionary *)fst_dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
