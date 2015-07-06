//
//  RecommendMembersTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-16.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class RecommendMembersTableViewCell: UITableViewCell {
    @IBOutlet weak var recommendCodeLabel: UILabel!
    @IBOutlet weak var codeTimeLabel: UILabel!
    @IBOutlet weak var codeStatusLabel: UIButton!
    @IBOutlet weak var codeStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func loadData(recommendCodeList : RecommendCodeList){
        println("loadData\(recommendCodeList)")
        recommendCodeLabel.text = recommendCodeList.recomCode
        
        println()
        
        codeTimeLabel.text = recommendCodeList.time
        println("1111\(recommendCodeList)")
        println("099999999\(recommendCodeList.time)")
//        codeTimeLabel.text = NSString(format: "%d", recommendCodeList.time!)
        if recommendCodeList.isUse == true {
//            codeStatusLabel.titleLabel?.text = "已使用"
//            codeStatusLabel.titleLabel?.textColor = UIColor.grayColor()
            codeStatus.text = "已使用"
            codeStatus.textColor = UIColor.grayColor()
        }else{
            codeStatus.text = "未使用"
            codeStatus.textColor = UIColor(red: 53/255.0, green: 148/255.0, blue: 255/255.0, alpha: 1.0)
//            codeStatusLabel.titleLabel?.text = "未使用"
//            codeStatusLabel.titleLabel?.textColor = UIColor(red: 53/255.0, green: 148/255.0, blue: 255/255.0, alpha: 1.0)
        }
    }
    
}
