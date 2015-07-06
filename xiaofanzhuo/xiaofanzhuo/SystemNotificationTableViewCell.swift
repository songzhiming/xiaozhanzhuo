//
//  SystemNotificationTableViewCell.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-2-6.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class SystemNotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var contentTypeText: UILabel!
    @IBOutlet weak var contentText: UILabel!
    
    @IBOutlet weak var marginInNameContentType: NSLayoutConstraint!
    
    class var cellId : String {
        return "SystemNotificationTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        marginInNameContentType.constant = nameText.text!.isEmpty ? 0 : 8
    }
}

extension SystemNotificationTableViewCell {
    
    func configureCell(systemMessage:SystemMessage){
        
        var data = systemMessage.dataForSystemNotificationCell()
        
        nameText.text = data.name
        contentTypeText.text = data.contentType
        contentText.text = data.content
        
        
        self.layoutIfNeeded()
    }
}
