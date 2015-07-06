//
//  WorkInfoViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/3/11.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class WorkInfoViewController: BasicViewController  {

    @IBOutlet weak var bgBtn: UIButton!
    @IBOutlet weak var direction: HolderTextView!
    @IBOutlet weak var experience: HolderTextView!
    
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var experienceView: UIView!
    @IBOutlet weak var commnitBtn: UIButton!
    @IBOutlet weak var minViewTop: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!

    
    var tempConstant : CGFloat!
    
    var currentSituation : String! = ""
    let SITUATION_START = 3000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headView.hidden = true
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        //设置placeHolder与字数限制
        experience.placeHolder = "经历越详细，通过审核机会越大呦"//字数默认限制140字
        direction.placeHolder = "请简述您的创业方向："
        
        var ges = UITapGestureRecognizer(target: self, action: "directionTap")
        direction.addGestureRecognizer(ges)
        var longges = UILongPressGestureRecognizer(target: self, action: "directionTap")
         direction.addGestureRecognizer(longges)
        //键盘弹出监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShown:", name: UIKeyboardWillShowNotification, object: nil)
    }
}

//MARK: -按钮点击
extension WorkInfoViewController {
 
    @IBAction func backBtnClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func bgBtnClick(sender: AnyObject) {
        self.view.endEditing(true)
        self.contentView.sendSubviewToBack(bgBtn)
        UIView.animateWithDuration(0.25,
            delay: 0.07,
            usingSpringWithDamping: 2,
            initialSpringVelocity: 0.1,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                self.minViewTop.constant = 0
                self.view.layoutIfNeeded()
            }) { (Bool) -> Void in
                
        }
        
    }
    @IBAction func commitBtnClick(sender: AnyObject) {
        if direction.text.isEmpty {
            HYBProgressHUD.showError("创业方向不能为空")
            return
        }
        if currentSituation.isEmpty {
            HYBProgressHUD.showError("目前状态不能为空")
            return
        }
        var param = self.param as! [String:AnyObject]
        param["situation"] = currentSituation
        param["direction"] = direction.text
        param["experience"] = experience.text

        FLOG("param:\(param)")
        var userId = param["userId"] as! String
        var avatar = param["avatar"] as! String
        var phoneNum = param["phone"] as! String
        commnitBtn.enabled = false
        HttpManager.sendHttpRequestPost(SET_USER_INFO, parameters: param,
            success: { (json) -> Void in
                
                FLOG("个人信息提交json:\(json)")
                var userInfo = [String:AnyObject]()
                userInfo["userId"] = userId
                userInfo["avatar"] = BASE_URL + "upload/images/" + avatar
                userInfo["phoneNum"] = phoneNum
                ApplicationContext.saveUserInfo(userInfo)
                if (json["userState"] as! String) == "3" {//审核通过，进首页
                    HttpManager.sendHttpRequestPost(GETUSERINFO, parameters:
                        ["userId": ApplicationContext.getUserID()!,
                            "id": ApplicationContext.getUserID()!
                        ],
                        success: { (json) -> Void in
                            
                            FLOG("更新个人信息返回json:\(json)")
                            var userInfo = ApplicationContext.getUserInfo()!
                            
                            if let personInfo = json["userInfo"] as? [String:AnyObject] {
                                userInfo["personInfo"] = personInfo
                            }
                            if let binding = json["binding"] as? [String:AnyObject] {
                                userInfo["binding"] = binding
                            }
                            userInfo["userState"] = "3"
                            ApplicationContext.saveUserInfo(userInfo)
                            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
                            self.navigationController?.pushViewController(homeViewController, animated: true)
                        },
                        failure:{ (reason) -> Void in
                            FLOG("失败原因:\(reason)")
                    })
                }else{//此处跳转到审核页面
                    var userInfo = ApplicationContext.getUserInfo()!
                    userInfo["userState"] = "2"
                    ApplicationContext.saveUserInfo(userInfo)
                    var verifyViewController = VerifyViewController(nibName: "VerifyViewController", bundle: nil)
                    self.navigationController?.pushViewController(verifyViewController, animated: true)
                }
            },
            failure:{ (reason) -> Void in
                
                self.commnitBtn.enabled = true
                FLOG("失败原因:\(reason)")
        })
    }
    
    @IBAction func situationCheckBtnClick(sender: UIButton) {
        self.view.endEditing(true)
        for var i = 1;i<4;i++ {
            (self.view.viewWithTag(SITUATION_START + i) as! UIButton).selected = false
            (self.view.viewWithTag(SITUATION_START + i + 10) as! UILabel).textColor = UIColor.lightGrayColor()
        }
        sender.selected = true
        (self.view.viewWithTag(sender.tag + 10) as! UILabel).textColor = UIColor.blackColor()
        switch sender.tag - SITUATION_START {
        case 1:
            currentSituation = String(1)
            break
        case 2:
            currentSituation = String(2)
            break
        case 3:
            currentSituation = String(3)
            break
        default:
            break
        }
    }
}

//MARK: -类方法
extension WorkInfoViewController {
    //键盘弹出处理
    func keyboardWillShown(notification:NSNotification){
//        FLOG(notification)
        self.contentView.bringSubviewToFront(bgBtn)
    }
    
    func directionTap(){
        direction.becomeFirstResponder()

        UIView.animateWithDuration(0.25,
            delay: 0.07,
            usingSpringWithDamping: 2,
            initialSpringVelocity: 0.1,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                self.minViewTop.constant = -(261-100)*((UIScreen.mainScreen().bounds.width)/320)
                self.view.layoutIfNeeded()
            }) { (Bool) -> Void in
                
        }
        
        
    }
}

