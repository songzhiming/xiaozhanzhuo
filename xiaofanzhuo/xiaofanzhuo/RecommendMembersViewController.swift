//
//  RecommendMembersViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-16.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class RecommendMembersViewController: BasicViewController {

    
    var recommendCodeList : [RecommendCodeList]!
    @IBOutlet weak var RecommendCodeTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        recommendCodeList = [RecommendCodeList]()
        RecommendCodeTable.registerNib(UINib(nibName:"RecommendMembersTableViewCell", bundle:nil), forCellReuseIdentifier: "RecommendMembersTableViewCell")
        RecommendCodeTable.separatorColor = UIColor.clearColor()
        headView.changeLeftButton()
        headView.changeRightButton()
        headView.logoImage.hidden = true
        headView.changeTitle("推荐")
        
        RecommendCodeTable.delegate = self
        RecommendCodeTable.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.getRecommendCodeList()
    }
    
}
//MARK:- 实例方法
extension RecommendMembersViewController:UITableViewDataSource{
    func getRecommendCodeList(){
        var params : [String :String] = ["userId":ApplicationContext.getUserID()!]
        
        HttpManager.sendHttpRequestPost(GET_RECOMMENDCODELIST, parameters: params,
            success: { (json) -> Void in
                
                FLOG("推荐码json:\(json)")
                self.recommendCodeList.removeAll(keepCapacity: true)
                var dataArray = json["recomCodeList"] as! [[String:AnyObject]]
                if dataArray.count == 0 {
                    return
                }
                for  dataDic in dataArray {
                    self.recommendCodeList.append(RecommendCodeList(dataDic: dataDic))
                }
                
                
                self.RecommendCodeTable.reloadData()
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
        
    }
}
//MARK:- UITableViewDelegate
extension RecommendMembersViewController:UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var recommend = recommendCodeList[indexPath.row] as RecommendCodeList
        if !recommend.isUse! {
            var code = recommend.recomCode!
            var info = ["tag":"show","data":code]
            var generateCodeViewController : GenerateCodeViewController = GenerateCodeViewController(nibName: "GenerateCodeViewController", bundle: nil,param:info)
                self.navigationController?.pushViewController(generateCodeViewController, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
//MARK:- UITableViewDataSource
extension RecommendMembersViewController:UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendCodeList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: RecommendMembersTableViewCell = tableView.dequeueReusableCellWithIdentifier("RecommendMembersTableViewCell") as! RecommendMembersTableViewCell
        //        cell.userInteractionEnabled = false
        cell.loadData(recommendCodeList[indexPath.row])
        return cell
    }
    
}

