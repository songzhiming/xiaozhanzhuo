//
//  SenNewMakeUpReplyViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SenNewMakeUpReplyViewController: BasePublishViewController {

    var passInfo: [String:AnyObject]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentText.placeHolder = "请输入您要回复的组队信息(140字内)"
        passInfo = param as! [String : AnyObject]
        var dataDic = passInfo["dataDic"] as! [String:AnyObject]
        var isReply = passInfo["isReply"] as! Bool
        
        if isReply {//如果是下面的评论
            var helpInfo = passInfo["helpInfo"] as! [String:AnyObject]
            var commentId = helpInfo["_id"] as! String
            stateId = commentId
        }else{//如果是提供帮助
            stateId = dataDic["_id"] as! String
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
extension SenNewMakeUpReplyViewController{
    override func sendBtnClick() {
        var dataDic = passInfo["dataDic"] as! [String:AnyObject]
        var isReply = passInfo["isReply"] as! Bool
        var teamId = dataDic["_id"] as! String
        
        var observerId = ""
        var commentId = ""
        
        
        FLOG("dataDic:\(dataDic)")
        //,helpInfo:\(helpInfo)")
        self.headView.sendButton.enabled = false
        
        var dic: [String:AnyObject]!
        if isReply { //回复下面的评论
            var helpInfo = passInfo["helpInfo"] as! [String:AnyObject]
            var observerId = helpInfo["userIdFrom"] as! String
            var commentId = helpInfo["_id"] as! String
            
            dic =
                ["userId":ApplicationContext.getUserID()!,
                    "teamId":teamId,                        //组队的id
                    "observerId":observerId,                //被评论的用户的id
                    "commentId":commentId,                  //被评论的评论的id
                    "content":contentText.text,             //内容
                    "isReply":"true"
            ]
            FLOG("dic:\(dic)")
            
        }else{ //回复组队
            dic =
                ["userId":ApplicationContext.getUserID()!,
                    "teamId":teamId,                        //组队的id
                    "content":contentText.text,             //内容
                    "isReply":"false"
            ]
        }
        self.headView.sendButton.enabled = false
        HttpManager.sendHttpRequestPost(OFFERHELP, parameters:dic,
            success: { (json) -> Void in
                
                FLOG("提供帮助数据json:\(json)")
                
                //删除草稿
                PersistentManager.deleteById(self.stateId)
                self.isPublish = true
                
                //服务器数据返回成功
                HYBProgressHUD.showSuccess("回复成功")
                NSNotificationCenter.defaultCenter().postNotificationName("refreshMakeUpDetail", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
                self.headView.sendButton.enabled = true
            },
            failure:{ (reason) -> Void in
                self.headView.sendButton.enabled = true
                FLOG("失败原因:\(reason)")
        })
    }
}
