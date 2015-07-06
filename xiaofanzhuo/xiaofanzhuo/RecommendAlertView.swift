//
//  RecommendAlertView.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-16.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class RecommendAlertView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func closeView(sender: AnyObject) {
        self.removeFromSuperview()
    }
    
    @IBAction func RecommendMembers(sender: AnyObject) {
        NSLog("RecommendMembers")
        self.removeFromSuperview()
        NSNotificationCenter.defaultCenter().postNotificationName("goto.RecommendMembersViewController", object: nil)
    }
    @IBAction func RecommendProject(sender: AnyObject) {
        NSLog("RecommendProject")
        self.removeFromSuperview()
        NSNotificationCenter.defaultCenter().postNotificationName("goto.RecommendProjectViewController", object: nil)
    }

}
