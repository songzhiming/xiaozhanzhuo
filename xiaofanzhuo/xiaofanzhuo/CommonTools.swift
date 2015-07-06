//
//  CommonTools.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-21.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class CommonTools: NSObject {
    //打电话
    class func makeCall(phoneNum : String){
        var deviceType  = UIDevice.currentDevice().model
        if deviceType == "iPod touch" || deviceType == "iPad" || deviceType == "iPhone Simulator"{
            UIAlertView(title: "提示", message: "您的设备不能打电话", delegate: nil, cancelButtonTitle: "好的,知道了").show()
        }else{
            var phoneNumber = "tel:" + "\(phoneNum)"
            var phoneNumberUrl = (NSURL(string: phoneNumber))
            UIApplication.sharedApplication().openURL(phoneNumberUrl!)
        }
    }
}
