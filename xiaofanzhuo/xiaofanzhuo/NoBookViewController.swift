//
//  NoBookViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-2-3.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class NoBookViewController: BasicViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        headView.backButton.hidden = false
        headView.recommendButton.hidden = true
        headView.searchButton.hidden = true
        headView.logoImage.hidden = true
        headView.titleLabel.text = "赠书"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



}
