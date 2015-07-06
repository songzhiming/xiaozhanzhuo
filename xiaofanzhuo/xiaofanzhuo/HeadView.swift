//
//  HeadView.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-14.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class HeadView: UIView,UIAlertViewDelegate {
 
    var navgationController : UINavigationController!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var generateCodeButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var topicReplyButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var makeupDetailEditButton: UIButton!
    
    @IBOutlet weak var makeupHelpButton: UIButton!
    func changeTitle(titleName : String){
        titleLabel.text = titleName
    }
    func changeLeftButton(){
        recommendButton.hidden = true
        backButton.hidden = false
    }
    func changeRightButton(){
        searchButton.hidden = true
        generateCodeButton.hidden = false
    }
    func changeCenterView(){
        titleLabel.hidden = true
        logoImage.hidden = false
    }
    func hideRightButton(isShow : Bool){
        searchButton.hidden = isShow
        generateCodeButton.hidden = isShow
    }
    @IBAction func onclickRecommendButton(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("addRecommendAlertView", object: nil)
    }

    @IBAction func onclickBackButton(sender: AnyObject) {
        navgationController.popViewControllerAnimated(true)
    }

    @IBAction func onclickGenerateCodeButton(sender: AnyObject) {
        UIAlertView(title: "生成推荐码", message: "生成新的推荐码需要消耗20积分", delegate: self, cancelButtonTitle: "取消",otherButtonTitles:"好").show()
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex==0){
            NSLog("取消")
        }else{
            NSLog("好")
            self.getMyIntegral()
//            navigationController.pushViewController(recommendProjectViewController, animated: true)
        }
    }
    //获取积分并且判断能否生成邀请码
    func getMyIntegral(){
        println(ApplicationContext.getUserID()!)
        
        HttpManager.sendHttpRequestPost(GETINTEGRAL, parameters:
            ["userId": ApplicationContext.getUserID()!
            ],
            success: { (json) -> Void in
                
                FLOG("是否能生成json:\(json)")
                //服务器数据返回成功
                var integral = json["integral"] as! Int
                if integral >= 20 {
                    var info = ["tag":"generate","data":""]
                    var generateCodeViewController : GenerateCodeViewController = GenerateCodeViewController(nibName: "GenerateCodeViewController", bundle: nil,param:info)
                    self.navgationController.pushViewController(generateCodeViewController, animated: true)
                }else{
                    UIAlertView(title: "提示", message: "你的积分不够生成推荐码", delegate: self, cancelButtonTitle: "好的，知道了").show()
                }
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
    
    //显示添加按钮
    func showAddButton(isShow : Bool){
        addButton.hidden = isShow
    }
    
    @IBAction func onclickAddButton(sender: AnyObject) {
        var publishAriticleViewController : PublishAriticleViewController = PublishAriticleViewController(nibName: "PublishAriticleViewController", bundle: nil)
        navgationController.pushViewController(publishAriticleViewController, animated: true)
    }
    
    @IBAction func onclickLogoutButton(sender: AnyObject) {
        var changePersonInfoViewController : ChangePersonInfoViewController = ChangePersonInfoViewController(nibName: "ChangePersonInfoViewController", bundle: nil)
        navgationController.pushViewController(changePersonInfoViewController, animated: true)

    }
    
    //点击发言详情右上角回复本条发言
    @IBAction func commentBtnClick(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("replyToSpeak", object: nil, userInfo: nil)
    }
    //发起新话题右上角发送
    @IBAction func sendBtnClick(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("sendNewTopic", object: nil, userInfo: nil)
    }
    //发起新话题添加描述右上角完成
    @IBAction func finishBtnClick(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("finishDescribe", object: nil, userInfo: nil)
    }
    //对话题发表新发言
    @IBAction func topicReplyBtnClick(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("replyToTopic", object: nil, userInfo: nil)
    }
    
    //对对碰提供帮助
    @IBAction func onclickMakeUpHelpButton(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("makeUpHelp", object: nil, userInfo: nil)
    }
    
    //点击搜索按钮
    @IBAction func onclickSearchButton(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("goto.SearchView", object: nil, userInfo: nil)
    }
    //分享
    @IBAction func onclickShareButton(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("share.Article", object: nil, userInfo: nil)
    }
    
    
    //点击对对碰详情页面编辑按钮
    @IBAction func onclickMakeupDetailEditButton(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("makeup.support", object: nil, userInfo: nil)
    }

    
}
