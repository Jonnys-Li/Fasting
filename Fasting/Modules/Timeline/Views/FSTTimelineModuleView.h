//
//  FSTTimelineModuleView.h
//  Fasting
//
//  Timeline 页的"模块入口"控件 — 一组带图标、标题、摘要、CTA 文字的圆角卡。
//  - 触发场景：Timeline VC 上一组横向滚动 / 纵向排列的模块入口（如 "今日断食"、"体重趋势"、"餐食日记"）。
//  - 角色：UIControl 子类 — 整张卡可点击，触发标准 TouchUpInside 事件由 VC 监听并 push 对应详情页。
//  - 数据流：init 时传入静态信息（title/icon/actionTitle）；摘要内容靠 -updateSummary:detail: 每次刷新。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTTimelineModuleView : UIControl

/// 初始化模块入口卡。
/// @param title       卡顶部标题（如 "今日断食"）。
/// @param iconName    Asset Catalog 中的图标名（左侧大图标）。
/// @param actionTitle 卡底部 CTA 文字（如 "View detail" / "Log meal"）。
- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName actionTitle:(NSString *)actionTitle;

/// 更新中部摘要内容。
/// @param summary 主摘要（大字，如 "16:00 已断食"）。
/// @param detail  副摘要（小字，如 "目标 16h / 完成度 100%"）。
/// 由 Timeline VC 在 sessionManager 通知 / refreshTimer 触发时调用刷新。
- (void)updateSummary:(NSString *)summary detail:(NSString *)detail;

@end

NS_ASSUME_NONNULL_END
