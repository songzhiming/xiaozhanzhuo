//
//  TopicCommentCell.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/19.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class TopicCommentCell: UITableViewCell {

    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var publicTimeLabel: UILabel!
    @IBOutlet weak var commentTimeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarBtn: UIButton!
    @IBOutlet weak var praiseLabel: UILabel!
    @IBOutlet weak var commentImage: UIImageView!
    
    var data : AnyObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = 2
        avatar.layer.masksToBounds = true
        praiseLabel.layer.cornerRadius = 2
        praiseLabel.layer.masksToBounds = true
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension TopicCommentCell{
    
    func setCommentCountHidden(yesOrNo : Bool){
        commentCount.hidden = yesOrNo
    }

    func loadData(data :AnyObject){
        self.data = data
        avatar.sd_setImageWithURL(NSURL(string:""), placeholderImage: UIImage(named:"avatarDefaultImage"))
        
        if data is Reply {
            var reply = data as! Reply
            if let ava = reply.avatar {
                avatar.sd_setImageWithURL(NSURL(string:ava), placeholderImage: UIImage(named:"avatarDefaultImage"))
            }
            contentLabel.numberOfLines = 4

            var str = NSMutableAttributedString(string:reply.content!)
            var style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            style.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            str.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 15)!, range: NSMakeRange(0, str.length))
            str.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, str.length))
            str.addAttribute(NSKernAttributeName, value: NSNumber(float: 0.5), range: NSMakeRange(0, str.length))
            
            praiseLabel.hidden = false
            commentImage.hidden = false
            
            contentLabel.attributedText = str
            
            userNameLabel.text = reply.userName
            
            praiseLabel.text = "\(reply.praiseCount!)"
            
            if let time = reply.time {
                var strTime = "\(time)"
                publicTimeLabel.text = "\(CommonTool.getLastOnlineTime(strTime))"
//                publicTimeLabel.hidden = true
//                publicTimeLabel.text = "发布时间：\(time)"
            }
            if let count = reply.count {
                commentCount.text = "\(count)"
            }
    //        "参与人数：\(topic.count!)"
    //        countLabel.text = "参与人数：\(topic.count!)"
        }else if data is Comment {
            var comment = data as! Comment
            if let ava = comment.avatarFrom {
                avatar.sd_setImageWithURL(NSURL(string:ava), placeholderImage: UIImage(named:"avatarDefaultImage"))
            }
            contentLabel.numberOfLines = 0
            var content = ""
            if comment.isReply! {
                if let userToName = comment.userIdToName {
                    content = "回复@\(userToName)：" + comment.content!
                }
            }else{
                content = comment.content!
            }
            var str = NSMutableAttributedString(string:content)
            var style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            
            str.addAttribute(NSKernAttributeName, value: NSNumber(float: 0.5), range: NSMakeRange(0, str.length))
            str.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, str.length))
            str.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 15)!, range: NSMakeRange(0, str.length))
            contentLabel.attributedText = str

            
            userNameLabel.text = comment.userNameFrom
            
            if let time = comment.time {
                var strTime = "\(time)"
                commentTimeLabel.text = "\(CommonTool.getLastOnlineTime(strTime))"
                commentTimeLabel.hidden = false
                publicTimeLabel.hidden = true

            }
            
        }// else if

    }
    
    func getCellDynamicHeight() -> CGFloat {
        self.layoutIfNeeded()
        // 51 = margin(=8)*2 + table灰色margin(=5)*2 + 头像宽度（=17）+ labelInset(=4)*2
        var limitWidth : CGFloat = UIScreen.mainScreen().bounds.width - 53 - 4

        var style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        var size = (contentLabel.text! as NSString).boundingRectWithSize(CGSizeMake(limitWidth , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont(name: "FZLanTingHeiS-R-GB", size: 15)!,NSKernAttributeName:NSNumber(float: 0.5),NSParagraphStyleAttributeName:style],
            context: nil)
        var height = size.height
//        FLOG("height:\(height)")
        if self.data is Reply {

            if height > 90 { //4行最大行高为90，如果大于4行，则最多显示4行
                height = 90
            }
        }

        //margin + 头像高度 + 正文离头像高度 + 正文高度 + margin
        return 8 + 17 + 6 + (height) + 8
    }
    
}

//MARK: -按钮点击
extension TopicCommentCell{
    @IBAction func avatarBtnClick(sender: AnyObject) {
        var useId : String?
        if data is Reply {
            var reply = data as! Reply
            useId = reply.userId
        }else if data is Comment {
            var comment = data as! Comment
            useId = comment.userIdFrom
        }
        self.avatarBtn.enabled = false
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
                self.avatarBtn.enabled = true
                FLOG("失败原因:\(reason)")
        })//HTTPManager
    }
}