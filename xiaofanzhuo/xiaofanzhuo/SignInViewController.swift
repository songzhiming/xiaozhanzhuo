//
//  SignInViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/3/10.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SignInViewController: BasicViewController {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var agreeCheckBtn: UIButton!
    
    var initFlag : Bool = false
    
    let USERNAME_MAXLENGTH = 16
    let PASSWORD_CODE_MAXLENGTH = 16
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headView.hidden = true
        //textField的圆角，边框颜色和宽度
        usernameText.layer.cornerRadius = 4
        usernameText.layer.borderWidth = 1
        usernameText.layer.borderColor =  UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1).CGColor
        passwordText.layer.cornerRadius = 4
        passwordText.layer.borderWidth = 1
        passwordText.layer.borderColor =  UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1).CGColor
        
         UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        //确认按钮默认不可用
        confirmBtn.enabled = false
        agreeCheckBtn.selected = true
        //接收通知用于限制字数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChange:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //设置文字左边距
        if !initFlag {
            usernameText.leftView = UIView(frame: CGRectMake(0, 0, 8, usernameText.frame.size.height))
            usernameText.leftViewMode = UITextFieldViewMode.Always
            passwordText.leftView = UIView(frame: CGRectMake(0, 0, 8, passwordText.frame.size.height))
            passwordText.leftViewMode = UITextFieldViewMode.Always
            initFlag = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
    }
}

// MARK: -类方法
extension SignInViewController {
    private func checkIsCompleted() -> Bool {
        if usernameText.text.isEmpty || passwordText.text.isEmpty {//|| !agreeCheckBtn.selected{
            confirmBtn.enabled = false
            return false
        }
        confirmBtn.enabled = true
        return true
    }
    
    private func limitTextLength(textField:UITextField,maxLength:Int){
        var text = textField.text as NSString
        if text.length > maxLength {
            textField.text = text.substringToIndex(maxLength)
        }
    }
}

// MARK: -按钮点击
extension SignInViewController {
    //确认按钮
    @IBAction func confirmBtnClick(sender: AnyObject) {
        var pushId : String = ""
        if let id = (NSUserDefaults.standardUserDefaults().objectForKey("pushId") as? String) {
            pushId = id
        }
        
        HttpManager.sendHttpRequestPost(LOGIN_NEW, parameters:
            ["loginName": usernameText.text,
                "loginPass":passwordText.text.md5_with_tail,
                "pushId":pushId
            ],
            success: { (json) -> Void in
                
                FLOG("登录返回json:\(json)")
                //服务器数据返回成功,添加用户状态
                var userInfo = json["userInfo"] as! [String:AnyObject]
                userInfo["userState"] = json["userState"]
                userInfo["userId"] = json["userId"]
                userInfo["personInfo"] = json["userInfo"]
                
                if let stateInfo = json["userStateInfo"] as? String{
                    userInfo["userStateInfo"] = stateInfo
                }
                
                //处理登陆授权成功页面跳转,根据服务器返回的userState，跳转 首页 还是 审核页 还是 信息填写页
                var userState = (userInfo["userState"] as! String).toInt()//(ApplicationContext.getUserInfo()!["userState"] as String).toInt()
                var nextViewController : UIViewController!
                
                if userState == 1{//没提交写个人信息
                    var id = json["userId"] as! String
                    var num = (json["userInfo"] as! [String:AnyObject])["phone"] as! String
                    var param = ["phoneNum":num,"userId":id]
                    nextViewController = PersonInfoViewController(nibName: "PersonInfoViewController", bundle: nil,param:["phoneNum":num,"userId":id])
                }else if userState == 2 || userState == 4{//已提交个人信息，未通过审核或审核中
                    nextViewController = VerifyViewController(nibName: "VerifyViewController", bundle: nil)
                }else{//已提交个人信息，审核通过，跳转主页
                    nextViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
                    userInfo["personInfo"] = json["userInfo"] //as NSDictionary   //[String : AnyObject]
                    userInfo["binding"] = json["binding"]
                }
                //保存登陆信息
                FLOG("userinfo\(userInfo)")
                ApplicationContext.saveUserInfo(userInfo)
                self.navigationController?.pushViewController(nextViewController, animated: true)
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })

    }
    
    //右上角关闭按钮
    @IBAction func closeBtnClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    //同意左边选择按钮
    @IBAction func agreeCheckBtnClick(sender: AnyObject) {
        agreeCheckBtn.selected = !agreeCheckBtn.selected
        checkIsCompleted()
    }
    //用户协议查看
    @IBAction func checkProtocalBtnClick(sender: AnyObject) {
    }
    
    @IBAction func getPasswordBtnClick(sender: AnyObject) {
        var viewController = RegisterViewController(nibName: "RegisterViewController", bundle: nil,param:["state":"reset_password","data":""])
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// MARK: -UITextFieldDelegate 和 相关通知
extension SignInViewController : UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        //检测是否数字
        if range.length == 0 && textField == usernameText {//输入
            return CommonTool.isNumber(string)
        }
        return true
    }

    func textChange(notification:NSNotification){
        var textField = notification.object as! UITextField
        checkIsCompleted()
        if textField == usernameText {   //电话号码输入框
            limitTextLength(textField, maxLength: USERNAME_MAXLENGTH)
        }
//        if textField == passwordText {//验证码输入框
//            limitTextLength(textField, maxLength: PASSWORD_CODE_MAXLENGTH)
//        }
    }
}
