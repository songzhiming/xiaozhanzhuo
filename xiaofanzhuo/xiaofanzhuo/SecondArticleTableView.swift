//
//  SecondArticleTableView.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-3-6.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SecondArticleTableView: UITableView,UITableViewDataSource,UITableViewDelegate {


    var titleAritcleHeadView : TitleAritcleHeadView!
    let newsCellIdentifier = "NewsCell"
    var newsLists : [NewsList]!
    var titleImages : [TitleImage]!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        newsLists = [NewsList]()
        titleImages = [TitleImage]()
        self.delegate = self
        self.dataSource = self
//        self.separatorColor = UIColor.clearColor()
        self.separatorStyle = UITableViewCellSeparatorStyle.None
        self.registerNib(UINib(nibName:"NewsTableViewCell", bundle:nil), forCellReuseIdentifier: newsCellIdentifier)
        self.tableFooterView = UIView()
        self.addRefreshController()
        self.addTabelViewHeader()
        self.backgroundColor = UIColor.clearColor()//UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        self.contentInset = UIEdgeInsetsMake(36, 0, (50/320)*UIScreen.mainScreen().bounds.width, 0);
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //添加刷新
    func addRefreshController(){
        self.addHeaderWithTarget(self, action:"beginRefresh")
        self.addFooterWithTarget(self, action:"loadMore")
    }
    
    //自定义UItableView的header
    func addTabelViewHeader(){
        titleAritcleHeadView = NSBundle.mainBundle().loadNibNamed("TitleAritcleHeadView", owner: self, options: nil)[0] as! TitleAritcleHeadView
        titleAritcleHeadView.backgroundColor = UIColor.clearColor()
//        self.tableHeaderView = titleAritcleHeadView
    }
    
    //  table
    // MARK: - TableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (newsLists != nil) {
            return newsLists.count
        }else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 62
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: NewsTableViewCell = tableView.dequeueReusableCellWithIdentifier(newsCellIdentifier) as! NewsTableViewCell
        cell.loadData(newsLists[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView,didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }

    //MARK:-网络请求
    func getTopicListFromWeb(){
        HttpManager.sendHttpRequestPost(GET_ARTICLELIST, parameters:
            ["userId":ApplicationContext.getUserID()!,"begin":"0","limit":"10"],
            success: { (json) -> Void in
                
                var vc = CommonTool.findNearsetViewController(self) as! RefactorArticleViewController
                if vc.currentIndex == 0 {
                    vc.failView.hidden = true
                }
                self.tableHeaderView = self.titleAritcleHeadView
                
                FLOG("获取文章列表返回json:\(json)")
                if json["isMore"] as! Bool == true {
                    self.footerHidden = false
                }else{
                    self.footerHidden = true
                }
                var dataArray = json["articleList"] as! [[String:AnyObject]]
                
                self.newsLists.removeAll(keepCapacity: false)
                
                for  dataDic in dataArray {
                    self.newsLists.append(NewsList(dataDic: dataDic))
                }
                
                if (json["articleTitleImages"] != nil) {
                    var imageArray  = json["articleTitleImages"] as! [[String : AnyObject]]
                    self.titleImages.removeAll(keepCapacity: false)
                    for dataDic1 in imageArray {
                        self.titleImages.append(TitleImage(dataDic: dataDic1))
                        
                    }
                    self.titleAritcleHeadView.loadImage(self.titleImages)
                }
                if self.newsLists.count == 0 && self.titleImages.count == 0 && vc.currentIndex == 0{
                    
                    vc.failView.hidden = false
                    vc.failLabel.text = LOAD_EMPTY
                    self.tableHeaderView = nil
                }
                
                self.headerEndRefreshing()
                self.reloadData()
                
            },
            failure:{ (reason) -> Void in
                var vc = CommonTool.findNearsetViewController(self) as! RefactorArticleViewController
                if self.newsLists.count == 0 && self.titleImages.count == 0 && vc.currentIndex == 0{
                    
                    vc.failView.hidden = false
                    vc.failLabel.text = LOAD_FAILED
                    self.tableHeaderView = nil
                }
                self.headerEndRefreshing()
                FLOG("失败原因:\(reason)")
        })
    }
    
    
    
    func getActivityListFromWeb(){

        HttpManager.sendHttpRequestPost(GET_ACTIVITYLIST, parameters: ["userId":ApplicationContext.getUserID()!,"begin":"0","limit":"10"],
            success: { (json) -> Void in
                
                var vc = CommonTool.findNearsetViewController(self) as! RefactorArticleViewController
                if vc.currentIndex == 1 {
                    vc.failView.hidden = true
                }
                self.tableHeaderView = self.titleAritcleHeadView
                
                FLOG("获取活动列表返回json:\(json)")
                if json["isMore"] as! Bool == true {
                    self.footerHidden = false
                }else{
                    self.footerHidden = true
                }
                var dataArray = json["activityList"] as! [[String:AnyObject]]
                self.newsLists.removeAll(keepCapacity: false)
                for  dataDic in dataArray {
                    self.newsLists.append(NewsList(dataDic: dataDic))
                }
                
                if (json["activityTitleImages"]!.count != 0) {
                    var imageArray  = json["activityTitleImages"] as! [[String : AnyObject]]
                    self.titleImages.removeAll(keepCapacity: false)
                    for dataDic1 in imageArray {
                        self.titleImages.append(TitleImage(dataDic: dataDic1))
                    }
                    self.titleAritcleHeadView.loadImage(self.titleImages)
                }
                
                if self.newsLists.count == 0 && self.titleImages.count == 0 && vc.currentIndex == 1{
                    
                    vc.failView.hidden = false
                    vc.failLabel.text = LOAD_EMPTY
                    self.tableHeaderView = nil
                }
                self.headerEndRefreshing()
                self.reloadData()
            },
            failure:{ (reason) -> Void in
                
                var vc = CommonTool.findNearsetViewController(self) as! RefactorArticleViewController
                if self.newsLists.count == 0 && self.titleImages.count == 0 && vc.currentIndex == 1{
                    
                    vc.failView.hidden = false
                    vc.failLabel.text = LOAD_FAILED
                    self.tableHeaderView = nil
                }
                
                self.headerEndRefreshing()
                FLOG("失败原因:\(reason)")
        })
    }
    
    
    //下拉刷新
    func beginRefresh(){
        var index = (CommonTool.findNearsetViewController(self.superview) as! RefactorArticleViewController).currentIndex
        println(index)
        if index == 0{
            getTopicListFromWeb()
        }else{
            getActivityListFromWeb()
        }
    }
    //加载更多
    func loadMore(){
        var indexPage = 1
        var index = (CommonTool.findNearsetViewController(self.superview) as! RefactorArticleViewController).currentIndex
        if index == 0 {
            var begin = NSString(format: "%d", self.newsLists!.count)
            FLOG("begin::::\(begin)")
            
            HttpManager.sendHttpRequestPost(GET_ARTICLELIST, parameters:
                ["userId": ApplicationContext.getUserID()!,
                "begin":begin,
                "limit":"10"
                ],
                success: { (json) -> Void in
                    
                    FLOG("加载更多文章列表返回json:\(json)")
                    if json["isMore"] as! Bool == true {
                        self.footerHidden = false
                    }else{
                        self.footerHidden = true
                    }
                    var dataArray = json["articleList"] as! [[String:AnyObject]]
                    for  dataDic in dataArray {
                        self.newsLists.append(NewsList(dataDic: dataDic))
                    }
                    if (json["articleTitleImages"] != nil) {
                        var imageArray  = json["activityTitleImages"] as! [[String : AnyObject]]
                        self.titleImages.removeAll(keepCapacity: false)
                        for dataDic1 in imageArray {
                            self.titleImages.append(TitleImage(dataDic: dataDic1))
                            self.titleAritcleHeadView.loadImage(self.titleImages)
                        }
                    }
                    self.reloadData()
                    self.footerEndRefreshing()
                    
                },
                failure:{ (reason) -> Void in
                    FLOG("失败原因:\(reason)")
                    self.footerEndRefreshing()
            })
            
        }else {
            var begin = NSString(format: "%d", self.newsLists!.count)

            HttpManager.sendHttpRequestPost(GET_ACTIVITYLIST, parameters:
                ["userId": ApplicationContext.getUserID()!,
                    "begin":begin,
                    "limit":"10"
                ],
                success: { (json) -> Void in
                    
                    FLOG("加载更多活动列表返回json:\(json)")
                    //服务器数据返回成功
                    if json["isMore"] as! Bool == true {
                        self.footerHidden = false
                    }else{
                        self.footerHidden = true
                    }
                    var dataArray = json["activityList"] as! [[String:AnyObject]]
                    for  dataDic in dataArray {
                        self.newsLists.append(NewsList(dataDic: dataDic))
                    }
                    if (json["articleTitleImages"] != nil) {
                        var imageArray  = json["articleTitleImages"] as! [[String : AnyObject]]
                        self.titleImages.removeAll(keepCapacity: false)
                        for dataDic1 in imageArray {
                            self.titleImages.append(TitleImage(dataDic: dataDic1))
                            self.titleAritcleHeadView.loadImage(self.titleImages)
                        }
                    }
                    self.reloadData()
                    self.footerEndRefreshing()
                    
                },
                failure:{ (reason) -> Void in
                    self.footerEndRefreshing()
                    FLOG("失败原因:\(reason)")
            })
        }
    }


}
