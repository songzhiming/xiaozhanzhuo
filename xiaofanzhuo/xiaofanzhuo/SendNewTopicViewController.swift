//
//  SendNewTopicViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SendNewTopicViewController: BasePublishViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置
        titleText.placeHolder = "请输入话题(40字内)"
        titleText.maxLength = 40
        
        contentText.placeHolder = "请输入您对话题的描述"
        contentText.maxLength = 5000
        
        self.stateId = "newTopic"
        getDraft(stateId)

    }
}

//MARK:-overrides
extension SendNewTopicViewController {
    override func sendBtnClick() {
        var params : [String:AnyObject] = ["userId":ApplicationContext.getUserID()!,
            "topicTitle":titleText.text,
            "topicDescribe":contentText.text,
            "topicImage":imageSource.translateNamesToJsonString()
        ]
        FLOG("新话题参数\(params)")
        self.addLoadingView()
        self.headView.sendButton.enabled = false
        HttpManager.sendHttpRequestPost(NEW_TOPIC, parameters: params,
            success: { (json) -> Void in
                
                FLOG("发表新话题返回json:\(json)")
                
                //成功发表，不存储草稿,并删除草稿记录
                self.isPublish = true
                PersistentManager.deleteById(self.stateId)
                
                HYBProgressHUD.showSuccess("发表成功")
                
                NSNotificationCenter.defaultCenter().postNotificationName("refreshCommunity", object: nil)
                self.headView.sendButton.enabled = true
                self.removeLoadingView()
                self.navigationController?.popViewControllerAnimated(true)
                
            },
            failure:{ (reason) -> Void in
                self.headView.sendButton.enabled = true
                self.removeLoadingView()
                FLOG("失败原因:\(reason)")
        })
    }
}