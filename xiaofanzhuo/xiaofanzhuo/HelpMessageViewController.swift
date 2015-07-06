//
//  HelpMessageViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-21.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class HelpMessageViewController: BasicViewController {

    @IBOutlet weak var myAnswerTextView: HolderTextView!
    @IBOutlet weak var countLabel: UILabel!
    
    //用于保存草稿
    var stateId = ""
    var isPublish = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.recommendButton.hidden = true
        headView.backButton.hidden = false
        headView.titleLabel.text = "留言"
        headView.logoImage.hidden = true
        headView.searchButton.hidden = true
        headView.makeupHelpButton.hidden = false
        
        
        myAnswerTextView.placeHolder = "请输入您要回复的组队信息(140字内)"
        myAnswerTextView.maxLength = 140
        myAnswerTextView.holderTextViewDelegate = self
        countLabel.text = "0/140"
        
        var dataDic = (param as! [String : AnyObject])["dataDic"] as! [String:AnyObject]
        
        var isReply = (param as! [String : AnyObject])["isReply"] as! Bool

        /******传参数不用Model而滥用用Dictionary的后果，就会造成一大堆if,else还有类型的转换!!例如这个Controller的一大堆，老子也懒得重构Model,直接复制粘贴各种转换和ifelse得了,日了狗🐶了,引以为鉴*****/
        /********上级调用关系
        这个controller在DetailMakeUpTouchViewController调用，
        param是dic = [
        "dataDic":value,
        "helpInfo":value,
        "isReply":value]
*/
        if isReply {//如果是下面的评论
            var helpInfo = (param as! [String : AnyObject])["helpInfo"] as! [String:AnyObject]
            var commentId = helpInfo["_id"] as! String
            stateId = commentId
        }else{//如果是提供帮助
            stateId = dataDic["_id"] as! String
        }

        //获取草稿
        if let dic = PersistentManager.getValueById(stateId){
            myAnswerTextView.text = dic["describe"]
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "makeUpHelp", name: "makeUpHelp", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit{
        if !isPublish{
            PersistentManager.setValueById(stateId, describe: myAnswerTextView.text)
        }
    }
    
    func makeUpHelp(){
        
        var dataDic = (param as! [String : AnyObject])["dataDic"] as! [String:AnyObject]
        var isReply = (param as! [String : AnyObject])["isReply"] as! Bool
        var teamId = dataDic["_id"] as! String
        
        var observerId = ""
        var commentId = ""
        
        
        FLOG("dataDic:\(dataDic)")
            //,helpInfo:\(helpInfo)")
        self.headView.sendButton.enabled = false
        
        var dic: [String:AnyObject]!
        if isReply { //回复下面的评论
            var helpInfo = (param as! [String : AnyObject])["helpInfo"] as! [String:AnyObject]
            var observerId = helpInfo["userIdFrom"] as! String
            var commentId = helpInfo["_id"] as! String
            
            dic =
            ["userId":ApplicationContext.getUserID()!,
                "teamId":teamId,                        //组队的id
                "observerId":observerId,                //被评论的用户的id
                "commentId":commentId,                  //被评论的评论的id
                "content":myAnswerTextView.text,        //内容
                "isReply":"true"
            ]
            FLOG("dic:\(dic)")
            
        }else{ //回复组队
            dic =
                ["userId":ApplicationContext.getUserID()!,
                    "teamId":teamId,                        //组队的id
                    "content":myAnswerTextView.text,        //内容
                    "isReply":"false"
            ]
        }
        
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

extension HelpMessageViewController :HolderTextViewDelegate{
    func holderTextViewDidChange(textView:HolderTextView){
        var length = (textView.text as NSString).length
        countLabel.text = "\(textView.maxLength-length)/\(textView.maxLength)"
    }
}