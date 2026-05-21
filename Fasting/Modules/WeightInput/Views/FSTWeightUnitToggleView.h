//
//  FSTWeightUnitToggleView.h
//  Fasting
//
//  kg/lb 单位切换胶囊视图：内部小白块滑动 + 字色互换 + 动画。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 体重单位 — 仅影响 UI 显示，业务持久化恒以 kg 存储。
/// 写入方：用户在 FSTWeightUnitToggleView 上点击触发 unit 切换。
/// 读取方：FSTWeightInputViewController 在写入 FSTFastingRecord.weightKg 前做单位换算（lb 时除以 2.20462）；
///         所有 FSTFastingRecord.weightKg / initialWeightKg / targetWeightKg 始终是 kg，跨设备/迁移不依赖 unit。
typedef NS_ENUM(NSInteger, FSTWeightUnit) {
    FSTWeightUnitKg = 0,  ///< 公斤（默认）。
    FSTWeightUnitLb,      ///< 磅。仅显示态切换；输入会按 0.45359237 倍率换算回 kg。
};

@interface FSTWeightUnitToggleView : UIView

/// 当前单位
@property (nonatomic, assign) FSTWeightUnit unit;

/// 单位被用户切换时回调
@property (nonatomic, copy, nullable) void (^onUnitChanged)(FSTWeightUnit newUnit);

@end

NS_ASSUME_NONNULL_END
