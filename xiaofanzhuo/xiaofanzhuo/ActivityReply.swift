//
//  ActivityReply.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/11.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class ActivityReply {
    
    var id              : String? //回复的id
    var userId          : String? //回复发起者的Id
    var userName        : String? //回复发起人姓名
    var replyToUserName : String? //被评论人的名字
    var avatar          : String? //发起人头像
    var content         : String? //内容
    var replyTime       : Double? //发起时间
    var isReply         : Bool?   //是否是被评论
    
    init(dataDic : [String:AnyObject]){
        id              = dataDic["id"] as? String
        userId          = dataDic["userId"] as? String
        userName        = dataDic["userName"] as? String
        replyToUserName = dataDic["replyToUserName"] as? String
        avatar          = dataDic["avatar"] as? String
        content         = dataDic["content"] as? String
        replyTime       = dataDic["replyTime"] as? Double
        isReply         = dataDic["isReply"] as? Bool
    }
    
    func description() {
        println("ActivityReply:id:\(id),userId:\(userId),userName:\(userName),replyToUserName:\(replyToUserName),avatar:\(avatar),content:\(content),replyTime:\(replyTime),isReply:\(isReply)")
    }
}

//用于显示数据
extension ActivityReply :CommonTableCellAdapter{
    func dataForCommentTableCell()->(avatarUrl:NSURL,name:String,time:String,contentText:NSMutableAttributedString){
        
        var avatarUrl = (avatar == nil) ? NSURL(string: "")! : NSURL(string: avatar!)!
        var name = userName ?? ""
        var time = (replyTime == nil) ? CommonTool.getLastOnlineTime("")
                                      : CommonTool.getLastOnlineTime("\(replyTime!)")
        var prefix = isReply! ? "回复@\(replyToUserName!)：":""
        var contentText = (content == nil) ? NSMutableAttributedString(string: "")
                                           : NSMutableAttributedString(string: prefix + content!)
        
        //配置attribute
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        contentText.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, contentText.length))
        contentText.addAttribute(NSKernAttributeName, value: NSNumber(float: 0.5), range: NSMakeRange(0, contentText.length))
        contentText.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 15)!, range: NSMakeRange(0, contentText.length))
        
        return (avatarUrl:avatarUrl,name:name,time:time,contentText:contentText)
    }
}

