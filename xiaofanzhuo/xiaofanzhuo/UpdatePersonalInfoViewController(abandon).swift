//
//  UpdatePersonalInfoViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-15.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class UpdatePersonalInfoViewController: BasicViewController {
//各种view
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topAlignment: NSLayoutConstraint!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var midBgView: UIView!
    @IBOutlet weak var commitBtn: UIButton!
//与数据相关的控件
    @IBOutlet weak var inviteCode: UITextField!
    @IBOutlet weak var fullName: UITextField!
    var age: String! = ""
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var city: UITextField!
    var cityPicker : UIPickerView!
    var sex : String! = ""
    var currentSituation : String! = "" //选填
    @IBOutlet weak var direction: HolderTextView!
    @IBOutlet weak var experience: HolderTextView!
    var industry : [[String:AnyObject]]! = [[String:AnyObject]]()
    @IBOutlet weak var industryText: UITextField!
    @IBOutlet weak var intro: HolderTextView!
    var skill : [[String:AnyObject]]! = [[String:AnyObject]]()
    @IBOutlet weak var skillText: UITextField!
//一些变量
    var imageUrl : String!
    var theImage : UIImage!
    private var locationManager : CLLocationManager!
    private var currentLocation : CLLocation!
//一些常量
    let AGE_START = 1000
    let SEX_START = 2000
    let SITUATION_START = 3000
    let INDUSTRY_FLAG = 0
    let SKILL_FLAG = 1
    let CITY_ARRAY = ["",
        "北京", "上海", "天津", "重庆", "石家庄", "唐山", "秦皇岛", "邯郸", "邢台",
        "保定", "张家口", "承德", "沧州", "廊坊", "衡水", "太原", "大同", "阳泉",
        "长治", "晋城", "朔州", "晋中", "运城", "忻州", "临汾", "吕梁", "呼和浩特",
        "包头", "乌海", "赤峰", "通辽", "鄂尔多斯", "呼伦贝尔", "巴彦淖尔", "乌兰察布",
        "兴安", "锡林郭勒", "阿拉善", "沈阳", "大连", "鞍山", "抚顺", "本溪", "丹东",
        "锦州", "营口", "阜新", "辽阳", "盘锦", "铁岭", "朝阳", "葫芦岛", "长春",
        "吉林", "四平", "辽源", "通化", "白山", "松原", "白城", "延边", "哈尔滨",
        "齐齐哈尔", "鸡西", "鹤岗", "双鸭山", "大庆", "伊春", "佳木斯", "七台河",
        "牡丹江", "黑河", "绥化", "大兴安岭", "南京", "无锡", "徐州", "常州", "苏州",
        "南通", "连云港", "淮安", "盐城", "扬州", "镇江", "泰州", "宿迁", "杭州", "宁波",
        "温州", "嘉兴", "湖州", "绍兴", "金华", "衢州", "舟山", "台州", "丽水", "合肥",
        "芜湖", "蚌埠", "淮南", "马鞍山", "淮北", "铜陵", "安庆", "黄山", "滁州", "阜阳",
        "宿州", "巢湖", "六安", "亳州", "池州", "宣城", "福州", "厦门", "莆田", "三明",
        "泉州", "漳州", "南平", "龙岩", "宁德", "南昌", "景德镇", "萍乡", "九江", "新余",
        "鹰潭", "赣州", "吉安", "宜春", "抚州", "上饶", "济南", "青岛", "淄博", "枣庄",
        "东营", "烟台", "潍坊", "威海", "济宁", "泰安", "日照", "莱芜", "临沂", "德州",
        "聊城", "滨州", "菏泽", "郑州", "开封", "洛阳", "平顶山", "焦作", "鹤壁", "新乡",
        "安阳", "濮阳", "许昌", "漯河", "三门峡", "南阳", "商丘", "信阳", "周口", "驻马店",
        "武汉", "黄石", "襄樊", "十堰", "荆州", "宜昌", "荆门", "鄂州", "孝感", "黄冈",
        "咸宁", "随州", "恩施", "长沙", "株洲", "湘潭", "衡阳", "邵阳", "岳阳", "常德",
        "张家界", "益阳", "郴州", "永州", "怀化", "娄底", "湘西", "广州", "深圳", "珠海",
        "汕头", "韶关", "佛山", "江门", "湛江", "茂名", "肇庆", "惠州", "梅州", "汕尾",
        "河源", "阳江", "清远", "东莞", "中山", "潮州", "揭阳", "云浮", "南宁", "柳州",
        "桂林", "梧州", "北海", "防城港", "钦州", "贵港", "玉林", "百色", "贺州", "河池",
        "来宾", "崇左", "海口", "三亚", "成都", "自贡", "攀枝花", "泸州", "德阳", "绵阳",
        "广元", "遂宁", "内江", "乐山", "南充", "宜宾", "广安", "达州", "眉山", "雅安",
        "巴中", "资阳", "阿坝", "甘孜", "凉山", "贵阳", "六盘水", "遵义", "安顺", "铜仁",
        "毕节", "黔西南", "黔东南", "黔南", "昆明", "曲靖", "玉溪", "保山", "昭通", "丽江",
        "普洱", "临沧", "文山", "红河", "西双版纳", "楚雄", "大理", "德宏", "怒江", "迪庆",
        "拉萨", "昌都", "山南", "日喀则", "那曲", "阿里", "林芝", "西安", "铜川", "宝鸡",
        "咸阳", "渭南", "延安", "汉中", "榆林", "安康", "商洛", "兰州", "嘉峪关", "金昌",
        "白银", "天水", "武威", "张掖", "平凉", "酒泉", "庆阳", "定西", "陇南", "临夏", "甘南",
        "西宁", "海东", "海北", "黄南", "海南", "果洛", "玉树", "海西", "银川", "石嘴山", "吴忠",
        "固原", "中卫", "乌鲁木齐", "克拉玛依", "吐鲁番", "哈密", "和田", "阿克苏", "喀什",
        "克孜勒苏柯尔克孜", "巴音郭楞蒙古", "昌吉", "博尔塔拉蒙古", "伊犁哈萨克", "塔城", "阿勒泰",
        "香港", "澳门", "台北", "高雄", "基隆", "台中", "台南", "新竹", "嘉义"]
    
    var oldY : CGFloat = 0
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置scrollView
        var height = contentView.frame.height
        contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-10, 1010)
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.bounds.size
        scrollView.delegate = self
 
        //头像形状ApplicationContext.getUserInfo()!["avatar"] as String
        avatar.sd_setImageWithURL(NSURL(string:ApplicationContext.getUserInfo()!["avatar"] as! String), placeholderImage: UIImage(named:"avater"))
        avatar.layer.cornerRadius = 5
        avatar.clipsToBounds = true
        FLOG(ApplicationContext.getUserInfo())
        //设置城市滚轮
        cityPicker = UIPickerView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height-150, UIScreen.mainScreen().bounds.width, 150))
        cityPicker.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        cityPicker.delegate = self
        cityPicker.dataSource = self
        
        //设置个人信息背景的阴影
        midBgView.layer.borderWidth = 1.5
        midBgView.layer.borderColor = CGColorCreateCopyWithAlpha(UIColor.lightGrayColor().CGColor, 0.3)
        
        //设置placeHolder与字数限制
        experience.placeHolder = "经历越详细，通过审核机会越大呦"//字数默认限制140字
        direction.placeHolder = "请简述您的创业方向："
        intro.placeHolder = "请一句话介绍您自己："
        
        //初始化定位设置
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 1000
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startUpdatingLocation()
        //限制字数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        FLOG(topView.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: -类方法
extension UpdatePersonalInfoViewController{
    func toJSONString(object : AnyObject) -> NSString{
        var data = NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
        var strJson : NSString! = NSString(data: data, encoding: NSUTF8StringEncoding)
        return strJson
    }
    
    //从相册取图片
    func pickImageFromAlbum(){
        var imagePicker : UIImagePickerController
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        imagePicker.allowsEditing = true
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
    
    func limitTextLength(textField:UITextField,maxLength:Int){
        var text = textField.text as NSString
        if text.length > maxLength {
            textField.text = text.substringToIndex(maxLength)
        }
    }
}

//MARK: -UIScrollViewDelegate
extension UpdatePersonalInfoViewController : UIScrollViewDelegate{  //顶部随scrollView滑动的动画
    func scrollViewDidScroll(scrollView: UIScrollView){
        if scrollView.contentOffset.y >= 0 {
            UIView.animateWithDuration(0.0, animations: { () -> Void in
                var nowY = scrollView.contentOffset.y
            
                if nowY > self.oldY { //向上拉
                    self.topAlignment.constant = -scrollView.contentOffset.y * 0.29
                }else if nowY < self.oldY { //向下拉
                    self.topAlignment.constant = -scrollView.contentOffset.y * 0.29
                }
                self.oldY = nowY
            })
            //FLOG(scrollView.contentOffset)
        }else{
            UIView.animateWithDuration(0.3, animations: { () -> Void in
               self.topAlignment.constant = 0
               self.view.layoutIfNeeded()
            })
        }
    }
}

//MARK: -UIPickerViewDataSource
extension UpdatePersonalInfoViewController : UIPickerViewDataSource{
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return CITY_ARRAY.count
    }
}

//MARK: -UIPickerViewDelegate
extension UpdatePersonalInfoViewController : UIPickerViewDelegate{
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!{
        return CITY_ARRAY[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        FLOG(CITY_ARRAY[row])
        self.city.text = CITY_ARRAY[row]
    }
}

//MARK: -按钮点击
extension UpdatePersonalInfoViewController {
    @IBAction func onclickSubmitButton(sender: AnyObject) {
        //TODO检测选填必填
        if fullName.text.isEmpty {
            UIAlertView(title: "提示", message: "姓名不能为空", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        if phoneNumber.text.isEmpty {
            UIAlertView(title: "提示", message: "电话号码不能为空", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        if sex.isEmpty {
            UIAlertView(title: "提示", message: "性别不能为空", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        if experience.text.isEmpty {
            UIAlertView(title: "提示", message: "个人经历不能为空", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        if currentSituation.isEmpty {
            UIAlertView(title: "提示", message: "目前状态不能为空", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        if direction.text.isEmpty {
            UIAlertView(title: "提示", message: "创业方向不能为空", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        //测试个人信息
        var userID = ApplicationContext.getUserID()!
        var imageUrl = ApplicationContext.getUserInfo()!["avatar"] as! String
        
        var param : [String:AnyObject] = // ["":""]
        ["userId": userID,
            "code":inviteCode.text,
            "username":fullName.text,
            "avatar":imageUrl,
            "phone":phoneNumber.text,
            "sex":sex,
            "age":age,
            "city":city.text,
            "situation":currentSituation,
            "intro":intro.text,
            "industry": toJSONString(industry),
            "skill":toJSONString(skill),
            "direction":direction.text,
            "experience":experience.text
        ]
        FLOG("提交个人信息参数：\(param)")
        //加上if let
        commitBtn.enabled = false
        HttpManager.postDatatoServer(.POST, BASE_URL + SET_USER_INFO ,parameters:
            param)
            .responseJSON { (_, _, JSON, _) in
            FLOG("个人信息测试：\(JSON)")
            if let json = JSON as? [String:AnyObject] {
                if (json["code"] as! Int) == 0 {
                    println(json["userState"])
                    if (json["userState"] as! String) == "3" {//审核通过，进首页
                        HttpManager.postDatatoServer(.POST, BASE_URL + GETUSERINFO ,parameters:
                            ["userId": ApplicationContext.getUserID()!,
                                "id": ApplicationContext.getUserID()!
                            ])
                            .responseJSON { (_, _, JSON, _) in
                                if let json = JSON as? [String:AnyObject] {
                                    FLOG("更新个人信息返回json:\(json)")
                                    if (json["code"] as! Int) == 0 {//未填写个人信息，或者填写个人信息通过了审核
                                        var userInfo = ApplicationContext.getUserInfo()!
                                        
                                        if let personInfo = json["userInfo"] as? [String:AnyObject] {
                                            userInfo["personInfo"] = personInfo
                                        }
                                        if let binding = json["binding"] as? [String:AnyObject] {
                                            userInfo["binding"] = binding
                                        }
                                        userInfo["userState"] = "3"
                                        ApplicationContext.saveUserInfo(userInfo)
                                        var homeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
                                        self.navigationController?.pushViewController(homeViewController, animated: true)
                                    }
                                }
                        }
   
                    }else{//此处跳转到审核页面
                        var userInfo = ApplicationContext.getUserInfo()!
                        userInfo["userState"] = "2"
                        ApplicationContext.saveUserInfo(userInfo)
                        var verifyViewController = VerifyViewController(nibName: "VerifyViewController", bundle: nil)
                        self.navigationController?.pushViewController(verifyViewController, animated: true)
                    }
                }else{
                    //code !=0
                    self.commitBtn.enabled = true
                    HYBProgressHUD.showError(json["message"] as! String)
                    FLOG("服务器返回数据错误,code!=0")
                }
            }else{
                    self.commitBtn.enabled = true
                HYBProgressHUD.showError("网络连接错误")
                FLOG("网络连接错误！")
            }
            
        }
    }
    
//强制关闭键盘
    @IBAction func bgBtnClick(sender: AnyObject) {
        self.view.endEditing(true)
        self.cityPicker.removeFromSuperview()
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
    
    @IBAction func situationCheckBtnClick(sender: UIButton) {
        self.view.endEditing(true)
        self.cityPicker.removeFromSuperview()
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
        //  FLOG(currentSituation)
    }
//更多弹出信息（行业，技能）
    @IBAction func getMoreInfoBtnClikc(sender: UIButton) {
        
        var infoView = NSBundle.mainBundle().loadNibNamed("MoreInformationView", owner: self, options: nil)[0] as! MoreInformationView
//        infoView.frame = self.view.frame
        sender.userInteractionEnabled = false
        self.view.endEditing(true)
        self.cityPicker.removeFromSuperview()
        HttpManager.postDatatoServer(.POST, BASE_URL + GET_USER_INFO_OPTIONS)
            .responseJSON { (_, _, JSON, _) in
                if let json = JSON as? [String:AnyObject] {
                    if (json["code"] as! Int) == 0 {
//                        var dataArray = json["topicList"] as [[String:AnyObject]]
                        //FLOG(json)
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
                                sender.userInteractionEnabled = true //防止多次点击
                                //FLOG(self.industry)
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
                                sender.userInteractionEnabled = true //防止多次点击
                                //FLOG("技能：\(self.skill)")
                            })
                            break
                        default:
                            break
                        }
                        self.view.addSubview(infoView)
                    }else{
                        //code !=0
                        HYBProgressHUD.showError(json["message"] as! String)
                        FLOG("服务器返回数据错误,code!=0")
                    }
                }else{
                    HYBProgressHUD.showError("网络连接错误")
                    FLOG("网络连接错误！")
                }
        }
    }
//城市按钮
    @IBAction func cityBtnClick(sender: AnyObject) {
        self.view.endEditing(true)
        self.view.addSubview(cityPicker)
    }
    
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
}

//MARK: -UIActionSheetDelegate
extension UpdatePersonalInfoViewController : UIActionSheetDelegate{
    
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

//MARK: -Notifications
extension UpdatePersonalInfoViewController{
    
    func textChanged(notification:NSNotification){
        var textField = notification.object as! UITextField
        
        if textField == phoneNumber {   //电话号码输入框
            limitTextLength(textField, maxLength: 11)
        }
        if textField == inviteCode {//邀请码输入框
            limitTextLength(textField, maxLength: 4)
        }
        if textField == fullName {//邀请码输入框
            limitTextLength(textField, maxLength: 16)
        }
        
    }
}

//MARK: -UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension UpdatePersonalInfoViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        if picker.sourceType == UIImagePickerControllerSourceType.PhotoLibrary{
            theImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
           // self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            theImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
          //  self.dismissViewControllerAnimated(true, completion: nil)
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
        
        
        //            imageEditor.doneCallback
        imageEditor.doneCallback = {(editedImage:UIImage!,canceled:Bool) -> Void in
            if !canceled == true {
                self.theImage = editedImage
                self.theImage = CommonTool.fullScreenImage(self.theImage)
                UIImageWriteToSavedPhotosAlbum(self.theImage, nil, nil, nil)
//                self.testImageView.image = self.theImage
                self.dismissViewControllerAnimated(true, completion: nil)
                self.addLoadingView()
                HttpManager.uploadFileToServer(BASE_URL + UPLOAD_IMAGE , uploadImage: self.theImage,imageType:.Jpg)
                    .responseJSON{(_, _, JSON, _) in
                        if let json = JSON as? [String:AnyObject] {
                            if (json["code"] as! Int) == 0 {
                                println("上传图片返回JSON\(json)")
                                self.imageUrl = json["imageUrl"] as! String
                                self.avatar.image = self.theImage
                                //本地保存头像
                                var userInfo = ApplicationContext.getUserInfo()!
                                 userInfo["avatar"] = self.imageUrl
                                ApplicationContext.saveUserInfo(userInfo)
        //                        FLOG("save\(ApplicationContext.getUserInfo())")
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
        }
    }
}

//MARK: -CLLocationManagerDelegate
extension UpdatePersonalInfoViewController : CLLocationManagerDelegate{
    
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
                self.city.text = placemark.locality
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



