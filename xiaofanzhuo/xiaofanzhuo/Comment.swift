//
//  Comment.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/27.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class Comment {
    var id           : String? //评论的Id
    var userIdFrom   : String? //评论者的id
    var userNameFrom : String? //评论者昵称
    var avatarFrom   : String? //评论者的头像
    var time         : Double? //评论发布时间
    var userIdTo     : String? //被评论者的Id”, 此id可为回复者的Id，也可为评论者Id
    var userIdToName : String? //被评论者的昵称
    var content      : String? //评论的内容
    var isReply      : Bool?   //是否为评论回复 true 针对回复的评论，false针对评论的评论
    
    init(dataDic : [String:AnyObject]){
        id           = dataDic["_id"] as? String
        userIdFrom   = dataDic["userIdFrom"] as? String
        userNameFrom = dataDic["userNameFrom"] as? String
        avatarFrom   = dataDic["avatarFrom"] as? String
        time         = dataDic["time"] as? Double
        userIdTo     = dataDic["userIdTo"] as? String
        userIdToName = dataDic["userIdToName"] as? String
        content      = dataDic["content"] as? String
        isReply      = dataDic["isReply"] as? Bool
        
//        println("Comment: id:\(id),userIdFrom:\(userIdFrom),userNameFrom:\(userNameFrom),avatarFrom:\(avatarFrom),time:\(time),userIdTo:\(userIdTo),userIdToName:\(userIdToName),content:\(content),isReply:\(isReply)")
    }
}

extension Comment {
    func discription() {
        println("Comment: id:\(id),userIdFrom:\(userIdFrom),userNameFrom:\(userNameFrom),avatarFrom:\(avatarFrom),time:\(time),userIdTo:\(userIdTo),userIdToName:\(userIdToName),content:\(content),isReply:\(isReply)")
    }
}