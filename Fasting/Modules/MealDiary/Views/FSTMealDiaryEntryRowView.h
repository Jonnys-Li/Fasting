//
//  FSTMealDiaryEntryRowView.h
//  Fasting

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealDiaryEntryRowView : UIView

- (instancetype)initWithCategory:(NSString *)category
                        dietType:(NSString *)dietType
                      tasteLevel:(NSInteger)tasteLevel
                        dateText:(NSString *)dateText NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@property (nonatomic, copy, nullable) void (^onCardTapped)(void);
@property (nonatomic, copy, nullable) void (^onEditTapped)(void);

@property (nonatomic, assign) BOOL hidesTopLine;
@property (nonatomic, assign) BOOL hidesBottomLine;

@end

NS_ASSUME_NONNULL_END
