//
//  AvaterTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-15.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class AvaterTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadData() {
        
        //设置头像形状
        avatarImageView.layer.cornerRadius = 5
        avatarImageView.clipsToBounds = true
        
        
        usernameLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 18)
        ageLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 14)
        addressLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 14)
        var userInfo : [String : AnyObject] = ApplicationContext.getMyUserInfo()!
        var avatarImageUrl = userInfo["avatar"] as? NSString
//        avatarImageView.sd_setImageWithURL(NSURL(string: avatarImageUrl!))
        
        
        avatarImageView.sd_setImageWithURL(NSURL(string: avatarImageUrl! as String), placeholderImage: UIImage(named: "avatarDefaultImage"))
        usernameLabel.text = userInfo["username"] as? String
        ageLabel.text = userInfo["age"] as? String
        addressLabel.text = userInfo["city"] as? String
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
