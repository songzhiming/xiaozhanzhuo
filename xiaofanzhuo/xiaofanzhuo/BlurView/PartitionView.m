//
//  PartitionView.m
//  NightApp4iPhone
//
//  Created by Marshal Wu on 14-10-2.
//  Copyright (c) 2014年 Marshal Wu. All rights reserved.
//

#import "PartitionView.h"
#import "FXBlurView.h"

#define DARK_MAX_ALPHA 0.45f

@implementation PartitionView
{
    FXBlurView *blurView;//虚化的view
    UIImageView *snapView;
    UIView *darkView;
}

-(void)setSnapImage:(UIImage *)image{
    self.tintColor=nil;
    
    snapView=[[UIImageView alloc] initWithFrame:self.frame];
    [self addSubview:snapView];
    snapView.image=image;
    snapView.tintColor=nil;
    
    blurView=[[FXBlurView alloc] initWithFrame:self.frame];
    blurView.tintColor=nil;
    blurView.blurRadius = 10;
    [self addSubview:blurView];
    
    darkView=[[UIView alloc] initWithFrame:self.frame];
    [self addSubview:darkView];
    darkView.backgroundColor=[UIColor blackColor];
    darkView.alpha=0;
}

-(void) setDark:(float)dark{
    blurView.blurRadius=40*dark;
    
    //障眼法，因为blur不参与动画，容易看出跳动来
    if (dark<0.08) {
        blurView.alpha=dark;
    }else{
        blurView.alpha=1;
    }
    
    darkView.alpha=dark*DARK_MAX_ALPHA;
}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(cgcontext);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(cgcontext, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(cgcontext, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(cgcontext,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:cgcontext];
            
            // Restore the context
            CGContextRestoreGState(cgcontext);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
