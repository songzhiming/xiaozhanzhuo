//
//  SendArticleCommentViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/13.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SendArticleCommentViewController: BasePublishViewController {

    var passInfo: [String:AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentText.placeHolder = "请输入您的评论(140字)"
        passInfo = param as! [String:AnyObject]
        
        var isReply = passInfo["isReply"] as! String
        
        if isReply == "true" {//如果是回复下面的评论
            var comment = passInfo["commnentInfo"] as! ArticleReply
            stateId = comment.id!
        }else{
            stateId = passInfo["articleId"] as! String
        }
        
        //获取草稿
        if let dic = PersistentManager.getValueById(stateId){
            contentText.text = dic["describe"]
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTitleViewHidden()
        setToolViewHidden()
    }
}

// MARK: - overrides
extension SendArticleCommentViewController {
    override func sendBtnClick() {
        
        var dic =  [String:AnyObject]()
        var isReply = passInfo["isReply"] as! String
        var articleId = passInfo["articleId"] as! String
        
        if isReply == "false" {//回复活动
            dic = ["userId":ApplicationContext.getUserID()!,
                "articleId":articleId,
                "isReply":isReply,
                "replyId":"",
                "replyUserId":"",
                "content":self.contentText.text
            ]
        }else{//回复活动下的评论
            var articleReply = passInfo["commnentInfo"] as! ArticleReply
            dic = ["userId":ApplicationContext.getUserID()!,
                "articleId":articleId,
                "isReply":isReply,
                "replyId":articleReply.id!,
                "replyUserId":articleReply.userId!,
                "content":self.contentText.text
            ]
        }
        self.headView.sendButton.enabled = false
        self.addLoadingView()
        HttpManager.sendHttpRequestPost(REPLY_TO_ARTICLE, parameters: dic,
            success: { (json) -> Void in
                
                //发表成功，删除草稿
                PersistentManager.deleteById(self.stateId)
                self.isPublish = true
                
                FLOG("文章回复评论返回json:\(json)")
                NSNotificationCenter.defaultCenter().postNotificationName("refreshActivityComment", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
                HYBProgressHUD.showSuccess("回复成功")
                self.removeLoadingView()
            },
            failure:{ (reason) -> Void in
                self.removeLoadingView()
                self.headView.sendButton.enabled = true
                FLOG("失败原因:\(reason)")
        })
    }
}
