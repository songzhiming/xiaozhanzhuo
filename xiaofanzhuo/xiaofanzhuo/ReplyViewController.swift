//
//  ReplyViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/19.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class ReplyViewController : BasicViewController {

    @IBOutlet weak var textField: HolderTextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    
    //用于草稿保存
    var stateId = ""
    var isPublish = false
    
    override func viewDidLoad() {

        super.viewDidLoad()
        headView.changeLeftButton()
        headView.logoImage.hidden = true
        headView.titleLabel.text = "评论回复"
        headView.searchButton.hidden = true
        headView.generateCodeButton.hidden = true
        
        textField.placeHolder = "请输入您的问题(140字内)"
        textField.holderTextViewDelegate = self
        countLabel.text = "0/140"
        self.view.bringSubviewToFront(sendBtn)
        
        //获取草稿
        

        var isToReplyComment = ( param as! [String:AnyObject] )["isToReplyComment"] as! Bool
        if isToReplyComment {//如果是回复下面的评论
            var comment = ( param as! [String:AnyObject] )["comment"] as! Comment
            stateId = comment.id!
        }else{
            stateId = ( param as! [String:AnyObject] )["topicReplyId"] as! String
        }
        
        if let dic = PersistentManager.getValueById(stateId){
            textField.text = dic["describe"]
        }
//        FLOG("replyviewcontroller:\()")
        
    }
    
    deinit{
        if !isPublish{
            PersistentManager.setValueById(stateId, describe: textField.text)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: -按钮点击
extension ReplyViewController {
    
    @IBAction func commit(sender: AnyObject) {
 
        var topicReplyId = ( param as! [String:AnyObject] )["topicReplyId"] as! String
        var isToReplyComment = ( param as! [String:AnyObject] )["isToReplyComment"] as! Bool
        var dic : [String:AnyObject]!
        if isToReplyComment {
            var comment = ( param as! [String:AnyObject] )["comment"] as! Comment
            dic = ["userId":ApplicationContext.getUserID()!,
                "topicReplyId":topicReplyId,//(要回复哪条评论)
                "observerId":comment.userIdFrom!,//被评论的用户id isReply true 的时候要传
                "commentId":comment.id!,//评论id isReply true 的时候要传
                "content":textField.text,
                "isReply":true]          //如果为true回复评论，如果为false，回复发言
        }else{
            dic = ["userId":ApplicationContext.getUserID()!,
                "topicReplyId":topicReplyId,//(要回复哪条评论)
                "content":textField.text,
                "isReply":false]
        }
        FLOG("发表评论（评论回复（发言）参数:\(dic)")
        HttpManager.sendHttpRequestPost(COMMENT_TO_TOPIC_REPLY, parameters: dic,
            success: { (json) -> Void in
                
                //发表成功，删除草稿
                PersistentManager.deleteById(self.stateId)
                self.isPublish = true
                
                FLOG("发表评论（评论回复（发言）返回json:\(json)")
                NSNotificationCenter.defaultCenter().postNotificationName("refreshPersonComment", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
                HYBProgressHUD.showSuccess("回复成功")
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
}

//MARK: -按钮点击
extension ReplyViewController :HolderTextViewDelegate{
    func holderTextViewDidChange(textView:HolderTextView){
        var length = (textView.text as NSString).length
        countLabel.text = "\(140-length)/140"
    }
}
