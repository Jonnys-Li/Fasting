//
//  FSTAddRecordNoteCardView.h
//  Fasting
//
//  备注卡片：标题"记录" + 多行文本框（灰底，圆角 14）。
//

#import "FSTAddRecordBaseCardView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTAddRecordNoteCardView : FSTAddRecordBaseCardView

/// 当前文本内容
@property (nonatomic, copy, nullable) NSString *text;

@end

NS_ASSUME_NONNULL_END
