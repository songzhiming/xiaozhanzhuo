//
//  PartitionView.h
//  NightApp4iPhone
//
//  Created by Marshal Wu on 14-10-2.
//  Copyright (c) 2014年 Marshal Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FXBlurView;

@interface PartitionView : UIView

-(void) setDark:(float)dark;

//-(void) enable:(BOOL)enable;

-(void)setSnapImage:(UIImage *)image;

-(UIImage*)screenshot;

@end
