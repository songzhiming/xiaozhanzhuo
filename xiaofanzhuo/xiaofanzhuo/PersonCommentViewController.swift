//
//  PersonCommentViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/19.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class PersonCommentViewController: BasicViewController {

    @IBOutlet weak var tableView: UITableView!
    var replyInfo : ReplyInfo!
    var tableHeader : PersonCommentHeader!
    var selectedIndexpath : NSIndexPath!
    
    let commentCellID = "TopicCommentCell"
    
    var isInit : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.changeTitle("发言详情")
        headView.changeLeftButton()
        headView.hideRightButton(true)
        headView.logoImage.hidden = true
        
        //显示大的蓝色按钮
        self.extraView.hidden = false
        self.extraView.image.image = UIImage(named: "add_communiti_comment")!
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "replyToSpeak", name: "replyToSpeak", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPersonComment", name: "refreshPersonComment", object: nil)

        //变量初始化
        replyInfo = ReplyInfo()
        
        
        tableView.registerNib(UINib(nibName: "TopicCommentCell", bundle: nil), forCellReuseIdentifier: commentCellID)
        tableView.autoresizesSubviews = true    
            
        tableHeader = NSBundle.mainBundle().loadNibNamed("PersonCommentHeader", owner: self, options: nil)[0] as! PersonCommentHeader
//        self.tableView.tableHeaderView = self.tableHeader
        self.tableView.tableFooterView = UIView()
        //tableHeader.loadData(replyInfo)
        //tableView.addSubview(tableHeader)
        tableView.addHeaderWithTarget(self, action:"getCommentListFromWeb")
        tableView.addFooterWithTarget(self, action:"loadMore")
        getCommentListFromWeb()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isInit {
            tableView.contentInset = UIEdgeInsetsZero
            isInit = true
        }

        setExtraView_B_R(15,right:15)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        getCommentListFromWeb()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDataSource
extension PersonCommentViewController : UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return replyInfo.commentList!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = self.tableView.dequeueReusableCellWithIdentifier(commentCellID) as! TopicCommentCell
        cell.setCommentCountHidden(true)
        cell.loadData(replyInfo.commentList![indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PersonCommentViewController : UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        selectedIndexpath = indexPath
        var userIdFrom = self.replyInfo.commentList![selectedIndexpath.row].userIdFrom!
        var otherButtonTitle = ( userIdFrom == ApplicationContext.getUserID()! ) ? "删除":"举报"
        var actionSheet = UIActionSheet(
            title: "操作",
            delegate: self,
            cancelButtonTitle: "取消",
            destructiveButtonTitle: "回复",
            otherButtonTitles:otherButtonTitle)
        actionSheet.actionSheetStyle = UIActionSheetStyle.BlackOpaque
        actionSheet.destructiveButtonIndex = -1
        actionSheet.showInView(self.view)
        
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

// MARK: - UIActionSheetDelegate
extension PersonCommentViewController : UIActionSheetDelegate{
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex {
        case 0://回复
            var param : [String:AnyObject] = ["topicReplyId":self.replyInfo.id!,"comment":self.replyInfo.commentList![selectedIndexpath.row],"isToReplyComment":true]
            var vc = SendNewCommentViewController(nibName: "BasePublishViewController", bundle: nil,param: param)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2://
            if self.replyInfo.commentList![selectedIndexpath.row].userIdFrom! == ApplicationContext.getUserID()! {//删除
                UIAlertView(title: "提示", message: "确定删除该回复？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定").show()
            }else{//举报
                UIAlertView(title: "提示", message: "确定举报此用户？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定").show()
            }
            break
        case 3:
            break
        default:
            break
        }
        FLOG(buttonIndex)
        
    }
}

// MARK: - 类方法
extension PersonCommentViewController {
    func getCommentListFromWeb(){
        var dic : [String:AnyObject] = ["userId":ApplicationContext.getUserID()!,
            "id":self.param as! String,
            "begin":"0",
            "limit":"10"]

        HttpManager.sendHttpRequestPost(GET_TOPIC_COMMENT, parameters: dic,
            success: { (json) -> Void in
                
                FLOG("个人评论详情返回json:\(json)")
                self.replyInfo = ReplyInfo(dataDic: json)
                if let isMore = json["isMore"] as? Bool {
                    if isMore == false {
                        self.tableView.footerHidden = true
                    }else{
                        self.tableView.footerHidden = false
                    }
                }
                self.tableHeader.loadData(self.replyInfo)
                self.tableView.tableHeaderView = self.tableHeader
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
        var begin = self.replyInfo.commentList!.count//self.topicList.count
        HttpManager.sendHttpRequestPost(GET_TOPIC_COMMENT, parameters:
            ["id":self.param as! String,
                "userId":ApplicationContext.getUserID()!,
                "begin":begin,
                "limit":"5"],
            success: { (json) -> Void in
                
                FLOG("发言详情上拉加载json:\(json)")
                var dataArray = json["commentList"] as! [[String:AnyObject]]
                
                for dataDic in dataArray {
                    self.replyInfo.commentList!.append(Comment(dataDic:dataDic))
                }
                if let isMore = json["isMore"] as? Bool {
                    if isMore == false {
                        self.tableView.footerHidden = true
                    }else{
                        self.tableView.footerHidden = false
                    }
                }
                self.tableHeader.loadData(self.replyInfo)
                self.tableView.reloadData()
                self.tableView.footerEndRefreshing()
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
                self.tableView.footerEndRefreshing()
        })
    }
    
    
    //点击发言详情右上角回复本条发言
    func replyToSpeak(){
        replyInfo.discription()
        var param : [String:AnyObject] = ["topicReplyId":self.replyInfo.id!,"comment":"","isToReplyComment":false]
        var replyViewController = ReplyViewController(nibName: "ReplyViewController", bundle: nil,param: param)
        self.navigationController?.pushViewController(replyViewController, animated: true)
    }
    
    func refreshPersonComment(){
        getCommentListFromWeb()
    }
}

//MARK: -UIAlertViewDelegate
extension PersonCommentViewController : UIAlertViewDelegate{
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1 {//点击确定按钮,删除回复
            switch alertView.message! {
            case "确定删除该回复？":
                HttpManager.sendHttpRequestPost(DEL_TOPIC_REPLY_COMMENT, parameters:
                    ["userId":ApplicationContext.getUserID()!,
                        "id":self.replyInfo.commentList![selectedIndexpath.row].id!],
                    success: { (json) -> Void in
                        
                        FLOG("删除评论返回json:\(json)")
                        UIAlertView(title: "提示", message: "删除成功！", delegate: nil, cancelButtonTitle: "好的,知道了").show()
                        self.getCommentListFromWeb()
                    },
                    failure:{ (reason) -> Void in
                        FLOG("失败原因:\(reason)")
                })
                break
            case "确定举报此用户？":
                HttpManager.sendHttpRequestPost(BLOCK_TO_TOPIC_REPLY_COMMENT, parameters:
                    ["userId":ApplicationContext.getUserID()!,
                        "id":self.replyInfo.commentList![selectedIndexpath.row].id!],
                    success: { (json) -> Void in

                        FLOG("举报评论返回json:\(json)")
                        if let isSuccess = json["isSuccess"] as? Bool{
                            var isSuccess = json["isSuccess"] as! Bool
                            var str = isSuccess ? "举报成功" : "您已举报过该用户"
                            HYBProgressHUD.showSuccess(str)
                        }
                    },
                    failure:{ (reason) -> Void in
                        FLOG("失败原因:\(reason)")
                })
                break
            default:
                return
            }
        }
    }
}

// MARK: - overrides
extension PersonCommentViewController {
    override func extraViewClick() {
        var param : [String:AnyObject] = ["topicReplyId":self.replyInfo.id!,"comment":"","isToReplyComment":false]
        var vc = SendNewCommentViewController(nibName: "BasePublishViewController", bundle: nil,param: param)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
