//
//  PersonalCenterViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-15.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class PersonalCenterViewController: UIViewController {
    enum Sections: Int {
        case Headers, Body
    }
    var headers: [String] = ["个人积分","消息","福利"]
    var body :[String] = ["我参与的组队","我发起的组队","我的发言","我发起的话题","我收藏的话题","推荐会员","推荐项目","关于小饭桌"]
    
    @IBOutlet weak var myPersonalInfoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPersonalInfoTable.registerNib(UINib(nibName:"AvaterTableViewCell", bundle:nil), forCellReuseIdentifier: "AvaterTableViewCell")
        myPersonalInfoTable.registerNib(UINib(nibName:"PersonalCenterCommonTableViewCell", bundle:nil), forCellReuseIdentifier: "PersonalCenterCommonTableViewCell")
        
        myPersonalInfoTable.separatorColor = UIColor.clearColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPushCount", name: "refresh_push_count", object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        myPersonalInfoTable.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
//        myPersonalInfoTable.contentInset = UIEdgeInsetsZero
            myPersonalInfoTable.contentInset = UIEdgeInsetsMake(0, 0, (50/320)*UIScreen.mainScreen().bounds.width, 0);
    }
    
    
    

    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clearColor()
        view.backgroundColor = UIColor.clearColor()
    }
    func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clearColor()
        view.backgroundColor = UIColor.clearColor()
    }
    
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1{
            return 3
        }else {
            return 8
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            var cell: AvaterTableViewCell = tableView.dequeueReusableCellWithIdentifier("AvaterTableViewCell") as! AvaterTableViewCell
            cell.loadData()
            return cell
        }else if indexPath.section == 1 {
            if indexPath.row == 0{
                var cell: PersonalCenterCommonTableViewCell = tableView.dequeueReusableCellWithIdentifier("PersonalCenterCommonTableViewCell") as! PersonalCenterCommonTableViewCell
                cell.loadData(headers[indexPath.row],isShow: false,indexPath:indexPath)
                cell.setMyIntegral()
                return cell
            }else if indexPath.row == 1{
                var cell: PersonalCenterCommonTableViewCell = tableView.dequeueReusableCellWithIdentifier("PersonalCenterCommonTableViewCell") as! PersonalCenterCommonTableViewCell
                var count = NSUserDefaults.standardUserDefaults().objectForKey("push_count") as! Int
                cell.loadData(headers[indexPath.row],isShow: true,indexPath:indexPath,badgeNumber:count)
                return cell
            }else {
                var cell: PersonalCenterCommonTableViewCell = tableView.dequeueReusableCellWithIdentifier("PersonalCenterCommonTableViewCell") as! PersonalCenterCommonTableViewCell
                cell.loadData(headers[indexPath.row],isShow: true,indexPath:indexPath)
                return cell
            }
        }else{
            var cell: PersonalCenterCommonTableViewCell = tableView.dequeueReusableCellWithIdentifier("PersonalCenterCommonTableViewCell") as! PersonalCenterCommonTableViewCell
            cell.loadData(body[indexPath.row],isShow : true,indexPath:indexPath)
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 80
        }else{
            return 45
        }
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 1 {
            return 5
        }
        if section == 2 {
            return 5
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
        for i in self.view.superview!.subviews{
            if (i as! UIView).tag == 201 {
                (i as! UIView).removeFromSuperview()
            }
        }
        if indexPath.section == 0 {
            var personalSettingViewController : PersonalSettingViewController = PersonalSettingViewController(nibName: "PersonalSettingViewController", bundle: nil)
            self.navigationController?.pushViewController(personalSettingViewController, animated: true)
        }else if indexPath.section == 1 {
            switch indexPath.row
            {
            case 0:
                var integralViewController : IntegralViewController = IntegralViewController(nibName: "IntegralViewController", bundle: nil)
                self.navigationController?.pushViewController(integralViewController, animated: true)
            case 1:
                var systemNotificationViewController : SystemNotificationViewController = SystemNotificationViewController(nibName: "SystemNotificationViewController", bundle: nil)
                self.navigationController?.pushViewController(systemNotificationViewController, animated: true)
            case 2:
//                self.getBookInfo()
                var welfareViewController : WelfareViewController = WelfareViewController(nibName: "WelfareViewController", bundle: nil)
                self.navigationController?.pushViewController(welfareViewController, animated: true)
            default:
                var personalSettingViewController : PersonalSettingViewController = PersonalSettingViewController(nibName: "PersonalSettingViewController", bundle: nil)
                self.navigationController?.pushViewController(personalSettingViewController, animated: true)
            }
        }else {
            switch indexPath.row
            {
            case 0:
                var myJoinMakeUpTouchViewController : MyJoinMakeUpTouchViewController = MyJoinMakeUpTouchViewController(nibName: "MyJoinMakeUpTouchViewController", bundle: nil)
                self.navigationController?.pushViewController(myJoinMakeUpTouchViewController, animated: true)
            case 1:
                var myMakeUpTouchViewController : MyMakeUpTouchViewController = MyMakeUpTouchViewController(nibName: "MyMakeUpTouchViewController", bundle: nil)
                self.navigationController?.pushViewController(myMakeUpTouchViewController, animated: true)
            case 2:
                var info:[String:AnyObject] = ["tag":"myTopic","data":""]
                var donateBookViewController : MyTopicViewController = MyTopicViewController(nibName: "MyTopicViewController", bundle: nil,param:info)//我参与
                self.navigationController?.pushViewController(donateBookViewController, animated: true)
            case 3:
                
                
                var donateBookViewController : MyCommunityViewController = MyCommunityViewController(nibName: "MyCommunityViewController", bundle: nil)//
                self.navigationController?.pushViewController(donateBookViewController, animated: true)
            case 4:
                //我收藏的话题
                var favoriteCommunityViewController : FavoriteCommunityViewController = FavoriteCommunityViewController(nibName: "FavoriteCommunityViewController", bundle: nil)//
                self.navigationController?.pushViewController(favoriteCommunityViewController, animated: true)
                break
            case 5:
                var recommendMembersViewController : RecommendMembersViewController = RecommendMembersViewController(nibName: "RecommendMembersViewController", bundle: nil)
                self.navigationController?.pushViewController(recommendMembersViewController, animated: true)
            case 6:
                var recommendProjectViewController : RecommendProjectViewController = RecommendProjectViewController(nibName: "RecommendProjectViewController", bundle: nil)
                self.navigationController?.pushViewController(recommendProjectViewController, animated: true)
            case 7:
                //关于小饭桌
                var aboutViewController : AboutViewController = AboutViewController(nibName: "AboutViewController", bundle: nil)
                self.navigationController?.pushViewController(aboutViewController, animated: true)
                break;
            default:
                var personalSettingViewController : PersonalSettingViewController = PersonalSettingViewController(nibName: "PersonalSettingViewController", bundle: nil)
                self.navigationController?.pushViewController(personalSettingViewController, animated: true)
            }
        }
    }

    
    //获取书籍详情
    func getBookInfo(){
        self.myPersonalInfoTable.userInteractionEnabled = false
        HttpManager.sendHttpRequestPost(GIFT_LIST, parameters: ["userId": ApplicationContext.getUserID()!,
            "type": "info"
            ],
            success: { (json) -> Void in
                
                FLOG("赠书返回数据json:\(json)")
                if (json["has"] as! Bool) == true {
                    var donateBookViewController : DonateBookViewController = DonateBookViewController(nibName: "DonateBookViewController", bundle: nil)
                    self.navigationController?.pushViewController(donateBookViewController, animated: true)
                }else {
                    var noBookViewController : NoBookViewController = NoBookViewController(nibName: "NoBookViewController", bundle: nil)
                    self.navigationController?.pushViewController(noBookViewController, animated: true)
                }
                self.myPersonalInfoTable.userInteractionEnabled = true
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
                self.myPersonalInfoTable.userInteractionEnabled = true
        })
        
    }
    
    func refreshPushCount(){
        //设定为Optional的原因是怕程序第一次启动推送来到，default里面还没有这个字段，会导致为Nil
        var count = NSUserDefaults.standardUserDefaults().objectForKey("push_count") as? Int
        if let pushCount = count {
            var cell = self.myPersonalInfoTable.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! PersonalCenterCommonTableViewCell
            cell.loadData("消息",isShow: true,indexPath:NSIndexPath(forRow: 1, inSection: 1),badgeNumber:pushCount)
        }
    }
}
