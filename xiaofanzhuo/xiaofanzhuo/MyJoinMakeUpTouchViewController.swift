//
//  MyJoinMakeUpTouchViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-23.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class MyJoinMakeUpTouchViewController: BasicViewController {

    @IBOutlet weak var myJoinMakeUpTableView: UITableView!
    var taskList : NSMutableArray?
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failLabel: UILabel!
    var isInit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("param\(param)")
        if let pa = param as? String {//他人
            headView.titleLabel.text = "他参与的组队"
        }else{
            headView.titleLabel.text = "我参与的组队"
        }
        taskList = NSMutableArray()
        headView.recommendButton.hidden = true
        headView.backButton.hidden = false
        headView.logoImage.hidden = true
        headView.titleLabel.hidden = false
//        headView.titleLabel.text = "我参与的组队"
        headView.searchButton.hidden = true
        myJoinMakeUpTableView.separatorColor = UIColor.clearColor()
        myJoinMakeUpTableView.registerNib(UINib(nibName:"MakeUpTouchTableViewCell", bundle:nil), forCellReuseIdentifier: "MakeUpTouchTableViewCell")
        myJoinMakeUpTableView.addFooterWithTarget(self, action:"loadMore")
//        myJoinMakeUpTableView.addHeaderWithTarget(self, action:"getMakeUpTouchData")
        myJoinMakeUpTableView.tableFooterView = UIView()
        self.getMakeUpTouchData()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !isInit {
            myJoinMakeUpTableView.contentInset = UIEdgeInsetsZero
            isInit = true
        }
    }

    //获取我参与的对对碰列表
    func getMakeUpTouchData(){
        
        println(BASE_URL + TASKREPLIED)
        var userId : String
        if let pa = param as? String {//他人
            userId = param as! String
        }else{
            userId = ApplicationContext.getUserID()!
        }
        println(ApplicationContext.getUserID()!)
        HttpManager.sendHttpRequestPost(TASKREPLIED, parameters:
            ["userId": userId,
                "type":"help",
                "begin":"0",
                "limit":"10"
            ],
            success: { (json) -> Void in
                
                FLOG("我参与的组队json:\(json)")
                self.failView.hidden = true
                //服务器数据返回成功
                var ismore: Bool?  = json["isMore"] as? Bool

                if json["isMore"] as! Bool == true {
                    self.myJoinMakeUpTableView.footerHidden = false
                }else{
                    self.myJoinMakeUpTableView.footerHidden = true
                }
                self.taskList = (json["taskList"])?.mutableCopy() as? NSMutableArray
                self.myJoinMakeUpTableView.reloadData()
                self.myJoinMakeUpTableView.headerEndRefreshing()

                if self.taskList?.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_EMPTY
                }
            },
            failure:{ (reason) -> Void in
                self.myJoinMakeUpTableView.headerEndRefreshing()

                if self.taskList?.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_FAILED_NO_REFRESH
                }
                FLOG("失败原因:\(reason)")
        })
    }
    

    //加载更多
    func loadMore(){
        var begin = NSString(format: "%d", self.taskList!.count)
        println("begin::::\(begin)")
        var userId : String
        if let pa = param as? String {//他人
            userId = param as! String
        }else{
            userId = ApplicationContext.getUserID()!
        }
        
        HttpManager.sendHttpRequestPost(TASKREPLIED, parameters:
            ["userId": userId,
                "type":"help",
                "begin":begin,
                "limit":"10"
            ],
            success: { (json) -> Void in
                
                FLOG("我参与的组队json:\(json)")
                if json["isMore"] as! Bool == true {
                    self.myJoinMakeUpTableView.footerHidden = false
                }else{
                    self.myJoinMakeUpTableView.footerHidden = true
                }

                var array = json["taskList"] as? NSMutableArray
                
                self.taskList?.addObjectsFromArray(array! as [AnyObject])

                self.myJoinMakeUpTableView.reloadData()
                self.myJoinMakeUpTableView.footerEndRefreshing()
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
                self.myJoinMakeUpTableView.footerEndRefreshing()
        })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.taskList?.count == nil {
            return 0
        }
        return (self.taskList?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: MakeUpTouchTableViewCell = tableView.dequeueReusableCellWithIdentifier("MakeUpTouchTableViewCell") as! MakeUpTouchTableViewCell
        var dataDic = taskList?.objectAtIndex(indexPath.row) as? NSDictionary
//        println("dataDic:::::\(dataDic)")
        cell.loadData(dataDic)
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var detailMakeUpTouchViewController = DetailMakeUpTouchViewController(nibName: "DetailMakeUpTouchViewController", bundle: nil, param: taskList?.objectAtIndex(indexPath.row) )
        self.navigationController?.pushViewController(detailMakeUpTouchViewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
    }

}
