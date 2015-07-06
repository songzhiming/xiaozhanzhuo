//
//  PersonalSettingViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-16.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class OtherInfoViewController: BasicViewController {
    var userId : String!
    //views
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    //控件
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var avaterImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var skillLabel: UILabel!
    
    var imageUrl = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.changeLeftButton()
        headView.logoImage.hidden = true
        headView.titleLabel.text = "ta人详情"
        headView.searchButton.hidden = true
        headView.generateCodeButton.hidden = true
        
        //装配scrollerView
        contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-10, 580)
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.bounds.size
        
        //设置头像形状
        avaterImageView.layer.cornerRadius = 5
        avaterImageView.clipsToBounds = true
        self.userId = param as! String
        getUserInfo()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //他发起的话题
    @IBAction func gotoPublishedCommunityView(sender: AnyObject) {
        println("他发起的话题")
        var myMakeUpTouchViewController : MyCommunityViewController = MyCommunityViewController(nibName: "MyCommunityViewController", bundle: nil,param:self.userId)
        self.navigationController?.pushViewController(myMakeUpTouchViewController, animated: true)
    }
    
    //他的发言
    @IBAction func gotoJoinedCommunityView(sender: AnyObject) {
        println("他参与的话题")
        var info:[String:AnyObject] = ["tag":"othersTopic","data":self.userId]
        var donateBookViewController : MyTopicViewController = MyTopicViewController(nibName: "MyTopicViewController", bundle: nil,param:info)//我参与
        self.navigationController?.pushViewController(donateBookViewController, animated: true)
    }
    //他发起的对对碰
    @IBAction func gotoPublishedMakeUpView(sender: AnyObject) {
        println("他发起的对对碰")
        var myMakeUpTouchViewController : MyMakeUpTouchViewController = MyMakeUpTouchViewController(nibName: "MyMakeUpTouchViewController", bundle: nil,param:self.userId)
        self.navigationController?.pushViewController(myMakeUpTouchViewController, animated: true)
    }
    //他参与的对对碰
    @IBAction func gotoJoindMakeUpView(sender: AnyObject) {
        println("他参与的对对碰")
        var myJoinMakeUpTouchViewController : MyJoinMakeUpTouchViewController = MyJoinMakeUpTouchViewController(nibName: "MyJoinMakeUpTouchViewController", bundle: nil,param:self.userId)
        self.navigationController?.pushViewController(myJoinMakeUpTouchViewController, animated: true)
    }
}

// MARK: -按钮点击
extension OtherInfoViewController {
    @IBAction func gotoBindAccountView(sender: AnyObject) {
        var bindAccountViewController = BindAccountViewController(nibName: "BindAccountViewController", bundle: nil)
        self.navigationController?.pushViewController(bindAccountViewController, animated: true)
    }
    @IBAction func avatarBtnClikc(sender: AnyObject) {

        
        var imageArray : [String] = [String]()
        
        

        imageArray.append(imageUrl)
        
        var param = ["index":0,
            "imageArray":imageArray]
        
        var zoomViewController : ZoomViewController = ZoomViewController(nibName: "ZoomViewController", bundle: nil,param:param)
        zoomViewController.view.frame = UIScreen.mainScreen().bounds
        self.addChildViewController(zoomViewController)
        self.view.addSubview(zoomViewController.view)
    }
}

// MARK: -类方法
extension OtherInfoViewController {
    func getUserInfo(){
        HttpManager.sendHttpRequestPost(GETUSERINFO, parameters:
            ["id": self.userId,
                "userId": ApplicationContext.getUserID()!
            ],
            success: { (json) -> Void in
                
                FLOG("个人信息返回json:\(json)")
                var userInfo = json["userInfo"] as! [String:AnyObject]
                //头像
                var avatarImageUrl = userInfo["avatar"] as? String
                self.imageUrl = avatarImageUrl!
                self.avaterImageView.sd_setImageWithURL(NSURL(string:avatarImageUrl!), placeholderImage: UIImage(named:"avatarDefaultImage"))
                //用户名
                self.usernameLabel.text = (userInfo["username"] as! String)
                //性别
                if userInfo["sex"] as? NSString == "1" {
                    self.sexLabel.text = "男士"
                }else{
                    self.sexLabel.text = "女士"
                }
                //年龄
                self.ageLabel.text = (userInfo["age"] as! String)
                //地址
                self.addressLabel.text = (userInfo["city"] as! String)
                //个人简介
                self.introLabel.text = (userInfo["intro"] as! String)
                var str : NSString = ""
                for skillDic in userInfo["skill"] as! [[String:AnyObject]] {
                    str = (str as String) + ((skillDic["name"] as! NSString) as String) + "、"
                }
                if str != "" {
                    self.skillLabel.text = str.substringToIndex(str.length - 1)
                }
                str = ""
                for skillDic in userInfo["industry"] as! [[String:AnyObject]] {
                    str = (str as String) + ((skillDic["name"] as! NSString) as String) + "、"
                }
                if str != "" {
                    self.industryLabel.text = str.substringToIndex(str.length - 1)
                }
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })        
    }

}
