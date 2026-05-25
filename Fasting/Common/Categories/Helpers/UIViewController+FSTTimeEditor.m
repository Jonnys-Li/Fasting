//
//  UIViewController+FSTTimeEditor.m
//  Fasting
//

#import "UIViewController+FSTTimeEditor.h"

@implementation UIViewController (FSTTimeEditor)

- (void)fst_presentTimeEditorWithTitle:(NSString *)title
                           initialDate:(NSDate *)initialDate
                              onCommit:(void (^)(NSDate *pickedDate))onCommit {
    [self fst_presentTimeEditorWithTitle:title
                             initialDate:initialDate
                             minimumDate:nil
                             maximumDate:nil
                           alignChipText:nil
                    alignDurationSeconds:0
                               alignMode:FSTTimeEditorAlignModeStartFast
                      alignReferenceDate:nil
                                onCommit:^(NSDate *pickedDate, BOOL aligned) {
        (void)aligned;
        if (onCommit) onCommit(pickedDate);
    }];
}

- (void)fst_presentTimeEditorWithTitle:(NSString *)title
                           initialDate:(NSDate *)initialDate
                           minimumDate:(nullable NSDate *)minimumDate
                           maximumDate:(nullable NSDate *)maximumDate
                         alignChipText:(nullable NSString *)alignChipText
                  alignDurationSeconds:(NSTimeInterval)alignDurationSeconds
                             alignMode:(FSTTimeEditorAlignMode)alignMode
                    alignReferenceDate:(nullable NSDate *)alignReferenceDate
                              onCommit:(void (^)(NSDate *pickedDate, BOOL aligned))onCommit {
    FSTTimeEditorSheetViewController *sheet =
        [[FSTTimeEditorSheetViewController alloc] initWithTitle:title
                                                    initialDate:initialDate ?: [NSDate date]
                                                    minimumDate:minimumDate
                                                    maximumDate:maximumDate
                                                  alignChipText:alignChipText
                                           alignDurationSeconds:alignDurationSeconds
                                                      alignMode:alignMode
                                             alignReferenceDate:alignReferenceDate
                                                       onCommit:onCommit];
    [self presentViewController:sheet animated:YES completion:nil];
}

@end
