//
//  PersonCommentHeader.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/27.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class PersonCommentHeader: UIView {


    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var contentTextHeigth: NSLayoutConstraint!
    @IBOutlet weak var imageTop: NSLayoutConstraint!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var publicTimeLabel: UILabel!
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var praiseBtn: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var avatarBtn: UIButton!
    @IBOutlet weak var praiseCountLabel: UILabel!
    
    //从左往右的5张图片，ugly的一个方法 viewWithTag在Ios8下一直报空
    @IBOutlet weak var imageView0: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    //装imageView的一个数组
    var imageViewArray : [UIImageView]!
    
    var replyInfo : ReplyInfo!
    var praiseCount = 0
    var initFlag : Bool = false //是否进行过初始化
    
    let MARGIN : CGFloat = 10
    let SPLIT_LINE_HEIGHT : CGFloat = 1
    let AVATAR_HEIGHT : CGFloat = 20 + 13
    let COMMENT_COUNT_HEIGHT : CGFloat = 21
    let IMAGE_START_TAG  = 50000
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame = CGRectMake(0,0, UIScreen.mainScreen().bounds.width - 10, 100)
        avatar.layer.cornerRadius = 2
        avatar.layer.masksToBounds = true
        
        imageViewArray = [UIImageView]()
        imageViewArray.append(imageView0)
        imageViewArray.append(imageView1)
        imageViewArray.append(imageView2)
        imageViewArray.append(imageView3)
        imageViewArray.append(imageView4)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

//MARK: -类方法
extension PersonCommentHeader {
    func loadData(replyInfo:ReplyInfo){
        
        //图片恢复默认状态
        for i in 0..<5 {
            imageViewArray[i].hidden = true
            imageViewArray[i].userInteractionEnabled = false
        }
        
        self.replyInfo = replyInfo
        //println("replyInfo:\(replyInfo.)")
        //replyInfo.discription()
        //装配头像
        if let ava = replyInfo.avatar {
            avatar.sd_setImageWithURL(NSURL(string:ava), placeholderImage: UIImage(named:"avatarDefaultImage"))
        }
        
        //评论数量
        if let count = replyInfo.count {
            commentCount.text = "  \(String(count))条评论"
        }
        
        //日期
        if let time = replyInfo.time {
            var strTime = "\(time)"
            publicTimeLabel.text = "发布日期:\(CommonTool.getLastOnlineTime(strTime))"
        }
        
        //昵称
        name.text = replyInfo.userName
        
        //装配正文
        var intro = replyInfo.content! as NSString
        var str = NSMutableAttributedString(string:replyInfo.content!)
        var style = NSMutableParagraphStyle()
        str.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 16)!, range: NSMakeRange(0, intro.length))
        str.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1), range: NSMakeRange(0, intro.length))
        str.addAttribute(NSKernAttributeName, value: NSNumber(float: 0.5), range: NSMakeRange(0, str.length))
        style.lineSpacing = 5
        str.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, str.length))
        
        //添加@列表
        str.appendAttributedString(replyInfo.getAtUserAttributteString())

        contentText.attributedText = str
        contentText.delegate = self
        //计算正文在contentText的高度，减掉16 = 8 + 8 = TextField的2个inset的宽度 contentText.frame.size.width - 16
        
//        var size =  (intro as NSString).boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 10 - 14 , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont(name: "FZLanTingHeiS-R-GB", size: 16)!,NSParagraphStyleAttributeName : style,NSKernAttributeName:NSNumber(float: 1)],
//            context: nil)
        
        var size = contentText.attributedText.boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 10 - 10 - 10 , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        var height = size.height
        contentTextHeigth.constant = height + 16 + style.lineSpacing
        
        
        //设置编辑按钮状态，删除按钮状态
        if let isMy = replyInfo.isMy {
            if isMy {
                reportBtn.hidden = true
                praiseBtn.hidden = true
                praiseCountLabel.hidden = true
            }else{
                editBtn.hidden = true
                deleteBtn.hidden = true
            }
        }
        
        //设置赞按钮状态
        if let praise = replyInfo.isPraise {
            praiseBtn.selected = praise
        }
        if let count = replyInfo.praiseCount {
            self.praiseCount = count
            praiseCountLabel.text = "\(self.praiseCount)"
        }
        
        //显示正文图片
//        imageTop.constant = 0
        imageWidth.constant = 0
        if let imageUrls = replyInfo.imageUrl {
            var imageArray = imageUrls as [[String:AnyObject]]
            if imageArray.count > 0 {
                imageWidth.constant = (UIScreen.mainScreen().bounds.width - 8*2 - 10 - 2*4 ) / 5
                imageTop.constant = 10
                FLOG("imageWidth.constant:\(imageWidth.constant)")
                for var i = 0;i < imageArray.count; i++ {
                    
//                    var image1 = self.viewWithTag(IMAGE_START_TAG + i) as UIImageView
                    var image = imageViewArray[i]
                    image.userInteractionEnabled = true
                    var url = imageArray[i]["imageUrl"] as! String
                    image.hidden = false
                    image.sd_setImageWithURL(NSURL(string:url), placeholderImage: UIImage(named:"avater"))
                }
                self.adjustFrame()
            }
        }
        
        if !initFlag {  //控制手势只添加一次
            initFlag = true
        }else{
            return
        }
        
        //所有图片添加手势
        for var i = 0;i < 5; i++ {
            var imageView = imageViewArray[i]
            var ges = UITapGestureRecognizer(target: self, action: "tapImage:")
            imageView.addGestureRecognizer(ges)
        }
        
        adjustFrame()
    }
    
    //调整大小
    func adjustFrame(){
        self.layoutIfNeeded()
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width - 10 ,
            self.MARGIN*2 +
            self.AVATAR_HEIGHT +
            self.SPLIT_LINE_HEIGHT +
            imageTop.constant +
            imageWidth.constant +
            contentTextHeigth.constant +
            self.COMMENT_COUNT_HEIGHT
        )
        FLOG("imagetop:\(imageTop.constant)")
        //println("herderframe1:\(self.frame)")
        //println("herderframe2:\(imageTop.constant),\(imageHeight.constant),\(contentTextHeigth.constant)")
    }
    
    func tapImage(gesture:UITapGestureRecognizer){
        var imageView = gesture.view as? UIImageView
        var tag = imageView?.tag
        var index = tag! - IMAGE_START_TAG
        
        var imageArray : [String] = [String]()
        FLOG ("tag:\(tag)")
        
        for (var i = 0 ;i < replyInfo.imageUrl!.count ; i++){
            
            var url = replyInfo.imageUrl![i]["imageUrl"] as! String
            
            imageArray.append(url)
        }
        
        var param = ["index":index,
            "imageArray":imageArray]
        
        var zoomViewController : ZoomViewController = ZoomViewController(nibName: "ZoomViewController", bundle: nil,param:param)
        zoomViewController.view.frame = UIScreen.mainScreen().bounds
        CommonTool.findNearsetViewController(self).addChildViewController(zoomViewController)
        CommonTool.findNearsetViewController(self).view.addSubview(zoomViewController.view)
//        FLOG ("NEARSET:\(CommonTool.findNearsetViewController(self))")
    }
    
    func praiseBtnAnimation(){

        var systemVersion = (UIDevice.currentDevice().systemVersion as NSString).floatValue
        if systemVersion < 8.0 {//ios7
            UIView.animateWithDuration(
                0.8,
                delay: 0.1,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0,
                options: UIViewAnimationOptions.CurveLinear,
                animations: { () -> Void in
                    self.praiseBtn.transform = CGAffineTransformMakeScale(1.3,1.3)
                    self.praiseBtn.transform = CGAffineTransformIdentity
                    self.layoutIfNeeded()
                }) { (Bool) -> Void in
            }
        }else{//ios8
            
            UIView.animateWithDuration(
                0.3,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0,
                options: UIViewAnimationOptions.CurveLinear,
                animations: { () -> Void in
                    self.praiseBtn.transform = CGAffineTransformMakeScale(1.3,1.3)
                    self.layoutIfNeeded()
                }) { (Bool) -> Void in
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        self.praiseBtn.transform = CGAffineTransformIdentity
                        self.layoutIfNeeded()
                    })
            }
        }
        
        
    }
}

//MARK: -按钮点击
extension PersonCommentHeader{
    //点赞
    @IBAction func praiseBtnClick(sender: AnyObject) {
        if self.praiseBtn.selected == true {//已经点赞
            self.praiseBtn.enabled = false
            HttpManager.sendHttpRequestPost(CANCEL_PRAISE_TO_TOPIC_REPLY, parameters:
                ["userId":ApplicationContext.getUserID()!,
                    "id":self.replyInfo.id!],
                success: { (json) -> Void in
                    
                    FLOG("取消点赞返回json:\(json)")
                    if let isSuccess = json["isSuccess"] as? Bool{
                        if isSuccess { //取消点赞成功，否则是已经点过赞
                            self.praiseBtn.selected = false
                            self.praiseBtnAnimation()
                            self.praiseCountLabel.text = "\(--self.praiseCount)"
                        }
                    }
                    self.praiseBtn.enabled = true
                },
                failure:{ (reason) -> Void in
                    self.praiseBtn.enabled = true
                    FLOG("失败原因:\(reason)")
            })
        }else{//未点赞
            self.praiseBtn.enabled = false
            HttpManager.sendHttpRequestPost(PRAISE_TO_TOPLY_REPLY, parameters:
                ["userId":ApplicationContext.getUserID()!,
                "id":self.replyInfo.id!],
                success: { (json) -> Void in
                    
                    FLOG("点赞返回json:\(json)")
                    if let isSuccess = json["isSuccess"] as? Bool{
                        if isSuccess { //点赞成功，否则是已经点过赞
                            self.praiseBtn.selected = true
                            self.praiseBtnAnimation()
                            self.praiseCountLabel.text = "\(++self.praiseCount)"
                        }
                    }
                    self.praiseBtn.enabled = true
                },
                failure:{ (reason) -> Void in
                    self.praiseBtn.enabled = true
                    FLOG("失败原因:\(reason)")
            })
        }//else
    }
    
    //编辑
    @IBAction func editBtnclick(sender: AnyObject) {

//        var param : [String:AnyObject] =
//        ["topicReplyId":self.replyInfo.id!,
//            "content":self.replyInfo.content!,
//            "imageUrl":self.replyInfo.imageUrl!
//        ]
        var vc = EditMyReplyDetailViewController(nibName: "BasePublishViewController", bundle: nil,param:self.replyInfo)
        CommonTool.findNearsetViewController(self).navigationController?.pushViewController(vc, animated: true)

    }
    
    //删除
    @IBAction func deleteBtnClick(sender: AnyObject) {
//        UIAlertViewDelegate?
        UIAlertView(title: "提示", message: "确定删除该发言？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定").show()
    }
    //举报
    @IBAction func reportBtnClick(sender: AnyObject) {
        
        UIAlertView(title: "提示", message: "确定确定举报此用户？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定").show()
        
        
//        HttpManager.sendHttpRequestPost(BLOCK_TO_TOPIC_REPLY, parameters:
//            ["userId":ApplicationContext.getUserID()!,
//                "id":self.replyInfo.id!],
//            success: { (json) -> Void in
//                
//                FLOG("举报发言返回json:\(json)")
//                if let isSuccess = json["isSuccess"] as? Bool{
//                    if !isSuccess { //已经点过赞
//                        HYBProgressHUD.showError("您已举报过该用户")
//                    }else{
//                        HYBProgressHUD.showSuccess("举报成功")
//                    }
//                }
////                HYBProgressHUD.showSuccess("举报成功")
//            },
//            failure:{ (reason) -> Void in
//                FLOG("失败原因:\(reason)")
//        })
    }
    
    @IBAction func avatarBtnClick(sender: AnyObject) {
        self.avatarBtn.enabled = false
        var useId = replyInfo.userId
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
        })
    }
}

//MARK: -UIAlertViewDelegate
extension PersonCommentHeader : UIAlertViewDelegate{
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1 {//点击确定按钮
            switch alertView.message! {
                case "确定删除该发言？":
                    HttpManager.sendHttpRequestPost(DEL_TOPIC_REPLY, parameters:
                        ["userId":ApplicationContext.getUserID()!,
                            "id":self.replyInfo.id!],
                        success: { (json) -> Void in
                            
                            FLOG("删除发言返回json:\(json)")
                            UIAlertView(title: "提示", message: "删除成功！", delegate: nil, cancelButtonTitle: "好的,知道了").show()
                            NSNotificationCenter.defaultCenter().postNotificationName("refreshTopicDetail", object: nil)
                            CommonTool.findNearsetViewController(self).navigationController?.popViewControllerAnimated(true)
                        },
                        failure:{ (reason) -> Void in
                            FLOG("失败原因:\(reason)")
                    })

                case"确定确定举报此用户？":
                    var userId = ApplicationContext.getUserID()!
                    var topiId = self.replyInfo.id!
            
                    HttpManager.postDatatoServer(.POST, BASE_URL + BLOCK_TO_TOPIC_REPLY, parameters:
                        ["userId":userId,
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

            default:
                return
            }
            
        }
    }
}

//MARK: -UITextViewDelegate
extension PersonCommentHeader : UITextViewDelegate{
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool{
        var index = URL.absoluteString!.toInt()!
        var useId = replyInfo.userIds[index].userId!
        if useId == ApplicationContext.getUserID()! {
            var personalSettingViewController = PersonalSettingViewController(nibName: "PersonalSettingViewController", bundle: nil,param:useId)
            CommonTool.findNearsetViewController(self).navigationController?.pushViewController(personalSettingViewController, animated: true)
        }else{
            var otherInfoViewController = OtherInfoViewController(nibName: "OtherInfoViewController", bundle: nil,param:useId)
            CommonTool.findNearsetViewController(self).navigationController?.pushViewController(otherInfoViewController, animated: true)
        }
        return true
    }
}
