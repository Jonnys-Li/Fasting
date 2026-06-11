//
//  FSTMealDetailContentCardView.h
//  Fasting
//
//  食物详情内容卡：相机按钮 + 状态文字 + 多行备注文本框。
//  - 触发场景：MealDetail 页内容主区。
//  - 数据双向同步：上游 VC 写入 imagePath/detailDescription；文本框内容无回调，
//    VC 在保存时直接读取属性值。imagePath 由 VC 侧 FSTMealDetailSaveImage 落盘后传入。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealDetailContentCardView : UIView

/// 食物照片文件名（"{UUID}.jpg"，落盘目录 Documents/meal-images）。
/// 写入方：上游 VC 把 record.imagePath 直接传入；用户选图后由 FSTMealDetailSaveImage 落盘并回写本属性。
/// 读取方：本视图仅按是否非空切换状态文案（当前不加载缩略图）。
@property (nonatomic, copy, nullable) NSString *imagePath;

/// 用户填写的文字描述（与 FSTMealRecord.detailDescription 同义）。
/// 写入方：VC 初始化推入；用户在文本框输入实时更新到本属性（无回调，靠 VC 保存时读取）。
@property (nonatomic, copy, nullable) NSString *detailDescription;

/// 相机按钮被点击 — 约定调用方拉起 UIImagePickerController，得到图片后落盘（FSTMealDetailSaveImage），
/// 把返回的文件名写回本视图的 imagePath。
@property (nonatomic, copy, nullable) void (^onImageTapped)(void);

@end

NS_ASSUME_NONNULL_END
