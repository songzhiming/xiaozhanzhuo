//
//  EditMyMakpViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class EditMyMakpViewController: BasePublishViewController {

    var passInfo: [String:AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passInfo = self.param as! [String : AnyObject]
        
        titleText.placeHolder = "组队标题"
        titleText.maxLength = 40
        
        contentText.placeHolder = "请输入您对组队的描述(140字内)"
        

        titleText.text = passInfo["title"] as! String
        contentText.text = passInfo["describe"] as! String
        
        var images = passInfo["imageUrl"] as? [[String:AnyObject]]
        
        //解析图片url，显示角标
        if let newImages = images {
            for (var i = 0 ;i < newImages.count ; i++){
                FLOG(newImages[i]["imageUrl"])
                var url = newImages[i]["imageUrl"] as! String
                self.imageSource.imageUrls.append(url)
            }
        }
        showPhotoBtnCornerStatus(imageSource.imageUrls.count)
        
        //相册刷新数据
        photoCollectionView.imageUrls = imageSource.imageUrls
        photoCollectionView.reloadData()
    }
}

//MARK:-overrides
extension EditMyMakpViewController {
    override func sendBtnClick() {
        
        var makeUpId = passInfo["id"] as! String
        
        self.addLoadingView()
        self.headView.sendButton.enabled = false
        HttpManager.sendHttpRequestPost(EDITTASK, parameters:
            ["userId":ApplicationContext.getUserID()!,
                "id": makeUpId,
                "title":titleText.text,
                "describe":contentText.text,
                "imageUrl":imageSource.translateNamesToJsonString(),
                "type":"edit"
            ],
            success: { (json) -> Void in
                
                FLOG("编辑组队json:\(json)")
                self.removeLoadingView()
                HYBProgressHUD.showSuccess("修改成功")
                self.headView.sendButton.enabled = true
                NSNotificationCenter.defaultCenter().postNotificationName("refreshMakeUpDetail", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
            },
            failure:{ (reason) -> Void in
                self.headView.sendButton.enabled = true
                self.removeLoadingView()
                FLOG("失败原因:\(reason)")
        })
    }
}
