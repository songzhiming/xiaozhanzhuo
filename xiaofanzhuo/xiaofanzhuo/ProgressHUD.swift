//
//  ProgressHUD.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/3/27.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation
import UIKit

//充当一个适配器
class HYBProgressHUD {
    
    class func show(status:String,isSuccess:Bool){
//        UIAlertView(title: "提示", message: status, delegate: nil, cancelButtonTitle: "好的，知道了").show()
        UIApplication.sharedApplication().keyWindow?.showToast(status)
    }
    
    class func showSuccess(status: String) {
        show(status,isSuccess:true)
    }
    
    class func showError(status: String) {
        show(status,isSuccess:false)
    }
}
