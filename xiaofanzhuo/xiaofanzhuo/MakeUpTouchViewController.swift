//
//  MakeUpTouchViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-15.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class MakeUpTouchViewController: BasicViewController {

    @IBOutlet weak var makeUpTouchTable: UITableView!
    @IBOutlet weak var failView: UIView!
    @IBOutlet weak var failLabel: UILabel!
    
    var taskList : NSMutableArray?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headView.hidden = true
        println("111\(self.view.subviews)")
        self.taskList = NSMutableArray()
        makeUpTouchTable.registerNib(UINib(nibName:"MakeUpTouchTableViewCell", bundle:nil), forCellReuseIdentifier: "MakeUpTouchTableViewCell")
        makeUpTouchTable.separatorColor = UIColor.clearColor()
        makeUpTouchTable.addHeaderWithTarget(self, action:"getMakeUpTouchData")
        makeUpTouchTable.addFooterWithTarget(self, action:"loadMore")
        var footerView = UIView()
//        footerView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50)
        makeUpTouchTable.tableFooterView = footerView
        
        self.extraView.hidden = false
        self.extraView.image.image = UIImage(named: "add_new_team")!

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMakeUp", name: "refreshMakeUp", object: nil)
        self.getMakeUpTouchData()
    }

//    deinit{
////        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: "refreshMakeUp")
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.makeUpTouchTable.contentInset = UIEdgeInsetsMake(0, 0, (50/320)*UIScreen.mainScreen().bounds.width, 0);
//        self.makeUpTouchTable.contentInset = UIEdgeInsetsZero;
                
    }
    

    
    
    //  table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: MakeUpTouchTableViewCell = tableView.dequeueReusableCellWithIdentifier("MakeUpTouchTableViewCell") as! MakeUpTouchTableViewCell
        var dataDic = taskList?.objectAtIndex(indexPath.row) as? NSDictionary
        cell.loadData(dataDic)
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 83
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        for i in self.view.superview!.subviews{
            if (i as! UIView).tag == 201 {
                (i as! UIView).removeFromSuperview()
            }
        }
        
        
        var detailMakeUpTouchViewController = DetailMakeUpTouchViewController(nibName: "DetailMakeUpTouchViewController", bundle: nil, param: taskList?.objectAtIndex(indexPath.row) )
        self.navigationController?.pushViewController(detailMakeUpTouchViewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath , animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.taskList?.count == nil {
            return 0
        }
        return (self.taskList?.count)!
    }

    
    //获取数据
    func getMakeUpTouchData(){
//        println(BASE_URL + GETTASKINFO)
//        println(ApplicationContext.getUserID()!)
        HttpManager.sendHttpRequestPost(GETTASKLIST, parameters:
            ["userId": ApplicationContext.getUserID()!,
                "begin":"0",
                "limit":"10"
            ],
            success: { (json) -> Void in
                
                FLOG("组队json:\(json)")
                //服务器数据返回成功
                self.failView.hidden = true
                var ismore: Bool?  = json["isMore"] as? Bool
                println("ismore::::\(ismore)")
                if json["isMore"] as! Bool == true {
                    self.makeUpTouchTable.footerHidden = false
                }else{
                    self.makeUpTouchTable.footerHidden = true
                }
                self.taskList = (json["taskList"])?.mutableCopy() as? NSMutableArray
                
                if self.taskList?.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_EMPTY
                }
                self.makeUpTouchTable.reloadData()
                self.makeUpTouchTable.headerEndRefreshing()
            },
            failure:{ (reason) -> Void in
                if self.taskList?.count == 0 {
                    self.failView.hidden = false
                    self.failLabel.text = LOAD_FAILED
                }
                self.makeUpTouchTable.headerEndRefreshing()
                FLOG("失败原因:\(reason)")
        })
    }
//    //下拉刷新
//    func beginRefresh(){
//        HttpManager.sendHttpRequestPost(GETTASKLIST, parameters:
//            ["userId": ApplicationContext.getUserID()!,
//                "begin":"0",
//                "limit":"10"
//            ],
//            success: { (json) -> Void in
//                
//                FLOG("组队返回数据json:\(json)")
//                //服务器数据返回成功
//                if json["isMore"] as! Bool == true {
//                    self.makeUpTouchTable.footerHidden = false
//                }else{
//                    self.makeUpTouchTable.footerHidden = true
//                }
//                self.taskList = (json["taskList"])?.mutableCopy() as? NSMutableArray
//                self.makeUpTouchTable.reloadData()
//                self.makeUpTouchTable.headerEndRefreshing()
//            },
//            failure:{ (reason) -> Void in
//                FLOG("失败原因:\(reason)")
//                self.makeUpTouchTable.headerEndRefreshing()
//        })
//    }
    //加载更多
    func loadMore(){
        var begin = NSString(format: "%d", self.taskList!.count)

        HttpManager.sendHttpRequestPost(GETTASKLIST, parameters:
            ["userId": ApplicationContext.getUserID()!,
                "begin":begin,
                "limit":"10"
            ],
            success: { (json) -> Void in
                
                FLOG("组队返回json:\(json)")
                //服务器数据返回成功
                if json["isMore"] as! Bool == true {
                    self.makeUpTouchTable.footerHidden = false
                }else{
                    self.makeUpTouchTable.footerHidden = true
                }
                
                var array = json["taskList"] as? NSMutableArray
                
                
                if array != nil {
                    self.taskList?.addObjectsFromArray(array! as [AnyObject])
                }
                self.makeUpTouchTable.reloadData()
                self.makeUpTouchTable.footerEndRefreshing()
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
                self.makeUpTouchTable.footerEndRefreshing()
        })
    }
    
    func refreshMakeUp(){
        getMakeUpTouchData()
    }
}

//MARK:-overrides
extension MakeUpTouchViewController {
    override func extraViewClick() {
        var vc = SendNewMakeUpViewController(nibName: "BasePublishViewController", bundle: nil,param: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
