//
//  MyTopicViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/19.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class MyTopicViewController: BasicViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failLabel: UILabel!

    let commentCellID = "TopicCommentCell"
    var topicInfo : TopicInfo! //话题详情数据源
    var isInit : Bool = false
    
    var selectedImageName:[String] = [String]()   //图片name数组
    var selectedImageArray:[String] = [String]()  //图片url数组
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let info = self.param as? [String:AnyObject] {
            var tag = info["tag"] as! String
            if tag == "myTopic" {
                headView.changeTitle("我的发言列表")
            }else if tag == "othersTopic" {
                headView.changeTitle("他的发言列表")  
            }
        }
        
        headView.changeLeftButton()
        headView.addButton.hidden = true
        headView.hideRightButton(true)
        headView.logoImage.hidden = true


        //初始化变量
        topicInfo = TopicInfo()
        
        tableView.registerNib(UINib(nibName: "MyReplyCell", bundle: nil), forCellReuseIdentifier: MyReplyCell.cellID)
        tableView.tableFooterView = UIView()
        getTopicListFromWeb()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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

//MARK: -按钮点击
extension MyTopicViewController{

}

// MARK: - UITableViewDataSource
extension MyTopicViewController : UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return topicInfo.replyList!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = self.tableView.dequeueReusableCellWithIdentifier(MyReplyCell.cellID) as! MyReplyCell
       // FLOG(topicInfo.replyList![indexPath.row])
        cell.loadData(topicInfo.replyList![indexPath.row])
        return cell
    }
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
//        return 1
//    }
}

// MARK: - UITableViewDelegate
extension MyTopicViewController : UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var personCommentViewController = PersonCommentViewController(nibName: "PersonCommentViewController", bundle: nil,param:topicInfo.replyList![indexPath.row].replyId)
        self.navigationController?.pushViewController(personCommentViewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 75
    }
}

// MARK: - 类方法
extension MyTopicViewController {
    func getTopicListFromWeb(){
        var userId = ""
        if let info = self.param as? [String:AnyObject] {
            var tag = info["tag"] as! String
            if tag == "myTopic" {
                userId = ApplicationContext.getUserID()!
            }else if tag == "othersTopic" {
                userId = info["data"] as! String
            }
        }
        
        var param : [String:AnyObject] = [
            "userId":userId]
        FLOG("话题详情参数：\(param)")
        
        HttpManager.sendHttpRequestPost(MY_TOPIC_REPLY_LIST, parameters: param,
            success: { (json) -> Void in
                
                FLOG("我的发言汤json:\(json)")
                self.failView.hidden = true
                self.topicInfo = TopicInfo(dataDic: json)
                self.topicInfo.id = self.param as? String
                if let isMore = json["isMore"] as? Bool {
                    if isMore == false {
                        self.tableView.footerHidden = true
                    }else{
                        self.tableView.footerHidden = false
                    }
                }
                self.tableView.reloadData()
                if self.topicInfo.replyList?.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_EMPTY
                }
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
                if self.topicInfo.replyList?.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_FAILED_NO_REFRESH
                }
        })
    }
    
    
    //话题刷新
    func refreshTopicDetail(){
        getTopicListFromWeb()
    }

}
