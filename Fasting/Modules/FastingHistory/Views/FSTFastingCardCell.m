//
//  FSTFastingCardCell.m
//  Fasting
//

#import "FSTFastingCardCell.h"
#import "FSTFastingTimelineCardView.h"
#import "FSTTheme.h"

static const CGFloat kFSTFastingCardCellVerticalInset = 10;
static const CGFloat kFSTFastingCardCellSideInset     = 24;

@interface FSTFastingCardCell ()
@property (nonatomic, strong, readwrite) FSTFastingTimelineCardView *cardView;
@end

@implementation FSTFastingCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _cardView = [[FSTFastingTimelineCardView alloc] initWithFrame:CGRectZero];
        _cardView.userInteractionEnabled = NO;
        [self.contentView addSubview:_cardView];
        [_cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView).inset(kFSTFastingCardCellVerticalInset);
            make.left.right.equalTo(self.contentView).inset(kFSTFastingCardCellSideInset);
        }];
    }
    return self;
}

@end
