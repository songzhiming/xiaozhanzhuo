//
//  EditMyReplyDetailViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class EditMyReplyDetailViewController: BasePublishViewController {

    var replyInfo : ReplyInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        replyInfo = self.param as! ReplyInfo
        self.atBtn.hidden = false
        atListView.delegate = self
        
        contentText.maxLength = 5000
        contentText.placeHolder = "请输入您的发言"
        
        var images = replyInfo.imageUrl as [[String:AnyObject]]?
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

        contentText.text = replyInfo.content
        
        //相册刷新数据
        photoCollectionView.imageUrls = imageSource.imageUrls
        photoCollectionView.reloadData()
        
        //@用户数据加载
        atDataSouce.translateReplyInfo(replyInfo)
        reloadAttributeText()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTitleViewHidden()
    }
}

//MARK:-overrides
extension EditMyReplyDetailViewController {
    override func sendBtnClick() {
        self.headView.sendButton.enabled = false
        self.addLoadingView()
        HttpManager.sendHttpRequestPost(EDIT_TOPIC_REPLY, parameters:
            ["userId":ApplicationContext.getUserID()!,
                "id":replyInfo.id!,
                "content":contentText.text,
                "imageUrls":imageSource.translateNamesToJsonString(),
                "userIds":atDataSouce.translateUserIdsToJsonString()
            ],
            success: { (json) -> Void in
                
                FLOG("修改发言详情json:\(json)")
                self.removeLoadingView()
                self.headView.sendButton.enabled = true
                NSNotificationCenter.defaultCenter().postNotificationName("refreshPersonComment", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
                HYBProgressHUD.showSuccess("编辑发言成功")
            },
            failure:{ (reason) -> Void in
                self.removeLoadingView()
                self.headView.sendButton.enabled = true
                FLOG("失败原因:\(reason)")
        })
    }
    override func atBtnClick(sender: AnyObject) {
        var vc = SearchUserViewController(nibName: "SearchUserViewController", bundle: nil)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:-UITextViewDelegate
extension EditMyReplyDetailViewController :UITextViewDelegate{
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "attributedText" {
            
            self.atListHeight.constant =
            atListView.attributedText.string.isEmpty ? 0 :
            atListView.attributedText.boundingRectWithSize(CGSizeMake(atListView.frame.width , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil).height + 10 + 10
        }
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool{
        deleteIndex = URL.absoluteString!.toInt()!
        UIAlertView(title: "提示", message: "确定删除？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定").show()
        return true
    }
}

//MARK:-SearchUserViewDelegate
extension EditMyReplyDetailViewController :SearchUserViewDelegate{
    func searchUserViewDidReturnData(searchUserInfo:SearchUserInfo){
        atDataSouce.userInfos.append(searchUserInfo)
        reloadAttributeText()
    }
}

//MARK: -UIAlertViewDelegate
extension EditMyReplyDetailViewController : UIAlertViewDelegate{
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1 {//点击确定按钮,删除回复
            atDataSouce.userInfos.removeAtIndex(deleteIndex)
            reloadAttributeText()
        }
    }
}