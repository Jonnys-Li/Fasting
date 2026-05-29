//
//  FSTBaseModalViewController.h
//  Fasting
//
//  弹窗控制器基类：自带半透明遮罩与白色卡片容器。
//  使用方式：子类把内容加到 self.cardContainer 上，遮罩点击会自动 dismiss。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 弹窗容器布局风格。
/// 写入方：子类在 viewDidLoad 前设置 self.containerStyle（默认 CenteredCard）。
/// 读取方：本基类的约束布置逻辑 — 决定 cardContainer 是居中浮卡还是从底部贴边升起。
typedef NS_ENUM(NSInteger, FSTBaseModalContainerStyle) {
    /// 居中浮卡。用于 FSTModalDialogViewController（确认弹窗）、FSTWeightInputViewController（体重输入卡）等。
    FSTBaseModalContainerStyleCenteredCard,
    /// 底部贴边升起。用于 FSTTimeEditorSheetViewController（时间编辑底卡），靠近用户拇指便于操作。
    FSTBaseModalContainerStyleBottomSheet,
};

@interface FSTBaseModalViewController : UIViewController

/// 指定初始化器（funnel UIViewController 的两个指定初始化器）。一切构造最终都经此跑 configureDefaults。
/// 子类若声明自己的指定初始化器，须 [super initWithNibName:bundle:] 链至此。
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

/// 半透明遮罩，点击会自动 dismiss
@property (nonatomic, strong, readonly) UIView *backdropView;

/// 居中的白色卡片容器，子类把内容加到这里
@property (nonatomic, strong, readonly) UIView *cardContainer;

/// 是否允许点击遮罩 dismiss，默认 YES
@property (nonatomic, assign) BOOL dismissOnBackdropTap;

/// 容器样式，默认居中卡片。
@property (nonatomic, assign) FSTBaseModalContainerStyle containerStyle;

/// 遮罩透明度，默认 0.4。
@property (nonatomic, assign) CGFloat backdropAlpha;

/// 遮罩基础颜色，默认黑色。
@property (nonatomic, strong) UIColor *backdropColor;

/// 容器圆角，默认 24。
@property (nonatomic, assign) CGFloat containerCornerRadius;

/// 容器是否裁剪子视图，默认 YES。
@property (nonatomic, assign) BOOL containerClipsToBounds;

/// 居中卡片的水平边距，默认 28。
@property (nonatomic, assign) CGFloat containerHorizontalInset;

/// 居中卡片的 Y 偏移，默认 0。
@property (nonatomic, assign) CGFloat containerVerticalOffset;

@end

NS_ASSUME_NONNULL_END
