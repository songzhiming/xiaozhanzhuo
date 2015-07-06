//
//  DonateBookViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-20.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class DonateBookViewController: BasicViewController,UIAlertViewDelegate {
     @IBOutlet var contentView: UIView!
    
    
    @IBOutlet weak var bookIntegralLabel: UILabel!
    @IBOutlet weak var bookDescribeLabel: UITextView!
    @IBOutlet weak var bookOwnerLabel: UILabel!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var donateBookScrollView: UIScrollView!
    var bookInfo : [String:AnyObject]!
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.backButton.hidden = false
        headView.recommendButton.hidden = true
        headView.searchButton.hidden = true
        headView.logoImage.hidden = true
        headView.titleLabel.text = "福利详情"
        
        contentView.frame = CGRectMake(0,0, UIScreen.mainScreen().bounds.width-10, 400)
        donateBookScrollView.addSubview(contentView)
        donateBookScrollView.contentSize = CGSizeMake(0,contentView.bounds.size.height)
        println(param)
        self.bookInfo = param as! [String:AnyObject]
        var avatarImageUrl = bookInfo["imageUrl"] as? NSString
        self.bookCoverImageView.sd_setImageWithURL(NSURL(string: avatarImageUrl! as String))
        self.bookNameLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 14)
        self.bookIntegralLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 14)
        self.bookDescribeLabel.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 14)
        self.bookNameLabel.text = bookInfo["name"] as? String        
        self.bookIntegralLabel.text =  String(bookInfo["integral"] as! Int)
        self.bookDescribeLabel.text = bookInfo["intro"] as? String
//        self.getBookInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func exchangeBook(sender: AnyObject) {
        var message = "确定要消耗" + String(bookInfo["integral"] as! Int) + "积分兑换此福利?"
        UIAlertView(title: "提示", message: message, delegate: self, cancelButtonTitle: "取消",otherButtonTitles:"好").show()
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex==0){
            NSLog("取消")
        }else{
            NSLog("好")
            self.getMyIntegral()
        }
    }
    
    
    func getMyIntegral(){
        HttpManager.sendHttpRequestPost(GETINTEGRAL, parameters:["userId": ApplicationContext.getUserID()!
            ],
            success: { (json) -> Void in
                
                FLOG("赠书返回数据json:\(json)")
                //服务器数据返回成功
                if (json["integral"] as! Int) > (self.bookInfo["integral"] as! Int) {
                    var secondDonateBookViewController : SecondDonateBookViewController = SecondDonateBookViewController(nibName: "SecondDonateBookViewController", bundle: nil,param:self.bookInfo)
                    self.navigationController?.pushViewController(secondDonateBookViewController, animated: true)
                }else{
                    UIAlertView(title: "提示", message: "您的积分不足以兑换此福利", delegate: nil, cancelButtonTitle: "确定").show()
                    FLOG("您的积分不足已兑换此书籍")
                }
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
    
}
