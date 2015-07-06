//
//  EditPasswordViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/3/27.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class EditPasswordViewController: BasicViewController {
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmNewPassword: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    
    //变量
    var initFlag : Bool = false
    
    //常量

    override func viewDidLoad() {
        super.viewDidLoad()
        headView.changeLeftButton()
        headView.logoImage.hidden = true
        headView.titleLabel.text = "修 改 密 码"
        headView.searchButton.hidden = true
        headView.generateCodeButton.hidden = true
        
        //textField的圆角，边框颜色和宽度
        initTextFieldsLayouts(password)
        initTextFieldsLayouts(newPassword)
        initTextFieldsLayouts(confirmNewPassword)
        
        //接收通知用于限制字数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChange:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //设置文字左边距
        if !initFlag {
            initTextFieldsMargin(password)
            initTextFieldsMargin(newPassword)
            initTextFieldsMargin(confirmNewPassword)
            self.view.bringSubviewToFront(self.headView)
            initFlag = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: -实例方法
extension EditPasswordViewController {
    //textField的圆角，边框颜色和宽度
    private func initTextFieldsLayouts(textField:UITextField!){
        textField.layer.cornerRadius = 4
        textField.layer.borderWidth = 1
        textField.layer.borderColor =  UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1).CGColor
    }
    //textField文字离左边距离
    private func initTextFieldsMargin(textField:UITextField!){
        textField.leftView = UIView(frame: CGRectMake(0, 0, 8, textField.frame.size.height))
        textField.leftViewMode = UITextFieldViewMode.Always
    }
    
    private func checkIsCompleted()->Bool{
        if password.text.isEmpty {
            HYBProgressHUD.showError("请输入旧密码,旧密码不能为空")
            return false
        }
        if newPassword.text.isEmpty {
            HYBProgressHUD.showError("请输入新密码")
            return false
        }
        if confirmNewPassword.text.isEmpty {
            HYBProgressHUD.showError("请确认信密码")
            return false
        }
        return true
    }
}

// MARK: -按钮点击
extension EditPasswordViewController {

    @IBAction func confirmBtnClick(sender: AnyObject) {
        if !checkIsCompleted() {
            return
        }
        confirmBtn.enabled = false
        HttpManager.sendHttpRequestPost(UPDATE_PASSWORD, parameters: ["oldPwd":password.text.md5_with_tail,
            "newPwd":newPassword.text.md5_with_tail,
            "userId":ApplicationContext.getUserID()!
            ],
            success: { (json) -> Void in
                //调用找回密码接口
                FLOG("修改密码返回json：\(json)")
                HYBProgressHUD.showSuccess("密码修改成功")
                self.navigationController?.popViewControllerAnimated(true)
                self.confirmBtn.enabled = true
                
            },
            failure:{ (reason) -> Void in
                self.confirmBtn.enabled = true
                FLOG("失败原因:\(reason)")
        })

    }
}

// MARK: -Notification
extension EditPasswordViewController {
    
    func textChange(notification:NSNotification){
        var textField = notification.object as! UITextField
        if textField == newPassword || textField == confirmNewPassword {   //电话号码输入框
            if newPassword.text == confirmNewPassword.text {
                alertLabel.hidden = true
            }else{
                alertLabel.hidden = false
            }
        }
    }
}


