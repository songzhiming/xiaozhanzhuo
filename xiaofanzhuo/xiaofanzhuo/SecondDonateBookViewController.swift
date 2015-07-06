//
//  SecondDonateBookViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-26.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SecondDonateBookViewController: BasicViewController,UIAlertViewDelegate{

    var keyboardShowstate : Bool = false
    
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.recommendButton.hidden = true
        headView.backButton.hidden = false
        headView.logoImage.hidden = true
        headView.titleLabel.hidden = false
        headView.searchButton.hidden = true
        headView.titleLabel.text = "赠送福利"
        
        var welfareInfoDic = NSUserDefaults.standardUserDefaults().objectForKey("welfareInfoDic") as! [String:String]?

        println(welfareInfoDic)
        if let newWelfareInfoDic = welfareInfoDic {
            nameTextField.text = welfareInfoDic!["userName"]
            phoneNumberTextField.text = welfareInfoDic!["phone"]
            addressTextField.text = welfareInfoDic!["address"]
            mailTextField.text = welfareInfoDic!["postcode"]
        }
        
        

        //键盘收起，和出来
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    @IBAction func submitBuyBookOwnerInfo(sender: AnyObject) {
        self.sendBookInfo()
    }

    
    
    //键盘出来
    func keyboardWillShow(){
        if keyboardShowstate ==  true {
                return
        }
        println(UIScreen.mainScreen().bounds.width)
        println(UIScreen.mainScreen().bounds.height)
        if UIScreen.mainScreen().bounds.height == 568 {//5S
            UIView.animateWithDuration(
                0.3,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.view.frame = CGRectMake(self.view.frame.origin.x, -50, self.view.frame.size.width, self.view.frame.size.height)
                }) { (Bool) -> Void in
                    
            }
            keyboardShowstate = true
        }
//        else if UIScreen.mainScreen().bounds.height == 736 {
//            UIView.animateWithDuration(
//                0.3,
//                delay: 0,
//                options: UIViewAnimationOptions.CurveEaseInOut,
//                animations: { () -> Void in
//                    self.view.frame = CGRectMake(self.view.frame.origin.x, -245, self.view.frame.size.width, self.view.frame.size.height)
//                }, completion: { (Bool) -> Void in
//
//            })
//            keyboardShowstate = true
//        }else{
//            UIView.animateWithDuration(
//                0.3,
//                delay: 0,
//                options: UIViewAnimationOptions.CurveEaseInOut,
//                animations: { () -> Void in
//                    self.view.frame = CGRectMake(self.view.frame.origin.x, -220, self.view.frame.size.width, self.view.frame.size.height)
//                }, completion: { (Bool) -> Void in
//                    
//            })
//            keyboardShowstate = true
//        }

        
        
        
    }
    //键盘隐藏
    func keyboardWillHide(){
            UIView.animateWithDuration(
                0.3,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height)
                }) { (Bool) -> Void in
                    
            }
            keyboardShowstate = false
        
    }
    
    //提交兑换书人的信息
    func sendBookInfo(){
        println(param)
        var bookId = param?.objectForKey("_id") as! String
        HttpManager.sendHttpRequestPost(SEND_GIFT_INFO, parameters:
            ["userId": ApplicationContext.getUserID()!,
                "id": bookId,
                "userName": nameTextField.text,
                "phone": phoneNumberTextField.text,
                "address": addressTextField.text,
                "postcode": mailTextField.text
                
            ],
            success: { (json) -> Void in
                
                FLOG("提交兑换书人的信息json:\(json)")
                var welfareInfoDic : [String:String] = [
                    "userName": self.nameTextField.text,
                    "phone": self.phoneNumberTextField.text,
                    "address": self.addressTextField.text,
                    "postcode": self.mailTextField.text
                ]
                println("welfareInfoDic::::\(welfareInfoDic)")
                NSUserDefaults.standardUserDefaults().setObject(welfareInfoDic, forKey: "welfareInfoDic")
                NSUserDefaults.standardUserDefaults().synchronize()
                UIAlertView(title: "提示", message: "提交成功", delegate: self, cancelButtonTitle: "好").show()
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }

    //关闭键盘
    @IBAction func closeKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
        //         [self.view endEditing:YES];
    }
    
    
    
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex==0){
            NSLog("取消::::\(self.navigationController?.viewControllers)")
            
            var index  = (self.navigationController?.viewControllers.count)! - 3
            
            var tempController = self.navigationController?.viewControllers[index] as! WelfareViewController
            self.navigationController?.popToViewController(tempController, animated: true)

        }
        
        
        
//        println("alertView.tag::::\(alertView.tag)")
//        if alertView.tag == 101 {
//            if(buttonIndex==0){
//                NSLog("取消")
//            }else{
//                self.releaseBind(1)
//            }
//        }else{
//            if(buttonIndex==0){
//                NSLog("取消")
//            }else{
//                self.releaseBind(2)
//            }
//        }
        
    }

    
    
    

}
