//
//  AtDataSource.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/18.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class AtDataSource:NSObject{
    var userInfos = [SearchUserInfo](){
        didSet{
           translateNamesToAttributeNames() 
        }
    }
    var atAttributeNames = NSMutableAttributedString()
    
    override init(){
        
    }
}

extension AtDataSource{
    private func translateNamesToAttributeNames(){
        //字符串重置
        atAttributeNames = NSMutableAttributedString()
        var count = 0 //用于点击跳转取userInfos的下标
        for info in userInfos {
            if let name = info.username {
                
                var attributeName = NSMutableAttributedString(string: "@\(name)")
                attributeName.addAttribute(NSLinkAttributeName, value: NSURL(string: "\(count++)")!, range: NSMakeRange(0, attributeName.length))
                attributeName.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 14)!, range: NSMakeRange(0, attributeName.length))
                var space = NSMutableAttributedString(string: "  ")
                atAttributeNames.appendAttributedString(attributeName)
                atAttributeNames.appendAttributedString(space)
            }
        }
    }
    
    func translateUserIdsToJsonString() -> String{
        var jsonArray = [[String:String]]()
        for info in userInfos{
            if let id = info.userId {
                jsonArray.append(["userId":id])
            }
        }
        return ApplicationContext.toJSONString(jsonArray) as! String
    }
    
    func translateReplyInfo(replyInfo:ReplyInfo){
        for info in replyInfo.userIds {
            var searchInfo = SearchUserInfo()
            if let id = info.userId {
                searchInfo.userId = id
            }
            if let name = info.username {
                searchInfo.username = name
            }
            userInfos.append(searchInfo)
        }
    }
}
