//
//  MyReplyCell.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/3/24.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class MyReplyCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    class var cellID : String{
        return "MyReplyCell"
    }
    class var cellHeight : CGFloat{
        return 80
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension MyReplyCell {
    func loadData(data:Reply){
        contentLabel.text = data.content

        if CommonTool.getLastOnlineTime("\(data.time!)").hasSuffix("分钟前") {
            timeLabel.textColor = UIColor(red: 53/255.0, green: 148/255.0, blue: 255/255.0, alpha: 1.0)
        }else{
            timeLabel.textColor = UIColor.grayColor()
        }
        timeLabel.text = CommonTool.getLastOnlineTime("\(data.time!)")
    }
}
