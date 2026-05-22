//
//  FSTWeightInputCardView.h
//  Fasting
//
//  体重输入弹窗的卡片视图：负责 UI 构建、kg/lb 切换、数字输入。
//  外部通过 weightKg 属性读写、onClose/onSave block 接收事件。
//

#import <UIKit/UIKit.h>
#import "FSTWeightUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTWeightInputCardView : UIView

/// 当前体重（kg），内部始终以 kg 存储；切换到 lb 仅影响显示。
@property (nonatomic, assign) CGFloat weightKg;

/// Initial unit to show. Set before view appears.
@property (nonatomic, assign) FSTWeightUnit initialUnit;

/// Current unit after user interaction. Read on save to persist preference.
@property (nonatomic, readonly) FSTWeightUnit currentUnit;

/// 关闭按钮（X）被点击时回调
@property (nonatomic, copy, nullable) void (^onClose)(void);

/// "保存"按钮被点击时回调，参数为最终的 kg 体重
@property (nonatomic, copy, nullable) void (^onSave)(CGFloat weightKg);

/// 让隐藏文本框成为 first responder，弹出数字键盘
- (void)beginEditing;

@end

NS_ASSUME_NONNULL_END
