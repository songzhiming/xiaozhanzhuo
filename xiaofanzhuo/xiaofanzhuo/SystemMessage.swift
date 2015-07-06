//
//  SystemMessage.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/20.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class SystemMessage {
    var name        : String?   //参与者昵称
    var contentType : String?   //参与了什么
    var content     : String?   //参与的内容
    var id          : String?   //参与内容的id
    var type        : String?   //参与内容的类型
    
    init(dataDic:[String:AnyObject]){
        name        = dataDic["name"] as? String
        contentType = dataDic["contentType"] as? String
        content     = dataDic["content"] as? String
        id          = dataDic["id"] as? String
        type        = dataDic["type"] as? String
    }
}

extension SystemMessage {
    func dataForSystemNotificationCell() -> (name:String,contentType:String,content:String) {
        var nameUW = name ?? ""
        var contentTypeUW = contentType ?? ""
        var contentUW = content ?? ""
        
        return (nameUW,contentTypeUW + "：",contentUW)
    }
}