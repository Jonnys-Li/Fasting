//
//  FSTPlanSelectViewController.h
//  Fasting
//
//  软切换计划界面：模态弹出，顶部 X 关闭 + "改变计划" 标题，下方 table-backed plan list。
//  点击 plan cell -> 触发 onPlanPicked，自动 dismiss。
//  点击 X       -> 直接 dismiss，不触发 onPlanPicked。
//

#import "FSTBaseViewController.h"
#import "FSTPlan.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTPlanSelectViewController : FSTBaseViewController

/// 是否显示顶部返回/关闭按钮。默认 YES；首次引导流设置为 NO。
@property (nonatomic, assign) BOOL showsCloseButton;

/// 选中计划后是否自动 dismiss。默认 YES；导航栈引导流设置为 NO。
@property (nonatomic, assign) BOOL dismissesOnPlanPicked;

@property (nonatomic, copy, nullable) void (^onPlanPicked)(FSTPlan *picked);

@end

NS_ASSUME_NONNULL_END
