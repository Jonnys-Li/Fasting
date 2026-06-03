//
//  FSTFastingFeedbackRow.m
//  Fasting
//

#import "FSTFastingFeedbackRow.h"
#import "FSTTheme.h"

@interface FSTFastingFeedbackRow ()
@property (nonatomic, strong) UILabel *emojiLabel;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *chevron;
@end

@implementation FSTFastingFeedbackRow

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = FSTRadiusL;
        [self setupSubviews];
        [self setupConstraints];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapped)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setupSubviews {
    self.emojiLabel = [UILabel fst_labelWithText:@"\U0001F4E9" font:FSTFontRegular(28) color:[UIColor blackColor]];
    self.textLabel  = [UILabel fst_labelWithText:@"Send feedback" font:FSTFontMedium(17) color:[UIColor blackColor]];
    self.chevron    = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"feedback_chevron"]];
    self.chevron.contentMode = UIViewContentModeScaleAspectFit;
    [self fst_addSubviews:@[self.emojiLabel, self.textLabel, self.chevron]];
}

- (void)setupConstraints {
    [self.emojiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.centerY.equalTo(self);
    }];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.emojiLabel.mas_right).offset(10);
        make.centerY.equalTo(self);
    }];
    [self.chevron mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(8, 14));
    }];
}

- (void)handleTapped {
    if (self.onTapped) self.onTapped();
}

@end
