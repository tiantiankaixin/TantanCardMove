//
//  HWCardView.m
//  TantanCardMove
//
//  Created by mal on 17/1/10.
//  Copyright © 2017年 mal. All rights reserved.
//

#import "HWCardView.h"
#import "UIView+Extend.h"

#define HWCardScale  0.95
#define HWCardMargin 5

@interface HWCardView()

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, strong) NSMutableArray *itemViews;

@end

@implementation HWCardView

- (NSMutableArray *)itemViews
{
    if (_itemViews == nil)
    {
        _itemViews = [[NSMutableArray alloc] init];
    }
    return _itemViews;
}

+ (HWCardView *)cardViewWithFrame:(CGRect)frame delegate:(id<HWCardViewDelegate>)delegate
{
    HWCardView *cardView = [[HWCardView alloc] initWithFrame:frame];
    cardView.m_delegate = delegate;
    [cardView loadCardItemView];
    return cardView;
}

- (void)setTopView:(UIView *)topView
{
    _topView = topView;
    UIPanGestureRecognizer *panges = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCardView:)];
    [_topView addGestureRecognizer:panges];
}

- (void)loadCardItemView
{
    NSInteger itemCount = [self.m_delegate itemCount];
    UIView *aboveView = nil;
    CGFloat scale = 1.0;
    CGFloat offset = 0;
    CGRect cardFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    for (int i = 0; i < itemCount; i++)
    {
        UIView *itemView = [self.m_delegate itemViewWithIndex:i frame:cardFrame];
        if (aboveView)
        {
            [self insertSubview:itemView belowSubview:aboveView];
        }
        else
        {
            [self addSubview:itemView];
            [self setTopView:itemView];
        }
        aboveView = itemView;
        itemView.transform = CGAffineTransformMakeScale(scale,1.0);
        itemView.transform =  CGAffineTransformTranslate(itemView.transform, 0, offset);
        if (i < 2)//从第4个开始与第3个保持一样的transform;
        {
            scale *= HWCardScale;
            offset += HWCardMargin;
        }
        [self.itemViews addObject:itemView];
    }
}

- (void)panCardView:(UIPanGestureRecognizer *)ges
{
    UIGestureRecognizerState state = ges.state;
    BOOL leftDelete = NO;
    if (state == UIGestureRecognizerStateBegan)
    {}
    else if(state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [ges translationInView:self];
        leftDelete = (translation.x < 0);
        self.topView.centerX += translation.x;
        self.topView.centerY += translation.y;
        [ges setTranslation:CGPointZero inView:self];
    }
    else
    {
        [self resetTopView];
    }
}

- (void)resetTopView
{
    if (self.topView)
    {
        [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.topView.left = 0;
            self.topView.top = 0;
            
        } completion:^(BOOL finished) {
            
            
        }];
    }
}

- (void)changeTopThreeViewWithProgress:(CGFloat)progress
{
    if (progress > 1.0)
    {
        return;
    }
    [self.itemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx > 0 && idx < 2)
        {
            
        }
    }];
}

@end
