//
//  SendNewMakeUpViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SendNewMakeUpViewController: BasePublishViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //设置
        titleText.placeHolder = "发起新组队(40字内)"
        titleText.maxLength = 40
        
        contentText.placeHolder = "请输入您对组队的描述(140字内)"
        
        //获取草稿
        stateId = "newMakeUp"
        getDraft(stateId)
    }
}

//MARK:-overrides
extension SendNewMakeUpViewController{
    override func sendBtnClick() {
        self.addLoadingView()
        self.headView.sendButton.enabled = false
        HttpManager.sendHttpRequestPost(PUBLISHTASK, parameters:
            ["userId":ApplicationContext.getUserID()!,
                "title":titleText.text,
                "describe":contentText.text,
                "imageUrl":imageSource.translateNamesToJsonString()
            ],
            success: { (json) -> Void in
                
                FLOG("发表组队返回json:\(json)")
                
                //成功发表，不存储草稿
                self.isPublish = true
                PersistentManager.deleteById(self.stateId)
                
                HYBProgressHUD.showSuccess("发表成功")
                NSNotificationCenter.defaultCenter().postNotificationName("refreshMakeUp", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
                self.removeLoadingView()
                self.headView.sendButton.enabled = true
                return
            },
            failure:{ (reason) -> Void in
                self.removeLoadingView()
                self.headView.sendButton.enabled = true
                FLOG("失败原因:\(reason)")
        })
    }
}
