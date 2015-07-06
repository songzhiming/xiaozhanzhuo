//
//  CommonTool.m
//  CountrySJapanese
//
//  Created by 宋志明 on 14-11-4.
//  Copyright (c) 2014年 王 军. All rights reserved.
//

#import "CommonTool.h"


@implementation CommonTool


//找到最近的上一级 ViewController
+ (UIViewController *)findNearsetViewController:(UIView *)view {
    UIViewController *viewController = nil;
    for (UIView *next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            viewController = (UIViewController *)nextResponder;
            break;
        }
    }
    return viewController;
}
+(NSString *)getTime{
    NSDate *fromdate=[NSDate date];
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* string=[dateFormat stringFromDate:fromdate];
    return string;
}

+(NSDate *)dateWithTimeStamp:(double)timestamp
{
    if(timestamp > 140000000000) {
        timestamp = timestamp / 1000;
    }
    return [NSDate dateWithTimeIntervalSince1970:timestamp];
}

+(NSString*)getLastOnlineTime:(NSString*)timestamp{
    
    //根据时间戳返回好友上次上线具体年月日
    NSTimeInterval interval = [timestamp doubleValue] ;//+ 28800;//时差问题要加8小时 == 28800 sec
    NSDate *today = NSDate.date;
    NSDate *date= [CommonTool dateWithTimeStamp:interval ];//[NSDate dateWithTimeIntervalSinceNow: interval/1000 - today.timeIntervalSinceNow]; 
    
    
    double difD =  fabs(today.timeIntervalSince1970 - date.timeIntervalSince1970) / (60 * 60 *24);//两个日期相差的天数
//    NSLog(@"today:%@,date:%@", today,date);
//    NSLog(@"dif:%f",difD);
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];
    //好友上次登录的年月日
    int Y = [comps year];
    int M = [comps month];
    int D = [comps day];
    int H = [comps hour];
    int Min = [comps minute];
//    int S = [comps second];
//    int weekday = [comps weekday];//周日是1，周1是2
    //自己系统时间的年月日
    NSDate* now = [NSDate date];
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    comps = [calendar components:unitFlags fromDate:now];
    
    //    int year = [comps year];
    //    int month = [comps month];
    int day = [comps day];
    int hour = [comps hour];
        int min = [comps minute];
    //    int sec = [comps second];
    
    //NSLog(@"%d:%d:%d", hour, min,sec);
    //NSLog(@"%d:%d:%d,%d", year, month, day,weekday);
    //
    //    NSLog(@"-*******YMD:->%d:%d:%d",Y,M,D);
    //    NSLog(@"-*******HMS:->%d:%d:%d",H,Min,S);
    
    //*******返回值逻辑判断
    
    //当天，则显示：24小时显示制，小时和分钟，如20:47。
    if(difD < 1){//if(day == D){
        if(hour == H && day == D){//同一个小时,同一天
//            NSLog(@"-******* min,Min:->%d:%d:",min,Min);
            return [NSString stringWithFormat:@"%d%@",min-Min,@"分钟前"];
        }else if(hour == H && day != D){
            return [NSString stringWithFormat:@"23小时前"];
        }else{
            return [NSString stringWithFormat:@"%d%@",(hour + 24 -H)%24,@"小时前"];
        }
    }
    //前一天，则显示：昨天。
    if(difD < 2 && difD >=1){//if(day - D == 1){
        return @"昨天";
    }
    //前二天=< 时间 <=前六天，则显示星期，如星期二。
    if(difD >=2 && difD < 6){//if(day - D >= 2 && day - D <=6){
//        NSArray *weekDayChinese = @[@"", @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"];
//        return weekDayChinese[weekday];
        
        
        return [NSString stringWithFormat:@"%.0f%@",difD,@"天前"];
    }
    //前七天，则显示日期，格式如：14-7-9（注意不是：14-07-09,无需添0)
    if(difD >= 6){//if(day - D >= 7){
        return [NSString stringWithFormat:@"%d-%d-%d",Y,M,D];
    }
    
    return @"计算错误";
}


//1.等比率缩放
+ (UIImage *)scaleImage:(UIImage *)image toScale:(CGSize)scaleSize
{
    UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0.0);
    [image drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
                                
}

+ (UIImage *)fullScreenImage : (UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGSize size;
    NSLog(@"image.size.height%f",image.size.height);
    NSLog(@"image.size.width%f",image.size.width);
    if (image.size.height > image.size.width) {
        CGFloat multiple = image.size.width/320.0f;
        size = CGSizeMake(320, image.size.height/multiple);
    }else{
        CGFloat multiple = image.size.height/320.0f;
        size = CGSizeMake(image.size.width/multiple, 320);
    }
    return [self scaleImage:image toScale:size];
}

+ (BOOL)isNumber:(NSString*)text{
    int i;
    for(i = 0;i<10;i++){
        NSString *strNum = [NSString stringWithFormat:@"%d",i];
        if([text isEqualToString:strNum])
            break;
    }
    if(i > 9)
        return NO;
    return YES;
}



                    


@end
