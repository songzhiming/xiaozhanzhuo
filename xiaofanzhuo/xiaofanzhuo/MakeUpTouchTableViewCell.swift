//
//  MakeUpTouchTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-20.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class MakeUpTouchTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var taskOwnerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishTimeLabel: UILabel!
    @IBOutlet weak var avatarBtn: UIButton!
    
    var currentDic : NSDictionary?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func loadData(data : NSDictionary?){
        //字号
        
        //设置头像形状
        avatarImage.layer.cornerRadius = 5
        avatarImage.clipsToBounds = true
        
        
        taskOwnerLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 14)
        titleLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 16)
        publishTimeLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 12)
        
        
        self.currentDic = data
        var avatarImageUrl = data?.objectForKey("avatar") as? NSString
//        println("url===\(NSURL(string: avatarImageUrl!))")
        

        if let url = avatarImageUrl {
            avatarImage.sd_setImageWithURL(NSURL(string:avatarImageUrl! as String), placeholderImage: UIImage(named:"avatarDefaultImage"))
        }else{
            avatarImage.image = UIImage(named: "avatarDefaultImage")
        }
        
//        println("data:::\(data)")
        if (data?.objectForKey("username") != nil) {
            taskOwnerLabel.text = "" + String(data?.objectForKey("username") as! NSString)
        }else{
            taskOwnerLabel.text = ""
        }

        //设置行间距
        var str = NSMutableAttributedString(string: (data?.objectForKey("title")! as! NSString) as NSString as String)
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        style.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        str.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, str.length))
        
        titleLabel.attributedText = str

        var time = data?.objectForKey("time") as! String
//        FLOG("TIME::\(time)")
        
        if CommonTool.getLastOnlineTime(time).hasSuffix("分钟前") {
            publishTimeLabel.textColor = UIColor(red: 53/255.0, green: 148/255.0, blue: 255/255.0, alpha: 1.0)
        }else{
            publishTimeLabel.textColor = UIColor.grayColor()
        }
        
        publishTimeLabel.text =  CommonTool.getLastOnlineTime(time) as String

    }

    
    
    @IBAction func onclickAvaterImageView(sender: AnyObject) {
        self.avatarBtn.enabled = false
        var useId = self.currentDic?.objectForKey("userId") as? String
        HttpManager.sendHttpRequestPost(GETUSERINFO, parameters:
            ["userId": ApplicationContext.getUserID()!,
                "id": useId!
            ],
            success: { (json) -> Void in
                self.avatarBtn.enabled = true
                FLOG("查看个人信息返回json:\(json)")
                if useId == ApplicationContext.getUserID()! {
                    var personalSettingViewController = PersonalSettingViewController(nibName: "PersonalSettingViewController", bundle: nil,param:useId)
                    CommonTool.findNearsetViewController(self).navigationController?.pushViewController(personalSettingViewController, animated: true)
                }else{
                    var otherInfoViewController = OtherInfoViewController(nibName: "OtherInfoViewController", bundle: nil,param:useId)
                    CommonTool.findNearsetViewController(self).navigationController?.pushViewController(otherInfoViewController, animated: true)
                }
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
                self.avatarBtn.enabled = true
        })
    }
}
