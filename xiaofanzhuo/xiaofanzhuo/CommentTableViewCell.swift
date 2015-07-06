//
//  CommentTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/11.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

protocol CommonTableCellAdapter{
    func dataForCommentTableCell()->(avatarUrl:NSURL,name:String,time:String,contentText:NSMutableAttributedString)
}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    class var cellId: String {
        return "CommentTableViewCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.layer.cornerRadius = 2
        avatar.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension CommentTableViewCell {
    
    func configureCell(data:CommonTableCellAdapter){
        
        var dataTuple = data.dataForCommentTableCell()
        
        avatar.sd_setImageWithURL(dataTuple.avatarUrl, placeholderImage: UIImage(named:"avatarDefaultImage"))
        nameLabel.text              = dataTuple.name
        timeLabel.text              = dataTuple.time
        contentLabel.attributedText = dataTuple.contentText
        
    }
    
    func getCellDynamicHeight() -> CGFloat {
//        self.layoutIfNeeded()
        
        //屏幕宽 - table两边的灰边[5+5] - 头像左边距[8] - 头像宽度[20] - 头像与contentLabel间距[8] - contentLabel右边距[8]
        var limitWidth = UIScreen.mainScreen().bounds.width - 10 - 8 - 20 - 8 - 8
        var style = contentLabel.attributedText.attribute(NSParagraphStyleAttributeName, atIndex: 0, effectiveRange: nil) as! NSMutableParagraphStyle
        var height = contentLabel.attributedText.boundingRectWithSize(
            CGSizeMake(limitWidth, 0),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            context: nil).height + style.lineSpacing * 2//行距2倍
        
        return 10 + 20 + 6 + height
    }
}