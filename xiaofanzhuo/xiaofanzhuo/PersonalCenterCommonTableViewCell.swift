//
//  PersonalCenterCommonTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-15.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class PersonalCenterCommonTableViewCell: UITableViewCell {
    @IBOutlet weak var gotoButtonImageView: UIImageView!
    
    @IBOutlet weak var myIntegral: UILabel!
    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var btnNameLabel: UILabel!
    @IBOutlet weak var cornerState: UILabel!
    
    var systemNotificationIndexPath = NSIndexPath(forRow: 1, inSection: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerState.layer.cornerRadius = 10
        cornerState.clipsToBounds = true
        cornerState.backgroundColor = UIColor.redColor()
        cornerState.textColor = UIColor.whiteColor()
        cornerState.textAlignment = NSTextAlignment.Center
        cornerState.font = UIFont(name: "FZLanTingHeiS-R-GB", size: 10) ?? UIFont.systemFontOfSize(10)
        cornerState.hidden = true
//        cornerState.text =  badgeNumber > 99 ? "..." : "\(badgeNumber)"
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func loadData(btnName : String, isShow : Bool,indexPath:NSIndexPath,badgeNumber:Int=0){
        btnNameLabel.text = btnName
        ruleLabel.hidden = isShow
        myIntegral.hidden = true
        
        //设置角标
        cornerState.hidden = !(indexPath == systemNotificationIndexPath)
        cornerState.hidden = (badgeNumber == 0)
        cornerState.text =  badgeNumber > 99 ? "..." : "\(badgeNumber)"
    }
    
    func setBtnNameLabelColor (){
        btnNameLabel.textColor = UIColor(red: 131.0/255.0, green: 182.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        btnNameLabel.font = UIFont.systemFontOfSize(18.0)
    }
    func setMyIntegral(){
        myIntegral.hidden = false
        gotoButtonImageView.hidden = true

        self.getMyIntegral()
    }
    
    
    
    //获取个人个人积分
    func getMyIntegral(){
        HttpManager.sendHttpRequestPost(GETINTEGRAL, parameters: ["userId": ApplicationContext.getUserID()!
            ],
            success: { (json) -> Void in
                
                FLOG("获取积分json:\(json)")
                self.myIntegral.text = String( json["integral"] as! Int )
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }   
}
