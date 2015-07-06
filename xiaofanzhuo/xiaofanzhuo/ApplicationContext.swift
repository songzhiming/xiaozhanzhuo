//
//  ApplicationContext.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-15.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

//var isCompleteUserInfo : Bool = true
class ApplicationContext: NSObject {
    

    
    class var sharedInstance :ApplicationContext {
        struct Singleton {
            static let instance = ApplicationContext()
        }
        return Singleton.instance
    }
    


    
    
    
    
    
    
    
    
    class func hasLogin()->Bool{
        var hasLogin : AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("userInfo") //as? [String:AnyObject]
        if let longin: AnyObject = hasLogin {
            return true
        }
        return false
    }
    
//    //获取用户信息是否完整
//    class func getIsCompleteUserInfo()->Bool {
//        return
//    }
    
    
    class func getUserID()->String? {
        return ApplicationContext.getUserInfo()!["userId"] as? String //NSUserDefaults.standardUserDefaults().valueForKeyPath("userInfo.userId") as? String
    }
    
    class func saveUserInfo(userInfo:[String:AnyObject]){
        NSUserDefaults.standardUserDefaults().setValue(NSKeyedArchiver.archivedDataWithRootObject(userInfo), forKey: "userInfo")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getUserInfo()->[String:AnyObject]? {
        
        var userData = NSUserDefaults.standardUserDefaults().valueForKey("userInfo") as? NSData
        if let data = userData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String:AnyObject]
        }
        return nil//NSUserDefaults.standardUserDefaults().valueForKey("userInfo") as? [String:AnyObject]//.objectForKey("userInfo") as? [String:AnyObject]
    }
    class func getMyUserInfo()->[String:AnyObject]? {
        return ApplicationContext.getUserInfo()!["personInfo"] as? [String:AnyObject]//NSUserDefaults.standardUserDefaults().valueForKeyPath("userInfo.personInfo") as? [String:AnyObject]
    }
    class func getBinding()->[[String:AnyObject]]? {
        return ApplicationContext.getUserInfo()!["binding"] as? [[String:AnyObject]]//NSUserDefaults.standardUserDefaults().valueForKeyPath("userInfo.binding") as? [[String:AnyObject]]
    }
    class func toJSONString(object : AnyObject) -> NSString{
        var data = NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
        var strJson : NSString! = NSString(data: data, encoding: NSUTF8StringEncoding)
        return strJson
    }
    
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

}




