//
//  ResetPasswordViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/4/29.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class ResetPasswordViewController: BasicViewController {

    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmNewPassword: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    
    //变量
    var initFlag : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headView.hidden = true
        confirmBtn.enabled = false
        setTextFieldLayout(newPassword)
        setTextFieldLayout(confirmNewPassword)
        
        //接收通知用于限制字数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChange:", name: UITextFieldTextDidChangeNotification, object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //设置文字左边距
        if !initFlag {
            setTextFieldMargins(newPassword)
            setTextFieldMargins(confirmNewPassword)
            initFlag = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK:- 实例方法
extension ResetPasswordViewController {
    private func setTextFieldLayout(textField:UITextField){
        textField.layer.cornerRadius = 4
        textField.layer.borderWidth = 1
        textField.layer.borderColor =  UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1).CGColor
    }
    
    private func setTextFieldMargins(textField:UITextField){
        textField.leftView = UIView(frame: CGRectMake(0, 0, 8, textField.frame.size.height))
        textField.leftViewMode = UITextFieldViewMode.Always
    }
}

//MARK:- 按钮点击
extension ResetPasswordViewController {
    @IBAction func closeBtnClikc(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func confirmBtnClick(sender: AnyObject) {
        
        var dataDic = self.param as! [String:String]
        var num = dataDic["phoneNum"]! as String
        confirmBtn.enabled = false
        HttpManager.sendHttpRequestPost(RESET_PASS, parameters: ["phone":num,"password":newPassword.text.md5_with_tail],
            success: { (json) -> Void in
                
                FLOG("重置密码json:\(json)")
                self.confirmBtn.enabled = true
                UIAlertView(title: "提示", message: "密码重置成功", delegate: nil, cancelButtonTitle: "确定").show()
                self.navigationController!.viewControllers.removeAtIndex(self.navigationController!.viewControllers.count-2)
                self.navigationController?.popViewControllerAnimated(true)
                
            },
            failure:{ (reason) -> Void in
                
                FLOG("失败原因:\(reason)")
                self.confirmBtn.enabled = true
        })
    }
}

//MARK:- NSNotification
extension ResetPasswordViewController{
    func textChange(notification:NSNotification){
        var textField = notification.object as! UITextField
        if  checkTextCount(textField,maxLength: 16) {   //电话号码输入框
            if newPassword.text == confirmNewPassword.text {
                alertLabel.hidden = true
                confirmBtn.enabled = true
            }else{
                confirmBtn.enabled = false
                alertLabel.hidden = false
            }
        }
    }
    
    func checkTextCount(textField:UITextField,maxLength:Int) -> Bool{
        
        if (count(textField.text) > maxLength) {
            textField.text = textField.text.substringToIndex(advance(textField.text.startIndex, maxLength))
        }
        
        if count(textField.text) >= 6 {
            return true
        }
        return false
    }
}
