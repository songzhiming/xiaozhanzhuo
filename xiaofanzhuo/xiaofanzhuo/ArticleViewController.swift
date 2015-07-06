//
//  ArticleViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-15.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

protocol ArticleViewControllerDelegate {
    func moveSidebarBegan(p: CGPoint)
    func moveSidebarChanged(p: CGPoint)
    func moveSidebarEnded(p: CGPoint)
}

class ArticleViewController: AllocDeallocViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var whiteImageLeadingLayout: NSLayoutConstraint!
    var articlesBarButtonItem: UIBarButtonItem!
    var activitiesBarButtonItem: UIBarButtonItem!
    var btn1: UIButton!
    var btn2: UIButton!
    var flexSpace : UIBarButtonItem!
    var delegate: ArticleViewControllerDelegate?
    var categories: Array<CategoryViewController> = Array()
    var scrollIndexPath: NSIndexPath!
    var leadingLayout : NSLayoutConstraint!

    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    @IBOutlet weak var toolBar: UIToolbar!
    //底部菜单栏的item的宽高
    let BUTTON_WIDTH :CGFloat = UIScreen.mainScreen().bounds.size.width/2
    let BUTTON_HEIGHT : CGFloat = 50
    let ButtonSelectedColor : UIColor = UIColor(red: 242.0/255.0, green: 241.0/255.0, blue: 242.0/255.0, alpha: 1)
    let ButtonUnSelectedColor : UIColor = UIColor(red: 107.0/255.0, green: 105.0/255.0, blue: 106.0/255.0, alpha: 1)
    let TAG_START : Int = 2000
    let categoryCellIdentifier = "CategoryCellIdentifier"
    
    // MARK: - view
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoAriticleDetailView:", name: "gotoAriticleDetailViewController", object: nil)
        for i in 0 ..< 2 {
            var categoryViewController: CategoryViewController = CategoryViewController(nibName: "CategoryViewController", bundle: NSBundle.mainBundle())
            categories.append(categoryViewController)
        }

        // ContentCollection
        contentCollectionView.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: categoryCellIdentifier)
        contentCollectionView.pagingEnabled = true
        contentCollectionView.bounces = true
        contentCollectionView.showsHorizontalScrollIndicator = false
        contentCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var categoryFlowLayout: UICollectionViewFlowLayout = contentCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        categoryFlowLayout.itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height-100.0 )
        categoryFlowLayout.sectionInset = UIEdgeInsetsZero
        contentCollectionView.reloadData()
        
        
        // barButton
        setUpToolBarButtons()
        // get data

        // Do any additional setup after loading the view.
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        var categoryFlowLayout: UICollectionViewFlowLayout = contentCollectionView.collectionViewLayout as UICollectionViewFlowLayout
//        categoryFlowLayout.itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height-100.0)
//        categoryFlowLayout.sectionInset = UIEdgeInsetsZero
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var whiteImage = UIImageView(frame: CGRectMake(23.0, 10, 117, 2))
        
        whiteImage.image = UIImage(named: "homeWhiteLine")
        whiteImage.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(whiteImage)
        
        println("self.view\(self.view)")
        var heightLayout = NSLayoutConstraint(
            item:whiteImage,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 2
        )
        var widthLayout = NSLayoutConstraint(
            item: whiteImage,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 117)
        whiteImage.addConstraints([heightLayout,widthLayout])
        var bottomLayout = NSLayoutConstraint(
            item:whiteImage,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 34
        )
        leadingLayout = NSLayoutConstraint(
            item:whiteImage,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1.0,
            constant: (UIScreen.mainScreen().bounds.width / 2 - 117)/2
        )
        
        self.view.addConstraints([leadingLayout,bottomLayout])
        self.view.bringSubviewToFront(whiteImage)
        println(self.view.subviews)
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
        
        

        
        


        

    }
    


    
    func swichingControllers(sender: UIButton) {

        
        if(sender.tag == 0 + TAG_START){
            sender.selected = true
            btn2.selected = false
            scrollIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            contentCollectionView.scrollToItemAtIndexPath(scrollIndexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.leadingLayout.constant = (UIScreen.mainScreen().bounds.width / 2 - 117)/2
            })
        }
        if(sender.tag == 1 + TAG_START){
            sender.selected = true
            btn1.selected = false
            scrollIndexPath = NSIndexPath(forRow: 1, inSection: 0)
            contentCollectionView.scrollToItemAtIndexPath(scrollIndexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.leadingLayout.constant = (UIScreen.mainScreen().bounds.width / 2 - 117)/2 + UIScreen.mainScreen().bounds.width / 2
            })
        }
    }
    
    // MARK: - collectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(categoryCellIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        
        var categoryViewController: CategoryViewController = categories[indexPath.row]
        var categoryView: UIView = categoryViewController.view
        
        cell.contentView.addSubview(categoryView)
        if indexPath.row == 0 {
            categoryViewController.getTopicListFromWeb()
            categoryViewController.setTheIndexPage(1)
        }else{
            categoryViewController.getActivityListFromWeb()
            categoryViewController.setTheIndexPage(2)
        }
        categoryView.setTranslatesAutoresizingMaskIntoConstraints(false)
        var padding = UIEdgeInsetsMake(0, 0, 0, 0)
        makeConstraints(cell.contentView, childView: categoryView, padding: padding)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height-100.0)
    }
    
    // MARK: - scrollViewdelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.tag == 200)
        {
            if (scrollView.contentOffset.y < 0) {
                scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, 0), animated: false)
            }
            // 禁止ScrollView左侧皮筋效果
            if (scrollView.contentOffset.x < 0) {
                scrollView.setContentOffset(CGPointZero, animated: false)
            }
            // 禁止ScrollView右侧皮筋效果
            if scrollView.contentOffset.x > (scrollView.contentSize.width - scrollView.bounds.size.width) {
                scrollView.contentOffset = CGPointMake(scrollView.contentSize.width - scrollView.bounds.size.width, scrollView.contentOffset.y)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.tag == 200 {
            let currentPageIndex: Int = self.currentPageIndexWithScrollView(scrollView)
            if (currentPageIndex == 0) {
                btn1.selected = true
                btn2.selected = false
                self.leadingLayout.constant = (UIScreen.mainScreen().bounds.width / 2 - 117)/2
            }
            else {
                btn1.selected = false
                btn2.selected = true
                self.leadingLayout.constant = (UIScreen.mainScreen().bounds.width / 2 - 117)/2 + UIScreen.mainScreen().bounds.width / 2
            }
        }
    }
    
    // 获取到当前scrollView索引值
    func currentPageIndexWithScrollView(scrollView: UIScrollView) -> Int {
        let contentOffsetX: Int = Int(abs(scrollView.contentOffset.x))
        let width: Int = Int(scrollView.bounds.size.width)
        return contentOffsetX / width
    }
        
    // MARK: - makeConstraints
    // 代替snp_makeConstraints
    func makeConstraints(parentView: UIView, childView: UIView, padding: UIEdgeInsets)
    {
        
        childView.setTranslatesAutoresizingMaskIntoConstraints(false)
        parentView.addSubview(childView)
        //    var padding = UIEdgeInsetsMake(10, 10, 10, 10)
        
        parentView.addConstraints([
            NSLayoutConstraint(
                item: childView,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: parentView,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1.0,
                constant: padding.top
            ),
            NSLayoutConstraint(
                item: childView,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: parentView,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1.0,
                constant: padding.left
            ),
            NSLayoutConstraint(
                item: childView,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: parentView,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1.0,
                constant: -padding.bottom
            ),
            NSLayoutConstraint(
                item: childView,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: parentView,
                attribute: NSLayoutAttribute.Right,
                multiplier: 1.0,
                constant: -padding.right
            )
            ])
    }
    
    
    
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
        var paramDic : [String:AnyObject] = ["data":dic,"type":type]
        FLOG(paramDic)
        var articleDetailViewController = ArticleDetailViewController(nibName: "ArticleDetailViewController", bundle: nil,dic: paramDic)
        self.navigationController?.pushViewController(articleDetailViewController, animated: true)
    }
}




