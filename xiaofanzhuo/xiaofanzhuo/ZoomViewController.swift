//
//  ZoomViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-3-13.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class ZoomViewController: AllocDeallocViewController {

    @IBOutlet weak var zoomCollectionView: UICollectionView!
//    var singleTapRecognizer: UITapGestureRecognizer!
    
    var param : AnyObject?
    var imageArray : [String] = [String]()
    var index : Int = Int()
    
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?,param : AnyObject?=nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.param = param
        
        
        FLOG("self.param::::\(self.param)")
        var pa = param as! [String : AnyObject]
        imageArray = pa["imageArray"] as! [String]
        index = pa["index"] as! Int
        FLOG("imageArray::::\(imageArray)")
        FLOG("index::::\(index)")
        
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoSystemNotificationViewController", name: "goto.SystemNotificationViewController", object: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        zoomCollectionView.registerNib(UINib(nibName: "NewsImageCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "NewsImageCollectionViewCell")
        //        imageCollectionView.

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var categoryFlowLayout: UICollectionViewFlowLayout = zoomCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        categoryFlowLayout.itemSize = CGSizeMake(UIScreen.mainScreen().bounds.width,UIScreen.mainScreen().bounds.height)
        categoryFlowLayout.minimumLineSpacing = 0
        categoryFlowLayout.minimumInteritemSpacing = 0

        zoomCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
        zoomCollectionView.layoutIfNeeded()
        
        FLOG("contentOffset:\(zoomCollectionView.contentOffset)")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



    
    
    // MARK: - collectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: NewsImageCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("NewsImageCollectionViewCell", forIndexPath: indexPath) as! NewsImageCollectionViewCell
        cell.loadData(imageArray[indexPath.row])
        //        cell.loadData(self.selectedImageArray[indexPath.row],index:indexPath.row)
        return cell
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
//    }
}
