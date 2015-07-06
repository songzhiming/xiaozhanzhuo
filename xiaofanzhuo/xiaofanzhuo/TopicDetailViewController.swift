//
//  TopicDetailViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/19.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class TopicDetailViewController: BasicViewController {
    
    @IBOutlet weak var tableView: UITableView!

    let commentCellID = "TopicCommentCell"
    var topicInfo : TopicInfo! //话题详情数据源
    var header : TopicDetailHeader!
    var isInit : Bool = false
    var isCollected = false
    
    var selectedImageName:[String] = [String]()   //图片name数组
    var selectedImageArray:[String] = [String]()  //图片url数组
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.changeTitle("话题详情")
        headView.changeLeftButton()
        headView.hideRightButton(true)
        headView.logoImage.hidden = true
        
        
        //显示大的蓝色按钮
        self.extraView.hidden = false
        self.extraView.image.image = UIImage(named: "add_community_reply")!

//        self.automaticallyAdjustsScrollViewInsets = false
        
        //初始化变量
        topicInfo = TopicInfo()
        
        tableView.registerNib(UINib(nibName: "TopicCommentCell", bundle: nil), forCellReuseIdentifier: commentCellID)
        header =  NSBundle.mainBundle().loadNibNamed("TopicDetailHeader", owner: self, options: nil)[0] as! TopicDetailHeader
        //header.frame =  CGRectMake(0,0, UIScreen.mainScreen().bounds.width, 190)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "replyToTopic", name: "replyToTopic", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTopicDetail", name: "refreshTopicDetail", object: nil)
//        tableView.addSubview(header)
        tableView.tableFooterView = UIView()

        tableView.addHeaderWithTarget(self, action:"getTopicListFromWeb")
        tableView.addFooterWithTarget(self, action:"loadMore")
        getTopicListFromWeb()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setExtraView_B_R(15,right:15)
        if !isInit {
            tableView.contentInset = UIEdgeInsetsZero
            isInit = true
        }
    }
}

//MARK: -按钮点击
extension TopicDetailViewController{

}

// MARK: - UITableViewDataSource
extension TopicDetailViewController : UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return topicInfo.replyList!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = self.tableView.dequeueReusableCellWithIdentifier(commentCellID) as! TopicCommentCell
       // FLOG(topicInfo.replyList![indexPath.row])
        cell.loadData(topicInfo.replyList![indexPath.row])
        return cell
    }
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
//        return 1
//    }
}

// MARK: - UITableViewDelegate
extension TopicDetailViewController : UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var personCommentViewController = PersonCommentViewController(nibName: "PersonCommentViewController", bundle: nil,param:topicInfo.replyList![indexPath.row].replyId)
        self.navigationController?.pushViewController(personCommentViewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var topicCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as? TopicCommentCell
        if let cell = topicCell {
            return cell.getCellDynamicHeight()
        }
        return 0
    }
}

// MARK: - 类方法
extension TopicDetailViewController {
    func getTopicListFromWeb(){
        var param : [String:AnyObject] = ["id":self.param as! String,
            "userId":ApplicationContext.getUserID()!,
            "begin":"0",
            "limit":"10"]
        FLOG("话题详情参数：\(param)")
        HttpManager.sendHttpRequestPost(GET_TOPICINFO, parameters: param,
            success: { (json) -> Void in
                
                FLOG("话题详情json:\(json)")
                self.topicInfo = TopicInfo(dataDic: json)
                self.topicInfo.id = self.param as? String
                //self.topicInfo.count = String(self.topicInfo.replyList!.count)
                self.tableView.tableHeaderView = self.header//.addSubview(self.header)
                self.header.loadData(self.topicInfo)
                self.headView.topicReplyButton.hidden = self.topicInfo.isMy!//收藏按钮，懒得去该名字了
                self.isCollected = self.topicInfo.isCollected!
                if let isMore = json["isMore"] as? Bool {
                    if isMore == false {
                        self.tableView.footerHidden = true
                    }else{
                        self.tableView.footerHidden = false
                    }
                }
                
                self.tableView.reloadData()
                self.tableView.headerEndRefreshing()
                
            },
            failure:{ (reason) -> Void in
                self.tableView.headerEndRefreshing()
                FLOG("失败原因:\(reason)")
        })
    }
    
    //上拉加载更多
    func loadMore(){
        var begin = self.topicInfo.replyList!.count//self.topicList.count
        HttpManager.sendHttpRequestPost(GET_TOPICINFO, parameters:
            ["id":self.param as! String,
                "userId":ApplicationContext.getUserID()!,
                "begin":begin,
                "limit":"5"],
            success: { (json) -> Void in
                
                FLOG("社区首页返回上拉加载json:\(json)")
                var dataArray = json["replyList"] as! [[String:AnyObject]]
                
                for dataDic in dataArray {
                    self.topicInfo.replyList!.append(Reply(dataDic:dataDic))
                }
                if let isMore = json["isMore"] as? Bool {
                    if isMore == false {
                        self.tableView.footerHidden = true
                    }else{
                        self.tableView.footerHidden = false
                    }
                }
                //self.topicInfo.count = String(self.topicInfo.replyList!.count)
//                self.header.loadData(self.topicInfo)
                FLOG("评论数\(self.topicInfo.count)")
                self.tableView.reloadData()
                self.tableView.footerEndRefreshing()
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
                self.tableView.footerEndRefreshing()
        })
    }
    
    //收藏
    func replyToTopic(){
        var url = ""
        var result = ""
        if self.isCollected {//已经收藏
            url = CANCEL_COLLECTION
            result = "取消收藏成功"
        }else{//没有收藏
            url = ADD_COLLECTION
            result = "收藏成功"
        }
        HttpManager.sendHttpRequestPost(url, parameters:
            ["userId":ApplicationContext.getUserID()!,
                "id":self.topicInfo.id!],
            success: { (json) -> Void in
                
                FLOG("收藏话题返回json:\(json)")
                HYBProgressHUD.showSuccess(result)
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })

    }
    
    //话题刷新
    func refreshTopicDetail(){
        getTopicListFromWeb()
    }

}

// MARK: - overrides
extension TopicDetailViewController {
    override func extraViewClick() {
        var vc = SendNewReplyViewController(nibName: "BasePublishViewController", bundle: nil,param: self.param)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
