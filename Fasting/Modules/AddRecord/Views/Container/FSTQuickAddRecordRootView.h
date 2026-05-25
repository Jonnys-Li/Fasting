//
//  FSTQuickAddRecordRootView.h
//  Fasting
//
//  快速添加断食记录页的根视图：选择开始/结束时间 + 保存按钮。
//

#import <UIKit/UIKit.h>

@class FSTTimeRowView;

NS_ASSUME_NONNULL_BEGIN

/// QuickAddRecord 页的根视图。承担全部 UI 创建与 Masonry 约束，
/// VC 仅负责通过暴露的子视图属性进行状态推送与回调接线。
@interface FSTQuickAddRecordRootView : UIView

/// 断食时长数值（如 "13hr 24min"）。
@property (nonatomic, strong, readonly) UILabel *durationValueLabel;

/// 开始时间行（绿点 + "Fast starts" + 时间 + picker）。
@property (nonatomic, strong, readonly) FSTTimeRowView *startRow;

/// 结束时间行（红点 + "Fast ends" + 时间 + picker）。
@property (nonatomic, strong, readonly) FSTTimeRowView *endRow;

/// 返回按钮点击回调。
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

/// 保存按钮点击回调。
@property (nonatomic, copy, nullable) void (^onSaveTapped)(void);

@end

NS_ASSUME_NONNULL_END
