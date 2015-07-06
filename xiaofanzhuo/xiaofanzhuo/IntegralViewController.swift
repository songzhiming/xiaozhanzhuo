//
//  IntegralViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-22.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class IntegralViewController:  BasicViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        headView.backButton.hidden = false
        headView.recommendButton.hidden = true
        headView.searchButton.hidden = true
        headView.logoImage.hidden = true
        headView.titleLabel.text = "积分说明"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



}
