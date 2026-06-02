//
//  FSTFastingSegmentControl.m
//  Fasting
//

#import "FSTFastingSegmentControl.h"
#import "FSTTheme.h"
#import <Masonry/Masonry.h>

@interface FSTFastingSegmentControl ()
@property (nonatomic, strong) UIView *selectorView;
@property (nonatomic, strong) UIImageView *bodyIconView;
@property (nonatomic, strong) UIImageView *forkIconView;
@end

@implementation FSTFastingSegmentControl

- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor fst_segmentBackground];
        self.layer.cornerRadius = FSTRadiusChip;
        [self buildSubviews];
    }
    return self;
}

/// 视觉：左侧 body 图标 + 右侧 fork 图标 + 中央白色滑块（静态，纯展示）。
- (void)buildSubviews {
    self.selectorView = [[UIView alloc] init];
    self.selectorView.backgroundColor = [UIColor whiteColor];
    self.selectorView.layer.cornerRadius = FSTRadiusChip;
    self.selectorView.userInteractionEnabled = NO;
    [self addSubview:self.selectorView];

    self.bodyIconView = [self iconViewWithAssetNamed:@"nav_people"];
    self.forkIconView = [self iconViewWithAssetNamed:@"nav_fork"];
    [self addSubview:self.bodyIconView];
    [self addSubview:self.forkIconView];

    [self.selectorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.width.equalTo(@70);
        make.right.equalTo(self);
    }];
    [self.bodyIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self.mas_left).offset(35);
        make.size.mas_equalTo(CGSizeMake(17, 19));
    }];
    [self.forkIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self.mas_right).offset(-35);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
}

- (UIImageView *)iconViewWithAssetNamed:(NSString *)assetName {
    UIImage *image = [UIImage fst_originalImageNamed:assetName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

@end
