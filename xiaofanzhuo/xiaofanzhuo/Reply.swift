//
//  Reply.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/21.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class Reply {
    var replyId  : String? //此条回复的Id
    var userId   : String? //回复者Id
    var userName : String? //回复者昵称
    var avatar   : String? //回复者头像
    var time     : Double? //回复时间
    var imageUrl : String? //回复的图片
    var content  : String? //回复内容
    var count    : Int? = 0//评论总数，针对本次回复的评论数
    var praiseCount:Int? = 0//点赞数
    
    init(dataDic : [String:AnyObject]){
        replyId  = dataDic["_id"] as? String
        userId   = dataDic["userId"] as? String
        userName = dataDic["username"] as? String
        avatar   = dataDic["avatar"] as? String
        time     = dataDic["time"] as? Double
        imageUrl = dataDic["imageUrl"] as? String
        content  = dataDic["content"] as? String
        count    = dataDic["count"] as? Int
        praiseCount = dataDic["praiseCount"] as? Int
//        println("replyId:\(replyId),userId:\(userId),userName:\(userName),avatar:\(avatar),time:\(time),imageUrl:\(imageUrl),content:\(content),count:\(count)")
    }
}