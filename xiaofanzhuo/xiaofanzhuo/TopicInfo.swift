//
//  TopicInfo.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/21.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class TopicInfo {

    var id       : String? //话题的id,从上级页面传值获得
    var title    : String? //话题标题
    var userId   : String? //话题发起者的Id
    var userName : String? //话题发起者昵称
    var avatar   : String? //话题发起者头像
    var time     : Double? //话题发布时间
    var imageUrl : [[String:AnyObject]]? //话题图片
    var intro    : String? //话题简介
    var count    : Int? //回复总数
    var replyList: [Reply]? = [Reply]()//回复List
    var isMore   : Bool?   //是否有更多回复
    var isMy     : Bool?   //是否为自己发布的话题
    var isCollected : Bool? //是否已经收藏
    
    init(){
        
    }
    
    init(dataDic : [String:AnyObject]){

        title     = dataDic["title"] as? String
        userId    = dataDic["userId"] as? String
        userName  = dataDic["username"] as? String
        avatar    = dataDic["avatar"] as? String
        time      = dataDic["time"] as? Double
        imageUrl  = dataDic["imageUrl"] as? [[String:AnyObject]]
        intro     = dataDic["intro"] as? String
        count     = dataDic["count"] as? Int
        isMore    = dataDic["isMore"] as? Bool
        isMy      = dataDic["isMy"] as? Bool
        isCollected = dataDic["isCollected"] as? Bool

  //      println("dataDic\(dataDic)")
//        println("title:\(title),userId:\(userId),userName:\(userName),avatar:\(avatar),time:\(time),imageUrl:\(imageUrl),intro:\(intro),count:\(count),isMore:\(isMore),isMy:\(isMy),")
        //组装replylist
        var replyDic = dataDic["replyList"] as! [[String:AnyObject]]
        for  dataDic in replyDic {
            replyList?.append(Reply(dataDic: dataDic))
        }
       // println(replyList)
    }
}
extension TopicInfo {
    func discription() {
        println("id:\(id),title:\(title),userId:\(userId),userName:\(userName),avatar:\(avatar),time:\(time),imageUrl:\(imageUrl),intro:\(intro),count:\(count),isMore:\(isMore),isMy:\(isMy),isCollected:\(isCollected)")
    }
}