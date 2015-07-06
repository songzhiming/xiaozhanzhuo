//
//  ArticleCommentViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/11.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class ArticleCommentViewController: BaseCommentViewController {
    
    var commentList:[ArticleReply]!
    var articleId: String!
    
    var selectedIndexpath : NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addHeaderWithTarget(self, action:"refreshCommentList")
        tableView.addFooterWithTarget(self, action:"loadMore")
        
        self.extraView.hidden = false
        self.extraView.image.image = UIImage(named: "article_activity_comment")
        
        commentList = [ArticleReply]()
        self.articleId = self.param as! String
        
        refreshCommentList()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshCommentList", name: "refreshActivityComment", object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setExtraView_B_R(15,right:15)
    }
}

// MARK: - 实例方法
extension ArticleCommentViewController{
    
    
    func refreshCommentList(){
        getCommentListFromWebBeginAt(0,limit:10)
    }
    
    func loadMore(){
        getCommentListFromWebBeginAt(self.commentList.count,limit:5)
    }
    
    func getCommentListFromWebBeginAt(begin:Int,limit:Int){
        HttpManager.sendHttpRequestPost(GET_ARTICLE_REPLYS, parameters:
            ["userId":ApplicationContext.getUserID()!,
                "articleId":articleId,
                "begin":begin,
                "limit":limit],
            success: { (json) -> Void in
                
                FLOG("文章给评论返回json:\(json)")
                
                if begin == 0 {
                    self.commentList.removeAll(keepCapacity: true)
                }
                
                var replyList = json["replyList"] as! [[String:AnyObject]]
                
                for dataDic in replyList{
                    self.commentList.append(ArticleReply(dataDic: dataDic))
                }
                
                if let isMore = json["isMore"] as? Bool {
                    self.tableView.footerHidden = !isMore
                }
                //                self.failView.hidden = true
                //                if self.topicList.count == 0 {
                //                    self.failView.hidden = false
                //                    self.failLabel.text = LOAD_EMPTY
                //                }
                self.tableView.reloadData()
                self.tableView.headerEndRefreshing()
                self.tableView.footerEndRefreshing()
                
            },
            failure:{ (reason) -> Void in
                self.tableView.headerEndRefreshing()
                self.tableView.footerEndRefreshing()
                //                if self.topicList.count == 0 {
                //                    self.failView.hidden = false
                //                    self.failLabel.text = LOAD_FAILED
                //                }
                FLOG("失败原因:\(reason)")
        })
    }
}

// MARK: - UITableViewDataSource
extension ArticleCommentViewController : UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return commentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = self.tableView.dequeueReusableCellWithIdentifier(CommentTableViewCell.cellId) as! CommentTableViewCell
        cell.configureCell(self.commentList[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ArticleCommentViewController : UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
        selectedIndexpath = indexPath
        var userIdFrom = self.commentList[selectedIndexpath.row].userId
        FLOG("userIdFrom:------\(userIdFrom)")
        if userIdFrom == ApplicationContext.getUserID()! {
            var actionSheet = UIActionSheet(
                title: "操作",
                delegate: self,
                cancelButtonTitle: "取消",
                destructiveButtonTitle: "回复",
                otherButtonTitles:"删除")
            actionSheet.actionSheetStyle = UIActionSheetStyle.BlackOpaque
            actionSheet.destructiveButtonIndex = -1
            actionSheet.showInView(self.view)
        }else{
            var actionSheet =
            UIActionSheet(
                title: "操作",
                delegate: self,
                cancelButtonTitle: "取消",
                destructiveButtonTitle: "回复")
            actionSheet.actionSheetStyle = UIActionSheetStyle.BlackOpaque
            actionSheet.destructiveButtonIndex = -1
            actionSheet.showInView(self.view)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var commentCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as? CommentTableViewCell
        if let cell = commentCell {
            return cell.getCellDynamicHeight()
        }
        return 0
    }
}

// MARK: - overrides
extension ArticleCommentViewController{
    override func extraViewClick() {
        var vc = SendArticleCommentViewController(nibName: "BasePublishViewController", bundle: nil,param: ["isReply":"false","articleId":articleId])
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UIActionSheetDelegate
extension ArticleCommentViewController : UIActionSheetDelegate{
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex {
        case 0://回复
            //被回复用户的id
            var dic = [
                "articleId":articleId,
                "commnentInfo":self.commentList[selectedIndexpath.row] ,
                "isReply":"true"]
            var vc = SendArticleCommentViewController(nibName: "BasePublishViewController", bundle: nil,param:dic)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2://删除
            UIAlertView(title: "提示", message: "确定删除该回复？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定").show()
            
            break
        case 3:
            break
        default:
            break
        }
        FLOG(buttonIndex)
    }
}

//MARK: -UIAlertViewDelegate
extension ArticleCommentViewController : UIAlertViewDelegate{
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1 {//点击确定按钮,删除回复
            var selReplyId = self.commentList[selectedIndexpath.row].id!
            HttpManager.sendHttpRequestPost(DELETE_ARTICLE_REPLY, parameters:
                ["userId":ApplicationContext.getUserID()!,
                    "articleId":articleId,
                    "replyId":selReplyId
                ],
                success: { (json) -> Void in
                    
                    FLOG("删除评论返回json:\(json)")
                    
                    self.refreshCommentList()
                    UIAlertView(title: "提示", message: "删除成功", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "确定").show()
                },
                failure:{ (reason) -> Void in
                    FLOG("失败原因:\(reason)")
            })
        }
    }
}
