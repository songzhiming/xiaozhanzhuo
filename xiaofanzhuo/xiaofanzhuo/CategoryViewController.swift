//
//  CategoryViewController.swift
//  xiaofanzhuo
//
//  Created by 李亚坤 on 15/1/20.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var postListTableView: UITableView!
    var indexPage = 1
    var newsLists : [NewsList]!
    var titleImages : [TitleImage]!
    let newsCellIdentifier = "NewsCell"
    var titleAritcleHeadView : TitleAritcleHeadView!

    override func viewDidLoad() {
        super.viewDidLoad()
        newsLists = [NewsList]()
        titleImages = [TitleImage]()
        
        postListTableView.registerNib(UINib(nibName:"NewsTableViewCell", bundle:nil), forCellReuseIdentifier: newsCellIdentifier)
        postListTableView.delegate = self
        postListTableView.dataSource = self
        postListTableView.showsVerticalScrollIndicator = false
        postListTableView.separatorColor = UIColor.clearColor()
        
        titleAritcleHeadView = NSBundle.mainBundle().loadNibNamed("TitleAritcleHeadView", owner: self, options: nil)[0] as! TitleAritcleHeadView
        postListTableView.tableHeaderView = titleAritcleHeadView

        postListTableView.addHeaderWithTarget(self, action:"beginRefresh")
        postListTableView.addFooterWithTarget(self, action:"loadMore")
//        var footerView = UIView()
//        footerView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.height, 50)
//        postListTableView.tableFooterView = footerView
//        getTopicListFromWeb()
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.sharedImageCache().clearMemory()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.postListTableView.contentInset = UIEdgeInsetsMake(0, 0, (50/320)*UIScreen.mainScreen().bounds.width, 0);
    }
    
    func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clearColor()
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
//        
//        var articleDetailViewController = ArticleDetailViewController(nibName: "ArticleDetailViewController", bundle: nil)
//        FLOG(self.navigationController)
//        self.navigationController?.pushViewController(articleDetailViewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
}
// MARK: - 类方法

extension CategoryViewController {
    func getTopicListFromWeb(){
        HttpManager.postDatatoServer(.POST, BASE_URL + GET_ARTICLELIST, parameters: ["userId":ApplicationContext.getUserID()!,"begin":"0","limit":"10"])
            .responseJSON { (_, _, JSON, _) in
                FLOG(JSON)
                if let json = JSON as? [String:AnyObject] {
                    if (json["code"] as! Int) == 0 {
                        if json["isMore"] as! Bool == true {
                            self.postListTableView.footerHidden = false
                        }else{
                            self.postListTableView.footerHidden = true
                        }
                        var dataArray = json["articleList"] as! [[String:AnyObject]]
                        if dataArray.count == 0 {
                            return
                        }
                        
                        self.newsLists.removeAll(keepCapacity: false)
                        
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
                        self.postListTableView.reloadData()
                    }else{
                        //code !=0
                        var message  = json["message"] as! String
                        HYBProgressHUD.showError(message)
                        FLOG("服务器返回数据错误,code!=0")
                    }
                }else{
                    HYBProgressHUD.showError("网络连接错误！")
                    FLOG("网络连接错误！")
                }
        }
    }
    
    
    
    func getActivityListFromWeb(){
        FLOG("userId:::::\(ApplicationContext.getUserID()!)")
        HttpManager.postDatatoServer(.POST, BASE_URL + GET_ACTIVITYLIST, parameters: ["userId":ApplicationContext.getUserID()!,"begin":"0","limit":"10"])
            .responseJSON { (_, _, JSON, _) in
                FLOG(JSON)
                if let json = JSON as? [String:AnyObject] {
                    if (json["code"] as! Int) == 0 {
                        if json["isMore"] as! Bool == true {
                            self.postListTableView.footerHidden = false
                        }else{
                            self.postListTableView.footerHidden = true
                        }
                        var dataArray = json["activityList"] as! [[String:AnyObject]]
                        if dataArray.count == 0 {
                            return
                        }
                        self.newsLists.removeAll(keepCapacity: false)
                        for  dataDic in dataArray {
                            self.newsLists.append(NewsList(dataDic: dataDic))
                        }

                        if (json["activityTitleImages"]!.count != 0) {
                            var imageArray  = json["activityTitleImages"] as! [[String : AnyObject]]
                            self.titleImages.removeAll(keepCapacity: false)
                            for dataDic1 in imageArray {
                                self.titleImages.append(TitleImage(dataDic: dataDic1))
                                self.titleAritcleHeadView.loadImage(self.titleImages)
                            }
                        }
                        self.postListTableView.reloadData()
                    }else{
                        //code !=0
                        var message  = json["message"] as! String
                        HYBProgressHUD.showError(message)
                        FLOG("服务器返回数据错误,code!=0")
                    }
                }else{
                    HYBProgressHUD.showError("网络连接错误！")
                    FLOG("网络连接错误！")
                }
        }
    }
    
    
    //下拉刷新
    func beginRefresh(){
        FLOG("123\(indexPage)")
        if indexPage == 1{
            HttpManager.postDatatoServer(.POST, BASE_URL + GET_ARTICLELIST,parameters:
                ["userId": ApplicationContext.getUserID()!,
                    "begin":"0",
                    "limit":"10"
                ])
                .responseJSON { (_, _, JSON, _) in
                    FLOG("对对碰返回数据\(JSON)")
                    if let json = JSON as? [String:AnyObject] {
                        //FLOG("对对碰数据：\(JSON)")
                        if (json["code"] as! Int) == 0 {
                            //服务器数据返回成功
                            if json["isMore"] as! Bool == true {
                                self.postListTableView.footerHidden = false
                            }else{
                                self.postListTableView.footerHidden = true
                            }
                            var dataArray = json["articleList"] as! [[String:AnyObject]]
                            if dataArray.count == 0 {
                                self.postListTableView.headerEndRefreshing()
                                return
                            }
                            self.newsLists.removeAll(keepCapacity: true)
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
                            self.postListTableView.reloadData()
                            self.postListTableView.headerEndRefreshing()
                        }else{
                            //code !=0
                            self.postListTableView.headerEndRefreshing()
                            FLOG("服务器返回数据错误,code!=0")
                            var message  = json["message"] as! String
                            HYBProgressHUD.showError(message)
                        }
                    }else{
                        self.postListTableView.headerEndRefreshing()
                        HYBProgressHUD.showError("网络连接错误！")
                        FLOG("网络连接错误！")
                    }
            }

        }else{
            
            HttpManager.postDatatoServer(.POST, BASE_URL + GET_ACTIVITYLIST,parameters:
                ["userId": ApplicationContext.getUserID()!,
                    "begin":"0",
                    "limit":"10"
                ])
                .responseJSON { (_, _, JSON, _) in
                    FLOG("对对碰返回数据\(JSON)")
                    if let json = JSON as? [String:AnyObject] {
                        //FLOG("对对碰数据：\(JSON)")
                        if (json["code"] as! Int) == 0 {
                            //服务器数据返回成功
                            if json["isMore"] as! Bool == true {
                                self.postListTableView.footerHidden = false
                            }else{
                                self.postListTableView.footerHidden = true
                            }
                            var dataArray = json["activityList"] as! [[String:AnyObject]]
                            if dataArray.count == 0 {
                                self.postListTableView.headerEndRefreshing()
                                return
                            }
                            self.newsLists.removeAll(keepCapacity: true)
                            for  dataDic in dataArray {
                                self.newsLists.append(NewsList(dataDic: dataDic))
                            }
                            if (json["activityTitleImages"] != nil) {
                                var imageArray  = json["activityTitleImages"] as! [[String : AnyObject]]
                                
                                println(imageArray)
                                self.titleImages.removeAll(keepCapacity: false)
                                for dataDic1 in imageArray {
                                    self.titleImages.append(TitleImage(dataDic: dataDic1))
                                }
                                println("aaaaaaaaa\(self.titleImages)")
                                self.titleAritcleHeadView.loadImage(self.titleImages)
                            }
                            self.postListTableView.reloadData()
                            self.postListTableView.headerEndRefreshing()
                        }else{
                            //code !=0
                            self.postListTableView.headerEndRefreshing()
                            var message  = json["message"] as! String
                            HYBProgressHUD.showError(message)
                            FLOG("服务器返回数据错误,code!=0")
                        }
                    }else{
                        self.postListTableView.headerEndRefreshing()
                        HYBProgressHUD.showError("网络连接错误！")
                        FLOG("网络连接错误！")
                    }
            }

            
        }
    }
    //加载更多
    func loadMore(){
        if indexPage == 1 {
            var begin = NSString(format: "%d", self.newsLists!.count)
            FLOG("begin::::\(begin)")
            
            HttpManager.postDatatoServer(.POST, BASE_URL + GET_ARTICLELIST,parameters:
                ["userId": ApplicationContext.getUserID()!,
                    "begin":begin,
                    "limit":"10"
                ])
                .responseJSON { (_, _, JSON, _) in
                    FLOG("对对碰返回数据\(JSON)")
                    if let json = JSON as? [String:AnyObject] {
                        //FLOG("对对碰数据：\(JSON)")
                        if (json["code"] as! Int) == 0 {
                            //服务器数据返回成功
                            if json["isMore"] as! Bool == true {
                                self.postListTableView.footerHidden = false
                            }else{
                                self.postListTableView.footerHidden = true
                            }
                            var dataArray = json["articleList"] as! [[String:AnyObject]]
                            if dataArray.count == 0 {
                                return
                            }
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
                            self.postListTableView.reloadData()
                            self.postListTableView.footerEndRefreshing()
                        }else{
                            //code !=0
                            FLOG("服务器返回数据错误,code!=0")
                            var message  = json["message"] as! String
                            HYBProgressHUD.showError(message)
                        }
                    }else{
                        HYBProgressHUD.showError("网络连接错误！")
                        FLOG("网络连接错误！")
                    }
            }

        }else {
            var begin = NSString(format: "%d", self.newsLists!.count)
            FLOG("begin::::\(begin)")
            HttpManager.postDatatoServer(.POST, BASE_URL + GET_ACTIVITYLIST,parameters:
                ["userId": ApplicationContext.getUserID()!,
                    "begin":begin,
                    "limit":"10"
                ])
                .responseJSON { (_, _, JSON, _) in
                    FLOG("对对碰返回数据\(JSON)")
                    if let json = JSON as? [String:AnyObject] {
                        //FLOG("对对碰数据：\(JSON)")
                        if (json["code"] as! Int) == 0 {
                            //服务器数据返回成功
                            if json["isMore"] as! Bool == true {
                                self.postListTableView.footerHidden = false
                            }else{
                                self.postListTableView.footerHidden = true
                            }
                            var dataArray = json["activityList"] as! [[String:AnyObject]]
                            if dataArray.count == 0 {
                                return
                            }
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
                            self.postListTableView.reloadData()
                            self.postListTableView.footerEndRefreshing()
                        }else{
                            //code !=0
                            var message  = json["message"] as! String
                            HYBProgressHUD.showError(message)
                            FLOG("服务器返回数据错误,code!=0")
                        }
                    }else{
                        HYBProgressHUD.showError("网络连接错误！")
                        FLOG("网络连接错误！")
                    }
            }

        }
    }
    
    
    
    func setTheIndexPage(index:Int){
        indexPage = index
    }

}

