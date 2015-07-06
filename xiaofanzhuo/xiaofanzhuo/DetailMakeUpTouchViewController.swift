//
//  DetailMakeUpTouchViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-20.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class DetailMakeUpTouchViewController: BasicViewController {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var detailTable: UITableView!
    
    var currentDic : [String : AnyObject]!
    var headerMakeUpView : HeaderMakeUpView!
    var helpList : [[String:AnyObject]]?
    var detailInfoDic : [String : AnyObject]!
    
    var selectedIndexpath : NSIndexPath!
    
    @IBOutlet weak var editButton: UIButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, param: AnyObject?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.currentDic = [String : AnyObject]()
        self.currentDic = param as? [String : AnyObject]
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "makeUpSupport", name: "makeup.support", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMakeUpDetail", name: "refreshMakeUpDetail", object: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headView.recommendButton.hidden = true
        headView.backButton.hidden = false
        headView.searchButton.hidden = true
//        headView.makeupDetailEditButton.hidden = false
        detailTable.registerNib(UINib(nibName: "DetailMakeUpTouchTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailMakeUpTouchTableViewCell")

        detailTable.delegate = self
        detailTable.dataSource = self
        detailTable.separatorColor = UIColor.clearColor()
        detailTable.addFooterWithTarget(self, action: "loadMore")
        detailTable.addHeaderWithTarget(self, action:"getDetailData")
        self.headerMakeUpView = NSBundle.mainBundle().loadNibNamed("HeaderMakeUpView", owner: self, options: nil)[0] as! HeaderMakeUpView
        
        self.extraView.hidden = false
        self.extraView.image.image = UIImage(named: "add_communiti_comment")!
        
        //变量初始化
        helpList = [[String:AnyObject]]()
        self.getDetailData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setExtraView_B_R(15,right:15)
    }
    
    @IBAction func toEditView(sender: AnyObject) {
        println("eidt")
        var dic  = ["curIndex":"3",
                    "data":self.detailInfoDic]
        var publishAriticleViewController : PublishAriticleViewController = PublishAriticleViewController(nibName: "PublishAriticleViewController", bundle: nil,param:dic)
        self.navigationController?.pushViewController(publishAriticleViewController, animated: true)
    }
}

//MARK: - 类方法
extension DetailMakeUpTouchViewController{
    
    func refreshMakeUpDetail(){
        getDetailData()
    }
    
    func makeUpSupport(){
        var dic = [
            "dataDic":self.currentDic,
            "isReply":false]
        var helpMessageViewController = HelpMessageViewController(nibName: "HelpMessageViewController", bundle: nil,param:dic)
        self.navigationController?.pushViewController(helpMessageViewController, animated: true)
    }
    
    //获取数据
    func getDetailData(){
        
        HttpManager.sendHttpRequestPost(GETTASKINFO, parameters:
            ["userId": ApplicationContext.getUserID()!,
                "id":self.currentDic["_id"]!,
                "begin":"0",
                "limit":"10"
            ],
            success: { (json) -> Void in
                
                FLOG("组队详情数据：\(json)")
                self.detailInfoDic = json
                if json["isMore"] as! Bool == true {
                    self.detailTable.footerHidden = false
                }else{
                    self.detailTable.footerHidden = true
                }
                self.helpList?.removeAll(keepCapacity: false)
                self.helpList = json["helpList"] as? [[String:AnyObject]]
                self.detailTable.tableHeaderView = self.headerMakeUpView
                self.headerMakeUpView.loadData(json)
                self.detailTable.reloadData()
                self.detailTable.headerEndRefreshing()
            },
            failure:{ (reason) -> Void in
                self.detailTable.headerEndRefreshing()
                FLOG("失败原因:\(reason)")
        })

    }
    
    //加载更多
    func loadMore(){
        var begin = NSString(format: "%d", self.helpList!.count)
        
        HttpManager.sendHttpRequestPost(GETTASKINFO, parameters:
            ["userId": ApplicationContext.getUserID()!,
                "id":self.currentDic["_id"]!,
                "begin":begin,
                "limit":"10"
            ],
            success: { (json) -> Void in
                
                FLOG("组队加载更多详情数据：\(json)")
                if json["isMore"] as! Bool == true {
                    self.detailTable.footerHidden = false
                }else{
                    self.detailTable.footerHidden = true
                }
                var array = json["helpList"] as? [[String:AnyObject]]
                if array != nil {
//                    self.helpList?.addObjectsFromArray(array! as [AnyObject])
                    self.helpList?.extend(array!)
                }
                self.detailTable.reloadData()
                self.detailTable.footerEndRefreshing()
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
}

//MARK: - UITableViewDelegate
extension DetailMakeUpTouchViewController : UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedIndexpath = indexPath
        var userIdFrom = (self.helpList![selectedIndexpath.row])["userIdFrom"] as! String
        
        if userIdFrom == ApplicationContext.getUserID()! {
            var actionSheet = UIActionSheet(
                title: "操作",
                delegate: self,
                cancelButtonTitle: "取消",
                destructiveButtonTitle: "回复",
                otherButtonTitles:"删除")
            actionSheet.actionSheetStyle = UIActionSheetStyle.BlackOpaque
            actionSheet.destructiveButtonIndex = -1
            actionSheet.showInView(self.view)
        }else{
            var actionSheet =
            UIActionSheet(
                title: "操作",
                delegate: self,
                cancelButtonTitle: "取消",
                destructiveButtonTitle: "回复")
            actionSheet.actionSheetStyle = UIActionSheetStyle.BlackOpaque
            actionSheet.destructiveButtonIndex = -1
            actionSheet.showInView(self.view)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.helpList?.count == nil {
            return 0
        }
        return (self.helpList?.count)!
    }
}

//MARK: - UITableViewDataSource
extension DetailMakeUpTouchViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: DetailMakeUpTouchTableViewCell = tableView.dequeueReusableCellWithIdentifier("DetailMakeUpTouchTableViewCell") as! DetailMakeUpTouchTableViewCell
        var dataDic = helpList![indexPath.row]
        cell.loadData(dataDic)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var customCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as? DetailMakeUpTouchTableViewCell
        if let cell = customCell {
            return cell.getDynamicCellHeight()
        }
        return 0
    }
}

// MARK: - UIActionSheetDelegate
extension DetailMakeUpTouchViewController : UIActionSheetDelegate{
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex {
        case 0://回复
            //被回复用户的id
            FLOG("helpList:\(self.helpList),selectedIndexpath:\(selectedIndexpath.row)")
            var dic = [
                "dataDic":self.currentDic,
                "helpInfo":self.helpList![selectedIndexpath.row] ,
                "isReply":true]
            var vc = SenNewMakeUpReplyViewController(nibName: "BasePublishViewController", bundle: nil,param: dic)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2://
            var helpId = (self.helpList![selectedIndexpath.row] as [String:AnyObject])["_id"] as! String
            HttpManager.sendHttpRequestPost(DELETE_TASK_REPLY, parameters:
                ["userId":ApplicationContext.getUserID()!,
                    "id":helpId],
                success: { (json) -> Void in
                    
                    FLOG("删除评论返回json:\(json)")
                    UIAlertView(title: "提示", message: "删除成功！", delegate: nil, cancelButtonTitle: "好的,知道了").show()
                    self.getDetailData()
                },
                failure:{ (reason) -> Void in
                    FLOG("失败原因:\(reason)")
            })
            break
        case 3:
            break
        default:
            break
        }
        FLOG(buttonIndex)        
    }
}

//MARK:-overrides
extension DetailMakeUpTouchViewController {
    override func extraViewClick() {
        var dic = [
            "dataDic":self.currentDic,
            "isReply":false]
        var vc = SenNewMakeUpReplyViewController(nibName: "BasePublishViewController", bundle: nil,param: dic)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
