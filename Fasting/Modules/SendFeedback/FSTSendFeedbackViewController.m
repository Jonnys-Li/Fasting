//
//  FSTSendFeedbackViewController.m
//  Fasting
//
//  Send Feedback 页面：选择反馈类别 + 可选文字描述 + 可选图片 + 提交。
//

#import "FSTSendFeedbackViewController.h"
#import "FSTSendFeedbackRootView.h"
#import <PhotosUI/PhotosUI.h>

@interface FSTSendFeedbackViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIImage *pickedImage;
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
    self.rootView.onBackTapped = ^{
        [weakSelf handleBack];
    };
    self.rootView.onSubmitTapped = ^{
        [weakSelf handleSubmit];
    };
    self.rootView.onAddPictureTapped = ^{
        [weakSelf handleAddPicture];
    };
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.rootView.placeholderLabel.hidden = textView.text.length > 0;
}

#pragma mark - Events

- (void)handleBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleAddPicture {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)handleSubmit {
    NSLog(@"Feedback submitted: category=%@, text=%@, hasImage=%d",
          self.rootView.selectedChipIndex >= 0 ? self.rootView.chipTitles[self.rootView.selectedChipIndex] : @"(none)",
          self.rootView.textView.text,
          self.pickedImage != nil);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.pickedImage = image;
        self.rootView.pickedImageView.image = image;
        self.rootView.pickedImageView.hidden = NO;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
