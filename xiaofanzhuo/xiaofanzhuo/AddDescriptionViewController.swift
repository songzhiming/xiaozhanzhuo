//
//  AddDescriptionViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-19.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit


class AddDescriptionViewController: BasicViewController,IFlyRecognizerViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    //
    @IBOutlet weak var View1: UIView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var view1WidthConstraint: NSLayoutConstraint!
    //
    @IBOutlet weak var View2: UIView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var view2WidthConstraint: NSLayoutConstraint!
    //
    @IBOutlet weak var View3: UIView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var view3WidthConstraint: NSLayoutConstraint!
    //
    @IBOutlet weak var View4: UIView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var view4WidthConstraint: NSLayoutConstraint!
    //
    @IBOutlet weak var View5: UIView!
    @IBOutlet weak var imageView5: UIImageView!
    @IBOutlet weak var view5WidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var redCloseBtn: UIImageView!
    @IBOutlet weak var testImageView: UIImageView!
    @IBOutlet weak var descibeInfoTextView: HolderTextView!
    
    var exitdescribeText : String?
    var exitImageUrl : String?
    var imageUrl : String!
    var imageName: String!
    var dataCallback : ((imageName:[String],imageUrl:[String],text:String?)->Void)!
    
    //用于保存草稿
    var stateId = ""
    var isPublish = false
    
    var selectedImageArray:[String] = [String]()  //图片url数组
    var selectedImageName:[String] = [String]()   //图片name数组
    var selectedImageData:[UIImage] = [UIImage]() //图片 data数组
    
    
    var theImage : UIImage!
    
    var _iFlySpeechSynthesizer :IFlySpeechSynthesizer?
    
    var _iflyRecognizerView : IFlyRecognizerView?
    
    var arrayCount : Int = Int()
    
    var isReplyTopic : Bool = false
    
    
    convenience init(param:AnyObject?=nil,describeText:String?,imageUrl:[String],dataCallBack:(imageName:[String],imageUrl:[String],text:String?)->Void) {
        println("describeText\(describeText)")
        println("imageUrl\(imageUrl)")

        self.init(nibName: "AddDescriptionViewController", bundle: nil, param:param)
        self.dataCallback = dataCallBack
        exitdescribeText = describeText
        selectedImageArray = imageUrl
        for (var i = 0 ;i < selectedImageArray.count ; i++){
            var imageName = NSMutableString(string: selectedImageArray[i]).stringByReplacingOccurrencesOfString(BASE_URL + "upload/images/", withString: "")
            selectedImageName.append(imageName)
        }
        
        
        
        println("selectedImageName:::\(selectedImageName)")
        println("selectedImageArray:::\(selectedImageArray)")
//        exitImageUrl = imageUrl
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headView.backButton.hidden = false
        headView.recommendButton.hidden = true
        headView.doneButton.hidden = true
        headView.searchButton.hidden = true
        headView.doneButton.hidden = false
        
        imageCollectionView.registerNib(UINib(nibName: "MoreImageCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "MoreImageCollectionViewCell")
//        imageCollectionView.
        var categoryFlowLayout: UICollectionViewFlowLayout = imageCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        categoryFlowLayout.itemSize = CGSizeMake(54,88)
        categoryFlowLayout.minimumLineSpacing = 0
        categoryFlowLayout.minimumInteritemSpacing = 0
        //1
        imageView1.layer.borderWidth = 3
        imageView1.layer.borderColor =  UIColor.whiteColor().CGColor
        //2
        imageView2.layer.borderWidth = 3
        imageView2.layer.borderColor =  UIColor.whiteColor().CGColor
        //3
        imageView3.layer.borderWidth = 3
        imageView3.layer.borderColor =  UIColor.whiteColor().CGColor
        //4
        imageView4.layer.borderWidth = 3
        imageView4.layer.borderColor =  UIColor.whiteColor().CGColor
        //5
        imageView5.layer.borderWidth = 3
        imageView5.layer.borderColor =  UIColor.whiteColor().CGColor

        if let pa = param as? Int {//发起
            if param as! Int == 1 { // 话题 1
                descibeInfoTextView.placeHolder = "请输入您的发言"
                descibeInfoTextView.maxLength = 5000
                stateId = "newTopic"
                //获取草稿
                getDraft(stateId)
                
            }else {// param as Int == 0 组队0
                descibeInfoTextView.placeHolder = "请输入您的组队要求(140字内)"
                countLabel.hidden = false
                stateId = "newMakeUp"
                //获取草稿
                getDraft(stateId)
            }
        }
        if let pa = param as? [String:AnyObject] {//编辑
            //var pa = param as [String : AnyObject]
            var curIndex = pa["curIndex"] as! String
            if curIndex == "3" {//编辑组队
                println("编辑对对碰")
                var data = pa["data"] as! [String : AnyObject]
                descibeInfoTextView.text = data["describe"] as! String
                descibeInfoTextView.placeHolder = "请输入您的组队要求(140字内)"
                countLabel.hidden = false
            }else if curIndex == "4" {//todo  编辑话题描述 curIndex = 4
                var data = pa["data"] as! TopicInfo
                descibeInfoTextView.maxLength = 5000
                descibeInfoTextView.placeHolder = "请输入您的发言"
                descibeInfoTextView.text = data.intro
            }else if curIndex == "0" {//发表发言 点击右上角按钮（回复话题）
                isReplyTopic = true
                descibeInfoTextView.placeHolder = "请输入您的发言"
                descibeInfoTextView.maxLength = 5000
                
                //要回复的话题的id
                stateId = (self.param as! [String:AnyObject])["data"] as! String
                getDraft(stateId)
            }
        }
        
//        self.descibeInfoTextView.becomeFirstResponder()
        var nstext : NSString = descibeInfoTextView.text as NSString
        self.descibeInfoTextView.scrollRangeToVisible(NSMakeRange(0, nstext.length))
        var length = (descibeInfoTextView.text as NSString).length
        countLabel.text = "\(descibeInfoTextView.maxLength - length)/\(descibeInfoTextView.maxLength)"
        descibeInfoTextView.holderTextViewDelegate = self
        
        //   将之前的数据展示出来
        if let a = exitdescribeText {
            if a == "" {
            
            }else {
                descibeInfoTextView.text = a
            }
        }
        imageCollectionView.reloadData()
//        if let b = exitImageUrl {
//            if b == "" {
//            
//            }else{
//                testImageView.sd_setImageWithURL(NSURL(string:b))
//                redCloseBtn.hidden = false
//            }
//        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishBtnClick", name: "finishDescribe", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var categoryFlowLayout: UICollectionViewFlowLayout = imageCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        categoryFlowLayout.itemSize = CGSizeMake(54,88)
        categoryFlowLayout.minimumLineSpacing = 0
        categoryFlowLayout.minimumInteritemSpacing = 0
//        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
//        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
    
    func getDraft(id:String){
        if let dic = PersistentManager.getValueById(id){
            self.exitdescribeText = dic["describe"]
        }
    }
    
    func finishBtnClick(){

        //参数写一个UIImage,一个String
        println(self.selectedImageArray)
        if let callback =  self.dataCallback{
            callback(imageName:selectedImageName,imageUrl: selectedImageArray,text:descibeInfoTextView.text)
            PersistentManager.setValueById(stateId, describe: descibeInfoTextView.text)
        }
        
        //如果是回复话题
        if isReplyTopic {
            var allImageArray : [AnyObject] = [AnyObject]()
            for (var i = 0 ;i < self.selectedImageName.count ;i++){
                allImageArray.append(["imageUrl":self.selectedImageName[i]])
            }
            FLOG("allImageArray:\(allImageArray)")
            var dic = self.param as! [String:AnyObject]
            var id = dic["data"] as! String
            var param : [String:AnyObject] = ["id":id,
                "userId":ApplicationContext.getUserID()!,
                "content":descibeInfoTextView.text,
                "imageUrls":ApplicationContext.toJSONString(allImageArray)
            ]
            self.view.endEditing(true)
            FLOG("话题回复param!:\(param)")
            self.addLoadingView()
            self.headView.doneButton.enabled = false
            HttpManager.sendHttpRequestPost(REPLY_TO_TOPIC, parameters:param,
                success: { (json) -> Void in
                    
                    //回复成功删除草稿
                    PersistentManager.deleteById(self.stateId)
                    self.isPublish = true
                    
                    FLOG("话题回复json:\(json)")
                    self.headView.doneButton.enabled = true
                    self.removeLoadingView()
                    HYBProgressHUD.showSuccess("回复成功")
                    NSNotificationCenter.defaultCenter().postNotificationName("refreshTopicDetail", object: nil)
                    self.navigationController?.popViewControllerAnimated(true)
                },
                failure:{ (reason) -> Void in
                    self.headView.doneButton.enabled = true
                    FLOG("失败原因:\(reason)")
            })
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    deinit{
        if !isPublish {
            PersistentManager.setValueById(stateId, describe: descibeInfoTextView.text)
        }
    }
    
    @IBAction func onclickVoiceButton(sender: AnyObject) {
        self.view.endEditing(true)
        _iflyRecognizerView = IFlyRecognizerView(center: self.view.center);
        _iflyRecognizerView?.delegate = self
        _iflyRecognizerView?.setParameter("iat", forKey: IFlySpeechConstant.IFLY_DOMAIN())
        _iflyRecognizerView?.setParameter("asrview.pcm", forKey: IFlySpeechConstant.ASR_AUDIO_PATH())
        _iflyRecognizerView?.start()
    }
    
    func onResult(resultArray: [AnyObject]!, isLast: Bool) {
        println("resultArray::\(resultArray)")
        println("isLast::\(isLast)")
        if resultArray == nil {
            return
        }
        var a = resultArray[0] as! [String : AnyObject]
        var str : NSString = ""
        for key in a.keys {
            println("asss\(key)")
            str = (str as String) + key
        }
        var data = str.dataUsingEncoding(NSUTF8StringEncoding)
        var JSONObject: Dictionary<String, AnyObject> = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as! Dictionary<String, AnyObject>
        var ws = JSONObject["ws"] as? Array<AnyObject>
        var voiceStr = ""
        for i in ws! {
            var cw = i["cw"] as? Array<AnyObject>
            for j in cw!{
                var wenzi = j["w"] as! String
                voiceStr += wenzi
            }
        }
        self.descibeInfoTextView.text = self.descibeInfoTextView.text + voiceStr
    }
    func onError(error: IFlySpeechError!) {
        println(error)
    }

    //data  转 json
    func JSONObject(data: NSData) -> AnyObject? {
        return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
    }
    @IBAction func onclickPhotoButton(sender: AnyObject) {
        self.view.endEditing(true)
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
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        println(buttonIndex)
        if buttonIndex == 0 {
        }else if buttonIndex == 1 {
            self.pickImageFromAlbum()
        }else if buttonIndex == 2 {
            self.pickImageFromCarera()
        }else {
            self.deleteImage()
        }
    }
    
    //删除图片
    func deleteImage(){
        self.testImageView.image = nil
        self.redCloseBtn.hidden = true
        self.imageUrl = ""
        self.imageName = ""
    }
    
    //从相册取图片
    func pickImageFromAlbum(){
        if self.selectedImageArray.count >= 5 {
            UIAlertView(title: "提示", message: "只可以选5张图片,您已经选了5个了。", delegate: nil, cancelButtonTitle: "确定").show()
        }else{
            println(5-self.selectedImageArray.count)
            var controller = AlbumTableViewController(nibName:"AlbumTableViewController",bundle:nil,maxCount:5-self.selectedImageArray.count)
            controller.getImagesArray { (imageArray) -> Void in
                println("first:\(imageArray)")
                var uploadCount = 0
                self.selectedImageData = self.selectedImageData + imageArray

                self.addLoadingView()
                for (var i = 0 ;i<imageArray.count;i++){
                    var a = i
                    var upLoadImage = imageArray[i] as UIImage
                    
                        HttpManager.uploadFileToServer(BASE_URL + UPLOAD_IMAGE , uploadImage: upLoadImage,imageType:.Jpg)
                            .responseJSON{(_, _, JSON, _) in
                                if let json = JSON as? [String:AnyObject] {
                                    if (json["code"] as! Int) == 0 {
                                        println("上传图片返回JSON\(json)")
                                        //                                    self.imageUrl = json["imageUrl"] as String
                                        //                                    self.imageName = json["name"] as String
                                        self.selectedImageArray.append(json["imageUrl"] as! String)
                                        self.selectedImageName.append(json["name"] as! String)
                                        uploadCount++
                                        println("uploadCount::::\(uploadCount)")
                                        if uploadCount == imageArray.count {
                                            self.imageCollectionView.reloadData()
                                            self.removeLoadingView()
                                            HYBProgressHUD.showSuccess("图片上传成功")
                                        }
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
                    }
                }

            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    //从摄像头获取图片
    func pickImageFromCarera(){

        
        if self.selectedImageArray.count >= 5 {
             UIAlertView(title: "提示", message: "只可以选5张图片,您已经选了5个了。", delegate: nil, cancelButtonTitle: "确定").show()
        }else{
            var imagePicker : UIImagePickerController
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
//            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        if picker.sourceType == UIImagePickerControllerSourceType.PhotoLibrary{    
        }else{//摄像头
            theImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
            UIImageWriteToSavedPhotosAlbum(self.theImage, nil, nil, nil)
            picker.dismissViewControllerAnimated(true, completion: nil)
            self.addLoadingView()
            HttpManager.uploadFileToServer(BASE_URL + UPLOAD_IMAGE , uploadImage: self.theImage,imageType:.Jpg)
                .responseJSON{(_, _, JSON, _) in
                    if let json = JSON as? [String:AnyObject] {
                        if (json["code"] as! Int) == 0 {
                            println("上传图片返回JSON\(json)")
                            //                                    self.imageUrl = json["imageUrl"] as String
                            //                                    self.imageName = json["name"] as String
                            self.selectedImageArray.append(json["imageUrl"] as! String)
                            self.selectedImageName.append(json["name"] as! String)
                            self.selectedImageData.append(self.theImage)
                            self.imageCollectionView.reloadData()
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
//            //裁减
//            var imageEditor : ImageEditorViewController =  ImageEditorViewController(nibName: "ImageEditorViewController", bundle: nil)
//            imageEditor.view.frame = UIScreen.mainScreen().bounds
//            imageEditor.checkBounds = true
//            imageEditor.rotateEnabled = false
//            imageEditor.sourceImage = theImage
//            imageEditor.reset(true)
//            imageEditor.setSquareSize(CGSizeMake(320, 320))
//            picker.pushViewController(imageEditor, animated: false)
//            picker.navigationBarHidden = true
//            
//            
//            //            imageEditor.doneCallback
//            imageEditor.doneCallback = {(editedImage:UIImage!,canceled:Bool) -> Void in
//                if !canceled == true {
//                    self.theImage = editedImage
//                    self.theImage = CommonTool.fullScreenImage(self.theImage)
//                    
//                    
//                    UIImageWriteToSavedPhotosAlbum(self.theImage, nil, nil, nil)
////                    self.testImageView.image = self.theImage
//                    self.dismissViewControllerAnimated(true, completion: nil)
//                    self.addLoadingView()
//                    HttpManager.uploadFileToServer(BASE_URL + UPLOAD_IMAGE , uploadImage: self.theImage,imageType:.Jpg)
//                        .responseJSON{(_, _, JSON, _) in
//                            if let json = JSON as? [String:AnyObject] {
//                                if (json["code"] as Int) == 0 {
//                                    println("上传图片返回JSON\(json)")
////                                    self.imageUrl = json["imageUrl"] as String
////                                    self.imageName = json["name"] as String
//                                    self.selectedImageArray.append(json["imageUrl"] as String)
//                                    self.selectedImageName.append(json["name"] as String)
//                                    self.selectedImageData.append(self.theImage)
//                                    self.imageCollectionView.reloadData()
//                                    self.removeLoadingView()
//                                    HYBProgressHUD.showSuccess("图片上传成功")
//                                }else{
//                                    self.removeLoadingView()
//                                    HYBProgressHUD.showError(json["message"] as String)
//                                    println("服务器返回数据错误,code!=0")
//                                }
//                            }else{
//                                self.removeLoadingView()
//                                HYBProgressHUD.showError("网络连接错误！")
//                                println("网络连接错误！")
//                            }
//                            
//                    }
//
//                }
//            }
        }

    }
    
    

    @IBAction func onclickDeleteImage(sender: AnyObject) {
        var tagNumber = (sender as! UIButton).tag
        
        self.selectedImageArray.removeAtIndex(tagNumber - 1011)
        self.selectedImageName.removeAtIndex(tagNumber - 1011)
        if tagNumber == 1011 {
            UIView.animateWithDuration(
                        0.1,
                        delay: 0.45,
                        options: UIViewAnimationOptions.CurveEaseInOut,
                        animations: { () -> Void in
                            self.view1WidthConstraint.constant = 0
                            self.View1.hidden = true
                            self.view.layoutIfNeeded()
                        }) { (Bool) -> Void in
            }
        }else if tagNumber == 1012{
            UIView.animateWithDuration(
                0.1,
                delay: 0.45,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.view2WidthConstraint.constant = 0
                    self.View2.hidden = true
                    self.view.layoutIfNeeded()
                }) { (Bool) -> Void in
            }
        }else if tagNumber == 1013{
            UIView.animateWithDuration(
                0.1,
                delay: 0.45,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.view3WidthConstraint.constant = 0
                    self.View3.hidden = true
                    self.view.layoutIfNeeded()
                }) { (Bool) -> Void in
            }
        }else if tagNumber == 1014{
            UIView.animateWithDuration(
                0.1,
                delay: 0.45,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.view4WidthConstraint.constant = 0
                    self.View4.hidden = true
                    self.view.layoutIfNeeded()
                }) { (Bool) -> Void in
            }
        }else{
            UIView.animateWithDuration(
                0.1,
                delay: 0.45,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.view5WidthConstraint.constant = 0
                    self.View5.hidden = true
                    self.view.layoutIfNeeded()
                }) { (Bool) -> Void in
            }
        }
    }
    
    
    
    
    
    // MARK: - collectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedImageArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: MoreImageCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("MoreImageCollectionViewCell", forIndexPath: indexPath) as! MoreImageCollectionViewCell
        cell.loadData(self.selectedImageArray[indexPath.row],index:indexPath.row)
//        var categoryViewController: CategoryViewController = categories[indexPath.row]
//        var categoryView: UIView = categoryViewController.view
//        
//        cell.contentView.addSubview(categoryView)
//        if indexPath.row == 0 {
//            categoryViewController.getTopicListFromWeb()
//            categoryViewController.setIndexPage(1)
//        }else{
//            categoryViewController.getActivityListFromWeb()
//            categoryViewController.setIndexPage(2)
//        }
//        categoryView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        var padding = UIEdgeInsetsMake(0, 0, 0, 0)
//        makeConstraints(cell.contentView, childView: categoryView, padding: padding)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(54, 88)
    }
}

//MARK: - HolderTextViewDelegate
extension AddDescriptionViewController:HolderTextViewDelegate{
    func holderTextViewDidChange(textView:HolderTextView){
        var length = (textView.text as NSString).length
        countLabel.text = "\(textView.maxLength-length)/\(textView.maxLength)"
//        self.descibeInfoTextView.scrollRangeToVisible(NSMakeRange(length-1, length))
//        textView.contentOffset = CGPointZero
//        textView.contentOffset = CGPointZero

        FLOG("textview.contentsize:\(textView.contentSize.height)")
        FLOG("textview.content:\(textView.contentOffset)")
        FLOG("textview.contentInset:\(textView.contentInset.bottom)")
    }
    
}

