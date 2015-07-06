//
//  ChangePersonInfoViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/2/3.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class ChangePersonInfoViewController: BasicViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var finishBtn: UIButton!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var inroText: HolderTextView!
    @IBOutlet weak var experienceText: HolderTextView!
    @IBOutlet weak var directionText: HolderTextView!
    @IBOutlet weak var industryText: HolderTextView!
    @IBOutlet weak var skillText: HolderTextView!
    
    //viewWithTag问题只能用如下办法（目前状态的从上到下3个button和从上到下3个label)
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    var btnGroup : [UIButton]!
    var labelGroup : [UILabel]!
    
    
    //约束
    @IBOutlet weak var introViewHeight: NSLayoutConstraint!
    @IBOutlet weak var introTextHeight: NSLayoutConstraint!
    

    @IBOutlet weak var industryHeight: NSLayoutConstraint!
    @IBOutlet weak var industryViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var skillHeight: NSLayoutConstraint!
    @IBOutlet weak var skillViewHeight: NSLayoutConstraint!
    
    var skill : [[String:AnyObject]]! = [[String:AnyObject]]()
    var industry : [[String:AnyObject]]! = [[String:AnyObject]]()
    var theImage : UIImage!
    var imageUrl : String! = ""
    var imageName : String!
    
    //常量定义
    let INDUSTRY_FLAG = 0
    let SKILL_FLAG = 1
    let SITUATION_START = 3000
    
    //变量
    var CONTENT_HEIGHT :CGFloat = 619
    var currentSituation : String! = ""
    
    var initFlag : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headView.changeLeftButton()
        headView.logoImage.hidden = true
        headView.titleLabel.text = "个人设置"
        headView.searchButton.hidden = true
        headView.generateCodeButton.hidden = true
        self.view.bringSubviewToFront(finishBtn)
        
        contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-10, CONTENT_HEIGHT)
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.bounds.size
        
        //textView设置placeHolder
        inroText.placeHolder = "请用一句话介绍您自己"
        inroText.maxLength = 5000
        inroText.holderTextViewDelegate = self
        inroText.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        industryText.placeHolder = "请选择您感兴趣的行业"
        skillText.placeHolder = "请选择您的技能"
        experienceText.holderTextViewDelegate = self
        directionText.holderTextViewDelegate = self

        FLOG("userinfo:\(ApplicationContext.getMyUserInfo()!)")
        //设置头像
        avatar.layer.cornerRadius = 5
        avatar.layer.masksToBounds = true
        avatar.sd_setImageWithURL(NSURL(string:ApplicationContext.getMyUserInfo()!["avatar"] as! String), placeholderImage: UIImage(named:"avatarDefaultImage"))
        
        //展示个人信息
        imageUrl = ApplicationContext.getMyUserInfo()!["avatar"] as! String
        skill = ApplicationContext.getMyUserInfo()!["skill"] as! [[String:AnyObject]]
        industry = ApplicationContext.getMyUserInfo()!["industry"] as! [[String:AnyObject]]
        inroText.text = ApplicationContext.getMyUserInfo()!["intro"] as! String
        var names = ""
        for dic in self.industry {
            var str = dic["name"] as! String
            names += "\(str),"
        }
        if !names.isEmpty {
            var ns = NSMutableString(string: names)
            self.industryText.text = ns.substringToIndex(ns.length - 1)
        }
        names = ""
        for dic in self.skill {
            var str = dic["name"] as! String
            names += "\(str),"
        }
        if !names.isEmpty {
            var ns = NSMutableString(string: names)
            self.skillText.text = ns.substringToIndex(ns.length - 1)
        }
        
        
        //设置目前状态
        btnGroup = [UIButton]()
        labelGroup = [UILabel]()
        btnGroup.append(btn1)
        btnGroup.append(btn2)
        btnGroup.append(btn3)
        labelGroup.append(label1)
        labelGroup.append(label2)
        labelGroup.append(label3)
        currentSituation = ApplicationContext.getMyUserInfo()!["situation"] as! String
        var index = (currentSituation as NSString).integerValue - 1
        btnGroup[index].selected = true
        labelGroup[index].textColor = UIColor.blackColor()
        
        //设置工作经历和创业方向
        experienceText.placeHolder = "经历越详细越好呦"//字数默认限制140字
        directionText.placeHolder = "请简述您的创业方向"
        experienceText.text = ApplicationContext.getMyUserInfo()!["experience"] as! String
        directionText.text = ApplicationContext.getMyUserInfo()!["direction"] as! String
//        (self.view.viewWithTag(SITUATION_START + index + 10) as UILabel).textColor = UIColor.blackColor()
        //监听键盘弹出
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.adjustIndustryOrInterestViewFrame(industryText)
        self.adjustIndustryOrInterestViewFrame(skillText)
        if !initFlag{
            self.view.bringSubviewToFront(self.headView)
            self.view.bringSubviewToFront(self.finishBtn)
            scrollView.contentOffset = CGPointZero
            scrollView.contentInset.top = 0
            //设置高度
            
            initFlag = true
        }
//        FLOG("scrollView:\(scrollView.contentOffset)")
//        FLOG("scrollView.top:\(scrollView.contentInset.top)")
//        FLOG("scrollView.bottom:\(scrollView.contentInset.bottom)")

    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.view.bringSubviewToFront(self.headView)
//        self.view.bringSubviewToFront(self.finishBtn)
//        
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: -按钮点击
extension ChangePersonInfoViewController {
    //完成编辑
    @IBAction func finishBtnClick(sender: AnyObject) {
        if currentSituation.isEmpty {
            HYBProgressHUD.showError("目前不能为空")
            return
        }
        if directionText.text.isEmpty {
            HYBProgressHUD.showError("创业方向不能为空")
            return 
        }
        
        var avatarUrl = ApplicationContext.getUserInfo()!["avatar"] as! String
        if let name = imageName {
            avatarUrl = name
        }
        var param : [String:AnyObject] =
        ["userId":ApplicationContext.getUserID()!,
            "avatar":avatarUrl,
            "intro":inroText.text,
            "industry":ApplicationContext.toJSONString(industry),
            "skill":ApplicationContext.toJSONString(skill),
            "direction":directionText.text,
            "situation":currentSituation,
            "experience":experienceText.text
        ]
        HttpManager.sendHttpRequestPost(UPDATE_USERINFO, parameters: param,
            success: { (json) -> Void in
                
                FLOG("个人信息编辑返回json:\(json)")
                //保存个人信息到本地
                var userInfo = ApplicationContext.getUserInfo()!
                var personInfo = userInfo["personInfo"] as! [String:AnyObject]
                personInfo["skill"] = self.skill
                personInfo["industry"] = self.industry
                personInfo["intro"] = self.inroText.text
                personInfo["direction"] = self.directionText.text
                personInfo["situation"] = self.currentSituation
                personInfo["experience"] = self.experienceText.text
                //本地保存头像
                personInfo["avatar"] = self.imageUrl
                userInfo["avatar"] = self.imageUrl
                userInfo["personInfo"] = personInfo
                ApplicationContext.saveUserInfo(userInfo)
                println("编辑保存后的个人信息：\(ApplicationContext.getUserInfo()!)")
                //重置是否显示信息完整提示
                NSUserDefaults.standardUserDefaults().setObject(false, forKey: "IsShownUserInfoCompleted")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.navigationController?.popViewControllerAnimated(true)
                HYBProgressHUD.showSuccess("个人信息编辑成功")
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })

    }
    
    //上传头像
    @IBAction func uploadAvatar(sender: AnyObject) {
        var actionSheet = UIActionSheet(
            title: nil,
            delegate: self,
            cancelButtonTitle: "取消",
            destructiveButtonTitle: nil,
            otherButtonTitles:"相册","拍照")
        actionSheet.actionSheetStyle = UIActionSheetStyle.BlackOpaque
        actionSheet.destructiveButtonIndex = -1
        actionSheet.showInView(self.view)
    }
    //行业与技能选择
    @IBAction func getMoreInfoBtnClikc(sender: UIButton) {
        var infoView = NSBundle.mainBundle().loadNibNamed("MoreInformationView", owner: self, options: nil)[0] as! MoreInformationView
        //        infoView.frame = self.view.frame
        self.view.endEditing(true)
        sender.userInteractionEnabled = false
        HttpManager.sendHttpRequestPost(GET_USER_INFO_OPTIONS,
            success: { (json) -> Void in
                
                FLOG("获取行业技能信息返回信息json:\(json)")
                switch sender.tag {
                case 4001://行业
                    infoView.loadDataWithDataCallBack(flag:self.INDUSTRY_FLAG, dataList: json["industryList"] as! [[String:AnyObject]], callback: { (selectedItems) -> Void in
                        self.industry = selectedItems
                        var names = ""
                        for dic in self.industry {
                            var str = dic["name"] as! String
                            names += "\(str),"
                        }
                        if !names.isEmpty {
                            var ns = NSMutableString(string: names)
                            self.industryText.text = ns.substringToIndex(ns.length - 1)
                        }
                        self.adjustIndustryOrInterestViewFrame(self.industryText)
                        sender.userInteractionEnabled = true
                        //println(self.industry)
                    })
                    break
                case 4002://技能
                    infoView.loadDataWithDataCallBack(flag: self.SKILL_FLAG, dataList: json["skillList"] as! [[String:AnyObject]], callback: { (selectedItems) -> Void in
                        self.skill = selectedItems
                        var names = ""
                        for dic in self.skill {
                            var str = dic["name"] as! String
                            names += "\(str),"
                        }
                        if !names.isEmpty {
                            var ns = NSMutableString(string: names)
                            self.skillText.text = ns.substringToIndex(ns.length - 1)
                        }
                        self.adjustIndustryOrInterestViewFrame(self.skillText)
                        sender.userInteractionEnabled = true
                        //println("技能：\(self.skill)")
                    })
                    break
                default:
                    break
                }
                self.view.addSubview(infoView)
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
    
    @IBAction func situationCheckBtnClick(sender: UIButton) {
        self.view.endEditing(true)
        for var i = 1;i<4;i++ {
            (self.view.viewWithTag(SITUATION_START + i) as! UIButton).selected = false
            (self.view.viewWithTag(SITUATION_START + i + 10) as! UILabel).textColor = UIColor.lightGrayColor()
        }
        sender.selected = true
        (self.view.viewWithTag(sender.tag + 10) as! UILabel).textColor = UIColor.blackColor()
        switch sender.tag - SITUATION_START {
        case 1:
            currentSituation = String(1)
            break
        case 2:
            currentSituation = String(2)
            break
        case 3:
            currentSituation = String(3)
            break
        default:
            break
        }
    }
}

//MARK: -UIActionSheetDelegate
extension ChangePersonInfoViewController : UIActionSheetDelegate{
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        println(buttonIndex)
        if buttonIndex == 0 {
        }else if buttonIndex == 1 {
            self.pickImageFromAlbum()
        }else if buttonIndex == 2 {
            self.pickImageFromCarera()
        }
    }
}

// MARK: -类方法
extension ChangePersonInfoViewController{
    //从相册取图片
    func pickImageFromAlbum(){
        var imagePicker : UIImagePickerController
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
//        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    //从摄像头获取图片
    func pickImageFromCarera(){
        var imagePicker : UIImagePickerController
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //键盘弹出处理
    func keyboardWillShown(notification:NSNotification){
        FLOG("notificationg:------>\(UIScreen.mainScreen().bounds.width)")
        if !inroText.isFirstResponder() {
            var height : CGFloat = 0
            switch UIScreen.mainScreen().bounds.width {
            case 320:
                height = 253
            case 375:
                height = 258
            case 414:
                height = 271
            default:
                break
            }
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                var y = UIScreen.mainScreen().bounds.width/320
                self.scrollView.transform = CGAffineTransformMakeTranslation(0, -height)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification:NSNotification){
        if !inroText.isFirstResponder() {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.scrollView.transform = CGAffineTransformIdentity
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func adjustIndustryOrInterestViewFrame(textView:HolderTextView){
        var size =  (textView.text! as NSString).boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 10 - 15, 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont(name: "FZLanTingHeiS-R-GB", size: 14)!],
            context: nil)
        var height = size.height
        
        var layoutHeight = textView == industryText ? industryHeight : skillHeight
        var viewLayoutHeight = textView == industryText ? industryViewHeight : skillViewHeight
        
        layoutHeight.constant = height + 20
        viewLayoutHeight.constant = 5 + 21 + layoutHeight.constant + 2
        
        contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-10, (CONTENT_HEIGHT + viewLayoutHeight.constant - 70) )//50是Ib里面一个小型父View的高度
        scrollView.contentSize = contentView.bounds.size
    }
    
    @IBAction func downKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
}

//MARK: -UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension ChangePersonInfoViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        
        if picker.sourceType == UIImagePickerControllerSourceType.PhotoLibrary{
            theImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        }else{
            theImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        }
        var imageEditor : ImageEditorViewController =  ImageEditorViewController(nibName: "ImageEditorViewController", bundle: nil)
        imageEditor.view.frame = UIScreen.mainScreen().bounds
        imageEditor.checkBounds = true
        imageEditor.rotateEnabled = false
        imageEditor.sourceImage = theImage
        imageEditor.reset(true)
        imageEditor.setSquareSize(CGSizeMake(320, 320))
        picker.pushViewController(imageEditor, animated: false)
        picker.navigationBarHidden = true
        imageEditor.doneCallback = {(editedImage:UIImage!,canceled:Bool) -> Void in
            if !canceled == true {
                self.theImage = editedImage
                self.theImage = CommonTool.fullScreenImage(self.theImage)
                UIImageWriteToSavedPhotosAlbum(self.theImage, nil, nil, nil)
                self.dismissViewControllerAnimated(true, completion: nil)
                self.addLoadingView()
                HttpManager.uploadFileToServer(BASE_URL + UPLOAD_IMAGE , uploadImage: self.theImage,imageType:.Jpg)
                    .responseJSON{(_, _, JSON, _) in
                        if let json = JSON as? [String:AnyObject] {
                            if (json["code"] as! Int) == 0 {
                                println(json["imageUrl"])
                                self.imageUrl = json["imageUrl"] as! String
                                self.avatar.image = self.theImage
                                self.imageName = json["name"] as! String
                                
                                //println("save\(ApplicationContext.getUserInfo())")
                                //                        UIAlertView(title: "提示", message: "图片上传成功", delegate: self, cancelButtonTitle: "OK").show()
                                self.removeLoadingView()
                                HYBProgressHUD.showSuccess("图片上传成功")
                            }else{
                                self.removeLoadingView()
                                HYBProgressHUD.showError(json["message"] as! String)
                                println("服务器返回数据错误,code!=0")
                            }
                        }else{
                            self.removeLoadingView()
                            HYBProgressHUD.showError("网络连接错误！")
                            println("网络连接错误！")
                        }
                }
            }else{
                if picker.sourceType == .PhotoLibrary {
                    picker.popViewControllerAnimated(true)
                    return
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

extension ChangePersonInfoViewController : HolderTextViewDelegate {
    func holderTextViewDidChange(textView:HolderTextView){
        
        if textView != inroText {
            return
        }
        
        var size =  (textView.text! as NSString).boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 10 - 10 - 10, 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont(name: "FZLanTingHeiS-R-GB", size: 14)!],
            context: nil)
        var height = size.height

        introTextHeight.constant = height + 26
        introViewHeight.constant = 5 + 21 + introTextHeight.constant + 2
        
        contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-10, (CONTENT_HEIGHT + introViewHeight.constant - 70 ) )//50是Ib里面一个小型父View的高度
        scrollView.contentSize = contentView.bounds.size
        
//        contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-10, (CONTENT_HEIGHT + introViewHeight.constant - 50 ) )//50是Ib里面一个小型父View的高度
        
        FLOG("\(textView.text)")
    }
    
    func returnButtonDidClick(textView:HolderTextView){
        self.view.endEditing(true)
    }
}
