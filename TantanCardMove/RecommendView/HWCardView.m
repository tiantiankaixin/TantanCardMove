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
#define HWFlyRate 1200//卡片飞出速度
#define HWAngle (M_PI_4 * (1 / 8.0))

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
    CGFloat addOffset = self.height / 2 - self.height * scale / 2;
    if (addOffset > 0)
    {
        offset = (offset + addOffset) / scale;
    }
    transform = CGAffineTransformMakeScale(scale,scale);
    transform = CGAffineTransformTranslate(transform, 0,offset);
    if (index == 0 && progress == 1.0)
    {
        transform = CGAffineTransformIdentity;
    }
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

//旋转进度
- (CGFloat)rotaionProgress
{
    CGFloat centerX = self.topView.width / 2;
    CGFloat currentCenterX = self.topView.centerX;
    return  ABS(currentCenterX - centerX) / centerX;
}

- (void)panCardView:(UIPanGestureRecognizer *)ges
{
    UIGestureRecognizerState state = ges.state;
    if(state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [ges translationInView:self];
        self.topView.centerX += translation.x;
        self.topView.centerY += translation.y;
        [ges setTranslation:CGPointZero inView:self];
        [self makeRotationWithProgress:[self rotaionProgress]];
        [self changeTopThreeViewWithProgress:[self progress]];
    }
    else
    {
        CGPoint ve = [ges velocityInView:self];
        BOOL canDelete = (ABS(self.topView.centerX - self.width / 2) > 0.3 * self.width);
        if ([self progress] > 0.8 && canDelete)
        {
            [self deleteTopCard];
        }
        else if (ABS(ve.x) > 800)
        {
            [self deleteTopCard];
        }
        else
        {
            [self resetCardView];
        }
    }
}

//MARK: 根据位移做rotaion
- (void)makeRotationWithProgress:(CGFloat)progress
{
    CGFloat angle = 0;
    if (progress == 0.0)
    {
        self.topView.transform = CGAffineTransformIdentity;
    }
    else
    {
        if (self.topView.centerX > self.width / 2)
        {
            angle = -HWAngle;
            self.topView.transform = CGAffineTransformMakeRotation(angle * progress);
        }
        else if(self.topView.centerX < self.width / 2)
        {
            angle = HWAngle;
            self.topView.transform = CGAffineTransformMakeRotation(angle * progress);
        }
        else
        {
            self.topView.transform = CGAffineTransformIdentity;
        }
    }
}

- (CGPoint)flyPoint
{
    CGPoint center = CGPointMake(self.width / 2, self.height / 2);
    CGFloat scale = ABS((self.topView.centerY - center.y) / (self.topView.centerX - center.x));
    CGFloat outsideX,outsideY;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    if(self.topView.centerX >= center.x)//往右边跑
    {
        outsideX = screenW + self.width / 2 - (screenW - self.width) / 2 + 50;
        if (self.topView.centerY <= center.y)//往上跑
        {
            outsideY = center.y - scale * (outsideX - center.x);
        }
        else//往下跑
        {
            outsideY = center.y + scale * (outsideX - center.x);
        }
    }
    else//往左跑
    {
        outsideX = -(self.width / 2 + (screenW - self.width) / 2) - 50;
        if (self.topView.centerY <= center.y)//往上跑
        {
            outsideY = center.y + scale * (outsideX - center.x);
        }
        else//往下跑
        {
            outsideY = center.y - scale * (outsideX - center.x);
        }
    }
    if (self.topView.centerX == center.x)
    {
        outsideX = center.x;
        outsideY = -(self.height / 2 + (screenH - self.height) / 2);
        if (self.topView.centerY > center.y)
        {
            outsideY = screenH + self.height / 2 - (screenH - self.height) / 2;
        }
    }
    else if (self.topView.centerY == center.y)
    {
        outsideY = center.y;
    }
    return CGPointMake(outsideX, outsideY);
}

//MARK: 移除顶部card
- (void)deleteTopCard
{
    CGPoint flyCenter = [self flyPoint];
    CGFloat duration = (flyCenter.x - self.width / 2) / HWFlyRate;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        //顶部card飞出
        self.topView.center = flyCenter;
        //接下来两个卡片改变transform
        [self changeTopThreeViewWithProgress:1.0];
        
    } completion:^(BOOL finished) {
        
        //改变topView
        if (finished)
        {
            [self.topView removeFromSuperview];
            if (self.itemViews.count > 0)
            {
                [self setTopView:[self.itemViews firstObject]];
                [self.itemViews removeObjectAtIndex:0];
            }
            else
            {
                [self.m_delegate closeCardView];
            }
        }
    }];
}

//MARK: 重置cardView
- (void)resetCardView
{
    if (self.topView)
    {
        [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:^{
            
            self.topView.centerX = self.width / 2;
            self.topView.centerY = self.height / 2;
            [self changeTopThreeViewWithProgress:0.0];
            [self makeRotationWithProgress:0.0f];
            
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
