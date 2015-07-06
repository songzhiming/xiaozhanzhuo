//
//  CommunityTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/19.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class CommunityTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var avatarBtn: UIButton!

    var topic : CommunityTopic!

    class var cellHeight : CGFloat {
        return 93
    }
    
    class var cellID : String {
        return "CommunityTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = 2
        avatar.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

//MARK: -类方法
extension CommunityTableViewCell{
    func loadData(topic :CommunityTopic){
        self.topic = topic
//        if let ava = topic.avatar {
//            avatar.sd_setImageWithURL(NSURL(string:ava), placeholderImage: UIImage(named:"avatarDefaultImage"))
//        }
        
        var str = NSMutableAttributedString(string:topic.title!)
        var style = NSMutableParagraphStyle()
        style.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        style.lineSpacing = 2
        str.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, str.length))
        str.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 16)!, range: NSMakeRange(0, (topic.title! as NSString).length))
        
        titleLabel.attributedText=str
        //titleLabel.text = topic.title
        
        if let count = topic.count {
            if count >= 10000 {
                var strCount : NSString = NSString(format: "%.1f",Float(topic.count!)/10000)
                countLabel.text = "\(strCount)万"
            }else{
                countLabel.text = "\(topic.count!)"
            }
        }
        
        if let name = topic.userName {
            userName.text = "\(name)"
        }else{//用于我收藏的话题
            userName.text = topic.userName1
        }
        if let time = topic.time {
            timeLabel.text = CommonTool.getLastOnlineTime("\(time)") //+ "发布"
        }
    }
    
    func getDynamicCellHeight()->CGFloat{
        self.layoutIfNeeded()
        var limitWidth : CGFloat = UIScreen.mainScreen().bounds.width - 28 - 4
        var height: CGFloat = 0
        
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        var size =  (topic.title! as NSString).boundingRectWithSize(CGSizeMake(limitWidth , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont(name: "FZLanTingHeiS-R-GB", size: 16)!,NSParagraphStyleAttributeName:style],
            context: nil)
//        var size = titleLabel.attributedText.boundingRectWithSize(CGSizeMake(limitWidth , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        height = size.height
//        FLOG("height:\(height)")

        if height > 39 { //2行最大行高为39，如果大于2行，则最多显示2行 + 4(3个行高)
            height = 39 
        }
        
        //[V:|-10-[titleLabel]-16-[avatar]-11-[灰边]-|]
        return 10 + height + 16 + 20 + 11 + 5
    }
    
    
}

//MARK: -按钮点击
extension CommunityTableViewCell{
    @IBAction func avatarBtnClick(sender: AnyObject) {
        
        avatarBtn.enabled = false
        var useId = self.topic.userId
        HttpManager.sendHttpRequestPost(GETUSERINFO, parameters:
            ["userId": ApplicationContext.getUserID()!,
            "id": useId!],
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
                self.avatarBtn.enabled = true
                FLOG("失败原因:\(reason)")
        })
    }
}
