//
//  NewsItem.swift
//  xiaofanzhuo
//
//  Created by 李亚坤 on 15/1/21.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class NewsList {
    var id: String?         // 文章Id
    var imageUrl: String?   // 文章图片url
    var title: String?      // 文章标题title
    var intro: String?      // 文章简介
    var htmlUrl: String?    // 文章url
    var shareUrl:String?    //分享的url
    
    init(dataDic : [String:AnyObject]){
        id       = dataDic["_id"] as? String
        title    = dataDic["title"] as? String
        imageUrl = dataDic["imageUrl"] as? String
        intro    = dataDic["intro"] as? String
        htmlUrl  = dataDic["htmlUrl"] as? String
        shareUrl = dataDic["shareUrl"] as? String
    }
}

extension NewsList {
    func discription() {
        println("id:\(id),title:\(title),imageUrl:\(imageUrl),intro:\(intro),htmlUrl:\(htmlUrl),shareUrl:\(shareUrl)")
    }
}