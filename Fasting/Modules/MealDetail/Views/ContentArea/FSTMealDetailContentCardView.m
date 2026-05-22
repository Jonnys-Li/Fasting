//
//  FSTMealDetailContentCardView.m
//  Fasting
//

#import "FSTMealDetailContentCardView.h"
#import "FSTTheme.h"

@interface FSTMealDetailContentCardView ()
@property (nonatomic, strong) UILabel *imageStatusLabel;
@property (nonatomic, strong) UITextView *detailTextView;
@end

@implementation FSTMealDetailContentCardView

- (instancetype)init {
    if ((self = [super init])) {
        [self fst_applyMealCardStyle];
        [self buildSubviews];
        [self refresh];
    }
    return self;
}

- (void)setImagePath:(NSString *)imagePath { _imagePath = [imagePath copy]; [self refresh]; }
- (void)setDetailDescription:(NSString *)detailDescription { self.detailTextView.text = detailDescription ?: @""; }
- (NSString *)detailDescription { return self.detailTextView.text; }

- (void)buildSubviews {
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    imageButton.backgroundColor = [UIColor fst_mealImageBackground];
    imageButton.layer.cornerRadius = FSTRadiusM;
    [imageButton setImage:[UIImage systemImageNamed:@"camera.fill"] forState:UIControlStateNormal];
    imageButton.tintColor = [UIColor fst_mealImageTint];
    [imageButton addTarget:self action:@selector(emitImageTapped) forControlEvents:UIControlEventTouchUpInside];

    self.imageStatusLabel = [UILabel new];
    self.imageStatusLabel.font = FSTFontRegular(16);
    self.imageStatusLabel.textColor = [UIColor fst_textSecondary];

    self.detailTextView = [UITextView new];
    self.detailTextView.backgroundColor = [UIColor fst_inputBackground];
    self.detailTextView.layer.cornerRadius = FSTRadiusS;
    self.detailTextView.font = FSTFontRegular(16);
    self.detailTextView.textColor = [UIColor fst_textPrimary];
    self.detailTextView.textContainerInset = UIEdgeInsetsMake(15, 15, 15, 15);

    for (UIView *subview in @[imageButton, self.imageStatusLabel, self.detailTextView]) [self addSubview:subview];

    [imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(24);
        make.left.equalTo(self).offset(22);
        make.size.mas_equalTo(CGSizeMake(62, 62));
    }];
    [self.imageStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageButton.mas_right).offset(16);
        make.centerY.equalTo(imageButton);
        make.right.equalTo(self).offset(-20);
    }];
    [self.detailTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageButton.mas_bottom).offset(18);
        make.left.right.equalTo(self).inset(22);
        make.height.equalTo(@108);
        make.bottom.equalTo(self).offset(-22);
    }];
}

- (void)refresh {
    self.imageStatusLabel.text = self.imagePath.length ? @"Food photo added" : @"Add food details";
}

- (void)emitImageTapped { if (self.onImageTapped) self.onImageTapped(); }

@end
