//
//  AppDelegate.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UIAlertViewDelegate {

    var window: UIWindow?
    var navigation : UINavigationController!
    var refreshInit = false
    var refreshView : RefreshView!
    var navDelegate : NavigationPopGestureDelagate!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
       //讯飞语音
//       var initString = "appid=54bf6f18"
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
       var initString = "appid=54d069c0"
       IFlySpeechUtility.createUtility(initString)

        //友盟配置信息
        UMSocialData.setAppKey("54d06833fd98c59e540009c8")
        UMSocialWechatHandler.setWXAppId("wx4cb2c074d58c96ba", appSecret: "96288e41a4743aa12d8e226981c61fcb", url: "http://www.xfz.cn/web/vpage/index.html")
        
        
        UMSocialConfig.setFinishToastIsHidden(true, position: UMSocialiToastPositionTop)
        //友盟统计
        MobClick.startWithAppkey("54d06833fd98c59e540009c8", reportPolicy: BATCH, channelId: "App Store")
        var version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        MobClick.setAppVersion(version)
        
        //百度推送
        BPush.setupChannel(launchOptions)
        BPush.setDelegate(self)
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil
                ))
        }else{
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "IsShownUserInfoCompleted")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "popToLogin:", name: "popToLogin", object: nil)
        
        /*********测试专用区域***
        var r = PersonInfoViewController(nibName: "PersonInfoViewController", bundle: nil)

        navigation = UINavigationController(rootViewController: r);
        navigation.setNavigationBarHidden(true, animated: false)
        self.window!.rootViewController = navigation
        self.window!.makeKeyAndVisible()
        return true
        ******/
 
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        var rootViewController = LoginViewControllerNew(nibName: "LoginViewControllerNew", bundle: nil)
        
        navigation = UINavigationController(rootViewController: rootViewController)
        
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.interactivePopGestureRecognizer.enabled = true
        
        //当把navigationBarHidden的时候，左侧滑动返回上一级就不能用，用这个来解决
        //参考地址：http://stackoverflow.com/questions/24710258/no-swipe-back-when-hiding-navigation-bar-in-uinavigationcontroller
        navDelegate = NavigationPopGestureDelagate()
        navigation.interactivePopGestureRecognizer.delegate = navDelegate

//        self.window!.rootViewController = navigation
//        self.window!.makeKeyAndVisible()
        refreshView = NSBundle.mainBundle().loadNibNamed("RefreshView", owner: self, options: nil)[0] as! RefreshView
        refreshView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        
        //如果是杀掉进程点击进来会走appdelegate
        var localNotif :[String:AnyObject]? = nil
        if let lo = launchOptions as? [String:AnyObject] {
            localNotif = lo[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String:AnyObject]
//            UIAlertView(title: "提示", message: "\(localNotif)", delegate: nil, cancelButtonTitle: "好的，知道了").show()
        }
        println("localNotif:\(localNotif)")
        checkState(localNotif)
        return true
    }

    
    
    //百度推送
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData){
        BPush.registerDeviceToken(deviceToken)
        BPush.bindChannel()
    }
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings){
        application.registerForRemoteNotifications()
    }
    
    func onMethod(method: String!, response data: [NSObject : AnyObject]!) {
        if BPushRequestMethod_Bind == method {
            var res : [String : AnyObject] = data as! [String : AnyObject]
            var pushId = ""
            if let id = BPush.getUserId() {
                pushId = id
            }
            FLOG("pushId:\(pushId)")
            NSUserDefaults.standardUserDefaults().setObject(pushId, forKey: "pushId")
            NSUserDefaults.standardUserDefaults().synchronize()

        }
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]){
        FLOG("userInfo=============\(userInfo)")
//        var resInfo : [String : AnyObject] = userInfo as [String : AnyObject]
//        var aps : [String : AnyObject] = resInfo["aps"] as [String : AnyObject]
//        var alert : String = aps["alert"] as String
//        UIAlertView(title: "提示", message: alert, delegate: self, cancelButtonTitle: "好的，知道了").show()
        BPush.handleNotification(userInfo)
    }
    
    //通知到来，应用内外都触发这里
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void){
        FLOG("userInfo=============\(userInfo)")
        FLOG(UIApplication.sharedApplication().applicationState)
        var resInfo : [String : AnyObject] = userInfo as! [String : AnyObject]
        
        //获取类型
        var t = -1
        var type = resInfo["t"] as? Int
        if let tuw = type {
            t = tuw
        }
        
        //获取类型对应id
        var theId = resInfo["id"] as? String
        var id = ""
        if theId != nil {
            id = theId!
        }
        
        var aps : [String : AnyObject] = resInfo["aps"] as! [String : AnyObject]
        var alert : String = aps["alert"] as! String
        
        //百度推送过来的是字符串，服务器推送过来的是整数
        if let bg = aps["badge"] as? String {//百度推送过来的badge什么也不做就返回
            return
        }
        var badge = aps["badge"] as! Int
        
        FLOG("aps====\(aps)")
        FLOG("alert=====\(alert)")
        
        //应用内
        if UIApplication.sharedApplication().applicationState == .Active {
            NSUserDefaults.standardUserDefaults().setObject(badge, forKey: "push_count")
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName("refresh_push_count", object: nil)
            HYBProgressHUD.showSuccess("\(alert)")
            return
        }
        
        var loginViewController = LoginViewControllerNew(nibName: "LoginViewControllerNew", bundle: nil)
        self.navigation = UINavigationController(rootViewController: loginViewController);
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.interactivePopGestureRecognizer.enabled = true
        
        //当把navigationBarHidden的时候，左侧滑动返回上一级就不能用，用这个来解决
        //参考地址：http://stackoverflow.com/questions/24710258/no-swipe-back-when-hiding-navigation-bar-in-uinavigationcontroller
        navDelegate = NavigationPopGestureDelagate()
        navigation.interactivePopGestureRecognizer.delegate = navDelegate
        
        if !ApplicationContext.hasLogin(){ //如果没有登录
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            return
        }
        
        //应用外 UIApplication.sharedApplication().applicationState == .Background
        if t == 1 {//审核通过
            HttpManager.postDatatoServer(.POST, BASE_URL + GETUSERINFO ,parameters:
                ["userId": ApplicationContext.getUserID()!,
                    "id": ApplicationContext.getUserID()!
                ])
                .responseJSON { (_, _, JSON, _) in
                    if let json = JSON as? [String:AnyObject] {
                        FLOG("更新个人信息返回json:\(json)")
                        if (json["code"] as! Int) == 0 {//未填写个人信息，或者填写个人信息通过了审核
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
                            self.navigation.pushViewController(homeViewController, animated: false)
                            UIApplication.sharedApplication().keyWindow?.rootViewController = self.navigation
//                            var navigation = UINavigationController(rootViewController: homeViewController);
//                            navigation.setNavigationBarHidden(true, animated: false)

                        }
                    }
            }
        }else if t == 3{//自己发起的话题下有新的发言【您的话题“XXX（话题内容前10个字加省略号）”有新的发言】 点击跳转话题页
            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
                navigation.pushViewController(homeViewController, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            var topicDetailViewController = TopicDetailViewController(nibName: "TopicDetailViewController", bundle: nil,param: id)
            navigation.pushViewController(topicDetailViewController, animated: true)
        }else if t == 4{//自己的发言有新的评论【您的发言“XXX（发言内容前10个字加省略号）”有新评论】点击跳转发言页
            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
            navigation.pushViewController(homeViewController, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            var personCommentViewController = PersonCommentViewController(nibName: "PersonCommentViewController", bundle: nil,param:id)
            navigation.pushViewController(personCommentViewController, animated: true)
        }else if t == 5{//社区中其他人发言中，自己的评论被“回复”【您有新的评论】点击跳转发言页
            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
            navigation.pushViewController(homeViewController, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            var personCommentViewController = PersonCommentViewController(nibName: "PersonCommentViewController", bundle: nil,param:id)
            navigation.pushViewController(personCommentViewController, animated: true)
        }else if t == 6{//自己发起的任务有新人参加【您的组队“XXXX（组队内容前10个字加省略号）”有新的伙伴加入】点击跳转
            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
            navigation.pushViewController(homeViewController, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            var data = ["_id":id]
            var detailMakeUpTouchViewController = DetailMakeUpTouchViewController(nibName: "DetailMakeUpTouchViewController", bundle: nil, param: data)
            navigation.pushViewController(detailMakeUpTouchViewController, animated: true)
        }else if t == 9 || t == 10 {//冻结用户,删除用户
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userInfo")
            NSUserDefaults.standardUserDefaults().synchronize()
//                NSUserDefaults.standardUserDefaults().removeObjectForKey("userInfo")
//            var loginViewController = LoginViewControllerNew(nibName: "LoginViewControllerNew", bundle: nil)
//            navigation.pushViewController(loginViewController, animated: false)
//            var navigation = UINavigationController(rootViewController: loginViewController);
//            navigation.setNavigationBarHidden(true, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            //NSuserDefault remove掉rootViewController字段
        }else if t == 11{//赞发言
            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
            navigation.pushViewController(homeViewController, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            var personCommentViewController = PersonCommentViewController(nibName: "PersonCommentViewController", bundle: nil,param:id)
            navigation.pushViewController(personCommentViewController, animated: true)
        }else if t == 12{//活动回复被评论
            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
            navigation.pushViewController(homeViewController, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            var vc = ActivityCommentViewController(nibName: "BaseCommentViewController", bundle: nil,param: id)
            navigation.pushViewController(vc, animated: true)
        }else if t == 13{//文章回复被评论
            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
            navigation.pushViewController(homeViewController, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            var vc = ArticleCommentViewController(nibName: "BaseCommentViewController", bundle: nil,param: id)
            navigation.pushViewController(vc, animated: true)
        }else if t == 14{//组队被回复
            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
            navigation.pushViewController(homeViewController, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            var data = ["_id":id]
            var detailMakeUpTouchViewController = DetailMakeUpTouchViewController(nibName: "DetailMakeUpTouchViewController", bundle: nil, param: data)
            navigation.pushViewController(detailMakeUpTouchViewController, animated: true)
        }else if t == 15{//组队回复被评论
            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
            navigation.pushViewController(homeViewController, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            var data = ["_id":id]
            var detailMakeUpTouchViewController = DetailMakeUpTouchViewController(nibName: "DetailMakeUpTouchViewController", bundle: nil, param: data)
            navigation.pushViewController(detailMakeUpTouchViewController, animated: true)
        }else if t == 16{//被邀请回复话题
            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
            navigation.pushViewController(homeViewController, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            var topicDetailViewController = TopicDetailViewController(nibName: "TopicDetailViewController", bundle: nil,param: id)
        }else if t == 17{//在发言中被@
            var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
            navigation.pushViewController(homeViewController, animated: false)
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
            var personCommentViewController = PersonCommentViewController(nibName: "PersonCommentViewController", bundle: nil,param:id)
        }

    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        //这里只有home键按下在回来的时候进入
        //这里需要刷一次的原因，不杀掉进程，按Home键，程序进入后台，来推送，不进入回调，没法更新应用内角标，在进入前台的时候刷一次

        if ApplicationContext.hasLogin() {
            if  let id = ApplicationContext.getUserID() {
                HttpManager.sendHttpRequestPost(GET_PUSH_COUNT, parameters: ["userId":id],
                    success: { (json) -> Void in
                        
                        FLOG("获取未读消息json:\(json)")
                        var pushCount = json["count"] as! Int
                        
                        //第四页添加角标
                        
                        
                        //本地存储一份，让“我的”->“消息”添加角标
                        NSUserDefaults.standardUserDefaults().setObject(pushCount, forKey: "push_count")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        NSNotificationCenter.defaultCenter().postNotificationName("refresh_push_count", object: nil)
                        
                    },
                    failure:{ (reason) -> Void in
                        FLOG("失败原因:\(reason)")
                })
            }
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        //无论是杀掉进程还是按下home键再重新进入程序，程序必经这个函数
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //URL跳转，通过友盟
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return UMSocialSnsService.handleOpenURL(url)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return UMSocialSnsService.handleOpenURL(url)
    }
    
    //检测用户状态
    func checkState(localNotif:[String:AnyObject]?){
        if ApplicationContext.hasLogin() && localNotif == nil{
            //以后加上：如果已经登录过：1.去服务器更新获取userState,在回调闭包中作以下页面跳转，可能在applicationWillEnterForeground中做，如果已经通过审核，就不错跳转逻辑（if 判断 userState == 3 ?）
            //服务器取一次信息，判断是userstate
            
//            HttpManager.sendHttpRequestPost(GETUSERINFO, parameters: ["userId": ApplicationContext.getUserID()!
//                ],
//                success: { (json) -> Void in
//                    
//                    FLOG("鸡汤json:\(json)")
//                },
//                failure:{ (reason) -> Void in
//                    FLOG("失败原因:\(reason)")
//            })
            
            
            HttpManager.postDatatoServer(.POST, BASE_URL + GET_USER_STATE ,parameters:
                ["userId": ApplicationContext.getUserID()!
                ])
                .responseJSON { (_, _, JSON, _) in
                    if let json = JSON as? [String:AnyObject] {
                        FLOG("检查userstate登录返回json:\(json)")
                        if (json["code"] as! Int) == 0 {
                            //服务器数据返回成功,添加用户状态
                            var userInfo = ApplicationContext.getUserInfo()!
                            userInfo["userState"] = json["userState"]
                            if let stateInfo = json["userStateInfo"] as? String{
                                userInfo["userStateInfo"] = stateInfo
                            }
                            ApplicationContext.saveUserInfo(userInfo)
                            
                            //获取最新的个人信息，判断用户是否已经通过审核，或者是否已经被冻结或者删除
                            HttpManager.postDatatoServer(.POST, BASE_URL + GETUSERINFO ,parameters:
                                ["userId": ApplicationContext.getUserID()!,
                                    "id": ApplicationContext.getUserID()!
                                ])
                                .responseJSON { (_, _, JSON, _) in
                                    if let json = JSON as? [String:AnyObject] {
                                        FLOG("更新个人信息返回json:\(json)")
                                        self.refreshView.removeFromSuperview()
                                        if (json["code"] as! Int) == 0 {//未填写个人信息，或者填写个人信息通过了审核
                                            var userInfo = ApplicationContext.getUserInfo()!
                                            
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
                                            if userState == 1{//没提交写个人信息
                                                var personInfo = ApplicationContext.getMyUserInfo()!
                                                var id = ApplicationContext.getUserID()!
                                                var num = personInfo["phone"] as! String
                                                rootViewController = PersonInfoViewController(nibName: "PersonInfoViewController", bundle: nil,param:["phoneNum":num,"userId":id])
                                            }else if userState == 3 {//已提交个人信息，审核通过，跳转主页
                                                
                                                rootViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
                                            }else{
                                                rootViewController = VerifyViewController(nibName: "VerifyViewController", bundle: nil)
                                            }
                                            self.navigation.pushViewController(rootViewController, animated: false)
                                            self.window!.rootViewController = self.navigation
                                            self.window!.makeKeyAndVisible()
                                        }else{//用户被冻结，未审核通过，或者已经被删除
                                            //code !=0
                                            var message  = json["message"] as! String
                                            HYBProgressHUD.showError(message)
                                            
                                            var userState = (ApplicationContext.getUserInfo()!["userState"] as! String).toInt()
                                            var rootViewController : UIViewController!
                                            if userState == 2 {//已提交个人信息，未通过审核或审核中
                                                rootViewController = VerifyViewController(nibName: "VerifyViewController", bundle: nil)
                                            }else{
                                                //到登陆页面
                                                rootViewController = LoginViewControllerNew(nibName: "LoginViewControllerNew", bundle: nil)
                                            }
                                            self.navigation.pushViewController(rootViewController, animated: false)
                                            self.window!.rootViewController = self.navigation
                                            self.window!.makeKeyAndVisible()
                                            FLOG(json["message"])
                                        }
                                    }else{
                                        
                                        if !self.refreshInit {
                                        
                                            self.window!.addSubview(self.refreshView)
                                            self.refreshView.listenRefreshBtnClick({ () -> () in
                                           self.refreshView.refreshBtn.enabled = false
                                                self.checkState(localNotif)
                                            })
                                            self.refreshInit = true
                                        }
                                        self.refreshView.refreshBtn.enabled = true
                                        HYBProgressHUD.showError("网络连接错误！")
                                        FLOG("网络连接错误！")
                                    }
                            }//HTTPManager
                            
                            
                        }else{
                            //code !=0
                            var message  = json["message"] as! String
                            var rootViewController = LoginViewControllerNew(nibName: "LoginViewControllerNew", bundle: nil)
                        
                            self.navigation.pushViewController(rootViewController, animated: false)
                            self.window!.rootViewController = self.navigation
                            self.window!.makeKeyAndVisible()
                                HYBProgressHUD.showError(message)
                            FLOG("服务器返回数据错误,code!=0")
                        }
                    }else{
                        
                        if !self.refreshInit {
                            
                            self.window!.addSubview(self.refreshView)
                            self.refreshView.listenRefreshBtnClick({ () -> () in
                                self.refreshView.refreshBtn.enabled = false
                                self.checkState(localNotif)
                            })
                            self.refreshInit = true
                        }
                        self.refreshView.refreshBtn.enabled = true
                        HYBProgressHUD.showError("网络连接错误！")
                        FLOG("网络连接错误！")
                }
            }//
            
        }else{//if hasLogin
            self.window!.rootViewController = self.navigation
            self.window!.makeKeyAndVisible()
        }
    }
    
    func popToLogin(notification:NSNotification){
//        var loginViewController = LoginViewControllerNew(nibName: "LoginViewControllerNew", bundle: nil)
//        var navigation = self.window?.rootViewController as? UINavigationController
//        navigation?.viewControllers.insert(loginViewController, atIndex: 0)
//        navigation?.popToRootViewControllerAnimated(true)
//        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userInfo")
//        NSUserDefaults.standardUserDefaults().synchronize()
//        UIAlertView(title: "提示", message: notification.object as! String!, delegate: nil, cancelButtonTitle: "好的，知道了").show()
        
        var loginViewController = LoginViewControllerNew(nibName: "LoginViewControllerNew", bundle: nil)
        navigation = UINavigationController(rootViewController: loginViewController);
        navigation.setNavigationBarHidden(true, animated: false)
        navDelegate = NavigationPopGestureDelagate()
        navigation.interactivePopGestureRecognizer.delegate = navDelegate
        UIApplication.sharedApplication().keyWindow?.rootViewController = navigation
//        self.navigation.popToRootViewControllerAnimated(true)
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userInfo")
        NSUserDefaults.standardUserDefaults().synchronize()
        PersistentManager.cleanAll()
        UIAlertView(title: "提示", message: notification.object as! String!, delegate: nil, cancelButtonTitle: "好的，知道了").show()
    }
}

