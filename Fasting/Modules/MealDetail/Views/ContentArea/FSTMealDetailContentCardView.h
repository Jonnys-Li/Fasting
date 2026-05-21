//
//  FSTMealDetailContentCardView.h
//  Fasting
//
//  食物详情内容卡：相机按钮（含图时变缩略图）+ 状态文字 + 多行备注文本框。
//  - 触发场景：MealDetail 页内容主区。
//  - 数据双向同步：上游 VC 写入 imagePath/detailDescription；本视图监听文本框变化并通过 …（当前无回调，
//    VC 直接读取属性值在保存时同步）。imagePath 由 [FSTMealImageService saveImage:] 落盘后传入。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealDetailContentCardView : UIView

/// 食物照片的完整磁盘路径（".../Documents/meal-images/{UUID}.jpg"）。
/// 写入方：上游 VC 把 record.imagePath 直接传入；用户拍照后由 onImageTapped → FSTMealImageService → 回写本属性。
/// 读取方：本视图内部 imageView — 把图片从磁盘加载到 UIImageView 并切换相机按钮态。
@property (nonatomic, copy, nullable) NSString *imagePath;

/// 用户填写的文字描述（与 FSTMealRecord.detailDescription 同义）。
/// 写入方：VC 初始化推入；用户在文本框输入实时更新到本属性（无回调，靠 VC 保存时读取）。
@property (nonatomic, copy, nullable) NSString *detailDescription;

/// 相机按钮被点击 — 约定调用方拉起 UIImagePickerController，得到图片后调 [FSTMealImageService saveImage:]，
/// 把返回的路径写回本视图的 imagePath。
@property (nonatomic, copy, nullable) void (^onImageTapped)(void);

@end

NS_ASSUME_NONNULL_END
