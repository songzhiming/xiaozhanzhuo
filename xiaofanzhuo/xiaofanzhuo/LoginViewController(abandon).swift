//
//  LoginViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: -按钮点击
extension LoginViewController {
    
    @IBAction func loginSina(sender: AnyObject) {
        
//        var updatePersonalInfoViewController : UpdatePersonalInfoViewController = UpdatePersonalInfoViewController(nibName: "UpdatePersonalInfoViewController", bundle: nil)
//        self.navigationController?.pushViewController(updatePersonalInfoViewController, animated: true)
//        var defaults = NSUserDefaults.standardUserDefaults()
//        defaults.setBool(true, forKey: "hasLogin")
//        return
        
        var snsPlatform : UMSocialSnsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToSina)
        
        snsPlatform.loginClickHandler(self,UMSocialControllerService.defaultControllerService(),true){
            (response : UMSocialResponseEntity! ) -> Void in
            
            //登录授权成功
            if response.responseCode.value == UMSResponseCodeSuccess.value {
                
//以下信息为新浪返回信息，到此处已经登陆授权成功

                //response的返回信息
                var snsAccount = UMSocialAccountManager.socialAccountDictionary()[UMShareToSina] as! UMSocialAccountEntity
//                println(snsAccount)

                //登录用户的用户信息
                UMSocialDataService.defaultDataService().requestSnsInformation(UMShareToSina, completion: { (response : UMSocialResponseEntity!) -> Void in
                    
                    //第一次保存userInfo
                    var userInfo = [String:AnyObject]()
                    //获取新浪头像
                    userInfo["avatar"] = response.data["profile_image_url"]
                    println(response.data)
                    //第一次登录该账号为注册，第二次为登录获取信息
                    var pushId : String
                    if let id = (NSUserDefaults.standardUserDefaults().objectForKey("pushId") as? String) {
                        pushId = NSUserDefaults.standardUserDefaults().objectForKey("pushId") as! String
                    }else {
                        pushId = ""
                    }
                    var name = response.data["screen_name"] as! String
                    println("name\(name)")
                     HttpManager.postDatatoServer(.POST, BASE_URL + LOGIN ,parameters:
                        ["uid": response.data["uid"]!,
                            "type":"sina",
                            "name":response.data["screen_name"]!,
                            "pushId":pushId
                        ])
                        .responseJSON { (_, _, JSON, _) in
                            println("新浪微博返回json::\(JSON)")
                            if let json = JSON as? [String:AnyObject] {
                                println(json)
                                if (json["code"] as! Int) == 0 {
                                    //服务器数据返回成功,添加用户状态
                                    userInfo["userState"] = json["userState"]
                                    userInfo["userId"] = json["userId"]
                                    userInfo["type"] = "sina"
                                    
                                    if let stateInfo = json["userStateInfo"] as? String{
                                        userInfo["userStateInfo"] = stateInfo
                                    }
                                    
                                    //处理登陆授权成功页面跳转,根据服务器返回的userState，跳转 首页 还是 审核页 还是 信息填写页
                                    var userState = (userInfo["userState"] as! String).toInt()//(ApplicationContext.getUserInfo()!["userState"] as String).toInt()
                                    var nextViewController : UIViewController!
                                    
                                    if userState == 1{//没提交写个人信息
                                         nextViewController = UpdatePersonalInfoViewController(nibName: "UpdatePersonalInfoViewController", bundle: nil)
                                    }else if userState == 2 || userState == 4{//已提交个人信息，未通过审核或审核中
                                         nextViewController = VerifyViewController(nibName: "VerifyViewController", bundle: nil)
                                    }else{//已提交个人信息，审核通过，跳转主页
                                         nextViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
                                         userInfo["personInfo"] = json["userInfo"] //as NSDictionary   //[String : AnyObject]
                                         userInfo["binding"] = json["binding"]
                                    }
                                    //保存登陆信息
                                    println("userinfo\(userInfo)")
                                    ApplicationContext.saveUserInfo(userInfo)
                                    self.navigationController?.pushViewController(nextViewController, animated: true)
                                    
                                    println("登录返回json:\(json)")
                                }else{
                                    //code !=0
                                    var message  = json["message"] as! String
                                    HYBProgressHUD.showError(message)
                                    println("服务器返回数据错误,code!=0")
                                }
                            }else{
                                HYBProgressHUD.showError("网络连接错误！")
                                println("网络连接错误！")
                            }
                    }
                    //println(response.data)
                })
                println("新浪微博认证成功")
            }
        }
    }
    
    @IBAction func loginWechat(sender: AnyObject) {
        //暂时屏蔽微信登陆
        
        var snsPlatform : UMSocialSnsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToWechatSession)
        
        snsPlatform.loginClickHandler(self,UMSocialControllerService.defaultControllerService(),true){
            (response : UMSocialResponseEntity! ) -> Void in
            
            //登录授权成功
            if response.responseCode.value == UMSResponseCodeSuccess.value {
//1.处理登陆授权成功页面跳转
                println("response\(response)")
                var snsAccount = UMSocialAccountManager.socialAccountDictionary()[UMShareToWechatSession] as! UMSocialAccountEntity
                                //登录用户的用户信息
                println(snsAccount.iconURL)
                UMSocialDataService.defaultDataService().requestSnsInformation(UMShareToWechatSession, completion: { (response : UMSocialResponseEntity!) -> Void in
                                    println(response.data)
                    var userInfo = [String:AnyObject]()
                    //获取新浪头像
                    userInfo["avatar"] = snsAccount.iconURL
                    println(response.data)
                    //第一次登录该账号为注册，第二次为登录获取信息
                    var pushId : String
                    if let id = (NSUserDefaults.standardUserDefaults().objectForKey("pushId") as? String) {
                        pushId = NSUserDefaults.standardUserDefaults().objectForKey("pushId") as! String
                    }else {
                        pushId = ""
                    }
                    var name = response.data["screen_name"] as! String
                    println("name\(name)")
                    
                    
                    
                    println("uid:::::\(snsAccount.usid)")
                    println("name::::\(snsAccount.userName)")
                    HttpManager.postDatatoServer(.POST, BASE_URL + LOGIN ,parameters:
                        ["uid": snsAccount.usid,
                            "type":"weixin",
                            "name":snsAccount.userName,
                            "pushId":pushId
                        ])
                        .responseJSON { (_, _, JSON, _) in
                            println("微信登陆返回数据::::\(JSON)")
                            if let json = JSON as? [String:AnyObject] {
                                println("微信登陆返回数据::::\(JSON)")
                                if (json["code"] as! Int) == 0 {
                                    //服务器数据返回成功,添加用户状态
                                    userInfo["userState"] = json["userState"]
                                    userInfo["userId"] = json["userId"]
                                    userInfo["type"] = "weixin"
                                    
                                    if let stateInfo = json["userStateInfo"] as? String{
                                        userInfo["userStateInfo"] = stateInfo
                                    }
                                    
                                    //处理登陆授权成功页面跳转,根据服务器返回的userState，跳转 首页 还是 审核页 还是 信息填写页
                                    var userState = (userInfo["userState"] as! String).toInt()//(ApplicationContext.getUserInfo()!["userState"] as String).toInt()
                                    var nextViewController : UIViewController!
                                    
                                    if userState == 1{//没提交写个人信息
                                        nextViewController = UpdatePersonalInfoViewController(nibName: "UpdatePersonalInfoViewController", bundle: nil)
                                    }else if userState == 2 || userState == 4{//已提交个人信息，未通过审核或审核中
                                        nextViewController = VerifyViewController(nibName: "VerifyViewController", bundle: nil)
                                    }else{//已提交个人信息，审核通过，跳转主页
                                        nextViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
                                        userInfo["personInfo"] = json["userInfo"] //as NSDictionary   //[String : AnyObject]
                                        userInfo["binding"] = json["binding"]
                                    }
                                    //保存登陆信息
                                    println("userinfo\(userInfo)")
                                    ApplicationContext.saveUserInfo(userInfo)
                                    self.navigationController?.pushViewController(nextViewController, animated: true)
                                    
                                    println("登录返回json:\(json)")
                                }else{
                                    //code !=0
                                    var message  = json["message"] as! String
                                    HYBProgressHUD.showError(message)
                                    println("服务器返回数据错误,code!=0")
                                }
                            }else{
                                HYBProgressHUD.showError("网络连接错误！")
                                println("网络连接错误！")
                            }
                    }

                                })
                
                
                
                
//                var updatePersonalInfoViewController : UpdatePersonalInfoViewController = UpdatePersonalInfoViewController(nibName: "UpdatePersonalInfoViewController", bundle: nil)
//                self.navigationController?.pushViewController(updatePersonalInfoViewController, animated: true)
//2.保存登陆信息
//                var defaults = NSUserDefaults.standardUserDefaults()
//                defaults.setBool(true, forKey: "hasLogin")
                
//3.以下信息为新浪返回信息，到此处已经登陆授权成功
//                //response的返回信息
//                var snsAccount = UMSocialAccountManager.socialAccountDictionary()[UMShareToWechatSession] as UMSocialAccountEntity
//                //登录用户的用户信息
//                UMSocialDataService.defaultDataService().requestSnsInformation(UMShareToWechatSession, completion: { (response : UMSocialResponseEntity!) -> Void in
//                    println(response.data)
//                })
//                println("微信认证成功")
            }
        }
    }
}
