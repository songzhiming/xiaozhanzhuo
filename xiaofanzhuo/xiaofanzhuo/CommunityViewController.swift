//
//  CommunityViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-15.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class CommunityViewController: BasicViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failLabel: UILabel!
    
    var topicList : [CommunityTopic]!
    var stickTopic : CommunityTopic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headView.hidden = true
        self.extraView.hidden = false
        self.extraView.image.image = UIImage(named: "add_community_topic")!
        //变量初始化
        topicList = [CommunityTopic]()
        stickTopic = CommunityTopic()
        
        tableView.registerNib(UINib(nibName: "CommunityTableViewCell", bundle: nil), forCellReuseIdentifier: CommunityTableViewCell.cellID)
        tableView.registerNib(UINib(nibName: "TopTopicTableViewCell", bundle: nil), forCellReuseIdentifier: TopTopicTableViewCell.cellID)
        
        tableView.tableFooterView = UIView()
        tableView.addHeaderWithTarget(self, action:"getTopicListFromWeb")
        tableView.addFooterWithTarget(self, action:"loadMore")
        //tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 0, (50/320)*UIScreen.mainScreen().bounds.width))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshCommunity", name: "refreshCommunity", object: nil)
        
        getTopicListFromWeb()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, (50/320)*UIScreen.mainScreen().bounds.width, 0);
    }
}


// MARK: - UITableViewDataSource
extension CommunityViewController : UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        switch section {
        case 0:
            if let id = stickTopic.id { //检查id是否为空，如果没有就不让显示
                return 1
            }else{
                return 0
            }
        case 1:
            return topicList.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        switch indexPath.section {
        case 0 :
            var cell = self.tableView.dequeueReusableCellWithIdentifier(TopTopicTableViewCell.cellID) as! TopTopicTableViewCell
            cell.loadData(stickTopic)
            return cell
        case 1:
            let cell = self.tableView.dequeueReusableCellWithIdentifier(CommunityTableViewCell.cellID) as! CommunityTableViewCell
            cell.loadData(topicList[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 2
    }
}

// MARK: - UITableViewDelegate
extension CommunityViewController : UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        for i in self.view.superview!.subviews{
            if (i as! UIView).tag == 201 {
                (i as! UIView).removeFromSuperview()
            }
        }
        switch indexPath.section {
        case 0 :
            var topicDetailViewController = TopicDetailViewController(nibName: "TopicDetailViewController", bundle: nil,param: stickTopic.id)
            self.navigationController?.pushViewController(topicDetailViewController, animated: true)
        case 1:
            var topicDetailViewController = TopicDetailViewController(nibName: "TopicDetailViewController", bundle: nil,param: topicList[indexPath.row].id)
            FLOG("asdfasdf:::::::\(topicList[indexPath.row].id)")
            self.navigationController?.pushViewController(topicDetailViewController, animated: true)
        default:
            return
        }
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        switch indexPath.section {
        case 0:
            return TopTopicTableViewCell.cellHeight
        case 1:
            var customCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as? CommunityTableViewCell
            if let cell = customCell {
                return cell.getDynamicCellHeight()
            }
            return 0
//            return CommunityTableViewCell.cellHeight
        default:
            return 0
        }
    }
}

// MARK: - 类方法
extension CommunityViewController {
    
    func refreshCommunity(){
        getTopicListFromWeb()
    }
    func getTopicListFromWeb(){
        HttpManager.sendHttpRequestPost(GET_TOPICLIST, parameters: ["userId":ApplicationContext.getUserID()!,"begin":"0","limit":"10"],
            success: { (json) -> Void in
                
                FLOG("社区首页返回json:\(json)")
                self.failView.hidden = true
                self.topicList.removeAll(keepCapacity: true)
                var dataArray = json["topicList"] as! [[String:AnyObject]]
                self.stickTopic = CommunityTopic(dataDic: json["stickTopic"] as! [String:AnyObject])
                
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
                if self.topicList.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_EMPTY
                }
                self.tableView.reloadData()
                self.tableView.headerEndRefreshing()
                
            },
            failure:{ (reason) -> Void in
                self.tableView.headerEndRefreshing()
                if self.topicList.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_FAILED
                }
                FLOG("失败原因:\(reason)")
        })
    }
    
    //上拉加载更多
    func loadMore(){
        var begin = self.topicList.count
        
        HttpManager.sendHttpRequestPost(GET_TOPICLIST, parameters: ["userId":ApplicationContext.getUserID()!,"begin":begin,"limit":"5"],
            success: { (json) -> Void in
                
                FLOG("鸡汤json:\(json)")
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
                self.tableView.footerEndRefreshing()
                FLOG("失败原因:\(reason)")
        })
    }
}

//MARK:-overrides
extension CommunityViewController {
    override func extraViewClick() {
        var vc = SendNewTopicViewController(nibName: "BasePublishViewController", bundle: nil,param: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

