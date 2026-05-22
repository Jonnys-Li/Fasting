//
//  FSTFastingSegmentControl.m
//  Fasting
//

#import "FSTFastingSegmentControl.h"
#import "FSTTheme.h"
#import "UIColor+FST.h"
#import <Masonry/Masonry.h>

@interface FSTFastingSegmentControl ()
@property (nonatomic, strong) UIControl *hitArea;
@property (nonatomic, strong) UIView *selectorView;
@property (nonatomic, strong) UIImageView *bodyIconView;
@property (nonatomic, strong) UIImageView *forkIconView;
@end

@implementation FSTFastingSegmentControl

- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor fst_segmentBackground];
        self.layer.cornerRadius = 17;
        [self buildSubviews];
    }
    return self;
}

/// 视觉：左侧 body 图标 + 右侧 fork 图标 + 中央白色滑块（静态）；
/// 整面盖一层透明 UIControl 接收点击，统一触发 onTapped。
- (void)buildSubviews {
    self.selectorView = [UIView new];
    self.selectorView.backgroundColor = [UIColor whiteColor];
    self.selectorView.layer.cornerRadius = 17;
    self.selectorView.userInteractionEnabled = NO;
    [self addSubview:self.selectorView];

    self.bodyIconView = [self iconViewWithAssetNamed:@"nav_people"];
    self.forkIconView = [self iconViewWithAssetNamed:@"nav_fork"];
    [self addSubview:self.bodyIconView];
    [self addSubview:self.forkIconView];

    self.hitArea = [UIControl new];
    [self.hitArea addTarget:self action:@selector(handleTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.hitArea];

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
    [self.hitArea mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (UIImageView *)iconViewWithAssetNamed:(NSString *)assetName {
    UIImage *image = [[UIImage imageNamed:assetName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

- (void)handleTapped {
    if (self.onTapped) self.onTapped();
}

@end
