//
//  NavigationPopGestureDelagate.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/4/27.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class NavigationPopGestureDelagate: NSObject,UIGestureRecognizerDelegate{
    
    let porjectName = "xiaofanzhuo."
    let classes = ["HomeViewController"
        ,"PersonInfoViewController"
        ,"VerifyViewController"
        ,"LoginViewControllerNew"]
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool{

        return getReturnState(UIApplication.sharedApplication().keyWindow?.rootViewController)
    }
}

extension NavigationPopGestureDelagate {
    
    //限制某几个界面不能响应左侧滑动返回上级页面
    func getReturnState(viewController:UIViewController?) -> Bool{
        
        for className in classes {
            
            if let vc = viewController as? UINavigationController {
                
                var lastVcO: AnyObject? = vc.viewControllers.last
                if let lastVc: AnyObject = lastVcO {
                    var curClassName = NSStringFromClass(lastVc.dynamicType)
                    if curClassName == porjectName + className {
                        return false
                    }
                }
                
            }
        }
        return true
    }
}
