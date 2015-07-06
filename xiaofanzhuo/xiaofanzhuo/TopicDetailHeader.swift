//
//  TopicDetailHeader.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/19.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class TopicDetailHeader: UIView {
    
    var isOpen : Bool = false
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var publicTimeLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var favorBtn: UIButton!
    @IBOutlet weak var avatarBtn: UIButton!
    @IBOutlet weak var inviteBtn: UIButton!
    
    //约束
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var imageTop: NSLayoutConstraint!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    @IBOutlet weak var textHeight: NSLayoutConstraint!
    
    var topicInfo : TopicInfo!
    //调整大小的常量
    let MARGIN : CGFloat = 8
    let SPLIT_LINE_HEIGHT : CGFloat = 1
    let TOPVIEW_HEIGHT : CGFloat = 40
    let COMMENT_COUNT_HEIGHT : CGFloat = 21
    let BUTTON_HEIGHT : CGFloat = 20
    //标志常量
    let IMAGE_START_TAG = 1000
    
    var contentTextHeigth : CGFloat!
    var titleTextHeight : CGFloat!
    
    var headerHeight_open : CGFloat!//展开的高度
    var headerHeight_close : CGFloat!//收起的高度
    
    var hasImage : Bool = false //是否有图片
    var initFlag : Bool = false //是否进行过初始化
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = 2
        avatar.layer.masksToBounds = true
        
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapToClose"))
        contentText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapToClose"))
        
//       self.frame = CGRectMake(0,0, UIScreen.mainScreen().bounds.width, 190)
    }
}

// MARK: - 按钮点击
extension TopicDetailHeader {
    @IBAction func inviteBtnClick(sender: AnyObject) {

        var vc = SearchUserViewController(nibName: "SearchUserViewController", bundle: nil)
        vc.delegate = self
        CommonTool.findNearsetViewController(self).navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openBtnClick(sender: AnyObject) {
        peformExpandCloseAnimation()
    }
    
    @IBAction func editBtnClick(sender: AnyObject) {
        var vc = EditMyTopicDetailViewController(nibName: "BasePublishViewController", bundle: nil,param:self.topicInfo)
        CommonTool.findNearsetViewController(self).navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func reportBtnClick(sender: AnyObject) {
        
        UIAlertView(title: "提示", message: "确定举报此用户？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定").show()
    }
    //收藏
    @IBAction func favBtnClcik(sender: AnyObject) {
        /****************代码已经弃用
        var url = ""
        var result = ""
        if self.favorBtn.selected {//已经收藏
            url = CANCEL_COLLECTION
            result = "取消收藏成功"
        }else{//没有收藏
            url = ADD_COLLECTION
            result = "收藏成功"
        }
        self.favorBtn.userInteractionEnabled = false
        HttpManager.sendHttpRequestPost(url, parameters:
            ["userId":ApplicationContext.getUserID()!,
                "id":self.topicInfo.id!],
            success: { (json) -> Void in
                
                FLOG("收藏话题返回json:\(json)")
                HYBProgressHUD.showSuccess(result)
                self.favorBtn.selected = !self.favorBtn.selected
                self.favorBtn.userInteractionEnabled = true
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
                self.favorBtn.userInteractionEnabled = true
        })
*****/
    }// favBtnClcik
    
    @IBAction func avatarBtnClick(sender: AnyObject) {
        var useId = topicInfo.userId
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
                FLOG("失败原因:\(reason)")
                self.avatarBtn.enabled = true
        })
    }
    
}

// MARK: - 类方法
extension TopicDetailHeader {
    func loadData(topicInfo:TopicInfo){
        
        self.isOpen = true
        
        self.topicInfo = topicInfo
//        if let ava = topicInfo.avatar {
//            avatar.sd_setImageWithURL(NSURL(string:ava), placeholderImage: UIImage(named:"avatarDefaultImage"))
//        }
        userNameLabel.text = topicInfo.userName
        if let time = topicInfo.time {
            var strTime = "\(time)"
            publicTimeLabel.text = "\(CommonTool.getLastOnlineTime(strTime))"
        }
        //是否隐藏编辑按钮
        if let isMy = topicInfo.isMy {
            editBtn.hidden = !isMy
            reportBtn.hidden = isMy
//            favorBtn.hidden = isMy
        }
        
//        FLOG(topicInfo.count)
        if let count = topicInfo.count {
            commentCount.text = "  \(count)条发言"
        }
        
//        //设置收藏按钮状态
//        if let isCollected = topicInfo.isCollected {
//            favorBtn.selected = isCollected
//        }
        
        var titleAttributeStr = NSMutableAttributedString(string:topicInfo.title!)
        var titleStyle = NSMutableParagraphStyle()
        titleStyle.lineSpacing = 5
        
        titleAttributeStr.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 18)!, range: NSMakeRange(0, titleAttributeStr.length))
        titleAttributeStr.addAttribute(NSParagraphStyleAttributeName, value: titleStyle, range: NSMakeRange(0, titleAttributeStr.length))
        titleAttributeStr.addAttribute(NSKernAttributeName, value: NSNumber(float: 0.5), range: NSMakeRange(0, titleAttributeStr.length))
        
        titleLabel.attributedText = titleAttributeStr
        titleTextHeight = titleLabel.attributedText.boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 10 -  16 , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil).height
        
        //设置正文字体，字体颜色，行距，字符间距
        var intro = topicInfo.intro! as NSString
        var str = NSMutableAttributedString(string:topicInfo.intro!)
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        
        str.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 16)!, range: NSMakeRange(0, intro.length))
        str.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1), range: NSMakeRange(0, intro.length))
        str.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, str.length))
        //添加字符间距
        str.addAttribute(NSKernAttributeName, value: NSNumber(float: 0.5), range: NSMakeRange(0, str.length))
        
        contentText.attributedText = str
        
        //计算正文在contentText的高度，减掉10 = 5 + 5 = TextField的2个inset的宽度 contentText.frame.size.width - 16
        var size = contentText.attributedText.boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 10 - 10 - 10 , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        var height = size.height

        contentTextHeigth = height + 16 + style.lineSpacing
        textHeight.constant = contentTextHeigth
//        
//        FLOG("行数：\(size.width / (UIScreen.mainScreen().bounds.width - 10 - 28))")
        FLOG("contentText.length:\(contentTextHeigth)")
   
        //显示正文图片
        imageWidth.constant = 0//默认为0
        imageTop.constant = 0
        if let imageUrls = topicInfo.imageUrl {
            var imageArray = imageUrls as [[String:AnyObject]]
            if imageArray.count > 0 {
                imageWidth.constant = (UIScreen.mainScreen().bounds.width - 8*2 - 10 - 2*4 ) / 5
                imageTop.constant = 10
                hasImage = true
                
                for var i = 0;i < imageArray.count; i++ {
                    var image = self.viewWithTag(IMAGE_START_TAG + i) as! UIImageView
                    var url = imageArray[i]["imageUrl"] as! String
                    image.sd_setImageWithURL(NSURL(string:url), placeholderImage: UIImage(named:"avater"))
                }
                self.adjustFrame()
            }
        }//if let
        
        self.setAllImagesHidden(false)
//        contentText.hidden = true
        contentText.alpha = 1

        adjustFrame()
        
        if !initFlag {
            //所有图片添加手势
            for var i = 0;i < 5; i++ {
                var imageView = self.viewWithTag(IMAGE_START_TAG + i) as! UIImageView
                var ges = UITapGestureRecognizer(target: self, action: "tapImage:")
                imageView.addGestureRecognizer(ges)
            }
            initFlag = true
        }
        
    }
    
    func adjustFrame(){
        self.layoutIfNeeded()//让titleLabel的属性刷新，获取高度
        headerHeight_open = TOPVIEW_HEIGHT + titleTextHeight + imageWidth.constant + imageTop.constant + contentTextHeigth + SPLIT_LINE_HEIGHT + MARGIN*2 + COMMENT_COUNT_HEIGHT

        headerHeight_close = TOPVIEW_HEIGHT + titleTextHeight + SPLIT_LINE_HEIGHT + MARGIN*2 +  COMMENT_COUNT_HEIGHT
        
        var isToShow = contentText.text.isEmpty && !hasImage
        var height = !isToShow ? headerHeight_open : headerHeight_close

        var frame = self.frame
        self.frame = CGRectMake(0, 0, frame.width, height)
        (self.superview as! UITableView).tableHeaderView = self
    
    }
    
    func setAllImagesHidden(yesOrNo : Bool) {
        if let imageUrls = self.topicInfo.imageUrl {
            var imageArray = imageUrls as [[String:AnyObject]]
            for var i = 0;i < 5 ; i++ {
                 var imageView = self.viewWithTag(IMAGE_START_TAG + i) as! UIImageView
                if i < imageArray.count {

                    if yesOrNo {//隐藏
                        imageView.alpha = 0
                        imageView.userInteractionEnabled = false
                    }else{
                        imageView.alpha = 1
                        imageView.userInteractionEnabled = true
                    }
                }else{

                    imageView.alpha = 0
                    imageView.userInteractionEnabled = false
                }
            }
        }
    }
    
    func tapImage(gesture:UITapGestureRecognizer){

        
        var imageView = gesture.view as? UIImageView
        var tag = imageView?.tag
        var index = tag! - IMAGE_START_TAG
        
        var imageArray : [String] = [String]()
        
        
        for (var i = 0 ;i < topicInfo.imageUrl!.count ; i++){
            
            var url = topicInfo.imageUrl![i]["imageUrl"] as! String
            
            imageArray.append(url)
        }
        
        var param = ["index":index,
            "imageArray":imageArray]
        
        var zoomViewController : ZoomViewController = ZoomViewController(nibName: "ZoomViewController", bundle: nil,param:param)
        zoomViewController.view.frame = UIScreen.mainScreen().bounds
        CommonTool.findNearsetViewController(self).addChildViewController(zoomViewController)
        CommonTool.findNearsetViewController(self).view.addSubview(zoomViewController.view)
    }
    
    //点击文本收起
    func tapToClose(){
        
        if contentText.isFirstResponder() {
            contentText.resignFirstResponder()
            return
        }
        peformExpandCloseAnimation()
    }
    
    func peformExpandCloseAnimation(){
        if contentText.text.isEmpty && !hasImage {
            return
        }
        var width = UIScreen.mainScreen().bounds.width - 10
        if isOpen == false {//展开
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.frame = CGRectMake(0, 0, width, self.headerHeight_open)
                (self.superview as! UITableView).tableHeaderView = self
                self.setAllImagesHidden(false)
                self.contentText.alpha = 1
                self.superview?.layoutIfNeeded()
            })

        }else{
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.frame = CGRectMake(0, 0, width, self.headerHeight_close)
                (self.superview as! UITableView).tableHeaderView = self
                self.setAllImagesHidden(true)
                self.contentText.alpha = 0
                self.superview?.layoutIfNeeded()
            })

        }
        isOpen = !isOpen
    }
}

//MARK:-UIAlertViewDelegate
extension TopicDetailHeader : UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1 {//点击确定按钮,举报
            
            var userId = ApplicationContext.getUserID()!
            var topiId = self.topicInfo.id!
            
            HttpManager.postDatatoServer(.POST, BASE_URL + BLOCK_TO_TOPIC, parameters: ["userId":userId,
                "id":topiId])
                .responseJSON { (_, _, JSON, _) -> Void in
                    if let json = JSON as? [String:AnyObject] {
                        if (json["code"] as! Int) == 0 {
                            var isSuccess = json["isSuccess"] as! Bool
                            var str = isSuccess ? "举报成功" : "您已举报过该用户"
                            HYBProgressHUD.showSuccess(str)
                            FLOG("举报发言返回json:\(json)")
                        }else{
                            HYBProgressHUD.showError(json["message"] as! String)
                        }
                    }else{
                        HYBProgressHUD.showError("网络连接错误！")
                    }
            }
        }
    }
}

//MARK:-SearchUserViewDelegate
extension TopicDetailHeader :SearchUserViewDelegate{
    func searchUserViewDidReturnData(searchUserInfo:SearchUserInfo){
        //添加邀请代码
        HttpManager.sendHttpRequestPost(INVITE, parameters:
            ["userId": ApplicationContext.getUserID()!,
                "topicId": topicInfo.id!,
                "invitedUserId":searchUserInfo.userId!
            ],
            success: { (json) -> Void in
                FLOG("邀请返回json:\(json)")
                HYBProgressHUD.showSuccess("邀请用户成功")
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
}
