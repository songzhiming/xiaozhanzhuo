//
//  ReplyInfo.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/27.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class ReplyInfo {
    var id       : String? //本条回复的Id
    var userId   : String? //回复发布者的id
    var userName : String? //回复者的昵称
    var avatar   : String? //回复者的头像
    var time     : Double? //回复发布的时间
    var content  : String? //回复的内容
    var imageUrl : [[String:AnyObject]]? //回复的图片
    var count    : Int? //回复总数
    var commentList: [Comment]? = [Comment]()//回复List
    var isMore   : Bool?   //是否有更多回复
    var isMy     : Bool?   //是否为自己发布的话题
    var isPraise : Bool?   //是否已赞
    var praiseCount :Int?  //赞数
    var userIds  = [AtUser]()//被@用户数组
    
    init(){
        
    }
    
    init(dataDic : [String:AnyObject]){
        id        = dataDic["_id"] as? String
        userId    = dataDic["userId"] as? String
        userName  = dataDic["username"] as? String
        avatar    = dataDic["avatar"] as? String
        time      = dataDic["time"] as? Double
        content   = dataDic["content"] as? String
        imageUrl  = dataDic["imageUrl"] as? [[String:AnyObject]]
        count     = dataDic["count"] as? Int
        isMore    = dataDic["isMore"] as? Bool
        isMy      = dataDic["isMy"] as? Bool
        isPraise  = dataDic["isPraise"] as? Bool
        praiseCount = dataDic["praiseCount"] as? Int

        //组装replylist
        var commentDic = dataDic["commentList"] as! [[String:AnyObject]]
        var idsDic = dataDic["userIds"] as! [[String:AnyObject]]
        
        for  dataDic in commentDic {
            commentList?.append(Comment(dataDic: dataDic))
        }
        for user in idsDic {
            userIds.append(AtUser(dataDic:user))
        }
    }
}

extension ReplyInfo {
    func discription() {
        println("ReplyInfo:id:\(id),userId:\(userId),userName:\(userName),avatar:\(avatar),time:\(time),content:\(content),imageUrl:\(imageUrl),count:\(count),isMore:\(isMore),isMy:\(isMy),isPraise:\(isPraise)")
    }
    
    func getAtUserAttributteString() -> NSMutableAttributedString {
        
        var attribute = userIds.count > 0 ? NSMutableAttributedString(string: "\n") : NSMutableAttributedString(string: "")
        var count = 0 //用于点击跳转取userInfos的下标
        for user in userIds {
            if let name = user.username {
                var attributeName = NSMutableAttributedString(string: "@\(name)")
                attributeName.addAttribute(NSLinkAttributeName, value: NSURL(string: "\(count++)")!, range: NSMakeRange(0, attributeName.length))
                attributeName.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 14)!, range: NSMakeRange(0, attributeName.length))
                var space = NSMutableAttributedString(string: "  ")
                attribute.appendAttributedString(attributeName)
                attribute.appendAttributedString(space)
            }
        }
        return attribute
    }
}