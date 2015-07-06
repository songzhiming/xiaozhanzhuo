//
//  BasePublishViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/12.
//  Copyright (c) 2015年 songzm. All rights reserved.
//
//  本类实现发布界面的基础功能，不作为实例new出来，由子类进行具体实现

import UIKit

let keyboard_height_iphone5      :CGFloat = 253
let keyboard_height_iphone6      :CGFloat = 258
let keyboard_height_iphone6_plus :CGFloat = 271

let toolView_hidden_constant :CGFloat = 0
let titleView_hidden_constant :CGFloat = 0

class BasePublishViewController: BasicViewController {

    //ib控件
    @IBOutlet weak var titleText: HolderTextView!
    @IBOutlet weak var contentText: HolderTextView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var atBtn: UIButton!
    @IBOutlet weak var atListView: UITextView!
    
    //约束
    @IBOutlet weak var titleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var toolViewTopToSuperBot: NSLayoutConstraint!
    @IBOutlet weak var atListHeight: NSLayoutConstraint!
    
    //view
    var photoCollectionView: ShowPhotoCollectionView!
    
    //讯飞语音相关
    var _iFlySpeechSynthesizer :IFlySpeechSynthesizer?
    var _iflyRecognizerView : IFlyRecognizerView?
    
    //变量
    var stateId = ""    //用于草稿保存
    var isPublish = false //标识草稿是否已发布
    var isToShowCol = true //是否显示已选照片的collectionView
    var deleteIndex = 0     //记录将要被删除的已选择的@用户的
    
    //常量
    let TOOLVIEW_HEIGHT = 40
    let ANIMATE_TIME = 0.3
    
    //Model
    var imageSource: ImageSource!
    var atDataSouce: AtDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headView.changeLeftButton()
        headView.hideRightButton(true)
        headView.sendButton.hidden = false
        
        photoCollectionView = ShowPhotoCollectionView(frame: CGRectMake(11, 77,UIScreen.mainScreen().bounds.width - 12 * 2, 200), collectionViewLayout: UICollectionViewFlowLayout())
        photoCollectionView.showPhotoDelegate = self
        toolView.addSubview(photoCollectionView)

        imageSource = ImageSource()
        atDataSouce = AtDataSource()
        
        //kvo具体实现由子类来进行
        atListView.addObserver(self, forKeyPath:"attributedText", options: NSKeyValueObservingOptions.New, context: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendBtnClick", name: "sendNewTopic", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    deinit {
        if !self.isPublish {
            PersistentManager.setValueById(stateId, describe: contentText.text, title: titleText.text)
        }
        atListView.removeObserver(self, forKeyPath: "attributedText")
    }
}

//MARK:-按钮点击
extension BasePublishViewController {
    func sendBtnClick(){
        
    } 

    @IBAction func photoBtnClick(sender: AnyObject) {
        self.view.endEditing(true)
        UIView.animateWithDuration(ANIMATE_TIME,
            animations: { () -> Void in
                self.showImageCollectionView(self.isToShowCol)
                self.view.layoutIfNeeded()
        }) { (finish) -> Void in
            self.isToShowCol = !self.isToShowCol
        }
    }
    
    @IBAction func speechBtnClick(sender: AnyObject) {
        self.view.endEditing(true)
        _iflyRecognizerView = IFlyRecognizerView(center: self.view.center);
        _iflyRecognizerView?.delegate = self
        _iflyRecognizerView?.setParameter("iat", forKey: IFlySpeechConstant.IFLY_DOMAIN())
        _iflyRecognizerView?.setParameter("asrview.pcm", forKey: IFlySpeechConstant.ASR_AUDIO_PATH())
        _iflyRecognizerView?.start()
    }

    @IBAction func atBtnClick(sender: AnyObject) {
    }
    @IBAction func toolBarTouh(sender: AnyObject) {
        self.view.endEditing(true)
    }
}

//MARK:-实例方法
extension BasePublishViewController {
    func setTitleViewHidden(){//隐藏标题
        titleViewHeight.constant = titleView_hidden_constant
    }
    func setToolViewHidden(){//隐藏底部工具栏
        toolViewTopToSuperBot.constant = toolView_hidden_constant
    }
    func showImageCollectionView(bool:Bool){
        toolViewTopToSuperBot.constant = bool ? 164 : 40
    }
    func showImageCollectionViewDelata(delata:CGFloat){
        if toolViewTopToSuperBot.constant != toolView_hidden_constant {//防止在设置了setToolViewHidden时弹出
            toolViewTopToSuperBot.constant = delata + 40
        }
    }
    func showPhotoBtnCornerStatus(count:Int){
        photoBtn.showCornerStatus(count, rateX: 0.8, rateY: 0.22)
    }
    func getDraft(id:String){
        if let dic = PersistentManager.getValueById(id){
            self.titleText.text = dic["title"]
            self.contentText.text = dic["describe"]
        }
    }
    func reloadAttributeText(){
        atListView.attributedText = atDataSouce.atAttributeNames
    }
}

//MARK:-KeyBoardNotifications
extension BasePublishViewController {
    //键盘弹出处理
    func keyboardWillShown(notification:NSNotification){
//        FLOG("notificationg:------>\(notification)")
        var height : CGFloat = 0
        switch UIScreen.mainScreen().bounds.width {
        case 320:
            height = keyboard_height_iphone5
        case 375:
            height = keyboard_height_iphone6
        case 414:
            height = keyboard_height_iphone6_plus
        default:
            break
        }
        UIView.animateWithDuration(ANIMATE_TIME, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.showImageCollectionViewDelata(height)
            self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in
        })
    }
    
    func keyboardWillHide(notification:NSNotification){
        UIView.animateWithDuration(ANIMATE_TIME, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.showImageCollectionView(self.isToShowCol)
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
        })
    }
}

//MARK:-ShowPhotoCollectionViewDelegate
extension BasePublishViewController:ShowPhotoCollectionViewDelegate {
    func imagesCollectionDidChange(imageUrls:[String]){
        imageSource.imageUrls = imageUrls
        showPhotoBtnCornerStatus(imageSource.imageUrls.count)
    }
}

//MARK:-IFlyRecognizerViewDelegate
extension BasePublishViewController:IFlyRecognizerViewDelegate{
    func onResult(resultArray: [AnyObject]!, isLast: Bool) {
        if resultArray == nil {
            return
        }
        var a = resultArray[0] as! [String : AnyObject]
        var str : NSString = ""
        for key in a.keys {
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
        self.contentText.text = self.contentText.text + voiceStr
    }
    func onError(error: IFlySpeechError!) {
        
    }
}
