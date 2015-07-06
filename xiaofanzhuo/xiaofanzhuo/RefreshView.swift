//
//  RefreshView.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/4/23.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class RefreshView: UIView {
    
    @IBOutlet weak var refreshClick: UIButton!
    @IBOutlet weak var refreshBtn: UIButton!
    var buttonClickCallBack : ( ()->() )!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func listenRefreshBtnClick(callBack:()->()){
        buttonClickCallBack = callBack
    }
    
    @IBAction func refreshBtnClick(sender: AnyObject) {
        self.buttonClickCallBack()
    }
}
