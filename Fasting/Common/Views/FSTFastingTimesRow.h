//
//  FSTFastingTimesRow.h
//  Fasting
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 通用"两列时间行"：左 Start / 右 Ends，每列 caption 在上、time + pencil 在下。
/// 使用方式：[[FSTFastingTimesRow alloc] init]，先 set startCaption/endCaption（其它属性可选），
/// 然后再 set startText/endText 显示时间。pencil 默认可见，editable=NO 可隐藏。
@interface FSTFastingTimesRow : UIView

/// 左列标题（"Start" / "Next fast starts"）。
@property (nonatomic, copy, nullable) NSString *startCaption;

/// 右列标题（"Ends" / "Next fast ends"）。
@property (nonatomic, copy, nullable) NSString *endCaption;

/// YES（默认）= 每列右侧渲染可点击的铅笔；NO = 隐藏铅笔。
@property (nonatomic, assign) BOOL editable;

/// 左列 time 颜色（如绿色高亮）；nil → fst_textPrimary。
@property (nonatomic, strong, nullable) UIColor *startHighlightColor;

@property (nonatomic, copy, nullable) NSString *startText;
@property (nonatomic, copy, nullable) NSString *endText;

@property (nonatomic, copy, nullable) dispatch_block_t onEditStartTapped;
@property (nonatomic, copy, nullable) dispatch_block_t onEditEndTapped;

@end

NS_ASSUME_NONNULL_END
