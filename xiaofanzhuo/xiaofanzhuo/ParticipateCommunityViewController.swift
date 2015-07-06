//
//  ParticipateCommunityViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/28.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class ParticipateCommunityViewController: BasicViewController {

    @IBOutlet weak var tableView: UITableView!
    var topicList : [CommunityTopic]!
    
    let communityCellID = "CommunityTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.changeLeftButton()
        headView.logoImage.hidden = true
        if let pa = param as? String {//他人
            headView.titleLabel.text = "他参与的话题"
        }else{
            headView.titleLabel.text = "我参与的话题"
        }
        headView.searchButton.hidden = true
        headView.generateCodeButton.hidden = true
        // Do any additional setup after loading the view.
        
        topicList = [CommunityTopic]()
        
        tableView.registerNib(UINib(nibName: "CommunityTableViewCell", bundle: nil), forCellReuseIdentifier: communityCellID)
        tableView.tableFooterView = UIView()
        tableView.addFooterWithTarget(self, action:"loadMore")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getTopicListFromWeb()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, (50/320)*UIScreen.mainScreen().bounds.width, 0);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDataSource
extension ParticipateCommunityViewController : UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return topicList.count
 
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = self.tableView.dequeueReusableCellWithIdentifier(communityCellID) as! CommunityTableViewCell
        cell.loadData(topicList[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ParticipateCommunityViewController : UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        println(topicList[indexPath.row].id)
        var topicDetailViewController = TopicDetailViewController(nibName: "TopicDetailViewController", bundle: nil,param: topicList[indexPath.row].id)
        
        self.navigationController?.pushViewController(topicDetailViewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return CommunityTableViewCell.cellHeight
    }
}

// MARK: - 类方法
extension ParticipateCommunityViewController {
    func getTopicListFromWeb(){
        var userId : String
        if let pa = param as? String {//他人
            userId = param as! String
        }else{
            userId = ApplicationContext.getUserID()!
        }
        HttpManager.postDatatoServer(.POST, BASE_URL + TOPIC_REPLYED, parameters: ["userId":userId,"type":"help","begin":"0","limit":"10"])
            .responseJSON { (_, _, JSON, _) in
                println("我参与的社区返回json：\(JSON)")
                if let json = JSON as? [String:AnyObject] {
                    if (json["code"] as! Int) == 0 {
                        self.topicList.removeAll(keepCapacity: true)
                        var dataArray = json["topicList"] as! [[String:AnyObject]]
                        
                        for  dataDic in dataArray {
                            self.topicList.append(CommunityTopic(dataDic: dataDic))
                        }
                        if let isMore = json["isMore"] as? Bool {
                            if isMore == false {
                                self.tableView.footerHidden = true
                            }else{
                                self.tableView.footerHidden = false
                            }
                        }
                        
                        self.tableView.reloadData()
                        self.tableView.headerEndRefreshing()
                    }else{
                        //code !=0
                        FLOG("服务器返回数据错误,code!=0")
                        HYBProgressHUD.showError(json["message"] as! String)
                        self.tableView.headerEndRefreshing()
                    }
                }else{
                    FLOG("网络连接错误！")
                    HYBProgressHUD.showError("网络连接错误")
                    self.tableView.headerEndRefreshing()
                }
        }
    }
    
    //上拉加载更多
    func loadMore(){
        var begin = self.topicList.count
        var userId : String
        if let pa = param as? String {//他人
            userId = param as! String
        }else{
            userId = ApplicationContext.getUserID()!
        }
        HttpManager.postDatatoServer(.POST, BASE_URL + TOPIC_REPLYED, parameters: ["userId":userId,"begin":begin,"limit":"5"])
            .responseJSON { (_, _, JSON, _) in
                println("社区首页返回json：\(JSON)")
                if let json = JSON as? [String:AnyObject] {
                    if (json["code"] as! Int) == 0 {
                        
                        var dataArray = json["topicList"] as! [[String:AnyObject]]
                        
                        for  dataDic in dataArray {
                            self.topicList.append(CommunityTopic(dataDic: dataDic))
                        }
                        if let isMore = json["isMore"] as? Bool {
                            if isMore == false {
                                self.tableView.footerHidden = true
                            }else{
                                self.tableView.footerHidden = false
                            }
                        }
                        
                        self.tableView.reloadData()
                        self.tableView.footerEndRefreshing()
                    }else{
                        //code !=0
                        FLOG("服务器返回数据错误,code!=0")
                        HYBProgressHUD.showError(json["message"] as! String)
                        self.tableView.headerEndRefreshing()
                    }
                }else{
                    FLOG("网络连接错误！")
                    HYBProgressHUD.showError("网络连接错误")
                    self.tableView.headerEndRefreshing()
                }
        }
    }
}
