//
//  BasicViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class BasicViewController: AllocDeallocViewController {
    var loadingView : LoadingView!
    var headView : HeadView!
    var param : AnyObject?
    var extraView:ExtraView!
    
    var botLayout : NSLayoutConstraint!
    var rightLayout : NSLayoutConstraint!
    
    var _initFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addHeadView()
        self.addExtraView()
        
    }

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?,param : AnyObject?=nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.param = param
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoSystemNotificationViewController", name: "goto.SystemNotificationViewController", object: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)

        if !_initFlag {
            self.view.bringSubviewToFront(extraView)
            self.view.layoutIfNeeded()
            _initFlag = true
        }
        
    }
    
    func setExtraView_B_R(bot:CGFloat,right:CGFloat){
        self.botLayout.constant = bot
        self.rightLayout.constant = right
        self.view.layoutIfNeeded()
    }
    
    func addExtraView(){
        extraView = NSBundle.mainBundle().loadNibNamed("ExtraView", owner: self, options: nil)[0] as! ExtraView
        extraView.delegate = self
        extraView.hidden = true
        extraView.setTranslatesAutoresizingMaskIntoConstraints(false)
        extraView.layer.cornerRadius = 30
        extraView.layer.masksToBounds = true
        
        self.view.addSubview(extraView)
        var heightLayout = NSLayoutConstraint(
            item:extraView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 60
        )
        var widthLayout = NSLayoutConstraint(
            item:extraView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 60
        )
        extraView.addConstraints([heightLayout,widthLayout])
        var botLayout = NSLayoutConstraint(
            item:self.view,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: extraView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0,
            constant: (50/320)*UIScreen.mainScreen().bounds.width + 5
        )
        var rightLayout = NSLayoutConstraint(
            item:self.view,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem:extraView,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1.0,
            constant: 8
        )
        self.botLayout = botLayout
        self.rightLayout = rightLayout
        self.view.addConstraints([botLayout,rightLayout])
    }
    
    //添加headView
    func addHeadView(){
        headView = NSBundle.mainBundle().loadNibNamed("HeadView", owner: self, options: nil)[0] as! HeadView
        headView.navgationController = self.navigationController
        headView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(headView)
        var heightLayout = NSLayoutConstraint(
                                        item:headView,
                                        attribute: NSLayoutAttribute.Height,
                                        relatedBy: NSLayoutRelation.Equal,
                                        toItem: nil,
                                        attribute: NSLayoutAttribute.NotAnAttribute,
                                        multiplier: 1.0,
                                        constant: 64.0
        )
        headView.addConstraint(heightLayout)
        var topLayout = NSLayoutConstraint(
            item:headView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 0.0
        )
        var leftLayout = NSLayoutConstraint(
            item:headView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1.0,
            constant: 0.0
        )
        var rightLayout = NSLayoutConstraint(
            item:headView,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1.0,
            constant: 0.0
        )
        self.view.addConstraints([topLayout,leftLayout,rightLayout])
    }
    
    
    func addLoadingView(){
        NSNotificationCenter.defaultCenter().postNotificationName("remove.loading.view", object: nil)
        loadingView = NSBundle.mainBundle().loadNibNamed("LoadingView", owner: self, options: nil)[0] as! LoadingView
        loadingView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(loadingView)
        
        var topLayout = NSLayoutConstraint(
            item:loadingView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 64
        )
        var leftLayout = NSLayoutConstraint(
            item:loadingView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1.0,
            constant: 0.0
        )
        var rightLayout = NSLayoutConstraint(
            item:loadingView,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1.0,
            constant: 0.0
        )
        var buttomLayout = NSLayoutConstraint(
            item: loadingView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0,
            constant: 0.0
        )
        self.view.addConstraints([topLayout,leftLayout,rightLayout,buttomLayout])
        
    }
    
    func removeLoadingView(){
        self.loadingView.removeFromSuperview()
    }
}

extension BasicViewController:ExtraViewDelegate {
    func extraViewClick(){
        
    }
}

