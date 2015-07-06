//
//  SendMessageViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/3/27.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SendMessageViewController: BasicViewController {

    @IBOutlet weak var numberText: UITextField!
    @IBOutlet weak var confrimBtn: UIButton!
    
    //变量
    var initFlag : Bool = false
    
    //常量
    let NUMBER_MAXLENGTH = 11
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headView.hidden = true
        //textField的圆角，边框颜色和宽度
        numberText.layer.cornerRadius = 4
        numberText.layer.borderWidth = 1
        numberText.layer.borderColor =  UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1).CGColor
        
        numberText.delegate = self
        
        //接收通知用于限制字数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChange:", name: UITextFieldTextDidChangeNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //设置文字左边距
        if !initFlag {
            numberText.leftView = UIView(frame: CGRectMake(0, 0, 8, numberText.frame.size.height))
            numberText.leftViewMode = UITextFieldViewMode.Always
            initFlag = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: -实例方法
extension SendMessageViewController {
    
    private func limitTextLength(textField:UITextField,maxLength:Int){
        var text = textField.text as NSString
        if text.length > maxLength {
            textField.text = text.substringToIndex(maxLength)
        }
    }
}

//MARK:-按钮点击
extension SendMessageViewController {
    
    @IBAction func closeBtnClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //忘记密码
    @IBAction func confirmBtnClick(sender: AnyObject) {
        confrimBtn.enabled = false
        HttpManager.sendHttpRequestPost(FORGET_PASSWORD, parameters: ["phone":numberText.text
            ],
            success: { (json) -> Void in
                
                FLOG("找回密码码返回json：\(json)")
                UIAlertView(title: "密码已发送", message: "短信有延时，请注意查收并保护密码安全", delegate: self, cancelButtonTitle: "确定").show()
                self.confrimBtn.enabled = true
            },
            failure:{ (reason) -> Void in
                self.confrimBtn.enabled = true
                FLOG("失败原因:\(reason)")
        })
    }
}

//MARK:-UIAlertViewDelegate
extension SendMessageViewController:UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController?.popViewControllerAnimated(true)
    }
}

//MARK:-UITextFieldDelegate
extension SendMessageViewController:UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //检测是否数字
        if range.length == 0 {//输入
            return CommonTool.isNumber(string)
        }
        return true
    }
    
    func textChange(notification:NSNotification){
        var textField = notification.object as! UITextField
        if textField == numberText {   //电话号码输入框
            limitTextLength(textField, maxLength: NUMBER_MAXLENGTH)
        }
    }
}
