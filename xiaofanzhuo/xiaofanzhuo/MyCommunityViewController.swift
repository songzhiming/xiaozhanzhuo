//
//  MyCommunityViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/28.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class MyCommunityViewController: BasicViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failLabel: UILabel!
    
    var topicList : [CommunityTopic]!
    var isInit : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headView.changeLeftButton()
        headView.logoImage.hidden = true
        if let pa = param as? String {//他人
            headView.titleLabel.text = "他发起的话题"
        }else{
            headView.titleLabel.text = "我发起的话题"
        }
        headView.searchButton.hidden = true
        headView.generateCodeButton.hidden = true
        // Do any additional setup after loading the view.
        topicList = [CommunityTopic]()
        tableView.tableFooterView = UIView()
        tableView.registerNib(UINib(nibName: "MyCommunityTableViewCell", bundle: nil), forCellReuseIdentifier: MyCommunityTableViewCell.cellID)
        
        tableView.addFooterWithTarget(self, action:"loadMore")
        getTopicListFromWeb()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !isInit {
            tableView.contentInset = UIEdgeInsetsZero
            isInit = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDataSource
extension MyCommunityViewController : UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return topicList.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = self.tableView.dequeueReusableCellWithIdentifier(MyCommunityTableViewCell.cellID) as! MyCommunityTableViewCell
        cell.loadData(topicList[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyCommunityViewController : UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        println(topicList[indexPath.row].id)
        var topicDetailViewController = TopicDetailViewController(nibName: "TopicDetailViewController", bundle: nil,param: topicList[indexPath.row].id)
        
        self.navigationController?.pushViewController(topicDetailViewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return MyCommunityTableViewCell.cellHeight
    }
}

// MARK: - 类方法
extension MyCommunityViewController {
    func getTopicListFromWeb(){
        var userId : String
        if let pa = param as? String {//他人
            userId = param as! String
        }else{
            userId = ApplicationContext.getUserID()!
        }
        HttpManager.sendHttpRequestPost(TOPIC_PUBLISHED, parameters: ["userId":userId,"type":"publish","begin":"0","limit":"10"],
            success: { (json) -> Void in
                
                FLOG("参与的社区json:\(json)")
                self.failView.hidden = true
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
                
                if self.topicList.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_EMPTY
                }
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
                if self.topicList.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_FAILED_NO_REFRESH
                }
                self.tableView.headerEndRefreshing()
        })
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
        HttpManager.sendHttpRequestPost(TOPIC_PUBLISHED, parameters: ["userId":userId,"begin":begin,"limit":"5"],
            success: { (json) -> Void in
                
                FLOG("我的话题json:\(json)")
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
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
                self.tableView.headerEndRefreshing()
        })

    }
}
