//
//  AtUser.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/18.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation
class AtUser {
    var userId   : String? //@用户的Id
    var username : String? //@用户昵称
    
    init(dataDic : [String:AnyObject]){
        userId     = dataDic["userId"] as? String
        username   = dataDic["username"] as? String
    }
}