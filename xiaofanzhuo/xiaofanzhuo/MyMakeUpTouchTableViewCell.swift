//
//  MyMakeUpTouchTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-23.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class MyMakeUpTouchTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func loadData(data : NSDictionary?){
        // println("data:\(data)")
//        var avatarImageUrl = data?.objectForKey("avatar") as? NSString
//        //        println("url===\(NSURL(string: avatarImageUrl!))")
//        avatarImage.sd_setImageWithURL(NSURL(string: avatarImageUrl!))
//        taskOwnerLabel.text = data?.objectForKey("username") as? NSString
        
        titleLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 16)
        publishTimeLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 12)
        
        

        
//        println("data:::\(data))")
        titleLabel.text = data?.objectForKey("title") as? String
        if (data?.objectForKey("state") as? String) == "1" {
            publishTimeLabel.text = "已完成"
            publishTimeLabel.textColor = UIColor.redColor()
        }else if (data?.objectForKey("state") as? String) == "4" {
            publishTimeLabel.text = "已取消"
            publishTimeLabel.textColor = UIColor.redColor()
        }else{
            var time = data?.objectForKey("time") as! String
            if CommonTool.getLastOnlineTime(time).hasSuffix("分钟前") {
                publishTimeLabel.textColor = UIColor(red: 53/255.0, green: 148/255.0, blue: 255/255.0, alpha: 1.0)
            }else{
                publishTimeLabel.textColor = UIColor.grayColor()
            }
            publishTimeLabel.text = CommonTool.getLastOnlineTime(time)
        }
        
//        println("time:::::::\(time)")
//        println("changeTime:::::\(CommonTool.getLastOnlineTime(time))")
//        publishTimeLabel.text = CommonTool.getLastOnlineTime(time)
        
    }
}
