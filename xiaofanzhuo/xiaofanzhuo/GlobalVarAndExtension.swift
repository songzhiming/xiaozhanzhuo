//
//  GlobalVarAndExtension.swift
//  xiaofanzhuo
//
//  Created by Fred on 2/6/15.
//  Copyright (c) 2015 songzm. All rights reserved.
//

import Foundation

func FLOG(logMessage: Any, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    println("\(file.lastPathComponent):\(function):\(line) >>> \(logMessage)");
}

//加载状态，用于大白显示
let LOAD_FAILED = "数据加载失败\n下拉页面重新加载"
let LOAD_FAILED_NO_REFRESH = "数据加载失败"
let LOAD_EMPTY = "还没有信息\n快去参与大家的互动吧~"
let LOAD_SEARCH_EMPTY = "没有找到您要的信息\n换个词试试吧~"

//用于md5加密的尾部
let MD5_BASE_TAIL = "selcome"

//用于xiaofanzhuo项目密码的MD5加密
extension String {
    var md5_with_tail: String! {
        get{
            var orginStr = self + MD5_BASE_TAIL
            let str = orginStr.cStringUsingEncoding(NSUTF8StringEncoding)
            let strLen = CC_LONG(orginStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
            let digestLen = Int(CC_MD5_DIGEST_LENGTH)
            let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
            
            CC_MD5(str!, strLen, result)
            
            var hash = NSMutableString()
            for i in 0..<digestLen {
                hash.appendFormat("%02x", result[i])
            }
            
            result.dealloc(digestLen)
            var md5_result = String(format: hash as String)
            return md5_result
        }
    }
}

//用于实现顶部弹出的提示
extension UIWindow {
    func showToast(message:String){
        
        var toastView = getToastView(message)
        toastView.transform = CGAffineTransformMakeTranslation(0, -toastView.frame.height)
        self.addSubview(toastView)
        //设置在状态栏之上
        self.windowLevel = UIWindowLevelAlert
        //动画
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: .CurveEaseOut,
            animations: { () -> Void in
                toastView.transform = CGAffineTransformIdentity
                
            }) { (finished) -> Void in
                var timer = NSTimer.scheduledTimerWithTimeInterval(
                    1.35,
                    target: self,
                    selector: "toastTimerDidFinish:",
                    userInfo:toastView, repeats: false)
        }
    }
    
    func toastTimerDidFinish(timer:NSTimer){
        self.hideToast(timer.userInfo as! UIView)
    }
    
    func hideToast(toast:UIView){
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: .CurveEaseIn,
            animations: { () -> Void in
                toast.transform = CGAffineTransformMakeTranslation(0, -toast.frame.height)
            }) { (finished) -> Void in
                self.windowLevel = UIWindowLevelNormal
                toast.removeFromSuperview()
        }
    }
    
    
    private func getToastView(message:String) -> UIView{
        
        //参数获取或定义
        var screenBounds = UIScreen.mainScreen().bounds
        var topMargin :CGFloat = 4
        var fontSize: CGFloat = 14
        
        //计算文本高度
        var labelHeight = (message as NSString).boundingRectWithSize(
            CGSizeMake(screenBounds.width,0),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName : UIFont.systemFontOfSize(fontSize)],
            context: nil).height
        
        //配置label
        var label = UILabel(frame: CGRectMake(0, topMargin, screenBounds.width, labelHeight))
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        label.font = UIFont(name: "FZLanTingHeiS-R-GB", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.text = message
        
        //配置toastView
        var toastView = UIView(frame: CGRectMake(0, 0, screenBounds.width, labelHeight + topMargin * 2 ))
        toastView.backgroundColor = UIColor.blackColor()
        toastView.alpha = 0.95
        toastView.addSubview(label)
        
        return toastView
    }
}

//用于显示小角标
extension UIView {
    
    //设置一个用于存放Objc-Runtime key 的结构体
    //参考资料http://nshipster.com/swift-objc-runtime/
    private struct AssociatedKeys {
        static var NumLabelKey = "xfz_NumLaebel"
    }
    
    func showCornerStatus(badgeNumber:Int,rateX:CGFloat,rateY:CGFloat){
        self.removeCornerStatus()
        if badgeNumber == 0 {
            return
        }
        
        var labelWidth: CGFloat = 20
        var numLabel = UILabel(frame: CGRectMake(0, 0, labelWidth, labelWidth))
        var settingCenter = CGPointZero
        
        settingCenter.x = self.frame.width * rateX
        settingCenter.y = self.frame.width * rateY
        
        numLabel.center = settingCenter
        numLabel.layer.cornerRadius = labelWidth/2
        numLabel.clipsToBounds = true
        numLabel.backgroundColor = UIColor.redColor()
        numLabel.textColor = UIColor.whiteColor()
        numLabel.textAlignment = NSTextAlignment.Center
        numLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 10) ?? UIFont.systemFontOfSize(10)
        numLabel.text =  badgeNumber > 99 ? "..." : "\(badgeNumber)"
        
        //设置关联变量
        objc_setAssociatedObject(self,&AssociatedKeys.NumLabelKey, numLabel, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        
        self.addSubview(numLabel)
        
    }
    
    func removeCornerStatus(){
        var numLabel = objc_getAssociatedObject(self, &AssociatedKeys.NumLabelKey) as? UIView
        numLabel?.removeFromSuperview()
    }
}