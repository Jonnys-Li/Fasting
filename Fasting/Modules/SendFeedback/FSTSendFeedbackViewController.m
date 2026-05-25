//
//  FSTSendFeedbackViewController.m
//  Fasting
//
//  Send Feedback 页面：选择反馈类别 + 可选文字描述 + 可选图片 + 提交。
//  当前实现：UI 完整保留，但 submit / addPicture 仅做"样子"，不真实上传或选图。
//

#import "FSTSendFeedbackViewController.h"
#import "FSTSendFeedbackRootView.h"

@interface FSTSendFeedbackViewController () <UITextViewDelegate>
@end

@implementation FSTSendFeedbackViewController

#pragma mark - Accessors

- (FSTSendFeedbackRootView *)rootView {
    return (FSTSendFeedbackRootView *)self.view;
}

#pragma mark - Lifecycle

- (void)loadView {
    self.view = [FSTSendFeedbackRootView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootView.textView.delegate = self;

    __weak typeof(self) weakSelf = self;
    self.rootView.onBackTapped       = ^{ [weakSelf handleBack]; };
    self.rootView.onSubmitTapped     = ^{ [weakSelf handleSubmit]; };
    self.rootView.onAddPictureTapped = ^{ /* 样子化：保留按钮，点击 noop */ };
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.rootView.placeholderLabel.hidden = textView.text.length > 0;
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
