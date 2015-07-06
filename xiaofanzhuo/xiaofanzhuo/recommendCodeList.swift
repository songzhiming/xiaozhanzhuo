//
//  recommendCodeList.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-26.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class RecommendCodeList {
    var recomCode : String?         // 邀请码
    var time : String?   // 时间戳
    var isUse : Bool?   //是否使用
    
    init(dataDic : [String:AnyObject]){
        recomCode       = dataDic["recomCode"] as? String
        time = dataDic["time"] as? String
        isUse = dataDic["isUse"] as? Bool
    }
}