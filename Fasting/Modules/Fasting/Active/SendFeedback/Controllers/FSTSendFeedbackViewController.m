//
//  FSTSendFeedbackViewController.m
//  Fasting
//
//  Send Feedback 页面：选择反馈类别 + 可选文字描述 + 可选图片 + 提交。
//  当前实现：UI 完整保留，但 submit / addPicture 仅做"样子"，不真实上传或选图。
//

#import "FSTSendFeedbackViewController.h"
#import "FSTSendFeedbackRootView.h"
#import "FSTTheme.h"

static NSString * const kPlaceholder = @"Anything you share helps us make fasting better for you.";

@interface FSTSendFeedbackViewController () <UITextViewDelegate>
@property (nonatomic, strong) FSTSendFeedbackRootView *rootView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@end

@implementation FSTSendFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self installRootView];
    [self bindCallbacks];
}

- (void)installRootView {
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = FSTFontRegular(16);
    self.textView.textColor = [UIColor blackColor];
    self.textView.textContainerInset = UIEdgeInsetsMake(16, 12, 16, 12);
    self.textView.delegate = self;

    self.placeholderLabel = [UILabel fst_labelWithText:kPlaceholder
                                                  font:FSTFontRegular(16)
                                                 color:[UIColor fst_textSecondary]];
    self.placeholderLabel.textAlignment = NSTextAlignmentLeft;
    self.placeholderLabel.numberOfLines = 0;

    self.rootView = [[FSTSendFeedbackRootView alloc] init];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.rootView mountTextView:self.textView placeholderLabel:self.placeholderLabel];
}

- (void)bindCallbacks {
    __weak typeof(self) weakSelf = self;
    self.rootView.onBackTapped = ^{
        [weakSelf handleBack];
    };
    self.rootView.onSubmitTapped = ^{
        [weakSelf handleSubmit];
    };
    self.rootView.onAddPictureTapped = ^{
        /* 样子化：保留按钮，点击 noop */
    };
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = textView.text.length > 0;
}

#pragma mark - Events

- (void)handleBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSubmit {
    // 样子化：不做真实提交，直接 pop。
    [self.navigationController popViewControllerAnimated:YES];
}

@end
