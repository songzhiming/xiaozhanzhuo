//
//  BindAccountViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-27.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class BindAccountViewController: BasicViewController,UIAlertViewDelegate{
    //sina
    @IBOutlet weak var sinaUsernameLabel: UILabel!
    @IBOutlet weak var sinaStateLabel: UILabel!
    
    @IBOutlet weak var sinaButton: UIButton!
    //weixin
    @IBOutlet weak var weixinUsernameLabel: UILabel!
    @IBOutlet weak var weixinStateLabel: UILabel!
    
    @IBOutlet weak var weixinButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.changeLeftButton()
        headView.logoImage.hidden = true
        headView.titleLabel.text = "账号绑定"
        headView.searchButton.hidden = true
        headView.generateCodeButton.hidden = true
        if let getBinding = ApplicationContext.getBinding() {
            var binding : [[String : AnyObject]] = getBinding
            println(binding)
            println(binding[0]["name"])
            if binding.count == 1 {
                if binding[0]["type"] as! String == "sina" {//绑定sina
                     sinaUsernameLabel.text = binding[0]["name"]! as? String
                     sinaStateLabel.text = "已绑定"
                     weixinStateLabel.text = "未绑定"
                     weixinUsernameLabel.text = ""
                     sinaButton.selected = false
                     weixinButton.selected = true
                    
                }else{//绑定weixin
                    sinaUsernameLabel.text = ""
                    weixinUsernameLabel.text = binding[0]["name"]! as? String
                    sinaStateLabel.text = "未绑定"
                    weixinStateLabel.text = "已绑定"
                    sinaButton.selected = true
                    weixinButton.selected = false
                }
            }else{//if binding.count
                if binding[0]["type"] as! String == "sina" {  //sina，weixin
                    sinaUsernameLabel.text = binding[0]["name"] as? String
                    sinaStateLabel.text = "已绑定"
                    weixinUsernameLabel.text = binding[1]["name"] as? String
                    weixinStateLabel.text = "已绑定"
                }else{//weixin ,sina
                    sinaUsernameLabel.text = binding[1]["name"] as? String
                    sinaStateLabel.text = "已绑定"
                    weixinUsernameLabel.text = binding[0]["name"] as? String
                    weixinStateLabel.text = "已绑定"
                }
            }
        }else{// if let
            weixinButton.selected = true
            sinaButton.selected = true  
            sinaStateLabel.text = "未绑定"
            weixinStateLabel.text = "未绑定"
            weixinUsernameLabel.text = ""
            sinaUsernameLabel.text = ""
        }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

    
    //点击sina
    @IBAction func onclickSinaButton(sender: AnyObject) {
        if sinaButton.selected == true {//添加sina绑定
            self.bindSina()
        }else{
            var binding : [[String : AnyObject]] = ApplicationContext.getBinding()!
            println(binding)
            if binding.count == 1 {
                var alertView = UIAlertView(title: "确定取消绑定", message: "由于你只绑定了sina账号，取消绑定将删除您的所有信息", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
                alertView.tag = 101
                alertView.show()
            }else{
                self.releaseBind(1)
            }
            
        }
        
    }
    
    
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        println("alertView.tag::::\(alertView.tag)")
        if alertView.tag == 101 {
            if(buttonIndex==0){
                NSLog("取消")
            }else{
                self.releaseBind(1)
            }
        }else{
            if(buttonIndex==0){
                NSLog("取消")
            }else{
                self.releaseBind(2)
            }
        }

    }
    
    

    
    //点击微信
    @IBAction func onclickWeixinButton(sender: AnyObject) {
        if weixinButton.selected == true {//添加微信绑定
            self.bindWeixin()
        }else{
            var binding : [[String : AnyObject]] = ApplicationContext.getBinding()!
            if binding.count == 1 {
                var alertView = UIAlertView(title: "确定取消绑定", message: "由于你只绑定了weixin账号，取消绑定将删除您的所有信息", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
                alertView.tag = 102
                alertView.show()
            }else{
                self.releaseBind(2)
            }
        }
    }
    
    
    
    //取消绑定
    func releaseBind(type : Int){
        if type == 1{//sina
            var binding : [[String : AnyObject]] = ApplicationContext.getBinding()!
            var uid : String
            uid = String()
            if binding[0]["type"] as! String == "sina" {
                uid = binding[0]["uid"]! as! String
            }else{
                uid = binding[1]["uid"]! as! String
            }
            
            HttpManager.postDatatoServer(.POST, BASE_URL + RELEASEBIND,parameters:
                ["userId": ApplicationContext.getUserID()!,
                    "type":"sina",
                    "uid":uid
                ])
                .responseJSON { (_, _, JSON, _) in
                    println("绑定返回数据\(JSON)")
                    if let json = JSON as? [String:AnyObject] {
                        //println("对对碰数据：\(JSON)")
                        if (json["code"] as! Int) == 0 {
                            //服务器数据返回成功
                            var binding : [[String : AnyObject]] = ApplicationContext.getBinding()!
                            if binding.count == 1 {
                                var loginViewController = LoginViewControllerNew(nibName: "LoginViewControllerNew", bundle: nil)
                                var navigation = UINavigationController(rootViewController: loginViewController);
                                navigation.setNavigationBarHidden(true, animated: false)
                                UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
                                //NSuserDefault remove掉rootViewController字段
                                NSUserDefaults.standardUserDefaults().removeObjectForKey("userInfo")
                            }else{
                                UIAlertView(title: "提示", message: "取消绑定成功", delegate: nil, cancelButtonTitle: "好的，知道了").show()
                                self.sinaButton.selected = true
                                self.sinaUsernameLabel.text = ""
                                self.sinaStateLabel.text = "未绑定"
                                self.getUserInfo()
                            }

                            println(json)
                        }else{
                            //code !=0
                            var message  = json["message"] as! String
                            HYBProgressHUD.showError(message)
                        }
                    }else{
                        HYBProgressHUD.showError("网络连接错误！")
                    }
            }

        }else{//weixin
            
            var binding : [[String : AnyObject]] = ApplicationContext.getBinding()!
            var uid : String
            uid = String()
            if binding[0]["type"] as! String == "sina" {
                uid = binding[1]["uid"]! as! String
            }else{
                uid = binding[0]["uid"]! as! String
            }
            HttpManager.postDatatoServer(.POST, BASE_URL + RELEASEBIND,parameters:
                ["userId": ApplicationContext.getUserID()!,
                    "type":"weixin",
                    "uid":uid
                ])
                .responseJSON { (_, _, JSON, _) in
                    println("绑定返回数据\(JSON)")
                    if let json = JSON as? [String:AnyObject] {
                        //println("对对碰数据：\(JSON)")
                        if (json["code"] as! Int) == 0 {
                            //服务器数据返回成功
                            var binding : [[String : AnyObject]] = ApplicationContext.getBinding()!
                            if binding.count == 1 {
                                var loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
                                var navigation = UINavigationController(rootViewController: loginViewController);
                                navigation.setNavigationBarHidden(true, animated: false)
                                UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
                                //NSuserDefault remove掉rootViewController字段
                                NSUserDefaults.standardUserDefaults().removeObjectForKey("userInfo")
                            }else{
                                UIAlertView(title: "提示", message: "取消绑定成功", delegate: nil, cancelButtonTitle: "好的，知道了").show()
                                self.weixinButton.selected = true
                                self.weixinUsernameLabel.text = ""
                                self.weixinStateLabel.text = "未绑定"
                                self.getUserInfo()
                            }
                            println(json)
                        }else{
                            //code !=0
                            var message  = json["message"] as! String
                            HYBProgressHUD.showError(message)
                        }
                    }else{
                        HYBProgressHUD.showError("网络连接错误！")
                    }
            }
            
        }
    }

    
    //sina绑定
    func bindSina(){
        var snsPlatform : UMSocialSnsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToSina)
        snsPlatform.loginClickHandler(self,UMSocialControllerService.defaultControllerService(),true){
            (response : UMSocialResponseEntity! ) -> Void in
            
            //登录授权成功
            if response.responseCode.value == UMSResponseCodeSuccess.value {
                var snsAccount = UMSocialAccountManager.socialAccountDictionary()[UMShareToSina] as! UMSocialAccountEntity
                HttpManager.postDatatoServer(.POST, BASE_URL + BINDACCOUNT,parameters:
                    ["userId": ApplicationContext.getUserID()!,
                        "type":"sina",
                        "uid":snsAccount.usid,
                        "name":snsAccount.userName
                    ])
                    .responseJSON { (_, _, JSON, _) in
                        println("绑定返回数据\(JSON)")
                        if let json = JSON as? [String:AnyObject] {
                            //println("对对碰数据：\(JSON)")
                            if (json["code"] as! Int) == 0 {
                                //服务器数据返回成功
                                UIAlertView(title: "提示", message: "绑定成功", delegate: nil, cancelButtonTitle: "好的，知道了").show()
                                self.sinaButton.selected = false
                                self.sinaUsernameLabel.text = snsAccount.userName
                                self.sinaStateLabel.text = "已绑定"
                                self.getUserInfo()
                                println(json)
                            }else{
                                //code !=0
                                var message  = json["message"] as! String
                                HYBProgressHUD.showError(message)
                            }
                        }else{
                            HYBProgressHUD.showError("网络连接错误！")
                        }
                }

            }
        }

    }
    
    
    
    //weixin绑定
    func bindWeixin(){
        var snsPlatform : UMSocialSnsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToWechatSession)
        
        snsPlatform.loginClickHandler(self,UMSocialControllerService.defaultControllerService(),true){
            (response : UMSocialResponseEntity! ) -> Void in
            
            //登录授权成功
            if response.responseCode.value == UMSResponseCodeSuccess.value {
                var snsAccount = UMSocialAccountManager.socialAccountDictionary()[UMShareToWechatSession] as! UMSocialAccountEntity
                println("weixinname======\(snsAccount.userName)")
                HttpManager.postDatatoServer(.POST, BASE_URL + BINDACCOUNT,parameters:
                    ["userId": ApplicationContext.getUserID()!,
                        "type":"weixin",
                        "uid":snsAccount.usid,
                        "name":snsAccount.userName
                    ])
                    .responseJSON { (_, _, JSON, _) in
                        println("绑定返回数据\(JSON)")
                        if let json = JSON as? [String:AnyObject] {
                            //println("对对碰数据：\(JSON)")
                            if (json["code"] as! Int) == 0 {
                                //服务器数据返回成功
                                UIAlertView(title: "提示", message: "绑定成功", delegate: nil, cancelButtonTitle: "好的，知道了").show()
                                self.weixinButton.selected = false
                                self.weixinUsernameLabel.text = snsAccount.userName
                                self.weixinStateLabel.text = "已绑定"
                                self.getUserInfo()
                                println(json)
                            }else{
                                //code !=0
                                var message  = json["message"] as! String
                                HYBProgressHUD.showError(message)
                            }
                        }else{
                            HYBProgressHUD.showError("网络连接错误！")
                        }
                }
                
            }
        }
        
    }

    
    
    func getUserInfo(){
        HttpManager.postDatatoServer(.POST, BASE_URL + GETUSERINFO,parameters:
            ["id": ApplicationContext.getUserID()!,
                "userId": ApplicationContext.getUserID()!
            ])
            .responseJSON { (_, _, JSON, _) in
                println("个人信息返回数据\(JSON)")
                if let json = JSON as? [String:AnyObject] {
                    if (json["code"] as! Int) == 0 {
                        var userInfo = ApplicationContext.getUserInfo()!
                        userInfo["binding"] = json["binding"]
                        ApplicationContext.saveUserInfo(userInfo)
                    }else{
                        var message  = json["message"] as! String
                        HYBProgressHUD.showError(message)
                        println("服务器返回数据错误,code!=0")
                    }
                }else{
                    HYBProgressHUD.showError("网络连接错误！")
                    println("网络连接错误！")
                }
        }

    }
    

}
