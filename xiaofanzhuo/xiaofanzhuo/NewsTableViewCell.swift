//
//  NewsTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 李亚坤 on 15/1/20.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var newsTitleLabel: UILabel!
    
    var currendDic : NewsList!
    func loadData(newsList: NewsList){

        currendDic  = newsList
        newsList.discription()
        if let titleImageURL = newsList.imageUrl {
            titleImageView.sd_setImageWithURL(NSURL(string:titleImageURL), placeholderImage: UIImage(named: "avater")!)
        }
        
        var str = NSMutableAttributedString(string: newsList.title!)
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        style.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        str.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, str.length))
        
        newsTitleLabel.attributedText = str
        
        self.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code-
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func gotoAriticleDetailView(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("gotoAriticleDetailViewController", object: nil,userInfo:["data":currendDic])
    }

    
}
