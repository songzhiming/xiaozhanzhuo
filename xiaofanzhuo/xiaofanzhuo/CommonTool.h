//
//  CommonTool.h
//  CountrySJapanese
//
//  Created by 宋志明 on 14-11-4.
//  Copyright (c) 2014年 王 军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CommonTool : NSObject



//找到最近的上一级 ViewController
+ (UIViewController *)findNearsetViewController:(UIView *)view;

+(NSString *)getTime;
//按照规则,转时间
+(NSString*)getLastOnlineTime:(NSString*)timestamp;

//缩放
+ (UIImage *)scaleImage:(UIImage *)image toScale:(CGSize)scaleSize;
//
+ (UIImage *)fullScreenImage : (UIImage *)image;
+ (BOOL)isNumber:(NSString*)text;
@end
