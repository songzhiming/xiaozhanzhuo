//
//  LabelArticleViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-3-12.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class LabelArticleViewController: BasicViewController {

    var newsLists : [NewsList] = [NewsList]()
    let newsCellIdentifier = "NewsCell"
    var labelId : String = String()
    var index : String = String()
    @IBOutlet weak var labelArticleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.recommendButton.hidden = true
        headView.backButton.hidden = false
        headView.logoImage.hidden = true
        headView.titleLabel.hidden = false
        headView.searchButton.hidden = true
        self.headView.titleLabel.text = "标签列表"
        
        
        println("1234::\(param)")
        
        var pa = param as! [String : AnyObject]
        index = pa["index"] as! String
        labelId = pa["labelId"] as! String
        labelArticleTableView.registerNib(UINib(nibName:"NewsTableViewCell", bundle:nil), forCellReuseIdentifier: newsCellIdentifier)
        labelArticleTableView.separatorColor = UIColor.clearColor()
        labelArticleTableView.addHeaderWithTarget(self, action:"beginRefresh")
        labelArticleTableView.addFooterWithTarget(self, action:"loadMore")
        println(index)
        println(labelId)
        if index == "0" {
            self.getTopicListFromWeb()
        }else{
            self.getActivityListFromWeb()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - TableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return newsLists.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 61
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: NewsTableViewCell = tableView.dequeueReusableCellWithIdentifier(newsCellIdentifier) as! NewsTableViewCell
        cell.loadData(newsLists[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView,didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
    
    
    
    
    
    //获取文章标签列表网络请求
    func getTopicListFromWeb(){
        HttpManager.sendHttpRequestPost(GETARTICLELIST_BYLABELLED, parameters:
            ["userId":ApplicationContext.getUserID()!,
                "begin":"0",
                "limit":"10",
                "labelId":labelId,
                "type":"article"],
            success: { (json) -> Void in
                
                FLOG("文章标签列表返回数据json:\(json)")
                if json["isMore"] as! Bool == true {
                    self.labelArticleTableView.footerHidden = false
                }else{
                    self.labelArticleTableView.footerHidden = true
                }
                var dataArray = json["articleList"] as! [[String:AnyObject]]
                if dataArray.count == 0 {
                    return
                }
                self.newsLists.removeAll(keepCapacity: false)
                for  dataDic in dataArray {
                    self.newsLists.append(NewsList(dataDic: dataDic))
                }
                self.headView.titleLabel.text = json["labelName"] as? String
                self.labelArticleTableView.reloadData()
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
    
    
    //获取活动标签列表网络请求
    func getActivityListFromWeb(){
        FLOG("userId:::::\(ApplicationContext.getUserID()!)")
        HttpManager.sendHttpRequestPost(GETACTIVITYLIST_BYLABELLED, parameters:
            [
                "userId":ApplicationContext.getUserID()!,
                "begin":"0",
                "limit":"10",
                "labelId":labelId,
                "type":"activity"],
            success: { (json) -> Void in
                
                FLOG("标签活动列表json:\(json)")
                if json["isMore"] as! Bool == true {
                    self.labelArticleTableView.footerHidden = false
                }else{
                    self.labelArticleTableView.footerHidden = true
                }
                var dataArray = json["activityList"] as! [[String:AnyObject]]
                if dataArray.count == 0 {
                    return
                }
                self.newsLists.removeAll(keepCapacity: false)
                for  dataDic in dataArray {
                    self.newsLists.append(NewsList(dataDic: dataDic))
                }
                self.headView.titleLabel.text = json["labelName"] as? String
                self.labelArticleTableView.reloadData()
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })

    }

    
    
    
    //下拉刷新
    func beginRefresh(){
        if self.index == "0" {
            HttpManager.sendHttpRequestPost(GETARTICLELIST_BYLABELLED, parameters:
                ["userId": ApplicationContext.getUserID()!,
                "begin":"0",
                "limit":"10",
                "labelId":labelId,
                "type":"article"
                ],
                success: { (json) -> Void in
                    
                    FLOG("标签文章json:\(json)")
                    //服务器数据返回成功
                    if json["isMore"] as! Bool == true {
                        self.labelArticleTableView.footerHidden = false
                    }else{
                        self.labelArticleTableView.footerHidden = true
                    }
                    var dataArray = json["articleList"] as! [[String:AnyObject]]
                    if dataArray.count == 0 {
                        self.labelArticleTableView.headerEndRefreshing()
                        return
                    }
                    self.newsLists.removeAll(keepCapacity: true)
                    for  dataDic in dataArray {
                        self.newsLists.append(NewsList(dataDic: dataDic))
                    }
                    self.labelArticleTableView.reloadData()
                    self.labelArticleTableView.headerEndRefreshing()
                    
                },
                failure:{ (reason) -> Void in
                    self.labelArticleTableView.headerEndRefreshing()
                    FLOG("失败原因:\(reason)")
            })

            
        }else{
            HttpManager.sendHttpRequestPost(GETACTIVITYLIST_BYLABELLED, parameters:
                ["userId": ApplicationContext.getUserID()!,
                    "begin":"0",
                    "limit":"10",
                    "labelId":labelId,
                    "type":"activity"
                ],
                success: { (json) -> Void in
                    
                    FLOG("下拉标签活动json:\(json)")
                    //服务器数据返回成功
                    if json["isMore"] as! Bool == true {
                        self.labelArticleTableView.footerHidden = false
                    }else{
                        self.labelArticleTableView.footerHidden = true
                    }
                    var dataArray = json["activityList"] as! [[String:AnyObject]]
                    if dataArray.count == 0 {
                        self.labelArticleTableView.headerEndRefreshing()
                        return
                    }
                    self.newsLists.removeAll(keepCapacity: true)
                    for  dataDic in dataArray {
                        self.newsLists.append(NewsList(dataDic: dataDic))
                    }
                    self.labelArticleTableView.reloadData()
                    self.labelArticleTableView.headerEndRefreshing()
                    
                },
                failure:{ (reason) -> Void in
                    FLOG("失败原因:\(reason)")
                    self.labelArticleTableView.headerEndRefreshing()
            })
        }
    }
    //加载更多
    func loadMore(){
        if self.index == "0" {
            var begin = NSString(format: "%d", self.newsLists.count)
            FLOG("begin::::\(begin)")
            
            HttpManager.sendHttpRequestPost(GETARTICLELIST_BYLABELLED, parameters:
                ["userId": ApplicationContext.getUserID()!,
                    "begin":begin,
                    "limit":"10",
                    "labelId":labelId,
                    "type":"activity"
                ],
                success: { (json) -> Void in
                    
                    FLOG("上拉标签文章列表json:\(json)")
                    //服务器数据返回成功
                    if json["isMore"] as! Bool == true {
                        self.labelArticleTableView.footerHidden = false
                    }else{
                        self.labelArticleTableView.footerHidden = true
                    }
                    var dataArray = json["articleList"] as! [[String:AnyObject]]
                    if dataArray.count == 0 {
                        return
                    }
                    for  dataDic in dataArray {
                        self.newsLists.append(NewsList(dataDic: dataDic))
                    }
                    self.labelArticleTableView.reloadData()
                    self.labelArticleTableView.footerEndRefreshing()
                    
                },
                failure:{ (reason) -> Void in
                    FLOG("失败原因:\(reason)")
                    self.labelArticleTableView.footerEndRefreshing()
            })
            
        }else {
            var begin = NSString(format: "%d", self.newsLists.count)
            FLOG("begin::::\(begin)")
            HttpManager.sendHttpRequestPost(GETACTIVITYLIST_BYLABELLED, parameters:
                ["userId": ApplicationContext.getUserID()!,
                    "begin":begin,
                    "limit":"10",
                    "labelId":labelId,
                    "type":"activity"
                ],
                success: { (json) -> Void in
                    
                    FLOG("下拉标签活动列表json:\(json)")
                    //服务器数据返回成功
                    if json["isMore"] as! Bool == true {
                        self.labelArticleTableView.footerHidden = false
                    }else{
                        self.labelArticleTableView.footerHidden = true
                    }
                    var dataArray = json["activityList"] as! [[String:AnyObject]]
                    if dataArray.count == 0 {
                        return
                    }
                    for  dataDic in dataArray {
                        self.newsLists.append(NewsList(dataDic: dataDic))
                    }
                    self.labelArticleTableView.reloadData()
                    self.labelArticleTableView.footerEndRefreshing()
                    
                },
                failure:{ (reason) -> Void in
                    FLOG("失败原因:\(reason)")
                    self.labelArticleTableView.footerEndRefreshing()
            })
        }
    }
}
