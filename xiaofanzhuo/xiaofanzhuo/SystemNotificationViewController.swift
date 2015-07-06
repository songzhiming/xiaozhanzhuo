//
//  SystemNotificationViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-22.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SystemNotificationViewController: BasicViewController {
    @IBOutlet weak var messageTableView: UITableView!
    var messageList : [SystemMessage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.backButton.hidden = false
        headView.recommendButton.hidden = true
        headView.searchButton.hidden = true
        headView.titleLabel.text = "消息列表"
        headView.logoImage.hidden = true
        messageTableView.separatorColor = UIColor.clearColor()
        messageTableView.registerNib(UINib(nibName: "SystemNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: SystemNotificationTableViewCell.cellId)
        messageTableView.addFooterWithTarget(self, action:"loadMore")
        messageList = [SystemMessage]()
        self.getMessageList()
        resetPushCount()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SystemNotificationTableViewCell = tableView.dequeueReusableCellWithIdentifier(SystemNotificationTableViewCell.cellId) as! SystemNotificationTableViewCell
        cell.configureCell(messageList[indexPath.row])
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
        var messageItem = messageList[indexPath.row]
        
        var type = messageItem.type!
        var id = messageItem.id!
        
        FLOG("推送测试id：\(id)")
        switch type{
            case "1"://注册审核通过【恭喜您，注册信息已经通过审核】不可点击
                
            break
            case "2"://报名审核通过【恭喜您！您已成功报名“XXXXX（活动标题）”活动】 不可点击
                
            break
            case "3"://自己发起的话题下有新的发言【您的话题“XXX（话题内容前10个字加省略号）”有新的发言】 点击跳转话题页
                var topicDetailViewController = TopicDetailViewController(nibName: "TopicDetailViewController", bundle: nil,param: id)
                self.navigationController?.pushViewController(topicDetailViewController, animated: true)
            break
            case "4"://自己的发言有新的评论【您的发言“XXX（发言内容前10个字加省略号）”有新评论】点击跳转发言页
                var personCommentViewController = PersonCommentViewController(nibName: "PersonCommentViewController", bundle: nil,param:id)
                self.navigationController?.pushViewController(personCommentViewController, animated: true)
            break
            case "5"://社区中其他人发言中，自己的评论被“回复”【您有新的评论】点击跳转发言页
                var personCommentViewController = PersonCommentViewController(nibName: "PersonCommentViewController", bundle: nil,param:id)
                self.navigationController?.pushViewController(personCommentViewController, animated: true)
            break
            case "6"://自己发起的任务有新人参加【您的组队“XXXX（组队内容前10个字加省略号）”有新的伙伴加入】点击跳转
                var data = ["_id":id]
                var detailMakeUpTouchViewController = DetailMakeUpTouchViewController(nibName: "DetailMakeUpTouchViewController", bundle: nil, param: data)
                self.navigationController?.pushViewController(detailMakeUpTouchViewController, animated: true)
                tableView.deselectRowAtIndexPath(indexPath , animated: true)
            break
            case "7"://推荐的新会员成功注册【您的小伙伴XXXX（推荐码：181817）已经加入小饭桌】不可点击
            break
            case "8"://推荐的新项目被定为优质项目【恭喜您！您提交的“XXX（项目名）”项目已经选为优质项目】不可点击
            break
            case "9"://
            break
            case "10"://
            break
            case "11"://赞发言
                var personCommentViewController = PersonCommentViewController(nibName: "PersonCommentViewController", bundle: nil,param:id)
                self.navigationController?.pushViewController(personCommentViewController, animated: true)
            case "12"://活动回复被评论
                var vc = ActivityCommentViewController(nibName: "BaseCommentViewController", bundle: nil,param: id)
                self.navigationController?.pushViewController(vc, animated: true)
            case "13"://文章回复被评论
                var vc = ArticleCommentViewController(nibName: "BaseCommentViewController", bundle: nil,param: id)
                self.navigationController?.pushViewController(vc, animated: true)
            case "14"://组队被回复
                var data = ["_id":id]
                var detailMakeUpTouchViewController = DetailMakeUpTouchViewController(nibName: "DetailMakeUpTouchViewController", bundle: nil, param: data)
                self.navigationController?.pushViewController(detailMakeUpTouchViewController, animated: true)
                tableView.deselectRowAtIndexPath(indexPath , animated: true)
            case "15"://组队回复被评论
                var data = ["_id":id]
                var detailMakeUpTouchViewController = DetailMakeUpTouchViewController(nibName: "DetailMakeUpTouchViewController", bundle: nil, param: data)
                self.navigationController?.pushViewController(detailMakeUpTouchViewController, animated: true)
                tableView.deselectRowAtIndexPath(indexPath , animated: true)
            case "16"://被邀请
                var topicDetailViewController = TopicDetailViewController(nibName: "TopicDetailViewController", bundle: nil,param: id)
                self.navigationController?.pushViewController(topicDetailViewController, animated: true)
            case "17"://被@
                var personCommentViewController = PersonCommentViewController(nibName: "PersonCommentViewController", bundle: nil,param:id)
                self.navigationController?.pushViewController(personCommentViewController, animated: true)
            default:
            break
        }

        
    }
    
    
    
    //获取消息列表
    func getMessageList(){
        HttpManager.sendHttpRequestPost(GETMESSAGELIST, parameters:
            ["userId": ApplicationContext.getUserID()!,
            "begin":"0",
            "limit":"10"
            ],
            success: { (json) -> Void in
                
                FLOG("获取消息列表返回数据json:\(json)")
                //服务器数据返回成功
                self.messageList.removeAll(keepCapacity: false)
                var ismore: Bool?  = json["isMore"] as? Bool

                if json["isMore"] as! Bool == true {
                    self.messageTableView.footerHidden = false
                }else{
                    self.messageTableView.footerHidden = true
                }
                var messageArr = json["messageList"] as! [[String:AnyObject]]
                for message in messageArr {
                    self.messageList.append(SystemMessage(dataDic: message))
                }
                self.messageTableView.reloadData()
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
    
    
    //加载更多
    func loadMore(){
        var begin = NSString(format: "%d", self.messageList!.count)
        
        HttpManager.sendHttpRequestPost(GETMESSAGELIST, parameters:
            ["userId": ApplicationContext.getUserID()!,
                "begin":begin,
                "limit":5
            ],
            success: { (json) -> Void in
                
                FLOG("获取消息列表返回数据json:\(json)")
                //服务器数据返回成功
                if json["isMore"] as! Bool == true {
                    self.messageTableView.footerHidden = false
                }else{
                    self.messageTableView.footerHidden = true
                }
                var messageArr = json["messageList"] as! [[String:AnyObject]]
                for message in messageArr {
                    self.messageList.append(SystemMessage(dataDic: message))
                }
                self.messageTableView.reloadData()
                self.messageTableView.footerEndRefreshing()
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
                self.messageTableView.footerEndRefreshing()
        })
    }
    
    func resetPushCount(){
        HttpManager.sendHttpRequestPost(CLEAR_PUSH_COUNT, parameters:
            ["userId": ApplicationContext.getUserID()!
            ],
            success: { (json) -> Void in
                
                FLOG("消息清零json:\(json)")
                NSUserDefaults.standardUserDefaults().setObject(0, forKey: "push_count")
                NSUserDefaults.standardUserDefaults().synchronize()
                NSNotificationCenter.defaultCenter().postNotificationName("refresh_push_count", object: nil)
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")

        })
    }
}
