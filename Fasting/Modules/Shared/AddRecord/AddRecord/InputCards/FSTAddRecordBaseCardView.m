//
//  FSTAddRecordBaseCardView.m
//  Fasting
//

#import "FSTAddRecordBaseCardView.h"
#import "FSTTheme.h"

@implementation FSTAddRecordBaseCardView

- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = FSTRadiusXL;
    }
    return self;
}

@end
