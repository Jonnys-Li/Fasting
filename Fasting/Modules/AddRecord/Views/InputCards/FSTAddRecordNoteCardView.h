//
//  FSTAddRecordNoteCardView.h
//  Fasting
//
//  备注卡片：标题"记录" + 多行文本框（灰底，圆角 14）。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTAddRecordNoteCardView : UIView

/// 当前文本内容
@property (nonatomic, copy, nullable) NSString *text;

@end

NS_ASSUME_NONNULL_END
