//
//  HomeViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class HomeViewController: BasicViewController,UIAlertViewDelegate{
    
    var childArray : [UIViewController]!
    var curIndex : Int!
    let TAG_START : Int = 1000
    var animateEnd : Bool  = true
    var btnGroup : [UIButton]!
    
    @IBOutlet weak var addArticleButton: UIButton!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var tooBarHeight: NSLayoutConstraint!
    var articleItem1: UIBarButtonItem!
    var articleItem2: UIBarButtonItem!
    var articleItem3: UIBarButtonItem!
    var articleItem4: UIBarButtonItem!
    var flexSpace : UIBarButtonItem!
    
    //底部菜单栏的item的宽高
    let BUTTON_WIDTH :CGFloat = UIScreen.mainScreen().bounds.width / 4//80
    let BUTTON_HEIGHT : CGFloat = (50/320)*UIScreen.mainScreen().bounds.width//50
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = UIColor.yellowColor()
        headView.recommendButton.titleLabel?.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 14)
        childArray = [UIViewController]()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addRecommendAlertView", name: "addRecommendAlertView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoRecommendMembersViewController", name: "goto.RecommendMembersViewController", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoRecommendProjectViewController", name: "goto.RecommendProjectViewController", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoSearchView", name: "goto.SearchView", object: nil)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)

        setUpToolBarButtons()
        getNotificationCount()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoSystemNotificationViewController", name: "goto.SystemNotificationViewController", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPushCount", name: "refresh_push_count", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //初始化subviews
        initSubViews()
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        tooBarHeight.constant = BUTTON_HEIGHT
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initSubViews(){
        if(childArray?.count == 0){
            initChildViewControllers()
        }
    }
    
    
    func initChildViewControllers(){
        
        curIndex = 0
        
        //默认第一个菜单选中
        (self.view.viewWithTag(curIndex + TAG_START) as? UIButton)?.selected = true
        headView.searchButton.hidden = false
//        addArticleButton.hidden = false
        headView.logoImage.hidden = false

        self.view.bringSubviewToFront(addArticleButton)
        
        //第一页 社区
        var communityViewController : CommunityViewController = CommunityViewController(nibName: "CommunityViewController", bundle: nil)
        self.addChildViewController(communityViewController)
        self.view.insertSubview(communityViewController.view, atIndex: 0)
        childArray.append(communityViewController)
        addConstraintsToParent(firstItem: communityViewController.view)
        
        //第二页 文章
//        var articleViewController : ArticleViewController = ArticleViewController(nibName: "ArticleViewController", bundle: nil)
//        childArray.append(articleViewController)
        
        var articleViewController : RefactorArticleViewController = RefactorArticleViewController(nibName: "RefactorArticleViewController", bundle: nil)
        childArray.append(articleViewController)
        
        //第三页 对对碰
        var makeUpTouchViewController : MakeUpTouchViewController = MakeUpTouchViewController(nibName: "MakeUpTouchViewController", bundle: nil)
        childArray.append(makeUpTouchViewController)
        
        //第四页 个人中心
        var personalCenterViewController : PersonalCenterViewController = PersonalCenterViewController(nibName: "PersonalCenterViewController", bundle: nil)
        childArray.append(personalCenterViewController)

        
    }
    
    
    //添加约束
    func addConstraintsToParent(#firstItem : UIView!){
        firstItem.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        firstItem.addConstraint(NSLayoutConstraint(
            item:firstItem,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: UIScreen.mainScreen().bounds.width )
        )
        self.view.addConstraint(NSLayoutConstraint(
            item:firstItem,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1.0,
            constant: 0)
        )

        self.view.addConstraint(NSLayoutConstraint(
            item:firstItem,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 65.0)
        )
        self.view.addConstraint(NSLayoutConstraint(
            item:firstItem,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0,
            constant:-0)
        )
    }

    func setUpToolBarButtons(){
        
        btnGroup = [UIButton]()
        
        var btn1 = UIButton(frame: CGRectMake(0.0, 0.0, BUTTON_WIDTH, BUTTON_HEIGHT))
        btn1.setBackgroundImage(UIImage(named: "bottom_article_unclick"), forState: UIControlState.Normal)
        btn1.setBackgroundImage(UIImage(named: "bottom_article_clicked"), forState: UIControlState.Selected)
        
        var btn2 = UIButton(frame: CGRectMake(0.0, 0.0, BUTTON_WIDTH, BUTTON_HEIGHT))
        btn2.setBackgroundImage(UIImage(named: "bottom_community_unclick"), forState: UIControlState.Normal)
        btn2.setBackgroundImage(UIImage(named: "bottom_community_clicked"), forState: UIControlState.Selected)
        
        var btn3 = UIButton(frame: CGRectMake(0.0, 0.0, BUTTON_WIDTH, BUTTON_HEIGHT))
        btn3.setBackgroundImage(UIImage(named: "bottom_team_unclick"), forState: UIControlState.Normal)
        btn3.setBackgroundImage(UIImage(named: "bottom_team_clicked"), forState: UIControlState.Selected)
        
        var btn4 = UIButton(frame: CGRectMake(0.0, 0.0, BUTTON_WIDTH, BUTTON_HEIGHT))
        btn4.setBackgroundImage(UIImage(named: "bottom_personalcenter_unclick"), forState: UIControlState.Normal)
        btn4.setBackgroundImage(UIImage(named: "bottom_personalcenter_clicked"), forState: UIControlState.Selected)
        
        btnGroup.append(btn1)
        btnGroup.append(btn2)
        btnGroup.append(btn3)
        btnGroup.append(btn4)
        
        articleItem1 = UIBarButtonItem(customView: btn2)
        articleItem2 = UIBarButtonItem(customView: btn1)
        articleItem3 = UIBarButtonItem(customView: btn3)
        articleItem4 = UIBarButtonItem(customView: btn4)
        flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace , target: nil, action: nil)
        
        btn1.tag = 1 + TAG_START
        btn2.tag = 0 + TAG_START
        btn3.tag = 2 + TAG_START
        btn4.tag = 3 + TAG_START
        
        btn1.addTarget(self, action: "swichingControllers:", forControlEvents: UIControlEvents.TouchUpInside)
        btn2.addTarget(self, action: "swichingControllers:", forControlEvents: UIControlEvents.TouchUpInside)
        btn3.addTarget(self, action: "swichingControllers:", forControlEvents: UIControlEvents.TouchUpInside)
        btn4.addTarget(self, action: "swichingControllers:", forControlEvents: UIControlEvents.TouchUpInside)
        

//        btn1.showCornerStatus(8, rateX: 0.7, rateY: 0.12)
//        btn2.showCornerStatus(1, rateX: 0.7, rateY: 0.12)
//        btn3.showCornerStatus(20, rateX: 0.7, rateY: 0.12)
//        btn4.showCornerStatus(100, rateX: 0.7, rateY: 0.12)

        
        toolBar.setItems([flexSpace,articleItem1,flexSpace,articleItem2,flexSpace,articleItem3,flexSpace,articleItem4,flexSpace], animated: false)
    }
    
    
    @IBAction func swichingControllers(sender: UIButton) {
        for i in self.view.subviews{
            if (i as! UIView).tag == 201 {
                (i as! UIView).removeFromSuperview()
            }
        }
        
        if(sender.tag == 0 + TAG_START){//社区
            switchController(index: 0)
            headView.searchButton.hidden = false
//            addArticleButton.hidden = false
            headView.logoImage.hidden = false
            self.view.bringSubviewToFront(addArticleButton)
        }
        if(sender.tag == 1 + TAG_START){//文章
            switchController(index: 1)
            headView.searchButton.hidden = false
//            addArticleButton.hidden = true
            headView.logoImage.hidden = false
            headView.titleLabel.hidden = true

            
        }
        if(sender.tag == 2 + TAG_START){//社区
            switchController(index: 2)
            headView.searchButton.hidden = false
            headView.logoImage.hidden = false
//            addArticleButton.hidden = false
            self.view.bringSubviewToFront(addArticleButton)
        }
        if(sender.tag == 3 + TAG_START){//个人中心
            switchController(index: 3)
            headView.searchButton.hidden = true
//            addArticleButton.hidden = true
            headView.logoImage.hidden = false
            headView.titleLabel.hidden = true
            
            //todo  调用  "获取个人信息是否完整"   接口
            
            var IsShownUserInfoCompleted = NSUserDefaults.standardUserDefaults().objectForKey("IsShownUserInfoCompleted") as! Bool
            println("\(IsShownUserInfoCompleted)")
            if IsShownUserInfoCompleted == false {
                self.getUserInfo()
               
            }
            
        }
    }
    
    //获取个人信息是否完整
    func getUserInfo(){
        HttpManager.sendHttpRequestPost(GETUSERINFO, parameters:
            ["id": ApplicationContext.getUserID()!,
            "userId": ApplicationContext.getUserID()!
            ],
            success: { (json) -> Void in
                
                FLOG("个人信息返回数据json:\(json)")
                var isIntact  = json["isIntact"] as! Bool
                var IsShownUserInfoCompleted = NSUserDefaults.standardUserDefaults().objectForKey("IsShownUserInfoCompleted") as! Bool
                if isIntact == false && IsShownUserInfoCompleted == false {//不完整而且没有显示过提示
                    UIAlertView(title: "提示", message: "完善个人资料可获赠积分", delegate: self, cancelButtonTitle: "取消",otherButtonTitles:"好").show()
                    NSUserDefaults.standardUserDefaults().setObject(true, forKey: "IsShownUserInfoCompleted")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
            if(buttonIndex==0){
                NSLog("取消")
            }else{
                var personalSettingViewController : PersonalSettingViewController = PersonalSettingViewController(nibName: "PersonalSettingViewController", bundle: nil)
                self.navigationController?.pushViewController(personalSettingViewController, animated: true)
            }
    }
    
    
    
    
    //在5个controller之间切换
    func switchController(#index : Int){
        println("index\(index)")
        println("curIndex\(curIndex)")
        if(index != curIndex && animateEnd == true){
            var newController = childArray[index];
            var curController = childArray[curIndex]
            println("newController\(newController)")
            println("curController\(curController)")
            var offset:CGFloat = CGFloat(self.view.frame.size.width)
            animateEnd = false
            // newController.view.frame = self.view.frame
            
            self.addChildViewController(newController)
            self.view.insertSubview(newController.view, atIndex: 0)
            addConstraintsToParent(firstItem: newController.view)
            
            //高亮显示
            (self.view.viewWithTag(index + TAG_START) as! UIButton).selected = true
            (self.view.viewWithTag(curIndex + TAG_START) as! UIButton).selected = false
            
            var newConstraint : NSLayoutConstraint?
            var curConstraint : NSLayoutConstraint?
            //获取centeX的constant
            for element in self.view.constraints(){
                var constraint = element as! NSLayoutConstraint
                if constraint.firstAttribute ==  NSLayoutAttribute.CenterX &&
                    constraint.firstItem as! UIView == curController.view{
                        curConstraint = constraint
                }
                if constraint.firstAttribute ==  NSLayoutAttribute.CenterX &&
                    constraint.firstItem as! UIView == newController.view{
                        newConstraint = constraint
                }
            }
            //区分动画方向
            if index > curIndex {//点击当前项右面选项
                newConstraint?.constant += offset
                self.view.layoutIfNeeded()
                UIView.animateWithDuration(
                    0.2,
                    delay: 0,
                    options: UIViewAnimationOptions.CurveEaseOut,
                    animations: { () -> Void in
                        newConstraint?.constant -= offset
                        curConstraint?.constant -= offset
                        //                        self.view.userInteractionEnabled = false
                        self.view.layoutIfNeeded()
                    },
                    completion: { (Bool) -> Void in
                        curController.removeFromParentViewController()
                        curController.view .removeFromSuperview()
                        //                        self.view.userInteractionEnabled = true
                        self.curIndex = index
                        self.animateEnd = true
                })
            } else if index < curIndex { //点击当前项左面选项
                newConstraint?.constant -= offset
                self.view.layoutIfNeeded()
                UIView.animateWithDuration(
                    0.2,
                    delay: 0,
                    options: UIViewAnimationOptions.CurveEaseOut,
                    animations: { () -> Void in
                        newConstraint?.constant += offset
                        curConstraint?.constant += offset
                        //                        self.view.userInteractionEnabled = false
                        self.view.layoutIfNeeded()
                    },
                    completion: { (Bool) -> Void in
                        curController.removeFromParentViewController()
                        curController.view .removeFromSuperview()
                        //                        self.view.userInteractionEnabled = true
                        self.curIndex = index
                        self.animateEnd = true
                })
            }//if index>
        }
    }

    
    // 添加推荐弹窗
    func addRecommendAlertView(){
        
        if self.view.subviews.count <= 6{
            println("___-dfdff-__>\(self.view.subviews)")
            
            var recommendAlertView = NSBundle.mainBundle().loadNibNamed("RecommendAlertView", owner: self, options: nil)[0] as! RecommendAlertView
            recommendAlertView.tag = 201
            recommendAlertView.setTranslatesAutoresizingMaskIntoConstraints(false)
            recommendAlertView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.42)
            self.view.addSubview(recommendAlertView)
            println("self.view\(self.view)")
            
            
            println(self.view.bounds.size.height)
            println(self.view.bounds.size.width)
            var heightLayout = NSLayoutConstraint(
                item:recommendAlertView,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1.0,
                constant: self.view.bounds.size.height
            )
            var widthLayout = NSLayoutConstraint(
                item:recommendAlertView,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1.0,
                constant: self.view.bounds.size.width
            )
            recommendAlertView.addConstraints([widthLayout,heightLayout])
            
            var topLayout = NSLayoutConstraint(
                item:recommendAlertView,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1.0,
                constant: 0
            )
            var leftLayout = NSLayoutConstraint(
                item:recommendAlertView,
                attribute: NSLayoutAttribute.Leading,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Leading,
                multiplier: 1.0,
                constant: 0.0
            )
            self.view.addConstraints([topLayout,leftLayout])
        }
    }
    
    func gotoRecommendMembersViewController(){
        var recommendMembersViewController : RecommendMembersViewController = RecommendMembersViewController(nibName: "RecommendMembersViewController", bundle: nil)
        self.navigationController?.pushViewController(recommendMembersViewController, animated: true)
    }
    
    func gotoRecommendProjectViewController(){
        var recommendProjectViewController : RecommendProjectViewController = RecommendProjectViewController(nibName: "RecommendProjectViewController", bundle: nil)
        self.navigationController?.pushViewController(recommendProjectViewController, animated: true)
    }
    
    //添加新的文章
    @IBAction func onclickAddAriticleButton(sender: AnyObject) {
        for i in self.view.subviews{
            if (i as! UIView).tag == 201 {
                (i as! UIView).removeFromSuperview()
            }
        }
        var numberIndex : Int
        numberIndex = Int()
        if curIndex == 0 {
            numberIndex = 1
        }
        var publishAriticleViewController : PublishAriticleViewController = PublishAriticleViewController(nibName: "PublishAriticleViewController", bundle: nil,param:numberIndex)
        self.navigationController?.pushViewController(publishAriticleViewController, animated: true)
    }
    //跳转到搜索页面
    func gotoSearchView(){
        for i in self.view.subviews{
            if (i as! UIView).tag == 201 {
                (i as! UIView).removeFromSuperview()
            }
        }
        if curIndex == 1 {
            var curController = childArray[curIndex]
            var controller : RefactorArticleViewController = curController as! RefactorArticleViewController
            if controller.btn1.selected == true {
                var searchViewController : MySearchViewController = MySearchViewController(nibName: "MySearchViewController", bundle: nil,param:"1")
                self.navigationController?.pushViewController(searchViewController, animated: false)
            }else{
                var searchViewController : MySearchViewController = MySearchViewController(nibName: "MySearchViewController", bundle: nil,param:"2")
                self.navigationController?.pushViewController(searchViewController, animated: false)
            }
        }else if curIndex == 0 {
            var searchViewController : MySearchViewController = MySearchViewController(nibName: "MySearchViewController", bundle: nil,param:"3")
            self.navigationController?.pushViewController(searchViewController, animated: false)
        }else{
            var searchViewController : MySearchViewController = MySearchViewController(nibName: "MySearchViewController", bundle: nil,param:"4")
            self.navigationController?.pushViewController(searchViewController, animated: false)
        }
    }

    //跳转到系统页面
    func gotoSystemNotificationViewController(){
        var systemNotificationViewController : SystemNotificationViewController = SystemNotificationViewController(nibName: "SystemNotificationViewController", bundle: nil)
        headView.navgationController.navigationController?.pushViewController(systemNotificationViewController, animated: true)
    }
    
    func getNotificationCount(){
//        GET_PUSH_COUNT
        HttpManager.sendHttpRequestPost(GET_PUSH_COUNT, parameters: ["userId":ApplicationContext.getUserID()!],
            success: { (json) -> Void in
                
                FLOG("获取未读消息json:\(json)")
                var pushCount = json["count"] as! Int
                
                //第四页添加角标
                self.btnGroup[3].showCornerStatus(pushCount, rateX: 0.7, rateY: 0.12)
                
                //本地存储一份，让“我的”->“消息”添加角标
                NSUserDefaults.standardUserDefaults().setObject(pushCount, forKey: "push_count")
                NSUserDefaults.standardUserDefaults().synchronize()
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
    
    func refreshPushCount(){
        //设定为Optional的原因是怕程序第一次启动推送来到，default里面还没有这个字段，会导致为Nil
        var count = NSUserDefaults.standardUserDefaults().objectForKey("push_count") as? Int
        if let pushCount = count {
            self.btnGroup[3].showCornerStatus(pushCount, rateX: 0.7, rateY: 0.12)
        }
    }
    
}
