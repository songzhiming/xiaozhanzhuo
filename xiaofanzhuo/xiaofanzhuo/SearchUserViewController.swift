//
//  SearchUserViewController.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/18.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

protocol SearchUserViewDelegate:class{
    func searchUserViewDidReturnData(searchUserInfo:SearchUserInfo)
}

class SearchUserViewController: BasicViewController {

    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate : SearchUserViewDelegate?
    var userList : [SearchUserInfo]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.changeTitle("搜索用户")
        headView.changeLeftButton()
        headView.hideRightButton(true)
        headView.logoImage.hidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        userList = [SearchUserInfo]()
        
        tableView.registerNib(UINib(nibName: "SearchUserTableCell", bundle: nil), forCellReuseIdentifier: SearchUserTableCell.cellId)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChange:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
}

// MARK: - UITableViewDataSource
extension SearchUserViewController : UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return userList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = self.tableView.dequeueReusableCellWithIdentifier(SearchUserTableCell.cellId) as! SearchUserTableCell
        cell.configureCell(userList[indexPath.row]) 
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchUserViewController : UITableViewDelegate{
    func scrollViewDidScroll(scrollView: UIScrollView){
        self.view.endEditing(true)
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        delegate?.searchUserViewDidReturnData(userList[indexPath.row])
        self.view.endEditing(true)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 57
    }
}

// MARK: - 实例方法
extension SearchUserViewController {
    func textChange(notification:NSNotification){
        if userNameText.text.isEmpty {
            return
        }
        var language = userNameText.textInputMode?.primaryLanguage
        if let lang = language {
            if lang == "zh-Hans" ||  lang == "zh-Hant" || lang == "ja-JP"{ //如果是中文简体,或者繁体输入,或者是日文这种带默认带高亮的输入法
                var selectedRange = userNameText.markedTextRange
                var position : UITextPosition?
                if let range = selectedRange {
                    position = userNameText.positionFromPosition(range.start, offset: 0)
                }
                //系统默认中文输入法会导致英文高亮部分进入输入统计，对输入完成的时候进行字数统计
                if position == nil {
                    startSearch()
                }
            }else{//非中文输入法
                startSearch()
            }
        }
    }
    
    func startSearch(){
        self.addLoadingView()
        HttpManager.sendHttpRequestPost(SEARCH_USER_BY_USERNAME, parameters:
            ["userId":ApplicationContext.getUserID()!,
                "content":userNameText.text
            ],
            success: { (json) -> Void in
                
                FLOG("搜索json:\(json)")
                self.userList.removeAll(keepCapacity: true)
                var listArray = json["userList"] as! [[String:AnyObject]]
                for info in listArray {
                    self.userList.append(SearchUserInfo(dataDic:info))
                }
                self.removeLoadingView()
                self.tableView.reloadData()
                //                self.navigationController?.popViewControllerAnimated(true)
            },
            failure:{ (reason) -> Void in
                self.removeLoadingView()
                FLOG("失败原因:\(reason)")
        })
    }
}
