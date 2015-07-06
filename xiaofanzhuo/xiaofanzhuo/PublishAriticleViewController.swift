//
//  PublishAriticleViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-19.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class PublishAriticleViewController: BasicViewController,UITextViewDelegate{
    
    
    @IBOutlet weak var topicTitleText: HolderTextView!
    @IBOutlet weak var countLabel: UILabel!
    var describeText : String! = ""
    var imageUrl : String! = ""
    var imageName : String! = ""
    var isPublish :Bool = false
    var stateId = ""
    
    var selectedImageName:[String] = [String]()   //图片name数组
    var selectedImageData:[UIImage] = [UIImage]() //图片 data数组
    var selectedImageArray:[String] = [String]()  //图片url数组
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.logoImage.hidden = true
        headView.titleLabel.hidden = false
        if let pa = param as? Int {//发起
            if param as! Int == 1 {
                headView.titleLabel.text = "发起新话题"
                topicTitleText.placeHolder = "请输入您的问题(40字内)"
                
                //获取草稿
                stateId = "newTopic"
                getDraft(stateId)
                
            }else{// param as Int = 0
                headView.titleLabel.text = "发起新组队"
                topicTitleText.placeHolder = "请输入您的组队要求(40字内)"
                //获取草稿
                stateId = "newMakeUp"
                getDraft(stateId)
            }
            FLOG("发起组队代号：\(pa)")
        }else{//编辑
            var pa = param as! [String : AnyObject]
            var curIndex = pa["curIndex"] as! String
            if curIndex == "3" {//编辑对对碰
                //FLOG("编辑对对碰")
                headView.titleLabel.text = "修改组队"
                var data = pa["data"] as! [String : AnyObject]
                topicTitleText.text = data["title"] as! String
                describeText = data["describe"] as! String
                
                
//                FLOG("data:::\(data)")
                FLOG(data["imageUrl"])
                
                var images = data["imageUrl"] as! [[String:AnyObject]]
                
                
                for (var i = 0 ;i < images.count ; i++){
                    FLOG(images[i]["imageUrl"])
                    
                    var url = images[i]["imageUrl"] as! String
                    
                    selectedImageArray.append(url)
                    
                    var nsImageUrl =  NSMutableString(string: url)
                    var imageName = nsImageUrl.stringByReplacingOccurrencesOfString(BASE_URL + "upload/images/", withString: "")
                    selectedImageName.append(imageName)
                }
                
                FLOG("编辑时初始化数据:\(topicTitleText.text)")
                FLOG("编辑时初始化数据:\(describeText)")
                FLOG("编辑时初始化数据:\(selectedImageName)")
            }else {//todo  编辑话题
                headView.titleLabel.text = "修改话题"
                var data = pa["data"] as! TopicInfo
                topicTitleText.text = data.title
                describeText = data.intro
                
                var images = data.imageUrl as [[String:AnyObject]]?
                
                if let newImages = images {
                    for (var i = 0 ;i < newImages.count ; i++){
                        FLOG(newImages[i]["imageUrl"])
                        
                        var url = newImages[i]["imageUrl"] as! String
                        
                        selectedImageArray.append(url)
                        
                        var nsImageUrl =  NSMutableString(string: url)
                        var imageName = nsImageUrl.stringByReplacingOccurrencesOfString(BASE_URL + "upload/images/", withString: "")
                        selectedImageName.append(imageName)
                    }
                }
                
                FLOG("编辑时初始化数据:\(topicTitleText.text)")
                FLOG("编辑时初始化数据:\(describeText)")
                FLOG("编辑时初始化数据:\(selectedImageName)")
            }
        }
        
        headView.backButton.hidden = false
        headView.recommendButton.hidden = true
        headView.searchButton.hidden = true
        headView.sendButton.hidden = false
        
        //设置placeHolder与字数限制
        
        topicTitleText.maxLength = 40
        topicTitleText.holderTextViewDelegate = self
        //设置剩余字数label
        var length = (topicTitleText.text as NSString).length
        countLabel.text = "\(40-length)/40"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendBtnClick", name: "sendNewTopic", object: nil)
        
    }
    
    deinit{
        if !self.isPublish {
            if let dic = PersistentManager.getValueById(stateId){
                //把二级页面的草稿存到这里
                PersistentManager.setValueById(stateId, describe: dic["describe"]!, title: topicTitleText.text)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}

//MARK: -按钮点击
extension PublishAriticleViewController {
    @IBAction func addDescription(sender: AnyObject) {
        FLOG(self.selectedImageArray)
        var addDescriptionViewController : AddDescriptionViewController = AddDescriptionViewController(param: param,describeText:self.describeText,imageUrl:self.selectedImageArray) { (imageName,imageUrl, text) -> Void in
            if let describe = text {
                self.describeText = describe
            }
            self.selectedImageArray = imageUrl
            self.selectedImageName = imageName
            
            FLOG("此处获得完成后的返回信息进行变量赋值：image:\(imageUrl),describe:\(text)")
        }
//AddDescriptionViewController(nibName: "AddDescriptionViewController", bundle: nil)

        self.navigationController?.pushViewController(addDescriptionViewController, animated: true)
    }
}

//MARK: -类方法
extension PublishAriticleViewController {
    
    func getDraft(id:String){
        if let dic = PersistentManager.getValueById(id){
            self.topicTitleText.text = dic["title"]
            self.describeText = dic["describe"]
        }
    }
    
    func sendBtnClick(){
        self.headView.sendButton.enabled = false
        var allImageArray : [AnyObject] = [AnyObject]()
        for (var i = 0 ;i < selectedImageName.count ;i++){
            allImageArray.append(["imageUrl":selectedImageName[i]])
        }
      
        FLOG("allImageArray::::\(ApplicationContext.toJSONString(allImageArray))")
        
        
        
        if let pa = param as? Int {//发起
            if param as! Int == 1 {//新话题
                if topicTitleText.text.isEmpty {
                    UIAlertView(title: "提示", message: "话题标题不能为空", delegate: nil, cancelButtonTitle: "OK").show()
                    return
                }
                var params : [String:AnyObject] = ["userId":ApplicationContext.getUserID()!,
                    "topicTitle":topicTitleText.text,
                    "topicDescribe":self.describeText,
                    "topicImage":ApplicationContext.toJSONString(allImageArray)
                ]
                FLOG("新话题参数\(params)")
                self.addLoadingView()
                HttpManager.sendHttpRequestPost(NEW_TOPIC, parameters: params,
                    success: { (json) -> Void in
                        
                        FLOG("发表新话题返回json:\(json)")
                        
                        //成功发表，不存储草稿,并删除草稿记录
                        self.isPublish = true
                        PersistentManager.deleteById(self.stateId)
                        
                        HYBProgressHUD.showSuccess("发表成功")

                        NSNotificationCenter.defaultCenter().postNotificationName("refreshCommunity", object: nil)
                        self.headView.sendButton.enabled = true
                        self.removeLoadingView()
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    },
                    failure:{ (reason) -> Void in
                        self.headView.sendButton.enabled = true
                        self.removeLoadingView()
                        FLOG("失败原因:\(reason)")
                })
            }else{//新组队
                if topicTitleText.text.isEmpty {
                    UIAlertView(title: "提示", message: "组队标题不能为空", delegate: self, cancelButtonTitle: "OK").show()
                    return
                }
                self.addLoadingView()
                HttpManager.sendHttpRequestPost(PUBLISHTASK, parameters:
                    ["userId":ApplicationContext.getUserID()!,
                        "title":topicTitleText.text,
                        "describe":self.describeText,
                        "imageUrl":ApplicationContext.toJSONString(allImageArray)
                    ],
                    success: { (json) -> Void in
                        
                        FLOG("发表组队返回json:\(json)")
                        
                        //成功发表，不存储草稿
                        self.isPublish = true
                        PersistentManager.deleteById(self.stateId)
                        
                        HYBProgressHUD.showSuccess("发表成功")
                        NSNotificationCenter.defaultCenter().postNotificationName("refreshMakeUp", object: nil)
                        self.navigationController?.popViewControllerAnimated(true)
                        self.removeLoadingView()
                        self.headView.sendButton.enabled = true
                        return
                    },
                    failure:{ (reason) -> Void in
                        self.removeLoadingView()
                        self.headView.sendButton.enabled = true
                        FLOG("失败原因:\(reason)")
                })
            }
        }else{//编辑
            var pa = param as! [String : AnyObject]
            var curIndex = pa["curIndex"] as! String
            if curIndex == "3" {//编辑对对碰   网络请求
                FLOG("编辑对对碰   网络请求")
                if topicTitleText.text.isEmpty {
                    UIAlertView(title: "提示", message: "组队标题不能为空", delegate: self, cancelButtonTitle: "OK").show()
                    return
                }
                var data = pa["data"] as! [String : AnyObject]
                FLOG("data\(data)")
                var makeUpId = data["_id"] as! String
                FLOG(ApplicationContext.getUserID()!)
                FLOG(makeUpId)
                FLOG(self.describeText)
                FLOG(ApplicationContext.toJSONString(["imageUrl":self.imageName]))
                self.addLoadingView()
                HttpManager.sendHttpRequestPost(EDITTASK, parameters:
                    ["userId":ApplicationContext.getUserID()!,
                        "id": makeUpId,
                        "title":topicTitleText.text,
                        "describe":self.describeText,
                        "imageUrl":ApplicationContext.toJSONString(allImageArray),
                        "type":"edit"
                    ],
                    success: { (json) -> Void in
                        
                        FLOG("编辑组队json:\(json)")
                        HYBProgressHUD.showSuccess("修改成功")
                        NSNotificationCenter.defaultCenter().postNotificationName("refreshMakeUpDetail", object: nil)
                        self.navigationController?.popViewControllerAnimated(true)
                    },
                    failure:{ (reason) -> Void in
                        self.removeLoadingView()
                        self.headView.sendButton.enabled = true
                        FLOG("失败原因:\(reason)")
                })
            }else {//todo  编辑话题     网络请求
                if topicTitleText.text.isEmpty {
                    UIAlertView(title: "提示", message: "话题标题不能为空", delegate: self, cancelButtonTitle: "OK").show()
                    return
                }
                var pa = self.param as! [String : AnyObject]
                var topicInfo = pa["data"] as! TopicInfo
                topicInfo.discription()
                var param : [String:AnyObject] =
                ["userId":ApplicationContext.getUserID()!,
                    "id": topicInfo.id!,
                    "topicTitle":topicTitleText.text,
                    "topicDescribe":self.describeText,
                    "topicImage":ApplicationContext.toJSONString(allImageArray)
//                    "topicImage":ApplicationContext.toJSONString([["imageUrl":self.imageName]])
                ]
                FLOG("param:\(param)")
                self.addLoadingView()
                HttpManager.sendHttpRequestPost(EDIT_TOPIC, parameters:param,
                    success: { (json) -> Void in
                        
                        FLOG("编辑话题返回json:\(json)")
                        HYBProgressHUD.showSuccess("修改成功")
                        self.removeLoadingView()
                        NSNotificationCenter.defaultCenter().postNotificationName("refreshTopicDetail", object: nil)
                        self.navigationController?.popViewControllerAnimated(true)
                    },
                    failure:{ (reason) -> Void in
                        self.headView.sendButton.enabled = true
                        self.removeLoadingView()
                        FLOG("失败原因:\(reason)")
                })
            }
        }
    }
}

//MARK: -HolderTextViewDelegate
extension PublishAriticleViewController :HolderTextViewDelegate{
    func holderTextViewDidChange(textView:HolderTextView){
        var length = (textView.text as NSString).length
        countLabel.text = "\(40-length)/40"
    }
}
