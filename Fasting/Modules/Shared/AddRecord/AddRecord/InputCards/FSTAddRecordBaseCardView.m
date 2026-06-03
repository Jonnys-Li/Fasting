//
//  FSTAddRecordBaseCardView.m
//  Fasting
//

#import "FSTAddRecordBaseCardView.h"
#import "FSTTheme.h"

@implementation FSTAddRecordBaseCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = FSTRadiusXL;
    }
    return self;
}

@end
