//
//  PersonalSettingViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-16.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class PersonalSettingViewController: BasicViewController,UIAlertViewDelegate{
    //views
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    //控件
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var avaterImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var skillLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var situationLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    
    //约束
    @IBOutlet weak var introViewHeight: NSLayoutConstraint!
    @IBOutlet weak var introLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var industryHeight: NSLayoutConstraint!
    @IBOutlet weak var industryViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var skillHeight: NSLayoutConstraint!
    @IBOutlet weak var skillViewHeight: NSLayoutConstraint!
    
    //变量
    var CONTENT_HEIGHT : CGFloat = 882
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.changeLeftButton()
        headView.logoImage.hidden = true
        headView.titleLabel.text = "个人设置"
        headView.searchButton.hidden = true
        headView.generateCodeButton.hidden = true
        headView.logoutButton.hidden = false
        
        //装配scrollerView
        contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-10, CONTENT_HEIGHT)
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.bounds.size
        
        //设置头像形状
        avaterImageView.layer.cornerRadius = 5
        avaterImageView.clipsToBounds = true
        
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated )
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: -按钮点击
extension PersonalSettingViewController {
    
    //修改密码：
    @IBAction func gotoBindAccountView(sender: AnyObject) {
        
        var editPasswordViewController = EditPasswordViewController(nibName: "EditPasswordViewController", bundle: nil)
        self.navigationController?.pushViewController(editPasswordViewController, animated: true)
//        var bindAccountViewController = BindAccountViewController(nibName: "BindAccountViewController", bundle: nil)
//        self.navigationController?.pushViewController(bindAccountViewController, animated: true)
    }
    
    @IBAction func onclikcLogoutButton(sender: AnyObject) {
        UIAlertView(title: "提示", message: "确认退出登录？", delegate: self, cancelButtonTitle: "取消",otherButtonTitles:"好").show()
    }
    
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex==0){
            println("取消")
        }else{
            println("确定")
            PersistentManager.cleanAll()
            var loginViewControllerNew = LoginViewControllerNew(nibName: "LoginViewControllerNew", bundle: nil)
            self.navigationController?.viewControllers[0] = loginViewControllerNew
            self.navigationController?.popToRootViewControllerAnimated(true)
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userInfo")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}

// MARK: -类方法
extension PersonalSettingViewController {
    func loadData(){
        var userInfo : [String : AnyObject] = ApplicationContext.getMyUserInfo()!
        println("userInfo:::\(userInfo)")
        var avatarImageUrl = userInfo["avatar"] as? NSString
        avaterImageView.sd_setImageWithURL(NSURL(string: avatarImageUrl! as String))
        avaterImageView.sd_setImageWithURL(NSURL(string: avatarImageUrl! as String), placeholderImage: UIImage(named: "avatarDefaultImage"))
        usernameLabel.text = userInfo["username"] as? String
        ageLabel.text = userInfo["age"] as? String
        addressLabel.text = userInfo["city"] as? String
        phoneLabel.text = userInfo["phone"] as? String
        introLabel.text = userInfo["intro"] as? String
        directionLabel.text = userInfo["direction"] as? String
        experienceLabel.text = userInfo["experience"] as? String 
        situationLabel.text = situationRouter(userInfo["situation"] as? String)
//
        if userInfo["sex"] as? NSString == "1" {
            sexLabel.text = "男士"
        }else{
            sexLabel.text = "女士"
        }
        var str : NSString = ""
        for skillDic in userInfo["skill"] as! [[String:AnyObject]] {
            str = (str as String) + ((skillDic["name"] as! NSString) as String) + "、"
        }
        if str != "" {
            skillLabel.text = str.substringToIndex(str.length - 1)
        }
        str = ""
        for skillDic in userInfo["industry"] as! [[String:AnyObject]] {
            str = (str as String) + ((skillDic["name"] as! NSString) as String) + "、"
        }
        if str != "" {
            industryLabel.text = str.substringToIndex(str.length - 1)
        }
        
        adjustIndustryOrInterestViewFrame(industryLabel)
        adjustIndustryOrInterestViewFrame(skillLabel)
        
        var size =  (introLabel.text! as NSString).boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 10 - 15 - 4 , 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont(name: "FZLanTingHeiS-R-GB", size: 11)!],
            context: nil)
        var height = size.height
        FLOG("height:\(height)")
        introLabelHeight.constant = height + 8
        introViewHeight.constant = 5 + 21 + introLabelHeight.constant + 5
        contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-10, (CONTENT_HEIGHT + introViewHeight.constant - 50 ) )//50是Ib里面一个小型父View的高度
        scrollView.contentSize = contentView.bounds.size
        self.view.layoutIfNeeded()
    }
    
    func adjustIndustryOrInterestViewFrame(label:UILabel){
        var size =  (label.text! as NSString).boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 10 - 15, 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont(name: "FZLanTingHeiS-R-GB", size: 11)!],
            context: nil)
        var height = size.height
        
        var layoutHeight = label == industryLabel ? industryHeight : skillHeight
        var viewLayoutHeight = label == industryLabel ? industryViewHeight : skillViewHeight
        
        layoutHeight.constant = height + 8
        viewLayoutHeight.constant = 5 + 21 + layoutHeight.constant + 5
        
        contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-10, (CONTENT_HEIGHT + viewLayoutHeight.constant - 50) )//50是Ib里面一个小型父View的高度
        scrollView.contentSize = contentView.bounds.size
    }
    
    func situationRouter(index:String?)->String{
        if let indexNum = index {
            switch indexNum {
            case "1" :
                return"全职创业，已有项目"
            case "2" :
                return"创业准备中"
            case "3" :
                return"还在公司，有创业意愿"
            default :
                return ""
            }
        }
        return ""
    }
}
