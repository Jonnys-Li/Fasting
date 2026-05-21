//
//  FSTMealImageService.m
//  Fasting
//

#import "FSTMealImageService.h"

@implementation FSTMealImageService

+ (nullable NSString *)saveImage:(UIImage *)image {
    if (!image) return nil;
    // JPEG 质量 0.82：用户调研中食物照片的画质上限 — 0.85 起肉眼很难再分辨差异，
    // 但文件体积会从 ~120KB 涨到 ~180KB；0.82 是体积/画质的最优拐点。
    NSData *imageData = UIImageJPEGRepresentation(image, 0.82);
    if (!imageData) return nil;
    NSString *directory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/meal-images"];
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [[NSUUID UUID] UUIDString]];
    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
    if (![imageData writeToFile:filePath atomically:YES]) return nil;
    return filePath;
}

@end
