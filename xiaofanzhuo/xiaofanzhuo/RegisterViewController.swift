//
//  RegisterViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/3/9.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class RegisterViewController: BasicViewController {
    
    @IBOutlet weak var numberText: UITextField!
    @IBOutlet weak var verifyCodeText: UITextField!
    @IBOutlet weak var agreeCheckBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var getVerifyCodeBtn: UIButton!

    var timer : NSTimer!
    var initFlag : Bool = false
    
    let NUMBER_MAXLENGTH = 11
    let VERIFY_CODE_MAXLENGTH = 4
    let VERIFY_CODE_TIME = 60
    
    var state = ""
    
    private var timeLeft: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headView.hidden = true
        //textField的圆角，边框颜色和宽度
        numberText.layer.cornerRadius = 4
        numberText.layer.borderWidth = 1
        numberText.layer.borderColor =  UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1).CGColor
        verifyCodeText.layer.cornerRadius = 4
        verifyCodeText.layer.borderWidth = 1
        verifyCodeText.layer.borderColor =  UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1).CGColor
        numberText.delegate = self
        verifyCodeText.delegate = self
        //确认按钮默认不可用
        confirmBtn.enabled = false
        getVerifyCodeBtn.enabled = false
        agreeCheckBtn.selected = true
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        //接收通知用于限制字数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChange:", name: UITextFieldTextDidChangeNotification, object: nil)
        
        var stateDicO = self.param as? [String:String]
        if let stateDic = stateDicO {
            self.state = stateDic["state"]!
            switch state {
            case "reset_password"://如果是充值密码，下面的确认按钮设置为“重置密码”

                confirmBtn.setTitle("重置密码", forState: UIControlState.Disabled)
                confirmBtn.setTitle("重置密码", forState: UIControlState.Normal)
                
                break
            case "regist_new_user"://默认是这个状态，不用修改
                break
            default:
                break
            }
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //设置文字左边距
        if !initFlag {
            numberText.leftView = UIView(frame: CGRectMake(0, 0, 8, numberText.frame.size.height))
            numberText.leftViewMode = UITextFieldViewMode.Always
            verifyCodeText.leftView = UIView(frame: CGRectMake(0, 0, 8, verifyCodeText.frame.size.height))
            verifyCodeText.leftViewMode = UITextFieldViewMode.Always
            initFlag = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: -按钮点击
extension RegisterViewController {
    //确认按钮 ,或者重置密码按钮
    @IBAction func confirmBtnClick(sender: AnyObject) {
        
        var url = self.state == "reset_password" ? VALIDATE_CAPTCHA : REGISTER_NEW
        
        var pushId : String = ""
        if let id = (NSUserDefaults.standardUserDefaults().objectForKey("pushId") as? String) {
            pushId = id
        }
        confirmBtn.enabled = false
        HttpManager.sendHttpRequestPost(url, parameters:
            ["phone":numberText.text,
            "authCode":verifyCodeText.text,
            "pushId":pushId
            ],
            success: { (json) -> Void in
                
                FLOG("注册返回json:\(json)")
                self.invalidateTheTimer()
                var num = self.numberText.text
                var id = ""
                var idO = json["userId"] as? String
                if let idUnwrap = idO {
                    id = idUnwrap
                }
                var param : [String:AnyObject] = ["phoneNum":num,"userId":id]
                
                var nextVc = self.state == "reset_password" ?
                    ResetPasswordViewController(nibName: "ResetPasswordViewController", bundle: nil,param:["phoneNum":num]) :
                    PersonInfoViewController(nibName: "PersonInfoViewController", bundle: nil,param:param)
                self.navigationController?.pushViewController(nextVc, animated: true)
                
            },
            failure:{ (reason) -> Void in
                self.confirmBtn.enabled = true
                FLOG("失败原因:\(reason)")
        })
    }
    //获取验证码
    @IBAction func getVerifyCodeBtnClick(sender: AnyObject) {
        
        var url = self.state == "reset_password" ? VALIDATE_PHONE : GET_AUTH_CODE

        getVerifyCodeBtn.enabled = false
        HttpManager.sendHttpRequestPost(url, parameters: ["phone":numberText.text],
            success: { (json) -> Void in
                
                FLOG("验证码返回json:\(json)")
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFire", userInfo: nil,repeats: true)
                UIAlertView(title: "提示", message: "验证码已经发送，请注意查收", delegate: nil, cancelButtonTitle: "确定").show()
                self.getVerifyCodeBtn.enabled = true
                self.checkIsCompleted()
            },
            failure:{ (reason) -> Void in
                
                FLOG("失败原因:\(reason)")
                self.getVerifyCodeBtn.enabled = true
        })
    }
    //右上角关闭按钮
    @IBAction func closeBtnClick(sender: AnyObject) {
        invalidateTheTimer()
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
}

// MARK: -类方法
extension RegisterViewController {
    private func checkIsCompleted() -> Bool {
        if (numberText.text as NSString).length < NUMBER_MAXLENGTH || (verifyCodeText.text as NSString).length < VERIFY_CODE_MAXLENGTH || !agreeCheckBtn.selected{
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
    
    private func invalidateTheTimer(){
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    func timerFire(){
        timeLeft++
        getVerifyCodeBtn.enabled = false
        getVerifyCodeBtn.setAttributedTitle(NSAttributedString(string: "\(VERIFY_CODE_TIME-timeLeft)秒重新获取"), forState: UIControlState.Disabled)
//        FLOG("\(VERIFY_CODE_TIME-timeLeft)")
        if timeLeft > VERIFY_CODE_TIME {
            getVerifyCodeBtn.enabled = true
            getVerifyCodeBtn.setAttributedTitle(NSAttributedString(string: "重新获取验证码"), forState: UIControlState.Disabled)
            timeLeft = 0
            timer.invalidate()
        }
    }
}

// MARK: -UITextFieldDelegate 和 相关通知
extension RegisterViewController : UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //检测是否数字
        if textField == numberText {
            if range.length == 0 {//输入
                return CommonTool.isNumber(string)
            }
        }
        return true
    }
    
    func textChange(notification:NSNotification){
        var textField = notification.object as! UITextField
        checkIsCompleted()
        if textField == numberText {   //电话号码输入框
            limitTextLength(textField, maxLength: NUMBER_MAXLENGTH)
            var text = textField.text as NSString
            //限制获取验证码按钮是否可用
            if text.length >= 11 {
                getVerifyCodeBtn.enabled = true
            }else{
                getVerifyCodeBtn.enabled = false
            }
        }
//        if textField == verifyCodeText {//验证码输入框
//            limitTextLength(textField, maxLength: VERIFY_CODE_MAXLENGTH)
//        }
    }
}

