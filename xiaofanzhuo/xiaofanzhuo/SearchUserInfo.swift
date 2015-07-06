//
//  SearchUserInfo.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/18.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class SearchUserInfo :NSObject{
    var userId   : String?   //用户id
    var intro    : String?   //用户描述
    var avatar   : String?   //头像
    var username : String?   //用户名
    
    override init(){
        
    }
    
    init(dataDic:[String:AnyObject]){
        userId = dataDic["userId"] as? String
        
        var userInfo = dataDic["userInfo"] as? [String:AnyObject]
        if let info = userInfo {
            intro = info["intro"] as? String
            avatar = info["avatar"] as? String
            username = info["username"] as? String
        }
    }
}

extension SearchUserInfo{
    func dataForSearchCell() -> (intro:String,avatar:String,username:String){
        //UW = Un Wrap = 强制拆包
        var introUW = intro ?? ""
        var avatarUW = avatar ?? ""
        var usernameUW = username ?? ""
        return (intro:introUW,avatar:avatarUW,username:usernameUW)
    }
}