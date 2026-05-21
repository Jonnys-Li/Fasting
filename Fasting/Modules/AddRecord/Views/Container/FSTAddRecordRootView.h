//
//  FSTAddRecordRootView.h
//  Fasting
//
//  添加/编辑断食记录页的根视图：顶部绿色 header + 4 张卡片纵向滚动 + 底部取消/保存按钮。
//

#import <UIKit/UIKit.h>

@class FSTAddRecordHeaderView;
@class FSTAddRecordTimeCardView;
@class FSTAddRecordWeightCardView;
@class FSTAddRecordFeelingCardView;
@class FSTAddRecordNoteCardView;

NS_ASSUME_NONNULL_BEGIN

/// AddRecord 页的根视图。承担全部 UI 创建与 Masonry 约束，
/// VC 仅负责通过暴露的子视图属性进行状态推送与回调接线。
@interface FSTAddRecordRootView : UIView

/// 顶部绿色 header。
@property (nonatomic, strong, readonly) FSTAddRecordHeaderView *headerView;

/// 时间卡片。
@property (nonatomic, strong, readonly) FSTAddRecordTimeCardView *timeCardView;

/// 体重卡片。
@property (nonatomic, strong, readonly) FSTAddRecordWeightCardView *weightCardView;

/// 心情卡片。
@property (nonatomic, strong, readonly) FSTAddRecordFeelingCardView *feelingCardView;

/// 备注卡片。
@property (nonatomic, strong, readonly) FSTAddRecordNoteCardView *noteCardView;

/// 底部"取消"按钮点击回调。
@property (nonatomic, copy, nullable) void (^onCancelTapped)(void);

/// 底部"保存"按钮点击回调。
@property (nonatomic, copy, nullable) void (^onSaveTapped)(void);

@end

NS_ASSUME_NONNULL_END
