//
//  FSTFastingCardCell.m
//  Fasting
//

#import "FSTFastingCardCell.h"
#import "FSTFastingRecordCardView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

static const CGFloat kVerticalInset = 10;
static const CGFloat kSideInset     = 24;

@interface FSTFastingCardCell ()
@property (nonatomic, strong) FSTFastingRecordCardView *cardView;
@end

@implementation FSTFastingCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _cardView = [[FSTFastingRecordCardView alloc] initWithFrame:CGRectZero];
        _cardView.userInteractionEnabled = NO;
        [self.contentView addSubview:_cardView];
        [_cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView).inset(kVerticalInset);
            make.left.right.equalTo(self.contentView).inset(kSideInset);
        }];
    }
    return self;
}

- (void)configureWithRecord:(FSTFastingRecord *)record {
    [self.cardView configureWithRecord:record];
}

@end
