//
//  FSTPlanChipPillView.m
//  Fasting
//
//  扁平灰底胶囊：左侧 plan 名 + 10pt 间距 + 右侧 20×20 plain pencil。
//  整个胶囊 tap 触发改变计划。
//

#import "FSTPlanChipPillView.h"
#import "FSTTheme.h"

@interface FSTPlanChipPillView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *pencilIconView;
@end

@implementation FSTPlanChipPillView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_ringTrackLight];
        self.layer.cornerRadius = FSTRadiusChip;
        self.clipsToBounds = YES;
        [self buildSubviews];

        UIControl *tapControl = [UIControl new];
        [tapControl addTarget:self action:@selector(handleTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tapControl];
        [tapControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)buildSubviews {
    self.titleLabel = [UILabel fst_labelWithText:nil font:FSTFontBold(15) color:[UIColor fst_textPrimary] alignment:NSTextAlignmentCenter];
    [self addSubview:self.titleLabel];

    self.pencilIconView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"plan_chip_pencil"]];
    self.pencilIconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.pencilIconView];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.equalTo(self);
    }];
    [self.pencilIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(10);
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

- (void)setPlanName:(NSString *)planName {
    _planName = [planName copy];
    self.titleLabel.text = planName ?: @"";
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    // pad-left 10 + text + gap 10 + pencil 20 + pad-right 10
    NSString *displayText = self.titleLabel.text.length ? self.titleLabel.text : @"00-00";
    CGSize textSize = [displayText sizeWithAttributes:@{ NSFontAttributeName: self.titleLabel.font }];
    CGFloat width = ceil(textSize.width) + 10 + 10 + 20 + 10;
    return CGSizeMake(width, 33);
}

- (void)handleTap {
    if (self.onTapped) self.onTapped();
}

@end
