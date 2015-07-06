//
//  ExtraView.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/12.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

protocol ExtraViewDelegate:class{
    func extraViewClick()
}

class ExtraView: UIView {
    
    weak var delegate: ExtraViewDelegate?
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func click(sender: AnyObject) {
        delegate?.extraViewClick()
    }

}
