//
//  HWCardView.h
//  TantanCardMove
//
//  Created by mal on 17/1/10.
//  Copyright © 2017年 mal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HWCardViewDelegate <NSObject>

@required
- (NSInteger)itemCount;
- (UIView *)itemViewWithIndex:(NSInteger)index frame:(CGRect)frame;
- (void)closeCardView;
- (void)clickItemWithIndex:(NSInteger)index;

@end

@interface HWCardView : UIView

@property (nonatomic, weak) id<HWCardViewDelegate> m_delegate;

+ (HWCardView *)cardViewWithFrame:(CGRect)frame delegate:(id<HWCardViewDelegate>)delegate;

@end
