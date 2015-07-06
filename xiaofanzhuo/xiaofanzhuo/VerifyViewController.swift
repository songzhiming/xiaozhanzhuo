//
//  VerifyViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/16.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class VerifyViewController: BasicViewController {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var commitState: UILabel!
    @IBOutlet weak var reCommitBtn: UIButton!
    @IBOutlet weak var midView: UIView!
    @IBOutlet weak var reasonText: UITextView!
    
    var timer : NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headView.hidden = true
        //设置头像圆角
        avatar.sd_setImageWithURL(NSURL(string:ApplicationContext.getUserInfo()!["avatar"] as! String), placeholderImage: UIImage(named:"avatarDefaultImage"))

        
        //设置个人信息背景的阴影
        midView.layer.borderWidth = 1.5
        midView.layer.borderColor = CGColorCreateCopyWithAlpha(UIColor.lightGrayColor().CGColor, 0.3)
        
        //从服务器获取数据，判断审核状态改变commitState,reCommitBtn是否隐藏
        if (ApplicationContext.getUserInfo()!["userState"] as! String).toInt() == 4{//如果审核没通过
            commitState.text = "您提交的信息正在审核中..."
            reasonText.text = ApplicationContext.getUserInfo()!["userStateInfo"] as? String
            reasonText.contentOffset = CGPointZero
        }else  {//审核中 userState = 2
            reCommitBtn.enabled = false
            timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "timeFire", userInfo: nil,     repeats: true) //定义了NSTimer对象
            timer.fire()  //启动计时
        }
        

        
    }
    //定时器方法，获取用户信息
    func timeFire() {
//        timer?.invalidate() //停止计时
        
        
        println(ApplicationContext.getUserInfo())
        if ApplicationContext.getUserInfo() == nil {
            timer?.invalidate() //停止计时
            return
        }
        HttpManager.sendHttpRequestPost(GET_USER_STATE, parameters:
            ["userId": ApplicationContext.getUserID()!
            ],
            success: { (json) -> Void in
                //服务器数据返回成功,添加用户状态
                FLOG("检查userstate登录返回json:\(json)")
                var userInfo = ApplicationContext.getUserInfo()
                if let newUserInfo = userInfo {
                    userInfo!["userState"] = json["userState"]
                    if let stateInfo = json["userStateInfo"] as? String{
                        userInfo!["userStateInfo"] = stateInfo
                    }
                    ApplicationContext.saveUserInfo(userInfo!)
                    
                    //获取最新的个人信息，判断用户是否已经通过审核，或者是否已经被冻结或者删除
                    HttpManager.postDatatoServer(.POST, BASE_URL + GETUSERINFO ,parameters:
                        ["userId": ApplicationContext.getUserID()!,
                            "id": ApplicationContext.getUserID()!
                        ])
                        .responseJSON { (_, _, JSON, _) in
                            if let json = JSON as? [String:AnyObject] {
                                FLOG("更新个人信息返回json:\(json)")
                                if (json["code"] as! Int) == 0 {//未填写个人信息，或者填写个人信息通过了审核
                                    var userInfo = [String:AnyObject]()//ApplicationContext.getUserInfo()!
                                    if let info = ApplicationContext.getUserInfo(){
                                        userInfo = info
                                    }else{
                                        return
                                    }
                                    if let personInfo = json["userInfo"] as? [String:AnyObject] {
                                        userInfo["personInfo"] = personInfo
                                    }
                                    if let binding = json["binding"] as? [String:AnyObject] {
                                        userInfo["binding"] = binding
                                    }
                                    ApplicationContext.saveUserInfo(userInfo)
                                    
                                    /**********页面跳转逻辑***********/
                                    //服务器返回信息，如果已经登陆，判断是否已经审核，若审核通过，主页，否则跳转等待审核
                                    var userState = (ApplicationContext.getUserInfo()!["userState"] as! String).toInt()
                                    var rootViewController : UIViewController!
                                    if userState == 3 {//已提交个人信息，审核通过，跳转主页
                                        self.timer.invalidate()
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
                                    }else if userState == 4{
                                        if (self.timer != nil) {
                                            self.timer.invalidate()
                                        }
                                        self.reCommitBtn.enabled = true
                                        self.commitState.text = "您提交的信息正在审核中..."
                                        self.reasonText.text = ApplicationContext.getUserInfo()!["userStateInfo"] as? String
                                        self.reasonText.contentOffset = CGPointZero
                                    }
                                }else{//用户被冻结，未审核通过，或者已经被删除
                                    //code !=0
                                    if (self.timer != nil) {
                                        self.timer.invalidate()
                                    }
                                    var message  = json["message"] as! String
                                    HYBProgressHUD.showError(message)
                                    
                                    var userState = (ApplicationContext.getUserInfo()!["userState"] as! String).toInt()
                                    var rootViewController : UIViewController!
                                    
                                    rootViewController = LoginViewControllerNew(nibName: "LoginViewControllerNew", bundle: nil)
                                    
                                    self.navigationController?.viewControllers[0] = rootViewController
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userInfo")
                                    FLOG(json["message"])
                                }
                            }else{
                                HYBProgressHUD.showError("网络连接错误！")
                                FLOG("网络连接错误！")
                            }
                    }//HTTPManager
                }
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }


    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatar.layer.cornerRadius = avatar.bounds.width / 2
        avatar.layer.masksToBounds = true
        reasonText.contentOffset = CGPointZero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: -按钮点击
extension VerifyViewController {
    @IBAction func logoutBtnClick(sender: AnyObject) {
        //1.注销当前登陆跳转登陆页
        if (timer != nil) {
            timer.invalidate()
        }
        var loginViewController = LoginViewControllerNew(nibName: "LoginViewControllerNew", bundle: nil)
        var navigation = UINavigationController(rootViewController: loginViewController);
        navigation.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
        //NSuserDefault remove掉rootViewController字段
        
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userInfo")
    }
    @IBAction func reCommitBtnClick(sender: AnyObject) {
        //跳转个人信息填写页面
        var info = ApplicationContext.getMyUserInfo()!
        println("sdfefefefefef->>>>>>>>\(info)")
        var num = info["phone"] as! String
        var param : [String:AnyObject] = ["phoneNum":num,"userId":ApplicationContext.getUserID()!]
        FLOG("param:\(param)")
        var personInfoViewController  = PersonInfoViewController(nibName: "PersonInfoViewController", bundle: nil,param:param)
        var navigation = UINavigationController(rootViewController: personInfoViewController);
        navigation.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
    }
}