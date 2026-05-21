//
//  FSTFastingTimesRow.h
//  Fasting
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 通用"两列时间行"：左 Start / 右 Ends，每列 caption 在上、time + pencil 在下。
/// 取代 FSTFastingTimelineRowView 与 FSTNextFastTimesRowView。
@interface FSTFastingTimesRow : UIView

/// @param startCaption          左列标题（"Start" / "Next fast starts"）
/// @param endCaption            右列标题（"Ends" / "Next fast ends"）
/// @param editable              true 时在每列右侧渲染可点击的铅笔；false 时无铅笔
/// @param startHighlightColor   左列 time 颜色（如绿色高亮）；nil → fst_textPrimary
- (instancetype)initWithStartCaption:(NSString *)startCaption
                          endCaption:(NSString *)endCaption
                            editable:(BOOL)editable
                 startHighlightColor:(nullable UIColor *)startHighlightColor NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@property (nonatomic, copy, nullable) NSString *startText;
@property (nonatomic, copy, nullable) NSString *endText;

@property (nonatomic, copy, nullable) dispatch_block_t onEditStartTapped;
@property (nonatomic, copy, nullable) dispatch_block_t onEditEndTapped;

@end

NS_ASSUME_NONNULL_END
