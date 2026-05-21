//
//  FSTMealImageService.h
//  Fasting
//
//  食物照片持久化服务。
//  - 写入路径：MealDetail 页用户从相册/相机选图 → [FSTMealImageService saveImage:]
//    生成唯一文件名（{UUID}.jpg）→ 写入 Documents/meal-images/ → 返回完整文件路径。
//    路径串被 FSTMealRecord.imagePath 持有 → 通过 +Persistence 序列化到 NSUserDefaults。
//  - 读取路径：MealDiary / MealDetail 用 imagePath 直接加载图片显示。
//  - 抽离原因（Step 5 重构）：把 JPEG 压缩 + 文件 IO 从 VC 抽出来，便于未来切换到 iCloud /
//    远端存储或加密保存时统一改动一处。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealImageService : NSObject

/// 把内存中的 UIImage 压缩并保存到 Documents/meal-images/ 下。
///
/// @param image 待保存图片。nil 时直接返回 nil（不抛错）。
/// @return 保存成功时返回完整文件路径（".../Documents/meal-images/{UUID}.jpg"）；
///         JPEG 编码失败或写入失败时返回 nil。
///         调用方应把它写入 FSTMealRecord.imagePath；下次显示时直接用该路径加载即可。
+ (nullable NSString *)saveImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
