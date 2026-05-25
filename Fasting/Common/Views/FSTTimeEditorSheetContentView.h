//
//  FSTTimeEditorSheetContentView.h
//  Fasting
//
//  时间编辑底卡的内容视图 — 承载关闭按钮、标题、滚轮 DatePicker、可选 Align 芯片、保存按钮。
//  由 FSTTimeEditorSheetViewController 创建并放入 cardContainer 内；
//  VC 负责状态逻辑（align 应用与否、clamp date），本视图只负责 UI 创建与约束。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTTimeEditorSheetContentView : UIView

/// 唯一指定初始化。alignChipText 为 nil 时不创建 align 芯片，布局更紧凑。
- (instancetype)initWithTitle:(NSString *)title
                alignChipText:(nullable NSString *)alignChipText NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// 滚轮日期选择器 — VC 读取/设置 date、minimumDate、maximumDate。
@property (nonatomic, strong, readonly) UIDatePicker *datePicker;

/// Align 芯片控件，alignChipText 为 nil 时此属性为 nil。
@property (nonatomic, strong, readonly, nullable) UIControl *alignControl;

/// 关闭按钮点击回调。
@property (nonatomic, copy, nullable) void (^onCloseTapped)(void);

/// 保存按钮点击回调。
@property (nonatomic, copy, nullable) void (^onSaveTapped)(void);

/// Align 芯片点击回调。
@property (nonatomic, copy, nullable) void (^onAlignToggled)(void);

/// 用户滚动 datePicker 触发 UIControlEventValueChanged 时回调；VC 用来更新 align chip 启用态。
@property (nonatomic, copy, nullable) void (^onPickerValueChanged)(void);

/// 更新 Align 芯片的「启用 / 禁用」视觉态：
///   enabled=YES → 绿色高亮可点；enabled=NO → 灰色禁用。
- (void)setAlignEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
