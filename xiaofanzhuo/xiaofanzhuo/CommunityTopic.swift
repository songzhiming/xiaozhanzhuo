//
//  CommunityTopic.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/21.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class CommunityTopic {
    var id       : String? //话题id
    var title    : String? //话题标题
    var userId   : String? //话题发起者的Id
    var userName : String? //话题发起人姓名
    var userName1: String? //接口文档usernameN大小写不同意，在我收藏的话题页面用这个来获取名字
    var avatar   : String? //话题发起人头像
    var count    : Int?    //参数人数
    var time     : Double? //发起时间
    
    init(){
        
    }
    init(dataDic : [String:AnyObject]){
        id        = dataDic["_id"] as? String
        title     = dataDic["title"] as? String
        userId    = dataDic["userId"] as? String
        userName  = dataDic["username"] as? String
        userName1 = dataDic["userName"] as? String
        avatar    = dataDic["avatar"] as? String
        count     = dataDic["count"] as? Int
        time      = dataDic["time"] as? Double
    }
}