//
//  RefactorArticleViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-3-6.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class RefactorArticleViewController: BasicViewController,UIScrollViewDelegate {
    var articlesBarButtonItem: UIBarButtonItem!
    var activitiesBarButtonItem: UIBarButtonItem!
    var btn1: UIButton!
    var btn2: UIButton!
    var flexSpace : UIBarButtonItem!
    let BUTTON_WIDTH :CGFloat = UIScreen.mainScreen().bounds.size.width/2
    let BUTTON_HEIGHT : CGFloat = 36
    let ButtonSelectedColor : UIColor = UIColor(red: 242.0/255.0, green: 241.0/255.0, blue: 242.0/255.0, alpha: 1)
    let ButtonUnSelectedColor : UIColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
    let TAG_START : Int = 2000
    
    var whiteImage : UIImageView?

    var currentIndex : Int = 0
    @IBOutlet weak var toolBar: UIToolbar!
    
    var leadingLayout : NSLayoutConstraint!
    @IBOutlet weak var refactorScrollview: UIScrollView!
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headView.hidden = true
        refactorScrollview.tag = 901
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoAriticleDetailView:", name: "gotoAriticleDetailViewController", object: nil)
//        println(self.view.subviews)
        
        setUpToolBarButtons()
        self.initRefactorScrollView()
        refactorScrollview.addObserver(self, forKeyPath: "contentInset", options: NSKeyValueObservingOptions.Initial, context: nil)
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)        
        if refactorScrollview.subviews.count == 2 {
//            self.initRefactorScrollView()
        }
    }
    
    deinit{
//        FLOG("refactorScrollview:\(refactorScrollview)")
        if refactorScrollview != nil {
            refactorScrollview.removeObserver(self, forKeyPath: "contentInset")
        }
    }
    
    func setUpToolBarButtons(){
        // 设置button的样式
        btn1 = UIButton(frame: CGRectMake(0.0, 0.0, BUTTON_WIDTH, BUTTON_HEIGHT))
        btn1.setTitle("干货", forState: UIControlState.Selected)
        btn1.setTitleColor(ButtonSelectedColor, forState: UIControlState.Selected)
        btn1.setTitle("干货", forState: UIControlState.Normal)
        btn1.setTitleColor(ButtonUnSelectedColor, forState: UIControlState.Normal)
        //        btn1.titleLabel?.font = UIFont.systemFontOfSize(15.0)
        btn1.titleLabel?.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 15)
        
        
        
        btn2 = UIButton(frame: CGRectMake(0.0, 0.0, BUTTON_WIDTH, BUTTON_HEIGHT))
        btn2.setTitle("活动", forState: UIControlState.Selected)
        btn2.setTitleColor(ButtonSelectedColor, forState: UIControlState.Selected)
        btn2.setTitle("活动", forState: UIControlState.Normal)
        btn2.setTitleColor(ButtonUnSelectedColor, forState: UIControlState.Normal)
        //        btn2.titleLabel?.font = UIFont.systemFontOfSize(15.0)
        btn2.titleLabel?.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 15)
        
        btn2.selected = false
        btn1.selected = true
        
        articlesBarButtonItem = UIBarButtonItem(customView: btn1)
        activitiesBarButtonItem = UIBarButtonItem(customView: btn2)
        flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace , target: nil, action: nil)
        
        btn1.tag = 0 + TAG_START
        btn2.tag = 1 + TAG_START
        
        btn1.addTarget(self, action: "swichingControllers:", forControlEvents: UIControlEvents.TouchUpInside)
        btn2.addTarget(self, action: "swichingControllers:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        toolBar.setItems([flexSpace,articlesBarButtonItem, flexSpace, activitiesBarButtonItem, flexSpace], animated: false)
        
//        println(self.view.subviews)
       
        
        self.addWhiteImage()
        
        
    }

    //toolBar按钮的点击事件
    func swichingControllers(sender: UIButton) {
        var screenBounds = UIScreen.mainScreen().bounds
        if(sender.tag == 0 + TAG_START){
            currentIndex = 0
            sender.selected = true
            btn2.selected = false
            refactorScrollview.setContentOffset(CGPointMake(screenBounds.size.width*0, 0), animated: true)
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.leadingLayout.constant = (UIScreen.mainScreen().bounds.width / 2 - 117)/2
                self.view.layoutIfNeeded()
            })
        }
        if(sender.tag == 1 + TAG_START){
            currentIndex = 1
            sender.selected = true
            btn1.selected = false
            refactorScrollview.setContentOffset(CGPointMake(screenBounds.size.width*1, 0), animated: true)
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.leadingLayout.constant = (UIScreen.mainScreen().bounds.width / 2 - 117)/2 + UIScreen.mainScreen().bounds.width / 2
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    //添加toolbar下的白条
    func addWhiteImage(){
        
        whiteImage = UIImageView(frame: CGRectMake(23.0, 10, 117, 2))
        whiteImage?.tag = 199
        whiteImage!.image = UIImage(named: "homeWhiteLine")
        whiteImage!.setTranslatesAutoresizingMaskIntoConstraints(false)
        toolBar.addSubview(whiteImage!)
        
//        println("self.view\(self.view)")
        var heightLayout = NSLayoutConstraint(
            item:whiteImage!,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 2
        )
        var widthLayout = NSLayoutConstraint(
            item: whiteImage!,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 117)
        whiteImage!.addConstraints([heightLayout,widthLayout])
        var bottomLayout = NSLayoutConstraint(
            item:whiteImage!,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: toolBar,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 34
        )
        leadingLayout = NSLayoutConstraint(
                item:whiteImage!,
                attribute: NSLayoutAttribute.Leading,
                relatedBy: NSLayoutRelation.Equal,
                toItem: toolBar,
                attribute: NSLayoutAttribute.Leading,
                multiplier: 1.0,
                constant: (UIScreen.mainScreen().bounds.width / 2 - 117)/2
        )


        
        toolBar.addConstraints([leadingLayout,bottomLayout])
//        self.view.bringSubviewToFront(whiteImage!)
    }
    
    
    
    func initRefactorScrollView(){
        var screenBounds = UIScreen.mainScreen().bounds
        refactorScrollview.contentSize = CGSizeMake(screenBounds.size.width*2,0)
        for i in 0 ..< 2 {
            var secondArticleTableView = SecondArticleTableView(frame: CGRectMake(screenBounds.size.width * CGFloat(i), 0, screenBounds.size.width, screenBounds.size.height-64), style: UITableViewStyle.Plain)
//            secondArticleTableView.contentInset = UIEdgeInsetsMake(36, 0, (50/320)*UIScreen.mainScreen().bounds.width, 0);
            secondArticleTableView.tag = 4000 + i
            refactorScrollview.addSubview(secondArticleTableView)
            switch (i) {
            case 0:
                secondArticleTableView.getTopicListFromWeb()
                break
            case 1:
                secondArticleTableView.getActivityListFromWeb()
                break
            default:
                break
            }
            
        }
//       println("2222\(self.refactorScrollview.subviews)")
        
    }
    
    
    //MARK:-scrollview  delegate
    func scrollViewDidScroll(scrollView: UIScrollView){
//        println("width=====\(scrollView.contentOffset.x)")
        
        //上面的白条也跟着变
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.leadingLayout.constant = (UIScreen.mainScreen().bounds.width / 2 - 117)/2 + scrollView.contentOffset.x/2
//            self.btn1.alpha = 1.5 - scrollView.contentOffset.x / UIScreen.mainScreen().bounds.width
//            self.btn2.alpha = 0.4 + scrollView.contentOffset.x / UIScreen.mainScreen().bounds.width
        })
    }
    
    
    
    
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
//        println("111")
        
        
        
        if scrollView.tag == 901 {
            var pageIndex  = Int(scrollView.contentOffset.x/scrollView.frame.size.width)
//            println("222\(pageIndex)")
            
            
            if pageIndex == 0 {
                currentIndex = 0
                btn1.selected = true
                btn2.selected = false
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.leadingLayout.constant = (UIScreen.mainScreen().bounds.width / 2 - 117)/2
                })
            }else{
                currentIndex = 1
                btn2.selected = true
                btn1.selected = false
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.leadingLayout.constant = (UIScreen.mainScreen().bounds.width / 2 - 117)/2 + UIScreen.mainScreen().bounds.width / 2
                })
            }
        }

        
    }
    
    
    
    //页面跳转
    func gotoAriticleDetailView(notification : NSNotification){
        
        for i in self.view.superview!.subviews{
            if (i as! UIView).tag == 201 {
                (i as! UIView).removeFromSuperview()
            }
        }
        
        var type : String
        if btn1.selected == true {
            type = "1"
        }else {
            type = "2"
        }
        var dic: AnyObject = notification.userInfo!["data"]!
        FLOG("data-------》》\(dic)")
        var paramDic : [String:AnyObject] = ["data":dic,"type":type]
        if btn1.selected == true {
            var articleDetailViewController = ArticleDetailViewController(nibName: "ArticleDetailViewController", bundle: nil,dic: paramDic)
            self.navigationController?.pushViewController(articleDetailViewController, animated: true)
        }else{
            var activityDetailViewController = ActivityDetailViewController(nibName: "ActivityDetailViewController", bundle: nil,dic: paramDic)
            self.navigationController?.pushViewController(activityDetailViewController, animated: true)
        }

    }
}

extension RefactorArticleViewController {
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentInset" {
            var scrollView = object as! UIScrollView
            if scrollView.contentInset.top > 0 {
                scrollView.contentInset = UIEdgeInsetsZero
                scrollView.contentOffset = CGPointZero  
                self.view.layoutIfNeeded()
            }
            FLOG("object：\(scrollView.contentInset.bottom)")
        }
    }
}
