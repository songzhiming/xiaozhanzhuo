//
//  MoreInformationView.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/1/23.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class MoreInformationView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var dataList : [[String:AnyObject]]!
    var flag : Int!
    var callback : ( (selectedItems:[[String:AnyObject]])->Void )!
    var partitionView : PartitionView!
    
    let ANIMATION_TIME = 0.2

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.frame = CGRectMake(0,UIScreen.mainScreen().bounds.height,UIScreen.mainScreen().bounds.width,UIScreen.mainScreen().bounds.height)

        collectionView.registerNib(UINib(nibName: "InfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: InfoCollectionViewCell.cellID)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        var categoryFlowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var width = CGFloat( UIScreen.mainScreen().bounds.width - 36 - 3 * 5 ) / 3
        var height = width * (35/90)
        categoryFlowLayout.itemSize = CGSizeMake( width,height)
        categoryFlowLayout.minimumInteritemSpacing = 5
        categoryFlowLayout.minimumLineSpacing = 6
        
        dataList = [[String:AnyObject]]()
        
        partitionView = PartitionView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,UIScreen.mainScreen().bounds.height))
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.partitionView.setSnapImage(self.partitionView.screenshot())
        })
        
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.animateWithDuration(
            ANIMATION_TIME,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                if let superview = self.superview {
                    self.center = superview.center//(self.superview?.center)!
                }
            }) { (Bool) -> Void in
               self.insertSubview(self.partitionView, atIndex: 0)
        }
    }
    
    override func removeFromSuperview() {
        partitionView.removeFromSuperview()
        UIView.animateWithDuration(
            ANIMATION_TIME,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
               self.frame = CGRectMake(0,UIScreen.mainScreen().bounds.height,UIScreen.mainScreen().bounds.width,UIScreen.mainScreen().bounds.height)
            }) { (Bool) -> Void in
        }
    }

}

//MARK: -按钮点击
extension MoreInformationView{

    @IBAction func closeBtnClick(sender: AnyObject) {
        self.callback(selectedItems: [[String:AnyObject]]())
        self.removeFromSuperview()
    }
    
    @IBAction func confirmBtnClick(sender: AnyObject) {
        var selectedItems = [[String:AnyObject]]()
        for indexPath in self.collectionView.indexPathsForSelectedItems() {
            selectedItems.append(self.dataList[indexPath.row])
        }
        //println(selectedItems)
        self.callback(selectedItems: selectedItems)
        self.removeFromSuperview()
    }
}

//MARK: -类方法
extension MoreInformationView{
    func loadDataWithDataCallBack(#flag:Int,dataList:[[String:AnyObject]],callback:(selectedItems:[[String:AnyObject]])->Void){
        self.flag = flag
        if flag == 0 {  //行业
            titleLabel.text = "Industry"
            infoLabel.text = "请选择您感兴趣的行业："
        }else{ //技能
            titleLabel.text = "Skills"
            infoLabel.text = "请选择您的技能："
        }
        self.callback = callback
        self.dataList = dataList
       // println(dataList)
    }
}

//MARK: - UICollectionViewDataSource
extension MoreInformationView : UICollectionViewDataSource{

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.dataList.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        var cell : InfoCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(InfoCollectionViewCell.cellID, forIndexPath: indexPath) as! InfoCollectionViewCell
        cell.loadData(self.dataList[indexPath.row])
        return cell
    }
    
}

//MARK: - UICollectionViewDelegate
extension MoreInformationView : UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        //println(indexPath.row)
        var cell = collectionView.cellForItemAtIndexPath(indexPath) as! InfoCollectionViewCell
        cell.selectState()
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath){
        var cell = collectionView.cellForItemAtIndexPath(indexPath) as! InfoCollectionViewCell
        cell.deSelectState()
    }
}

