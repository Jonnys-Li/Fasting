//
//  FSTAddRecordNoteCardView.m
//  Fasting
//

#import "FSTAddRecordNoteCardView.h"
#import "FSTTheme.h"

@interface FSTAddRecordNoteCardView ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation FSTAddRecordNoteCardView

- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 24;
        [self buildSubviews];
    }
    return self;
}

- (void)setText:(NSString *)text { self.textView.text = text ?: @""; }
- (NSString *)text { return self.textView.text; }

- (void)buildSubviews {
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"记录";
    titleLabel.font = FSTFontBold(20);
    titleLabel.textColor = [UIColor fst_textPrimary];
    [self addSubview:titleLabel];

    self.textView = [UITextView new];
    self.textView.font = FSTFontRegular(17);
    self.textView.textColor = [UIColor fst_textPrimary];
    self.textView.backgroundColor = [UIColor fst_inputBackground];
    self.textView.layer.cornerRadius = 14;
    self.textView.textContainerInset = UIEdgeInsetsMake(18, 18, 18, 18);
    [self addSubview:self.textView];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(28);
        make.centerX.equalTo(self);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(24);
        make.left.right.equalTo(self).inset(22);
        make.height.equalTo(@132);
        make.bottom.equalTo(self).offset(-28);
    }];
}

@end
