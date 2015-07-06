//
//  AboutViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/3/10.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class AboutViewController: BasicViewController {
    @IBOutlet weak var versonLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        headView.changeLeftButton()
        headView.logoImage.hidden = true
        headView.titleLabel.text = "关于小饭桌"
        headView.searchButton.hidden = true
        headView.generateCodeButton.hidden = true
        
        var key = "CFBundleShortVersionString"//String( kCFBundleVersionKey )
        versonLabel.text = NSBundle.mainBundle().objectForInfoDictionaryKey(key) as? String
        
        avatar.layer.cornerRadius = 5
        avatar.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
