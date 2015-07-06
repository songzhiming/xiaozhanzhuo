//
//  MyCommunityTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/3/1.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class MyCommunityTableViewCell: UITableViewCell {

    class var cellID : String {
        return "MyCommunityTableViewCell"
    }
    
    class var cellHeight : CGFloat{
        return 74
    }
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var topic : CommunityTopic!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK: -类方法
extension MyCommunityTableViewCell {
    func loadData(topic :CommunityTopic){
        self.topic = topic

        titleLabel.text = topic.title
        
        if let count = topic.count {
            countLabel.text = "评论 \(topic.count!)"
        }
    
        if let time = topic.time {
            if CommonTool.getLastOnlineTime("\(time)").hasSuffix("分钟前") {
                timeLabel.textColor = UIColor(red: 53/255.0, green: 148/255.0, blue: 255/255.0, alpha: 1.0)
            }else{
                timeLabel.textColor = UIColor.grayColor()
            }
            timeLabel.text = CommonTool.getLastOnlineTime("\(time)")
        }
    }
}
