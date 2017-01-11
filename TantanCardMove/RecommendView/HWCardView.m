//
//  HWCardView.m
//  TantanCardMove
//
//  Created by mal on 17/1/10.
//  Copyright © 2017年 mal. All rights reserved.
//

#import "HWCardView.h"
#import "UIView+Extend.h"

#define HWCardScale  0.9
#define HWCardMargin 5
#define HWFlyOutDistance 500 //卡片移除时偏移的距离

typedef NS_ENUM(NSInteger,CardFlyDirection){
    
    f_unKnown,
    f_top,
    f_bottom,
    f_left,
    f_right
};

@interface HWCardView()

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, assign) CardFlyDirection flyDirection;
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
    if (topView)
    {
        _topView = topView;
        UIPanGestureRecognizer *panges = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCardView:)];
        [_topView addGestureRecognizer:panges];
        _topView.userInteractionEnabled = YES;
    }
}

- (CGAffineTransform)transformWithIndex:(NSInteger)index progress:(CGFloat)progress
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (index > 2)
    {
        index = 2;
    }
    CGFloat scale = pow(HWCardScale, index * 1.0);
    CGFloat nextScale = pow(HWCardScale, (index + 1) * 1.0);
    scale = nextScale + (scale - nextScale) * progress;
    CGFloat offset = index * HWCardMargin;
    CGFloat nextOffset = (index + 1) * HWCardMargin;
    offset = nextOffset - (nextOffset - offset) * progress;
    transform = CGAffineTransformMakeScale(scale,1.0);
    transform = CGAffineTransformTranslate(transform, 0,offset);
    return transform;
}

- (void)loadCardItemView
{
    NSInteger itemCount = [self.m_delegate itemCount];
    UIView *aboveView = nil;
    CGRect cardFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    for (int i = 0; i < itemCount; i++)
    {
        UIView *itemView = [self.m_delegate itemViewWithIndex:i frame:cardFrame];
        itemView.tag = i;
        if (aboveView)
        {
            [self insertSubview:itemView belowSubview:aboveView];
            [self.itemViews addObject:itemView];
        }
        else
        {
            [self addSubview:itemView];
            [self setTopView:itemView];
        }
        aboveView = itemView;
        itemView.transform = [self transformWithIndex:i progress:1.0];
    }
}

//MARK：进度中心点移动到HWCardView的边界时进度为1
- (CGFloat)progress
{
    CGFloat progress = 0.0;
    CGFloat progressX,progressY;
    //水平进度
    CGFloat centerX = self.topView.width / 2;
    CGFloat currentCenterX = self.topView.centerX;
    progressX = ABS(currentCenterX - centerX) / centerX;
    //垂直方向进度
    CGFloat centerY = self.topView.height / 2;
    CGFloat currentCenterY = self.topView.centerY;
    progressY = ABS(currentCenterY - centerY) / centerY;
    progress = MAX(progressX, progressY);
    return progress;
}

//根据位移计算卡片飞出方向
- (CardFlyDirection)direction
{
    CardFlyDirection direction = f_unKnown;
    /*
    if (ABS(translation.y) > ABS(translation.x))//上下移动
    {
        direction = f_top;
        if (translation.y > 0)
        {
            direction = f_bottom;
        }
    }
    else//左右移动
    {
        direction = f_left;
        if (translation.x > 0)
        {
            direction = f_right;
        }
    }
     */
    CGPoint center = CGPointMake(self.width / 2, self.height / 2);
    CGPoint currentCenter = self.topView.center;
    if (ABS(currentCenter.x - center.x) > 0.1 * self.width)
    {
        if (currentCenter.x - center.x > 0)
        {
            direction = f_right;
        }
        else
        {
            direction = f_left;
        }
    }
    return direction;
}

- (void)panCardView:(UIPanGestureRecognizer *)ges
{
    UIGestureRecognizerState state = ges.state;
    if (state == UIGestureRecognizerStateBegan)
    {
        self.flyDirection = f_unKnown;
    }
    else if(state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [ges translationInView:self];
        self.topView.centerX += translation.x;
        self.topView.centerY += translation.y;
        [ges setTranslation:CGPointZero inView:self];
        [self changeTopThreeViewWithProgress:[self progress]];
    }
    else
    {
        CGPoint ve = [ges velocityInView:self];
        self.flyDirection = [self direction];
        if ([self progress] > 0.5 && self.flyDirection != f_unKnown)
        {
            [self deleteTopCardWithDirection:self.flyDirection];
        }
        else if (ABS(ve.x) > 800)
        {
            self.flyDirection = f_left;
            if (ve.x > 0)
            {
                self.flyDirection = f_right;
            }
            [self deleteTopCardWithDirection:self.flyDirection];
        }
        else
        {
            [self resetCardView];
        }
    }
}

//MARK: 移除顶部card
- (void)deleteTopCardWithDirection:(CardFlyDirection)direction
{
    CGFloat topCardX = self.topView.left;
    CGFloat topCardY = self.topView.top;
    switch (direction)
    {
        case f_top:
        {
            topCardY -= HWFlyOutDistance;
            break;
        }
        case f_bottom:
        {
            topCardY += HWFlyOutDistance;
            break;
        }
        case f_left:
        {
            topCardX -= HWFlyOutDistance;
            break;
        }
        case f_right:
        {
            topCardX += HWFlyOutDistance;
            break;
        }
        default:
            break;
    }
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        //顶部card飞出
        self.topView.left = topCardX;
        self.topView.top = topCardY;
        //接下来两个卡片改变transform
        [self changeTopThreeViewWithProgress:1.0];
        
    } completion:^(BOOL finished) {
        
        //改变topView
        if (finished && self.itemViews.count > 0)
        {
            [self.topView removeFromSuperview];
            [self setTopView:[self.itemViews firstObject]];
            [self.itemViews removeObjectAtIndex:0];
        }
    }];
}

//MARK: 重置cardView
- (void)resetCardView
{
    if (self.topView)
    {
        [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.topView.left = 0;
            self.topView.top = 0;
            [self changeTopThreeViewWithProgress:0.0];
            
        } completion:nil];
    }
}

- (void)changeTopThreeViewWithProgress:(CGFloat)progress
{
    if (progress > 1.0)
    {
        return;
    }
    NSLog(@"%.2f",progress);
    [self.itemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx < 2)
        {
            obj.transform = [self transformWithIndex:idx progress:progress];
        }
    }];
}

@end
