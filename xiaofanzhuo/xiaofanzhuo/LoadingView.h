//
//  LoadingView.h
//  CountrySJapanese
//
//  Created by 宋志明 on 14-10-26.
//  Copyright (c) 2014年 王 军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView
{
    __weak IBOutlet UIActivityIndicatorView *indicatorView;
    __weak IBOutlet UIView *indicatorContainerView;
    __weak IBOutlet UILabel *messageLabel;
    float _topGap;
}
- (void)initData:(NSString *)msg;
- (LoadingView *)adjustTopGat:(float)topGap;

@end
