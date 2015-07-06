//
//  SendNewCommentViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SendNewCommentViewController: BasePublishViewController {

    var passInfo: [String:AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentText.placeHolder = "请输入您的评论(140字)"
        passInfo = param as! [String:AnyObject]
        
        var isToReplyComment = passInfo["isToReplyComment"] as! Bool
        if isToReplyComment {//如果是回复下面的评论
            var comment = passInfo["comment"] as! Comment
            stateId = comment.id!
        }else{
            stateId = passInfo["topicReplyId"] as! String
        }
        
        getDraft(stateId)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTitleViewHidden()
        setToolViewHidden()
    }
}

//MARK:-overrides
extension SendNewCommentViewController {
    override func sendBtnClick() {
        var topicReplyId = passInfo["topicReplyId"] as! String
        var isToReplyComment = passInfo["isToReplyComment"] as! Bool
        var dic : [String:AnyObject]!
        if isToReplyComment {
            var comment = passInfo["comment"] as! Comment
            dic = ["userId":ApplicationContext.getUserID()!,
                "topicReplyId":topicReplyId,//(要回复哪条评论)
                "observerId":comment.userIdFrom!,//被评论的用户id isReply true 的时候要传
                "commentId":comment.id!,//评论id isReply true 的时候要传
                "content":contentText.text,
                "isReply":true]          //如果为true回复评论，如果为false，回复发言
        }else{
            dic = ["userId":ApplicationContext.getUserID()!,
                "topicReplyId":topicReplyId,//(要回复哪条评论)
                "content":contentText.text,
                "isReply":false]
        }
        FLOG("发表评论（评论回复（发言）参数:\(dic)")
        self.headView.sendButton.enabled = false
        self.addLoadingView()
        HttpManager.sendHttpRequestPost(COMMENT_TO_TOPIC_REPLY, parameters: dic,
            success: { (json) -> Void in
                
                //发表成功，删除草稿
                PersistentManager.deleteById(self.stateId)
                self.isPublish = true
                
                FLOG("发表评论（评论回复（发言）返回json:\(json)")
                self.removeLoadingView()
                self.headView.sendButton.enabled = true
                NSNotificationCenter.defaultCenter().postNotificationName("refreshPersonComment", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
                HYBProgressHUD.showSuccess("回复成功")
            },
            failure:{ (reason) -> Void in
                self.removeLoadingView()
                self.headView.sendButton.enabled = true
                FLOG("失败原因:\(reason)")
        })
    }
}