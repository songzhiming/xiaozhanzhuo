//
//  EditMyTopicDetailViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class EditMyTopicDetailViewController: BasePublishViewController {
    
    var topicInfo :TopicInfo!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleText.placeHolder = "请输入话题(40字内)"
        titleText.maxLength = 40
        
        contentText.placeHolder = "请输入您对话题的描述"
        contentText.maxLength = 5000
        
        topicInfo = self.param as! TopicInfo
        
        var images = topicInfo.imageUrl as [[String:AnyObject]]?
        
        //解析图片url，显示角标
        if let newImages = images {
            for (var i = 0 ;i < newImages.count ; i++){
                FLOG(newImages[i]["imageUrl"])
                var url = newImages[i]["imageUrl"] as! String
                self.imageSource.imageUrls.append(url)
            }
        }
        showPhotoBtnCornerStatus(imageSource.imageUrls.count)
        
        //文字数据
        titleText.text = topicInfo.title
        contentText.text = topicInfo.intro
        
        //相册刷新数据
        photoCollectionView.imageUrls = imageSource.imageUrls
        photoCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK:-overrides
extension EditMyTopicDetailViewController {
    override func sendBtnClick() {
        var param =
        ["userId":ApplicationContext.getUserID()!,
            "id": topicInfo.id!,
            "topicTitle":titleText.text,
            "topicDescribe":contentText.text,
            "topicImage":imageSource.translateNamesToJsonString()
        ]
        FLOG("param:\(param)")
        self.addLoadingView()
        self.headView.sendButton.enabled = false
        HttpManager.sendHttpRequestPost(EDIT_TOPIC, parameters:param,
            success: { (json) -> Void in
                
                FLOG("编辑话题返回json:\(json)")
                HYBProgressHUD.showSuccess("修改成功")
                self.removeLoadingView()
                NSNotificationCenter.defaultCenter().postNotificationName("refreshTopicDetail", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
            },
            failure:{ (reason) -> Void in
                self.headView.sendButton.enabled = true
                self.removeLoadingView()
                FLOG("失败原因:\(reason)")
        })
    }
}
