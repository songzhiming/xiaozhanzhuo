//
//  WelfareTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-3-5.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class WelfareTableViewCell: UITableViewCell {

    @IBOutlet weak var giftImageView: UIImageView!
    @IBOutlet weak var giftName: UILabel!
    @IBOutlet weak var giftIntegral: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func loadData(data : NSDictionary?) {
        giftName.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 16)
        giftIntegral.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 14)
        giftName.text = data?.objectForKey("name") as? String
        giftIntegral.text = "兑换积分:" + String(data?.objectForKey("integral") as! Int) + "积分"
        
        var avatarImageUrl = data?.objectForKey("imageUrl") as? NSString
        println(avatarImageUrl)
        giftImageView.sd_setImageWithURL(NSURL(string:avatarImageUrl! as String), placeholderImage: UIImage(named:"avatarDefaultImage"))

    }

    
    
    
}
