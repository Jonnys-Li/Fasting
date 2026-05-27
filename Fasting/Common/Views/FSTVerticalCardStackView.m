//
//  FSTVerticalCardStackView.m
//  Fasting
//

#import "FSTVerticalCardStackView.h"
#import "FSTTheme.h"

#pragma mark - Defaults

static const CGFloat kDefaultSpacing     = 18;
static const CGFloat kDefaultSideInset   = 22;
static const CGFloat kDefaultBottomInset = 28;

@implementation FSTVerticalCardStackView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _cardSpacing   = kDefaultSpacing;
        _contentInsets = UIEdgeInsetsMake(0,
                                          kDefaultSideInset,
                                          kDefaultBottomInset,
                                          kDefaultSideInset);
    }
    return self;
}

#pragma mark - 配置

- (void)setCards:(NSArray<UIView *> *)cards {
    for (UIView *previousCard in _cards) {
        [previousCard removeFromSuperview];
    }
    _cards = [cards copy];
    for (UIView *card in cards) {
        [self addSubview:card];
    }
    [self rebuildConstraints];
}

- (void)setCardSpacing:(CGFloat)cardSpacing {
    _cardSpacing = cardSpacing;
    [self rebuildConstraints];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    [self rebuildConstraints];
}

#pragma mark - 约束

- (void)rebuildConstraints {
    if (self.cards.count == 0) return;
    UIView *previousCard = nil;
    for (NSUInteger index = 0; index < self.cards.count; index++) {
        UIView *card = self.cards[index];
        UIView *predecessor = previousCard;
        CGFloat spacing = self.cardSpacing;
        UIEdgeInsets insets = self.contentInsets;
        [card mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (predecessor) {
                make.top.equalTo(predecessor.mas_bottom).offset(spacing);
            } else {
                make.top.equalTo(self).offset(insets.top);
            }
            make.left.equalTo(self).offset(insets.left);
            make.right.equalTo(self).offset(-insets.right);
        }];
        previousCard = card;
    }
    [self.cards.lastObject mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-self.contentInsets.bottom);
    }];
}

@end
