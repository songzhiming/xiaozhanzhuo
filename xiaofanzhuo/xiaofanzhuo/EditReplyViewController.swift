//
//  EditReplyViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-19.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class EditReplyViewController: BasicViewController,IFlyRecognizerViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var redCloseBtn: UIImageView!
    @IBOutlet weak var testImageView: UIImageView!
    @IBOutlet weak var descibeInfoTextView: HolderTextView!
    
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    var selectedImageName:[String] = [String]()   //图片name数组
    var selectedImageData:[UIImage] = [UIImage]() //图片 data数组
    var selectedImageArray:[String] = [String]()  //图片url数组
    
    var imageUrl : String! = ""
    var imageName: String! = ""
    var dataCallback : ((imageName:String?,imageUrl:String?,text:String?)->Void)!
    
    var imageArray : [[String:AnyObject]]! = [[String:AnyObject]]()
    
    convenience init(param:AnyObject?=nil,dataCallBack:(imageName:String?,imageUrl:String?,text:String?)->Void) {
        self.init(nibName: "EditReplyViewController", bundle: nil, param:param)
        self.dataCallback = dataCallBack
    }

    var theImage : UIImage!

    
    var _iFlySpeechSynthesizer :IFlySpeechSynthesizer?
    
    var _iflyRecognizerView : IFlyRecognizerView?
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.backButton.hidden = false
        headView.recommendButton.hidden = true
        headView.doneButton.hidden = true
        headView.searchButton.hidden = true
        headView.doneButton.hidden = false
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        
        imageCollectionView.registerNib(UINib(nibName: "MoreImageCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "MoreImageCollectionViewCell")
        descibeInfoTextView.placeHolder = "请输入您的发言"
        descibeInfoTextView.maxLength = 10000
        //如果是修改发言详情，接受图片
        if let info = self.param as? ReplyInfo {
            var imageArray = info.imageUrl!//params["imageUrl"] as [[String:AnyObject]]
            if imageArray.count > 0 { //如果有图

                //填充imageUrl
                for var i = 0 ; i < imageArray.count ; i++ {
                    var imageUrl = imageArray[i]["imageUrl"] as! String
                    selectedImageArray.append(imageUrl)
                    var nsImageUrl =  NSMutableString(string: imageUrl)
                    var imageName = nsImageUrl.stringByReplacingOccurrencesOfString(BASE_URL + "upload/images/", withString: "")
                    selectedImageName.append(imageName)
 
                }
            }
            FLOG("imageName:\(selectedImageName)")
            FLOG("imageName:\(selectedImageArray)")
            self.descibeInfoTextView.text = info.content
        }
        
        //滚动到底部
//        self.descibeInfoTextView.becomeFirstResponder()
        var nstext : NSString = descibeInfoTextView.text as NSString
        self.descibeInfoTextView.scrollRangeToVisible(NSMakeRange(0, nstext.length))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishBtnClick", name: "finishDescribe", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func finishBtnClick(){
        //修改发言详情,没有处理图片
        var allImageArray : [AnyObject] = [AnyObject]()
        for (var i = 0 ;i < selectedImageName.count ;i++){
            allImageArray.append(["imageUrl":selectedImageName[i]])
        }
        var  info = self.param as! ReplyInfo
        HttpManager.sendHttpRequestPost(EDIT_TOPIC_REPLY, parameters:
            ["userId":ApplicationContext.getUserID()!,
            "id":info.id!,
            "content":self.descibeInfoTextView.text,
            "imageUrls":ApplicationContext.toJSONString(allImageArray)],
            success: { (json) -> Void in
                
                FLOG("修改发言详情json:\(json)")
                NSNotificationCenter.defaultCenter().postNotificationName("refreshPersonComment", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
                HYBProgressHUD.showSuccess("编辑发言成功")
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
        
        //参数写一个UIImage,一个String
        if let callback =  self.dataCallback{
            callback(imageName:imageName,imageUrl: imageUrl,text:descibeInfoTextView.text)
        }
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onclickVoiceButton(sender: AnyObject) {
        _iflyRecognizerView = IFlyRecognizerView(center: self.view.center);
        _iflyRecognizerView?.delegate = self
        _iflyRecognizerView?.setParameter("iat", forKey: IFlySpeechConstant.IFLY_DOMAIN())
        _iflyRecognizerView?.setParameter("asrview.pcm", forKey: IFlySpeechConstant.ASR_AUDIO_PATH())
        _iflyRecognizerView?.start()
    }
    
    func onResult(resultArray: [AnyObject]!, isLast: Bool) {
        FLOG("结果：\(resultArray)")
        if resultArray == nil {
            return
        }
        var a = resultArray[0] as! [String : AnyObject]
        FLOG("aaassdd\(a)")
        
        
        var str : NSString = ""
        for key in a.keys {
            FLOG("asss\(key)")
            str = (str as String) + key
        }
        FLOG("str:::::\(str)")
        
        
        
        var data = str.dataUsingEncoding(NSUTF8StringEncoding)
        FLOG("data:\(data)")
        var JSONObject: Dictionary<String, AnyObject> = self.JSONObject(data! as NSData) as! Dictionary<String, AnyObject>
        FLOG("JSONObject::::\(JSONObject)")
        
        FLOG("1234uebhdbhdbhdbhdbhbhbhdbh\(JSONObject.count)")
        var ws = JSONObject["ws"] as? Array<AnyObject>
        FLOG("wswswsws\(ws)")
        var voiceStr = ""
        for i in ws! {
            FLOG("iiiiii:::\(i)")
            var cw = i["cw"] as? Array<AnyObject>
            FLOG("jjjjjj:::\(cw)")
            for j in cw!{
                FLOG("wwwww:::\(j)")
                var wenzi = j["w"] as! String
                FLOG("文字：：：：\(wenzi)")
                voiceStr += wenzi
            }
        }
        self.descibeInfoTextView.text = self.descibeInfoTextView.text + voiceStr
        FLOG(isLast)
    }
    func onError(error: IFlySpeechError!) {
        FLOG(error)
    }

    //data  转 json
    func JSONObject(data: NSData) -> AnyObject? {
        return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
    }
    @IBAction func onclickPhotoButton(sender: AnyObject) {
        FLOG("123")
        self.view.endEditing(true)
        if redCloseBtn.hidden == true {
            var actionSheet = UIActionSheet(
                title: nil,
                delegate: self,
                cancelButtonTitle: "取消",
                destructiveButtonTitle: nil,
                otherButtonTitles:"相册","拍照")
            actionSheet.actionSheetStyle = UIActionSheetStyle.BlackOpaque
            actionSheet.destructiveButtonIndex = -1
            actionSheet.showInView(self.view)
        }else{
            var actionSheet = UIActionSheet(
                title: nil,
                delegate: self,
                cancelButtonTitle: "取消",
                destructiveButtonTitle: nil,
                otherButtonTitles:"相册","拍照","删除")
            actionSheet.actionSheetStyle = UIActionSheetStyle.BlackOpaque
            actionSheet.destructiveButtonIndex = -1
            actionSheet.showInView(self.view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        FLOG(buttonIndex)
        if buttonIndex == 0 {
        }else if buttonIndex == 1 {
            self.pickImageFromAlbum()
        }else if buttonIndex == 2 {
            self.pickImageFromCarera()
        }else {
            self.deleteImage()
        }
    }
    
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
        
        //
        if picker.sourceType == UIImagePickerControllerSourceType.PhotoLibrary{
//            theImage = info["UIImagePickerControllerOriginalImage"] as UIImage
            // self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            theImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
            UIImageWriteToSavedPhotosAlbum(self.theImage, nil, nil, nil)
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
        self.addLoadingView()
        HttpManager.uploadFileToServer(BASE_URL + UPLOAD_IMAGE , uploadImage: self.theImage,imageType:.Jpg)
            .responseJSON{(_, _, JSON, _) in
                if let json = JSON as? [String:AnyObject] {
                    if (json["code"] as! Int) == 0 {
                        println("上传图片返回JSON\(json)")

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

    }

    // MARK: - collectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedImageArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: MoreImageCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("MoreImageCollectionViewCell", forIndexPath: indexPath) as! MoreImageCollectionViewCell
        cell.loadData(self.selectedImageArray[indexPath.row],index:indexPath.row)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(54, 88)
    }
  
}
