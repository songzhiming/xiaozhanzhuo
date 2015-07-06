//
//  DetailMakeUpTouchTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-21.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class DetailMakeUpTouchTableViewCell: UITableViewCell {

    @IBOutlet weak var adviceTextLabel: UILabel!
    @IBOutlet weak var acceptTimeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var avatarBtn: UIButton!
    
    var currentDic : [String:AnyObject]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.selectionStyle = UITableViewCellSelectionStyle.None;
        // Initialization code
    }
}

//MARK: -实例方法
extension DetailMakeUpTouchTableViewCell {
    func loadData(data : [String:AnyObject]){
        
        //设置头像形状
        avatarImage.layer.cornerRadius = 2
        avatarImage.clipsToBounds = true
        
        
        currentDic = data
        var avatarImageUrl = data["avatar"] as? String
        if let url = avatarImageUrl {
            avatarImage.sd_setImageWithURL(NSURL(string:url), placeholderImage:
                UIImage(named:"avatarDefaultImage"))
        }
        var isReply = data["isReply"] as! Bool
        var dataContent = data["content"] as! String
        var userToName = data["userIdToName"] as! String
        
        var content = isReply ? "回复@\(userToName)：" + dataContent : dataContent
        usernameLabel.text = data["userNameFrom"] as? String
        var time: AnyObject? = data["time"]
        acceptTimeLabel.text = "\(time!)"
        
        //设置行间距
        var str = NSMutableAttributedString(string: content)
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        str.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 14)!, range: NSMakeRange(0, str.length))
        str.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, str.length))
        //添加字符间距
        str.addAttribute(NSKernAttributeName, value: NSNumber(float: 0.5), range: NSMakeRange(0, str.length))
        
        adviceTextLabel.attributedText = str
//        adviceTextLabel.text = data["content"] as? String
        // 66 = margin(=8)*2 + table灰色margin(=5)*2 + 头像宽度（=20）+ labelInset(=4)*2
        
    }
    
    func getDynamicCellHeight()->CGFloat{
        self.layoutIfNeeded()
        var size = adviceTextLabel.attributedText.boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 66 , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
//        var size =  (adviceTextLabel.text! as NSString).boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 66 , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont(name: "FZLanTingHeiS-R-GB", size: 14)!],
//            context: nil)
        
        var height = size.height

        return  8 + 2 + 20 + (size.height) + 10
    }
}

//MARK: -按钮点击
extension DetailMakeUpTouchTableViewCell {
    @IBAction func onclickPhoneButton(sender: AnyObject) {
        var phone = self.currentDic["phone"] as? String
        CommonTools.makeCall(phone!)
    }
    @IBAction func onclickAvatarButton(sender: AnyObject) {
        
        self.avatarBtn.enabled = false
//        FLOG("userid->>>>>>>>>\(self.currentDic)")
        var useId = self.currentDic["userIdFrom"] as? String
        HttpManager.sendHttpRequestPost(GETUSERINFO, parameters:
            ["userId": ApplicationContext.getUserID()!,
            "id": useId!
            ],
            success: { (json) -> Void in
                self.avatarBtn.enabled = true
                FLOG("查看个人信息返回json:\(json)")
                var vc : UIViewController!
                if useId == ApplicationContext.getUserID()! {
                    vc = PersonalSettingViewController(nibName: "PersonalSettingViewController", bundle: nil,param:useId)
                }else{
                    vc = OtherInfoViewController(nibName: "OtherInfoViewController", bundle: nil,param:useId)
                }
                CommonTool.findNearsetViewController(self).navigationController?.pushViewController(vc, animated: true)
            },
            failure:{ (reason) -> Void in
                self.avatarBtn.enabled = true
                FLOG("失败原因:\(reason)")
        })
    }
}
