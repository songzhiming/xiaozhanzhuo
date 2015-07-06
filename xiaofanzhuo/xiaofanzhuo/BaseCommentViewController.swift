//
//  BaseCommentViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/11.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class BaseCommentViewController:BasicViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headView.changeTitle("评论")
        headView.changeLeftButton()
        headView.hideRightButton(true)
        headView.logoImage.hidden = true
        
        self.extraView.hidden = false

        tableView.registerNib(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: CommentTableViewCell.cellId)
        // Do any additional setup after loading the view.
    }
}
