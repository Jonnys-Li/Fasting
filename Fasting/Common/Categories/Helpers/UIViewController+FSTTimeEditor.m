//
//  UIViewController+FSTTimeEditor.m
//  Fasting
//

#import "UIViewController+FSTTimeEditor.h"
#import "FSTTimeEditorSheetViewController.h"

@implementation UIViewController (FSTTimeEditor)

- (void)fst_presentTimeEditorWithTitle:(NSString *)title
                           initialDate:(NSDate *)initialDate
                              onCommit:(void (^)(NSDate *pickedDate))onCommit {
    [self fst_presentTimeEditorWithTitle:title
                             initialDate:initialDate
                             minimumDate:nil
                             maximumDate:nil
                           alignChipText:nil
                             alignedDate:nil
                         initiallyAligned:NO
                                 onCommit:^(NSDate *pickedDate, BOOL aligned) {
        if (onCommit) onCommit(pickedDate);
    }];
}

- (void)fst_presentTimeEditorWithTitle:(NSString *)title
                           initialDate:(NSDate *)initialDate
                           minimumDate:(nullable NSDate *)minimumDate
                           maximumDate:(nullable NSDate *)maximumDate
                         alignChipText:(nullable NSString *)alignChipText
                           alignedDate:(nullable NSDate *)alignedDate
                       initiallyAligned:(BOOL)initiallyAligned
                               onCommit:(void (^)(NSDate *pickedDate, BOOL aligned))onCommit {
    FSTTimeEditorSheetViewController *sheet =
        [[FSTTimeEditorSheetViewController alloc] initWithTitle:title
                                                    initialDate:initialDate ?: [NSDate date]
                                                    minimumDate:minimumDate
                                                    maximumDate:maximumDate
                                                  alignChipText:alignChipText
                                                    alignedDate:alignedDate
                                                initiallyAligned:initiallyAligned
                                                        onCommit:onCommit];
    [self presentViewController:sheet animated:YES completion:nil];
}

@end
