//
//  WelfareViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-3-5.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class WelfareViewController: BasicViewController {

    @IBOutlet weak var welfareTableView: UITableView!
    var giftList : NSMutableArray?
    
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        giftList = NSMutableArray()
        headView.backButton.hidden = false
        headView.recommendButton.hidden = true
        headView.searchButton.hidden = true
        headView.logoImage.hidden = true
        headView.titleLabel.text = "选择福利"
        welfareTableView.addHeaderWithTarget(self, action:"getGiftList")
        welfareTableView.registerNib(UINib(nibName:"WelfareTableViewCell", bundle:nil), forCellReuseIdentifier: "WelfareTableViewCell")
        welfareTableView.separatorColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.getGiftList()
    }
    
    
    
    //获取数据
    func getGiftList(){
        HttpManager.sendHttpRequestPost(GIFT_LIST, parameters: ["userId": ApplicationContext.getUserID()!
            ],
            success: { (json) -> Void in
                
                FLOG("福利json:\(json)")
                self.failView.hidden = true
                self.giftList = (json["welfareList"])?.mutableCopy() as? NSMutableArray
                self.welfareTableView.reloadData()
                self.welfareTableView.headerEndRefreshing()
                if self.giftList?.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_EMPTY
                }
                
            },
            failure:{ (reason) -> Void in
                self.welfareTableView.headerEndRefreshing()
                if self.giftList?.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_FAILED_NO_REFRESH
                }
                FLOG("失败原因:\(reason)")
        })
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: WelfareTableViewCell = tableView.dequeueReusableCellWithIdentifier("WelfareTableViewCell") as! WelfareTableViewCell
        var dataDic = giftList?.objectAtIndex(indexPath.row) as? NSDictionary
        cell.loadData(dataDic)
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 83
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var donateBookViewController = DonateBookViewController(nibName: "DonateBookViewController", bundle: nil, param: giftList?.objectAtIndex(indexPath.row) )
        self.navigationController?.pushViewController(donateBookViewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if giftList?.count == nil {
            return 0
        }
        return (giftList?.count)!
    }

}
