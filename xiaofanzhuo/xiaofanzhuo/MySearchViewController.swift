//
//  MySearchViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-2-2.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class MySearchViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource{

    var loadingView : LoadingView!
    
    @IBOutlet weak var searchHeadView: UIView!
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failLabel: UILabel!
    
    var dataCount = 0
    var searchTableView : UITableView!
    var searchImageView: UIImageView!
    var holderView : UIView!
    var param : String!
    var topicList : [CommunityTopic]!  //社区
    var taskList : NSMutableArray?     //对对碰
    var newsLists : [NewsList]!        //文章
    var begin = 0
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?,param : String?=nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.param = param
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsLists = [NewsList]()
        topicList = [CommunityTopic]()
        self.searchTextField.delegate = self
        self.addSearchImageView()
        self.contentView.frame = CGRectMake(0, 64, self.contentView.frame.size.width, self.contentView.frame.size.height)
        searchTableView = UITableView(frame: CGRectMake(5, 0, UIScreen.mainScreen().bounds.width-10,UIScreen.mainScreen().bounds.height-64-11))
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.registerNib(UINib(nibName:"NewsTableViewCell", bundle:nil), forCellReuseIdentifier: "NewsCell")
        searchTableView.registerNib(UINib(nibName:"CommunityTableViewCell", bundle: nil), forCellReuseIdentifier: "CommunityTableViewCell")
        searchTableView.registerNib(UINib(nibName:"MakeUpTouchTableViewCell", bundle:nil), forCellReuseIdentifier: "MakeUpTouchTableViewCell")
        searchTableView.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
//        searchTableView.backgroundColor = UIColor.redColor()
        self.contentView.addSubview(searchTableView)
        searchTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        searchTableView.addFooterWithTarget(self, action:"loadmore")
        self.searchTableView.footerHidden = true
        holderView = UIView(frame: CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-64))
        holderView.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.contentView.frame = CGRectMake(0, 64, self.contentView.frame.size.width, self.contentView.frame.size.height)
        self.searchAnimation()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addSearchImageView(){
        searchImageView = UIImageView(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 33, 29, 20, 21))
        self.view.addSubview(searchImageView)
        searchImageView.image = UIImage(named: "search")
    }
    //搜索页面的动画
    func searchAnimation(){
        var transform = CATransform3DIdentity
        transform.m34 = -1.0/800;
        self.headView.layer.anchorPoint = CGPointMake(0.5, 0.5)
        self.headView.layer.position = CGPointMake(self.headView.frame.size.width/2, 0)
        self.headView.layer.removeAllAnimations()
        var animation = CABasicAnimation(keyPath: "transform")
        animation.duration = 0.45
        animation.fromValue = NSValue(CATransform3D: CATransform3DRotate(transform, 0, 1, 0, 0))
        animation.toValue = NSValue(CATransform3D: CATransform3DRotate(transform, CGFloat(M_PI_2), 1, 0, 0))
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards;
        self.headView.layer.addAnimation(animation, forKey: "flipUp")
        UIView.animateWithDuration(
            0.45,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                self.view.alpha = 1.0
                self.searchImageView.frame = CGRectMake(10, 29, 20, 21)
            }) { (Bool) -> Void in
                FLOG("123")
        }
        UIView.animateWithDuration(
            1.0,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.searchHeadView.alpha = 1.0
            }) { (Bool) -> Void in
        }
        
        dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
        self.view.bringSubviewToFront(self.searchImageView)
            return
        }
        
//        self.contentView.showOrigamiTransitionWith(
//            self.searchTableView,
//            numberOfFolds: 1,
//            duration: 0.45,
//            direction: UInt(XYOrigamiDirectionFromTop)) { (Bool) -> Void in
//        }
//        self.searchTextField.becomeFirstResponder()
    }
    
    //以动画的形式关闭页面
    @IBAction func closeSearchView(sender: AnyObject) {
//        println("close")
        self.failView.hidden = true 
        FLOG("close")
        self.headView.layer.removeAllAnimations()
        var animation = CABasicAnimation(keyPath: "transform")
        var transform = CATransform3DIdentity
        transform.m34 = -1.0/800;
        animation.fromValue = NSValue(CATransform3D: CATransform3DRotate(transform, CGFloat(M_PI_2), 1, 0, 0))
        animation.toValue = NSValue(CATransform3D: CATransform3DRotate(transform, 0, 1, 0, 0));
        animation.removedOnCompletion = true;
        animation.fillMode = kCAFillModeRemoved;
        self.headView.layer.addAnimation(animation, forKey: "flipDown")
        UIView.animateWithDuration(
            0.45,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                self.searchHeadView.alpha = 0.0;
                self.searchImageView.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 33, 29, 20, 21)
                
            }) { (Bool) -> Void in
                self.navigationController?.popViewControllerAnimated(false)
        }
//        UIView.animateWithDuration(
//            0.1,
//            delay: 0.45,
//            options: UIViewAnimationOptions.CurveEaseInOut,
//            animations: { () -> Void in
//                self.navigationController?.popViewControllerAnimated(false)
//            }) { (Bool) -> Void in
//        }

//        ApplicationContext.delay(0.45, closure: { () -> () in
//            self.navigationController?.popViewControllerAnimated(true)
//        })
        
        
        
//        self.contentView.hideOrigamiTransitionWith(
//            nil, numberOfFolds: 1, duration: 0.45, direction: UInt(XYOrigamiDirectionFromTop)) { (Bool) -> Void in
//            self.contentView.alpha = 0.0
//            self.searchTableView.alpha = 0.0
//            self.navigationController?.popViewControllerAnimated(false)
//        }
//        self.navigationController?.popViewControllerAnimated(false)
   
        
    }
    
    
    
    //点击键盘上 的return   key
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.searchTextField.resignFirstResponder()
        self.getSearchResultData()
        return true
    }
    
    
    
    
    //MARK:-table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.param == "3" {
            var cell = tableView.dequeueReusableCellWithIdentifier("CommunityTableViewCell") as! CommunityTableViewCell
            cell.loadData(topicList[indexPath.row])
            return cell
        }else if self.param == "4" {
            var cell: MakeUpTouchTableViewCell = tableView.dequeueReusableCellWithIdentifier("MakeUpTouchTableViewCell") as! MakeUpTouchTableViewCell
            var dataDic = taskList?.objectAtIndex(indexPath.row) as? NSDictionary
            cell.loadData(dataDic)
            return cell
        }else {
            var cell: NewsTableViewCell = tableView.dequeueReusableCellWithIdentifier("NewsCell") as! NewsTableViewCell
            cell.loadData(newsLists[indexPath.row])
            return cell
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.param == "1" || self.param == "2"{
            return 61
        }
        return 83
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if self.param == "3" {
            var topicDetailViewController = TopicDetailViewController(nibName: "TopicDetailViewController", bundle: nil,param: topicList[indexPath.row].id)
            self.navigationController?.pushViewController(topicDetailViewController, animated: true)
        }else if self.param == "4" {
            var detailMakeUpTouchViewController = DetailMakeUpTouchViewController(nibName: "DetailMakeUpTouchViewController", bundle: nil, param: taskList?.objectAtIndex(indexPath.row) )
            self.navigationController?.pushViewController(detailMakeUpTouchViewController, animated: true)
            
        }
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.param == "1" {
            if self.newsLists?.count == nil {
                return 0
            }
            return (self.newsLists?.count)!
        }else if self.param == "2"{
            if self.newsLists?.count == nil {
                return 0
            }
            return (self.newsLists?.count)!
        }else if self.param == "3"{
            if self.topicList?.count == nil {
                return 0
            }
            return (self.topicList?.count)!
        }else {
            if self.taskList?.count == nil {
                return 0
            }
            return (self.taskList?.count)!
        }
    }
    
    
    
    
    //获取网络数据
    func getSearchResultData(){
        if searchTextField.text.isEmpty {
            UIAlertView(title: "提示", message: "请输入搜索内容", delegate: nil, cancelButtonTitle: "好的,知道了").show()
        }
        else {
            self.addLoadingView()
            HttpManager.sendHttpRequestPost(SEARCH, parameters: ["type": self.param,
                "content":searchTextField.text,
                "begin":0,
                "limit":10
                ],
                success: { (json) -> Void in
                    
                    FLOG("鸡汤json:\(json)")
                    self.failView.hidden = true
                    if self.param == "3" {//社区
                        self.topicList.removeAll(keepCapacity: true)
                        var dataArray = json["topicList"] as! [[String:AnyObject]]
                        for  dataDic in dataArray {
                            self.topicList.append(CommunityTopic(dataDic: dataDic))
                        }
                        if let isMore = json["isMore"] as? Bool {
                            if isMore == false {
                                self.searchTableView.footerHidden = true
                            }else{
                                self.searchTableView.footerHidden = false
                            }
                        }
                        self.dataCount = self.topicList.count
                        self.searchTableView.reloadData()
                    }else if self.param == "4" {//对对碰
                        if json["isMore"] as! Bool == true {
                            self.searchTableView.footerHidden = false
                        }else{
                            self.searchTableView.footerHidden = true
                        }
                        self.taskList = (json["taskList"])?.mutableCopy() as? NSMutableArray
                        self.dataCount = self.taskList!.count
                        self.searchTableView.reloadData()
                    }else if self.param == "2" {//活动
                        
                        if json["isMore"] as! Bool == true {
                            self.searchTableView.footerHidden = false
                        }else{
                            self.searchTableView.footerHidden = true
                        }
                        var dataArray = json["activityList"] as! [[String:AnyObject]]
                        for  dataDic in dataArray {
                            self.newsLists.append(NewsList(dataDic: dataDic))
                        }
                        self.dataCount = self.newsLists!.count
                        self.searchTableView.reloadData()
                    }else {//文章
                        if json["isMore"] as! Bool == true {
                            self.searchTableView.footerHidden = false
                        }else{
                            self.searchTableView.footerHidden = true
                        }
                        var dataArray = json["articleList"] as! [[String:AnyObject]]
                        for  dataDic in dataArray {
                            println(dataDic)
                            self.newsLists.append(NewsList(dataDic: dataDic))
                        }
                        self.dataCount = self.newsLists!.count
                        println(self.newsLists)
                        self.searchTableView.reloadData()
                    }
                    if self.dataCount == 0 {
                        self.failView.hidden = false
                        self.failLabel.text = LOAD_SEARCH_EMPTY
                    }
                    self.removeLoadingView()
                },
                failure:{ (reason) -> Void in
                    if self.dataCount == 0 {
                        self.failView.hidden = false
                        self.failLabel.text = LOAD_FAILED_NO_REFRESH
                    }
                    FLOG("失败原因:\(reason)")
                    self.removeLoadingView()
            })

        }
        
    }
    
    
    
    
        //加载更多
        func loadmore(){
            if searchTextField.text.isEmpty {
                UIAlertView(title: "提示", message: "请输入搜索内容", delegate: nil, cancelButtonTitle: "好的,知道了").show()
            }
            else {
                switch self.param {
                case "3":
                    self.begin = self.topicList.count
                case "4":
                    self.begin = self.taskList!.count
                case "2":
                    self.begin = self.newsLists.count
                case "1":
                    self.begin = self.newsLists.count
                default:
                    break
                }

                HttpManager.sendHttpRequestPost(SEARCH, parameters: ["type": self.param,
                    "content":searchTextField.text,
                    "begin":self.begin,
                    "limit":5
                    ],
                    success: { (json) -> Void in
                        
                        FLOG("搜索返回数据json:\(json)")
                        //服务器数据返回成功
                        println(json["userInfo"])
                        if self.param == "3" {//社区
                            var dataArray = json["topicList"] as! [[String:AnyObject]]
                            for  dataDic in dataArray {
                                self.topicList.append(CommunityTopic(dataDic: dataDic))
                            }
                            if let isMore = json["isMore"] as? Bool {
                                if isMore == false {
                                    self.searchTableView.footerHidden = true
                                }else{
                                    self.searchTableView.footerHidden = false
                                }
                            }
                            self.searchTableView.reloadData()
                            self.searchTableView.footerEndRefreshing()
                        }else if self.param == "4" {//对对碰
                            if json["isMore"] as! Bool == true {
                                self.searchTableView.footerHidden = false
                            }else{
                                self.searchTableView.footerHidden = true
                            }
                            var array = json["taskList"] as? NSMutableArray
                            if array != nil {
                                self.taskList?.addObjectsFromArray(array! as [AnyObject])
                            }
                            self.searchTableView.reloadData()
                            self.searchTableView.footerEndRefreshing()
                        }else if self.param == "2" {//活动
                            if json["isMore"] as! Bool == true {
                                self.searchTableView.footerHidden = false
                            }else{
                                self.searchTableView.footerHidden = true
                            }
                            var dataArray = json["activityList"] as! [[String:AnyObject]]
                            for  dataDic in dataArray {
                                self.newsLists.append(NewsList(dataDic: dataDic))
                            }
                            self.searchTableView.reloadData()
                            self.searchTableView.footerEndRefreshing()
                        }else {//文章
                            if json["isMore"] as! Bool == true {
                                self.searchTableView.footerHidden = false
                            }else{
                                self.searchTableView.footerHidden = true
                            }
                            var dataArray = json["articleList"] as! [[String:AnyObject]]
                            for  dataDic in dataArray {
                                self.newsLists.append(NewsList(dataDic: dataDic))
                            }
                            self.searchTableView.reloadData()
                            self.searchTableView.footerEndRefreshing()
                        }
                        self.removeLoadingView()
                    },
                    failure:{ (reason) -> Void in
                        FLOG("失败原因:\(reason)")
                        self.removeLoadingView()
                })

            }

        }
    
    
    
    //loading
    func addLoadingView(){
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
