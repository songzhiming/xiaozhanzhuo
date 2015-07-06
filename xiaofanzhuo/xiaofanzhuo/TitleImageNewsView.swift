//
//  TitleImageNewsViewController.swift
//  xiaofanzhuo
//
//  Created by 李亚坤 on 15/1/21.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class TitleImageNewsView: UIView {

    @IBOutlet weak var homeHeadImageView: UIImageView!


    func setImage(imageurl : String){
//        var avatarImageUrl =  imageurl as? NSString
        
//        println("url===\(NSURL(string: avatarImageUrl!))")
//        println(imageurl)

        
        var url : NSURL = NSURL(string: imageurl)!

        homeHeadImageView.sd_setImageWithURL(NSURL(string: imageurl))
        homeHeadImageView.sd_setImageWithURL(NSURL(string: imageurl), placeholderImage: UIImage(named: "articleHeaderDefaultImage"))
    }
}
