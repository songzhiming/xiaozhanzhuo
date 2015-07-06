//
//  InfoCollectionViewCell.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/23.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class InfoCollectionViewCell: UICollectionViewCell {


    @IBOutlet weak var name: UILabel!

    class var cellID : String {
        return "InfoCollectionViewCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 2
        self.layer.borderColor = CGColorCreateCopyWithAlpha(UIColor.lightGrayColor().CGColor , 0.3)
        // Initialization code
    }

}

//MARK: -类方法
extension InfoCollectionViewCell{
    
    func loadData(dataDic:[String:AnyObject]){
        name.text = dataDic["name"] as? String
    }
    
    func selectState(){
//        name.selected = true÷
        name.backgroundColor = UIColor(red: 124/255, green: 185/255, blue: 254/255, alpha: 1)
        name.textColor = UIColor.whiteColor()
    }
    func deSelectState(){
//        name.selected = false÷
        name.backgroundColor = UIColor.whiteColor()
        name.textColor = UIColor.lightGrayColor()
    }
}