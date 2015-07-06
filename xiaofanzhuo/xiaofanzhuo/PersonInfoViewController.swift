//
//  PersonInfoViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/3/11.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class PersonInfoViewController: BasicViewController{
    //各种view
    @IBOutlet weak var bgBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    //数据相关控件变量
    @IBOutlet weak var inviteCode: UITextField!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var city: UITextField!
    var cityPicker : UIPickerView!
    var sex : String! = ""
    var age: String! = ""
    //一些变量
    var imageUrl : String! = ""
    var imageName : String = ""
    var theImage : UIImage!
    var preStr = ""
    //一些常量
    let AGE_START = 1000
    let SEX_START = 2000
    let MAX_LENGTH = 16
    let MIN_LENGTH = 6
    
    private var locationManager : CLLocationManager!
    private var currentLocation : CLLocation!
    
    var CITY_DIC:[String:AnyObject] {
        get{
            //获取文件资源中的城市
            var cityPath = NSBundle.mainBundle().pathForResource("citys", ofType: "json")!
            var dicc = NSString(contentsOfFile: cityPath, encoding: NSUTF8StringEncoding, error: nil)!
            var objectData: NSData = dicc.dataUsingEncoding(NSUTF8StringEncoding)!
            var cityPlaceJson = NSJSONSerialization.JSONObjectWithData(objectData,options:NSJSONReadingOptions.MutableContainers, error:nil) as! [String:AnyObject]
            return cityPlaceJson
        }
    }
    
    var provienceArray = [String]()
    var cityArray = [[String]]()
    var cityArrayForDisplay = [String]()

    var sel_provienceName = "北京"
    var sel_cityName = "东城区"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-10, 638)
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.bounds.size
        scrollView.delegate = self
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        self.headView.hidden = true
        
        //头像形状
        avatar.layer.cornerRadius = 5
        avatar.clipsToBounds = true
        
        //设置城市滚轮
        cityPicker = UIPickerView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height-150, UIScreen.mainScreen().bounds.width, 150))
        cityPicker.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        cityPicker.delegate = self
        cityPicker.dataSource = self
        
        //初始化定位设置
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.distanceFilter = 1000

        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startUpdatingLocation()
        
        //键盘弹出监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShown:", name: UIKeyboardWillShowNotification, object: nil)
        
        //初始化电话号码,从上层页面传过来
        if let data = self.param as? [String:AnyObject] {
            phoneNumber.text = data["phoneNum"] as! String
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChange:", name: UITextFieldTextDidChangeNotification, object: nil)
        
        //初始化城市与省份provienceArray
        var dic_provienceArray = CITY_DIC["citylist"] as! [[String:AnyObject]]
        
        
        for i in 0..<dic_provienceArray.count {
            var provienceJson = dic_provienceArray[i] as [String:AnyObject]
            var provienceName = provienceJson["p"] as! String
            self.provienceArray.append(provienceName)
            

            var dic_cityArray = provienceJson["c"] as! [AnyObject]

            
            var citys = [String]()
            for j in 0..<dic_cityArray.count{
                var cityJson = dic_cityArray[j] as! [String:AnyObject]
                var cityName = cityJson["n"] as! String
                
                citys.append(cityName)
            }
            self.cityArray.append(citys)
        }
        self.cityArrayForDisplay = self.cityArray[0]
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.locationManager.stopUpdatingLocation()
    }
}

//MARK: -按钮点击
extension PersonInfoViewController {
    //下一页
    @IBAction func nextPageBtnClick(sender: AnyObject) {
        
        //TODO检测选填必填
        if fullName.text.isEmpty {
            HYBProgressHUD.showError("姓名不能为空")
            return
        }
        if phoneNumber.text.isEmpty {
            HYBProgressHUD.showError("电话号码不能为空")
            return
        }
        if sex.isEmpty {
            HYBProgressHUD.showError("性别不能为空")
            return
        }
        if !checkTextCount(passWord,maxLength: MAX_LENGTH) {
            HYBProgressHUD.showError("密码位数需大于6")
            return
        }
        
//        if !checkIsFullOfChinese(fullName.text) {
//            HYBProgressHUD.showError("用户名不能包含非中文字符")
//            return
//        }
//        println("count:\(matches.count),length:\( (fullName.text as NSString).length)")
        
        //测试个人信息

        var userID = (self.param as! [String:AnyObject])["userId"] as! String!//ApplicationContext.getUserID()!
        var imageName = self.imageName//ApplicationContext.getUserInfo()!["avatar"] as String
        
        var param : [String:AnyObject] = // ["":""]
        ["userId": userID,
            "code":inviteCode.text,
            "username":fullName.text,
            "password":passWord.text.md5_with_tail,
            "avatar":imageName,
            "phone":phoneNumber.text,
            "sex":sex,
            "age":age,
            "city":city.text,
        ]
        FLOG("提交个人信息参数：\(param)")
        //加上if let
        
        var workInfoViewController = WorkInfoViewController(nibName: "WorkInfoViewController", bundle: nil,param:param)
        self.navigationController?.pushViewController(workInfoViewController, animated: true)
    }
    //上传头像
    @IBAction func uploadBtnClick(sender: AnyObject) {
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
    
    //年龄单选
    @IBAction func ageCheckBtnClick(sender: UIButton) {
        self.view.endEditing(true)
        self.cityPicker.removeFromSuperview()
        for var i = 1;i<5;i++ {
            (self.view.viewWithTag(AGE_START + i) as! UIButton).selected = false
            (self.view.viewWithTag(AGE_START + i + 10) as! UILabel).textColor = UIColor.lightGrayColor()
        }
        sender.selected = true
        (self.view.viewWithTag(sender.tag + 10) as! UILabel).textColor = UIColor.blackColor()
        switch sender.tag - AGE_START {
        case 1:
            age = "70后"
            break
        case 2:
            age = "80后"
            break
        case 3:
            age = "90后"
            break
        case 4:
            age = "其他"
            break
        default:
            break
        }
        // FLOG(age)
    }
    //性别单选
    @IBAction func sexCheckBtnClick(sender: UIButton) {
        self.view.endEditing(true)
        self.cityPicker.removeFromSuperview()
        for var i = 1;i<3;i++ {
            (self.view.viewWithTag(SEX_START + i) as! UIButton).selected = false
            (self.view.viewWithTag(SEX_START + i + 10) as! UILabel).textColor = UIColor.lightGrayColor()
        }
        sender.selected = true
        (self.view.viewWithTag(sender.tag + 10) as! UILabel).textColor = UIColor.blackColor()
        switch sender.tag - SEX_START {
        case 1:
            sex = String(1)
            break
        case 2:
            sex = String(2)
            break
        default:
            break
        }
        //        FLOG(sex)
    }
    //城市按钮
    @IBAction func cityBtnClick(sender: AnyObject) {
        self.view.endEditing(true)
        contentView.bringSubviewToFront(bgBtn)
        self.view.addSubview(cityPicker)
        self.city.text = sel_provienceName + sel_cityName
    }
    //强制关闭键盘
    @IBAction func bgBtnClick(sender: AnyObject) {
        contentView.sendSubviewToBack(bgBtn)
        self.view.endEditing(true)
        self.cityPicker.removeFromSuperview()
    }
}

//MARK: -UIActionSheetDelegate
extension PersonInfoViewController : UIActionSheetDelegate{
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        FLOG(buttonIndex)
        if buttonIndex == 0 {
        }else if buttonIndex == 1 {
            self.pickImageFromAlbum()
        }else if buttonIndex == 2 {
            self.pickImageFromCarera()
        }
    }
}

//MARK: -类方法
extension PersonInfoViewController{
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
        contentView.bringSubviewToFront(bgBtn)
    }
}

//MARK: -UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension PersonInfoViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
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
                                println("上传图片返回JSON\(json)")
                                self.imageUrl = json["imageUrl"] as! String
                                self.avatar.image = self.theImage
                                self.imageName = json["name"] as! String
                                //本地保存头像
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

//MARK: -UIPickerViewDataSource
extension PersonInfoViewController : UIPickerViewDataSource{
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        var provienceArray = CITY_DIC["citylist"] as! [[String:AnyObject]]

        switch component {
        case 0:
            return provienceArray.count
        case 1:
            return cityArrayForDisplay.count
        default:
            return 0
        }
        //CITY_ARRAY.count
    }
}

//MARK: -UIPickerViewDelegate
extension PersonInfoViewController : UIPickerViewDelegate{

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        switch component {
        case 0:
            self.cityArrayForDisplay = self.cityArray[row]
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            self.sel_provienceName = self.provienceArray[row]
            self.sel_cityName = self.cityArrayForDisplay[0]
        case 1:
            self.sel_cityName = self.cityArrayForDisplay[row]
            break
        default:
            break
        }
        self.city.text = sel_provienceName + sel_cityName
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView{

        var label = view as? UILabel
        if label == nil {
            label = UILabel()
            label?.textAlignment = NSTextAlignment.Center
        }
        label?.textColor = UIColor.whiteColor()
        //CITY_ARRAY[row]
        switch component {
        case 0:
            label?.text = self.provienceArray[row]
            return label!
        case 1:
            label?.text = self.cityArrayForDisplay[row]
            return label!
        default:
            break
        }
        return label!
    }
    
}

//MARK: -CLLocationManagerDelegate
extension PersonInfoViewController : CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        var count = locations.count
        if count <= 0 {
            return
        }
        
        if self.currentLocation != nil {
            return
        }
        
        self.currentLocation = locations.first as! CLLocation
        
        var geocoder = CLGeocoder()
        var placemark: CLPlacemark!
        geocoder.reverseGeocodeLocation(self.currentLocation, completionHandler: {(placemarks, error)->Void in
            var placemark:CLPlacemark!
            // 获取城市名称
            if error == nil && placemarks.count > 0 {
                placemark = placemarks[0] as! CLPlacemark
                if let local = placemark.locality {
                    self.city.text = placemark.locality
                }else{
                    HYBProgressHUD.showError("无法定位所在城市")
                }
                FLOG("placemark.locality:\(placemark.locality)")
            }
            manager.stopUpdatingLocation()
        })
        
        
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        manager.stopUpdatingLocation()
        HYBProgressHUD.showError("无法定位所在城市")
        
    }
}

//MARK:- TextFieldNSNotification
extension PersonInfoViewController{
    func textChange(notification:NSNotification){
        var textField = notification.object as! UITextField
        
        if textField == passWord {
            checkTextCount(textField,maxLength: MAX_LENGTH)
        }
        
        if textField == fullName {
            var language = textField.textInputMode?.primaryLanguage
            //        FLOG("language:\(language)")
            if let lang = language {
                if lang == "zh-Hans" ||  lang == "zh-Hant" || lang == "ja-JP"{ //如果是中文简体,或者繁体输入,或者是日文这种带默认带高亮的输入法
                    var selectedRange = textField.markedTextRange
                    var position : UITextPosition?
                    if let range = selectedRange {
                        position = textField.positionFromPosition(range.start, offset: 0)
                    }
                    //系统默认中文输入法会导致英文高亮部分进入输入统计，对输入完成的时候进行字数统计
                    if position == nil {
                        checkTextCount(textField,maxLength: 8)
                        if !checkIsFullOfChinese(textField.text) {
                            textField.text = preStr
                        }
                    }
                }else{//非中文输入法
                    checkTextCount(textField,maxLength: 8)
                    if !checkIsFullOfChinese(textField.text) {
                        textField.text = preStr
                    }
                    
                }
            }
            if checkIsFullOfChinese(textField.text) {
                preStr = textField.text
            }
            
        }
    }
    
    //判断字数个数是否大于最少个数，并对超出最大个数的进行限制
    func checkTextCount(textField:UITextField,maxLength:Int) -> Bool{
        
        if (count(textField.text) > maxLength) {
            textField.text = textField.text.substringToIndex(advance(textField.text.startIndex, maxLength))
        }
        
        if count(textField.text) >= MIN_LENGTH {
            return true
        }
        return false
    }
    
    //检查是否全是中文
    func checkIsFullOfChinese(text:String) -> Bool {
        var error:NSError?
        let expression=NSRegularExpression(pattern: "[\\u4e00-\\u9fa5]", options: .CaseInsensitive, error: &error)
        let matches = expression!.matchesInString(text, options: nil, range: NSMakeRange(0, count(text)))
        
        if matches.count < count(text) {
            return false
        }
        return true
    }
}

//MARK:-UIScrollViewDelegate
extension PersonInfoViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(scrollView: UIScrollView){
        self.view.endEditing(true)
    }
}
