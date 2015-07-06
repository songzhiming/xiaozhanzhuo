//
//  LoadingView.m
//  CountrySJapanese
//
//  Created by 宋志明 on 14-10-26.
//  Copyright (c) 2014年 王 军. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView



-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingView:) name:@"remove.loading.view" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)removeLoadingView:(NSNotification *)notifation
{
    [self removeFromSuperview];
    
}

- (void)initData:(NSString *)msg
{
    messageLabel.text = msg;
}

- (LoadingView *)adjustTopGat:(float)topGap {
    CGRect frame = self.frame;
    frame.origin.y = topGap;
    frame.size.height = [[UIScreen mainScreen] bounds].size.height - frame.origin.y;
    self.frame = frame;
    
    [indicatorView startAnimating];
    
    CGPoint center = indicatorContainerView.center;
    center.y = (self.bounds.size.height  - topGap) / 2;
    indicatorContainerView.center = center;
    
    _topGap = topGap;
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (_topGap) {
        [self adjustTopGat:_topGap];
    }
}

@end
