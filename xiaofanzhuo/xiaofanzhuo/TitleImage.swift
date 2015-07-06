//
//  TitleImage.swift
//  xiaofanzhuo
//
//  Created by 李亚坤 on 15/1/21.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class TitleImage {
    var id: String?         // 文章Id
    var imageUrl: String?   // 文章图片url
    var htmlUrl: String?    // 详情html
    var shareUrl:String?    //分享的url
    
    init(dataDic : [String:AnyObject]){
        id       = dataDic["_id"] as? String
        imageUrl = dataDic["imageUrl"] as? String
        htmlUrl  = dataDic["htmlUrl"]  as? String
        shareUrl = dataDic["shareUrl"] as? String
    }
}

extension TitleImage {
    func discription() {
        println("id:\(id),imageUrl:\(imageUrl),imageUrl:\(imageUrl),htmlUrl:\(htmlUrl),shareUrl:\(shareUrl)")
    }
}