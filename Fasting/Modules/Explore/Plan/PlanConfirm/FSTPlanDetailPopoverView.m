//
//  FSTPlanDetailPopoverView.m
//  Fasting
//

#import "FSTPlanDetailPopoverView.h"
#import "FSTTheme.h"

static const CGFloat kTriangleHeight = 8;
static const CGFloat kTriangleWidth  = 16;
static const CGFloat kCardHeight     = 92;
static const CGFloat kDotSize        = 10;

@interface FSTPlanDetailPopoverView ()
@property (nonatomic, strong) CAShapeLayer *triangleLayer;
@property (nonatomic, strong) UIView *cardContainer;
@property (nonatomic, strong) UIView *fastingDot;
@property (nonatomic, strong) UIView *eatingDot;
@property (nonatomic, strong) UILabel *fastingLabel;
@property (nonatomic, strong) UILabel *eatingLabel;
@end

@implementation FSTPlanDetailPopoverView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // 收起态高度被 RootView 压到 0，卡片（固定高、顶对齐）会溢出 —— 靠裁剪隐藏（R11：内容溢出，配套裁剪）。
        self.clipsToBounds = YES;
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (CGFloat)expandedHeight {
    return kTriangleHeight + kCardHeight;
}

- (void)setupSubviews {
    self.triangleLayer = [CAShapeLayer layer];
    self.triangleLayer.fillColor = [UIColor fst_stageBlue].CGColor;
    [self.layer addSublayer:self.triangleLayer];

    self.cardContainer = [UIView fst_containerWithBackground:[UIColor fst_stageBlue] radius:FSTRadiusCard];
    [self addSubview:self.cardContainer];

    self.fastingDot = [UIView fst_circularDotWithSize:kDotSize borderColor:nil borderWidth:0 bgColor:[UIColor fst_primaryGreen]];
    self.eatingDot  = [UIView fst_circularDotWithSize:kDotSize borderColor:nil borderWidth:0 bgColor:[UIColor fst_amber]];
    self.fastingLabel = [UILabel fst_labelWithText:nil font:FSTFontMedium(16) color:[UIColor fst_textSecondary]];
    self.eatingLabel  = [UILabel fst_labelWithText:nil font:FSTFontMedium(16) color:[UIColor fst_textSecondary]];

    [self.cardContainer fst_addSubviews:@[self.fastingDot, self.eatingDot, self.fastingLabel, self.eatingLabel]];
}

- (void)setupConstraints {
    // 卡片只锚顶 + 固定高（不锚 self.bottom）—— 这样 RootView 把 self 高度压到 0 时不会约束冲突，仅被裁剪。
    [self.cardContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kTriangleHeight);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(kCardHeight);
    }];
    [self.fastingDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardContainer).offset(20);
        make.centerY.equalTo(self.fastingLabel);
        make.size.mas_equalTo(CGSizeMake(kDotSize, kDotSize));
    }];
    [self.fastingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cardContainer).offset(18);
        make.left.equalTo(self.fastingDot.mas_right).offset(10);
        make.right.lessThanOrEqualTo(self.cardContainer).offset(-20);
    }];
    [self.eatingDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardContainer).offset(20);
        make.centerY.equalTo(self.eatingLabel);
        make.size.mas_equalTo(CGSizeMake(kDotSize, kDotSize));
    }];
    [self.eatingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fastingLabel.mas_bottom).offset(12);
        make.left.equalTo(self.eatingDot.mas_right).offset(10);
        make.right.lessThanOrEqualTo(self.cardContainer).offset(-20);
    }];
}

// 朝上的小三角，顶贴卡上沿、水平居中（指向标题/chevron）。依赖最终 bounds，放 layoutSubviews（R8）。
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat cx = CGRectGetWidth(self.bounds) / 2.0;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(cx, 0)];
    [path addLineToPoint:CGPointMake(cx - kTriangleWidth / 2.0, kTriangleHeight)];
    [path addLineToPoint:CGPointMake(cx + kTriangleWidth / 2.0, kTriangleHeight)];
    [path closePath];
    self.triangleLayer.path = path.CGPath;
}

- (void)setFastingHours:(NSInteger)fastingHours eatingHours:(NSInteger)eatingHours {
    self.fastingLabel.text = [NSString stringWithFormat:@"%ldh fasting", (long)fastingHours];
    self.eatingLabel.text  = [NSString stringWithFormat:@"%ldh eating", (long)eatingHours];
}

@end
