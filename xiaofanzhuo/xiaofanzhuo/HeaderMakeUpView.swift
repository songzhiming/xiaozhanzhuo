//
//  HeaderMakeUpView.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-21.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class HeaderMakeUpView: UIView{
    
    @IBOutlet weak var editButton: UIButton!
    
    
    @IBOutlet weak var acceptView: UIView!
    
    @IBOutlet weak var openViewHeight: NSLayoutConstraint!
    @IBOutlet weak var openView: UIView!


    @IBOutlet weak var openImageView: UIImageView!
    
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var splitline: UIImageView!
    
    @IBOutlet weak var commentNumber: UILabel!
    @IBOutlet weak var describeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var publishDateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarBtn: UIButton!
    
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var taskImage1: UIImageView!
    @IBOutlet weak var taskImage2: UIImageView!
    @IBOutlet weak var taskImage3: UIImageView!
    @IBOutlet weak var taskImage4: UIImageView!
    
    @IBOutlet weak var imageViewButton: UIButton!
    @IBOutlet weak var imageViewButton1: UIButton!
    @IBOutlet weak var imageViewButton2: UIButton!
    @IBOutlet weak var imageViewButton3: UIButton!
    @IBOutlet weak var imageViewButton4: UIButton!
    
    //约束
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var contentLabelHeight: NSLayoutConstraint!
    
    //变量
    var currentDic : NSDictionary!
    var isOpen : Bool = false
    var hasImage : Bool = false //是否有图片
    var closeFrame : CGRect = CGRect()
    var headerHeight_open : CGFloat!//展开的高度
    var headerHeight_close : CGFloat!//收起的高度
    var titleTextHeight : CGFloat!
    var initFlag : Bool = false //是否进行过初始化
    //常量
    let IMAGE_START_TAG = 5000
    let TOP_VIEW_HEIGHT : CGFloat = 63//顶部装载头像与其他信息的view的高度
    let MARGIN : CGFloat = 5 //空隙的高度
    let EXPEND_BUTTON_VIEW_HEIGHT : CGFloat = 25 //装载展开按钮的view的高度
    let BOTTOM_VIEW_HEIGHT : CGFloat = 20  //底部view的高度
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.layer.cornerRadius = 5
        avatarImage.clipsToBounds = true
    
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapToClose") )
        describeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapToClose") )
    }
}

//MARK:-实例方法
extension HeaderMakeUpView {
    //加载数据
    func loadData(data : NSDictionary?){
        
        self.isOpen = true
        openImageView.image = UIImage(named: "close")
        
        if data?.objectForKey("isMy") as! Bool == true {
            editButton.hidden = false
        }else{
            editButton.hidden = true
        }
        
        currentDic = data
        //设置头像形状
        
        var avatarImageUrl = data?.objectForKey("avatar") as? NSString
        avatarImage.sd_setImageWithURL(NSURL(string: avatarImageUrl! as String), placeholderImage: UIImage(named: "avatarDefaultImage"))
        //顶部的信息
        var username: AnyObject? = data?.objectForKey("userName")
        usernameLabel.text = "\(username!)"
        var publishDate: AnyObject? = data?.objectForKey("time")
        publishDateLabel.text = "发布日期： " + "\(publishDate!)"
        //标题
        titleLabel.text = data?.objectForKey("title") as? String
        //描述
        describeLabel.text = data?.objectForKey("describe") as? String
        //帮助文字
        var helpList = data?.objectForKey("helpList") as? [[String:AnyObject]]

        commentNumber.text = "回复组队信息数   " + "\(helpList!.count)"

        //计算title的高度
        var titleAttributeStr = NSMutableAttributedString(string:data?.objectForKey("title") as! String)
        var titleStyle = NSMutableParagraphStyle()
        titleStyle.lineSpacing = 5
        
        titleAttributeStr.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 18)!, range: NSMakeRange(0, titleAttributeStr.length))
        titleAttributeStr.addAttribute(NSParagraphStyleAttributeName, value: titleStyle, range: NSMakeRange(0, titleAttributeStr.length))
        titleAttributeStr.addAttribute(NSKernAttributeName, value: NSNumber(float: 0.5), range: NSMakeRange(0, titleAttributeStr.length))
        
        titleLabel.attributedText = titleAttributeStr
        titleTextHeight = titleLabel.attributedText.boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 10 - 20 , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil).height
        
        //计算contentLable的高度
        contentLabelHeight.constant = 0
        var str = NSMutableAttributedString(string:currentDic.objectForKey("describe") as! String)
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        str.addAttribute(NSFontAttributeName, value: UIFont(name: "FZLanTingHeiS-R-GB", size: 16)!, range: NSMakeRange(0, str.length))
        str.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, str.length))
        //添加字符间距
        str.addAttribute(NSKernAttributeName, value: NSNumber(float: 0.5), range: NSMakeRange(0, str.length))
        
        describeLabel.attributedText = str
        
        var size = describeLabel.attributedText.boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 30  , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)

        contentLabelHeight.constant = size.height + 8
        
        imageWidth.constant = 0//默认为0
        var images = currentDic.objectForKey("imageUrl") as? [[String:AnyObject]]
        if let imageUrls = images {
            var imageArray = imageUrls as [[String:AnyObject]]
            if imageArray.count > 0 {
                imageWidth.constant = (UIScreen.mainScreen().bounds.width - 10*2 - 10 - 2*4 ) / 5
                hasImage = true
                
                for var i = 0;i < imageArray.count; i++ {
                    var image = self.viewWithTag(IMAGE_START_TAG + i) as! UIImageView
                    var url = imageArray[i]["imageUrl"] as! String
                    FLOG("url:\(url)")
                    FLOG("image:\(image)")
                    image.sd_setImageWithURL(NSURL(string:url), placeholderImage: UIImage(named:"avater"))
                }
                self.adjustFrame()
            }
        }//if let
        
        if describeLabel.text!.isEmpty && !hasImage {
            openButton.hidden = true
            openImageView.hidden = true
            splitline.hidden = true
        }
        describeLabel.alpha = 1
        self.setAllImagesHidden(false)
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
        self.layoutIfNeeded()
        headerHeight_open = TOP_VIEW_HEIGHT + MARGIN*4 + titleTextHeight + imageWidth.constant +
            contentLabelHeight.constant + EXPEND_BUTTON_VIEW_HEIGHT + BOTTOM_VIEW_HEIGHT
        headerHeight_close = TOP_VIEW_HEIGHT + MARGIN*2 + titleTextHeight + EXPEND_BUTTON_VIEW_HEIGHT + BOTTOM_VIEW_HEIGHT
        
        var isToShow = describeLabel.text!.isEmpty && !hasImage
        var height = !isToShow ? headerHeight_open : headerHeight_close
        
        var frame = self.frame
        self.frame = CGRectMake(0, 0, frame.width, height)
        (self.superview as! UITableView).tableHeaderView = self
    }
    
    //设置alpha与是否可以Interact
    func setAllImagesHidden(yesOrNo : Bool) {
        var images = currentDic.objectForKey("imageUrl") as? [[String:AnyObject]]
        if let imageUrls = images {
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
        
        var images = currentDic.objectForKey("imageUrl") as? [[String:AnyObject]]
        for (var i = 0 ;i < images?.count; i++){
            var url = images![i]["imageUrl"] as! String
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
        peformExpandCloseAnimation()
    }
    
    func peformExpandCloseAnimation(){
        if describeLabel.text!.isEmpty && !hasImage {
            return
        }
        var width = UIScreen.mainScreen().bounds.width - 10
        if isOpen == false {//展开
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.frame = CGRectMake(0, 0, width, self.headerHeight_open)
                (self.superview as! UITableView).tableHeaderView = self
                self.setAllImagesHidden(false)
                self.describeLabel.alpha = 1
                self.superview?.layoutIfNeeded()
            })
            openImageView.image = UIImage(named: "close")
        }else{
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.frame = CGRectMake(0, 0, width, self.headerHeight_close)
                (self.superview as! UITableView).tableHeaderView = self
                self.setAllImagesHidden(true)
                self.describeLabel.alpha = 0
                self.superview?.layoutIfNeeded()
            })
            openImageView.image = UIImage(named: "open")
        }
        isOpen = !isOpen
    }

}

//MARK:-按钮点击
extension HeaderMakeUpView {
    //展开
    @IBAction func onclickOpenButton(sender: AnyObject) {
        peformExpandCloseAnimation()
        
    }
    
    @IBAction func onclickAvatar(sender: AnyObject) {
        
        self.avatarBtn.enabled = false
        var useId = self.currentDic?.objectForKey("userId") as? String
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
                FLOG("失败原因:\(reason)")
                self.avatarBtn.enabled = true
        })        
        
    }
    
    //编辑
    @IBAction func onclickEditButton(sender: AnyObject) {
        var vc = EditMyMakpViewController(nibName: "BasePublishViewController", bundle: nil,param:self.currentDic)
        CommonTool.findNearsetViewController(self).navigationController?.pushViewController(vc, animated: true)
    }
    
    //跳转到大图页面
    func onSingleTap(recognizer: UITapGestureRecognizer) {
        
    }
    
    @IBAction func onclickImageButton(sender: AnyObject) {
        var images = currentDic.objectForKey("imageUrl") as! [[String:AnyObject]]
        
        println("images--------\(images)")
        
        var imageArray : [String] = [String]()
        
        
        for (var i = 0 ;i < images.count ; i++){
            println(images[i]["imageUrl"])
            
            var url = images[i]["imageUrl"] as! String
            
            imageArray.append(url)
        }
        println("imageArray:::\(imageArray)")
        
        
        var index  = (sender as! UIButton).tag as Int - 10001
        
        var param = ["index":index,
            "imageArray":imageArray]
        
        var zoomViewController : ZoomViewController = ZoomViewController(nibName: "ZoomViewController", bundle: nil,param:param)
        zoomViewController.view.frame = UIScreen.mainScreen().bounds
        CommonTool.findNearsetViewController(self).addChildViewController(zoomViewController)
        CommonTool.findNearsetViewController(self).view.addSubview(zoomViewController.view)
    }
}
