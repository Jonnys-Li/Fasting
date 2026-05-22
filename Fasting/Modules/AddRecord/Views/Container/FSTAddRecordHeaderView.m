//
//  FSTAddRecordHeaderView.m
//  Fasting
//

#import "FSTAddRecordHeaderView.h"
#import "FSTTheme.h"

@interface FSTAddRecordHeaderView ()
@property (nonatomic, strong) UILabel *durationLabel;
@end

@implementation FSTAddRecordHeaderView

- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor fst_addRecordHeaderGreen];
        [self buildSubviews];
    }
    return self;
}

- (void)setTotalSeconds:(NSTimeInterval)totalSeconds {
    _totalSeconds = totalSeconds;
    NSInteger minutes = MAX(1, (NSInteger)llround(totalSeconds / 60.0));
    self.durationLabel.text = [NSString stringWithFormat:@"%ld min", (long)minutes];
}

/// 构建：山形背景色块 + 左右两个圆形按钮 + 标题 + 大数字。
- (void)buildSubviews {
    UIView *mountainBackground = [UIView new];
    mountainBackground.backgroundColor = [[UIColor fst_addRecordMountainGreen] colorWithAlphaComponent:0.35];
    [self addSubview:mountainBackground];

    UIButton *backButton = [self roundButtonWithSymbol:@"arrow.left"];
    [backButton addTarget:self action:@selector(emitBackTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];

    UIButton *trashButton = [self roundButtonWithSymbol:@"trash"];
    [trashButton addTarget:self action:@selector(emitTrashTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:trashButton];

    UILabel *captionLabel = [UILabel new];
    captionLabel.text = @"Total fasting time";
    captionLabel.font = FSTFontSubhead();
    captionLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.78];
    captionLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:captionLabel];

    self.durationLabel = [UILabel new];
    self.durationLabel.font = FSTFontBold(36);
    self.durationLabel.textColor = [UIColor whiteColor];
    self.durationLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.durationLabel];

    [mountainBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@92);
    }];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(22);
        make.left.equalTo(self).offset(22);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [trashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backButton);
        make.right.equalTo(self).offset(-24);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [captionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backButton.mas_bottom).offset(26);
        make.centerX.equalTo(self);
    }];
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(captionLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self);
    }];
}

- (UIButton *)roundButtonWithSymbol:(NSString *)systemSymbolName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.78];
    button.layer.cornerRadius = FSTRadiusXL;
    [button setImage:[UIImage systemImageNamed:systemSymbolName] forState:UIControlStateNormal];
    button.tintColor = [UIColor fst_textPrimary];
    return button;
}

- (void)emitBackTapped { if (self.onBackTapped) self.onBackTapped(); }
- (void)emitTrashTapped { if (self.onTrashTapped) self.onTrashTapped(); }

@end
