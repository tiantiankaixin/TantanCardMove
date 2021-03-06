//
//  ViewController.m
//  TantanCardMove
//
//  Created by mal on 17/1/10.
//  Copyright © 2017年 mal. All rights reserved.
//

#import "ViewController.h"
#import "HWCardView.h"

@interface ViewController ()<HWCardViewDelegate>

@property (nonatomic, weak) HWCardView *cardView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setUpView
{
    HWCardView *cardViwe = [HWCardView cardViewWithFrame:CGRectMake(37, 64, 300, 400) delegate:self];
    self.cardView = cardViwe;
    [self.view addSubview:cardViwe];
}

- (NSInteger)itemCount
{
    return 30;
}

- (UIView *)itemViewWithIndex:(NSInteger)index frame:(CGRect)frame
{
    UIView *itemView = [[UIView alloc] initWithFrame:frame];
    itemView.layer.cornerRadius = 8;
    itemView.layer.masksToBounds = YES;
    if (index % 2 == 0)
    {
        itemView.backgroundColor = [UIColor redColor];
    }
    else
    {
        itemView.backgroundColor = [UIColor blueColor];
    }
    return itemView;
}

- (void)closeCardView
{

}

- (void)clickItemWithIndex:(NSInteger)index
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
