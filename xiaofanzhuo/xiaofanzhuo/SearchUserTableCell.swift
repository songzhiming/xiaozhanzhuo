//
//  SearchUserTableCell.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/18.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SearchUserTableCell: UITableViewCell {

    class var cellId : String {
        return "SearchUserTableCell"
    }
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var intro: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SearchUserTableCell {
    func configureCell(serchUserInfo:SearchUserInfo){
        var data = serchUserInfo.dataForSearchCell()
        avatar.sd_setImageWithURL(NSURL(string:data.avatar), placeholderImage: UIImage(named:"avatarDefaultImage"))
        name.text = data.username
        intro.text = data.intro
    }
}
