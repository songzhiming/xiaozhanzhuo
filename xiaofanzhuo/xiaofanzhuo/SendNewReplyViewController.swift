//
//  SendNewReplyViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SendNewReplyViewController: BasePublishViewController {

    var topicId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentText.placeHolder = "请输入您的发言"
        contentText.maxLength = 5000
        atBtn.hidden = false
        topicId = self.param as! String
        atListView.delegate = self
        self.stateId = topicId
        getDraft(stateId)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTitleViewHidden()
    }
}

//MARK:-实例方法
extension SendNewReplyViewController {
    
}

//MARK:-overrrides
extension SendNewReplyViewController {
    override func sendBtnClick() {
        var param : [String:AnyObject] = ["id":topicId,
            "userId":ApplicationContext.getUserID()!,
            "content":contentText.text,
            "imageUrls":imageSource.translateNamesToJsonString(),
            "userIds":atDataSouce.translateUserIdsToJsonString()
        ]
        self.addLoadingView()
        self.headView.sendButton.enabled = false
        HttpManager.sendHttpRequestPost(REPLY_TO_TOPIC, parameters:param,
            success: { (json) -> Void in
                
                //回复成功删除草稿
                PersistentManager.deleteById(self.stateId)
                self.isPublish = true
                
                FLOG("话题回复json:\(json)")
                self.headView.sendButton.enabled = true
                self.removeLoadingView()
                HYBProgressHUD.showSuccess("回复成功")
                NSNotificationCenter.defaultCenter().postNotificationName("refreshTopicDetail", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
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
extension SendNewReplyViewController :UITextViewDelegate{
    
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
extension SendNewReplyViewController :SearchUserViewDelegate{
    func searchUserViewDidReturnData(searchUserInfo:SearchUserInfo){
        atDataSouce.userInfos.append(searchUserInfo)
        reloadAttributeText()
    }
}

//MARK: -UIAlertViewDelegate
extension SendNewReplyViewController : UIAlertViewDelegate{
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1 {//点击确定按钮,删除回复
            atDataSouce.userInfos.removeAtIndex(deleteIndex)
            reloadAttributeText()
        }
    }
}


