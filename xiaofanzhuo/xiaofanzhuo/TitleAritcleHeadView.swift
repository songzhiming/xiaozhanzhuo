//
//  TitleAritcleHeadView.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-22.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class TitleAritcleHeadView: UIView,UIScrollViewDelegate {

    var titleImages : [TitleImage]!
    @IBOutlet weak var titleHeadScrollView: UIScrollView!
    @IBOutlet weak var headPageControl: UIPageControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleHeadScrollView.delegate = self
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width/640*336)
    }
    
    
    func loadImage(dataDic : [TitleImage]!) {
        
        println(dataDic)
        println(dataDic.count)
        if dataDic.count == 0 {
            return
        }
        self.titleImages = dataDic
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width/640*336)
        FLOG("self\(self)")
       // FLOG("123::::\(titleImages)")
        var screenBounds = UIScreen.mainScreen().bounds
        headPageControl.numberOfPages = dataDic.count
        headPageControl.currentPage = 0
        headPageControl.pageIndicatorTintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
        headPageControl.currentPageIndicatorTintColor = UIColor(red: 94/255, green: 169/255, blue: 252/255, alpha: 0.8)
        titleHeadScrollView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width/16*9)


        if (dataDic.count == 1) {
            titleHeadScrollView.contentSize = CGSizeMake(screenBounds.size.width * CGFloat(dataDic.count), 0)
        } else {
            titleHeadScrollView.contentSize = CGSizeMake(screenBounds.size.width * CGFloat(dataDic.count+2), 0)
        }
        titleHeadScrollView.contentOffset = CGPointMake(screenBounds.size.width, 0)
        for var i = 0; i<dataDic.count+2;i++ {
            var titleImageView : UIImageView!
            var titleImageNewsView : TitleImageNewsView = NSBundle.mainBundle().loadNibNamed("TitleImageNewsView", owner: self, options: nil)[0] as! TitleImageNewsView
            var rect = self.titleHeadScrollView.frame
            rect.origin.x = self.titleHeadScrollView.frame.size.width * CGFloat(i)
            rect.origin.y = 0
            rect.size.height = self.titleHeadScrollView.frame.size.height
//            FLOG("height::::\(self.titleHeadScrollView.frame.size.height)")
            titleImageNewsView.frame = rect
            titleImageNewsView.tag = 200 + i
            self.titleHeadScrollView.addSubview(titleImageNewsView)

            
            if (dataDic.count == 1) {
                titleImageNewsView.setImage(dataDic[0].imageUrl!)
//                break
            } else {
                if i == 0 {
                    titleImageNewsView.setImage(dataDic[dataDic.count-1].imageUrl!)
                }else if i == dataDic.count + 1 {
                    titleImageNewsView.setImage(dataDic[0].imageUrl!)
                }else{
                    titleImageNewsView.setImage(dataDic[i-1].imageUrl!)
                }
            }

            var tapGuesture = UITapGestureRecognizer(target: self, action: "gotoArticleDetailView:")
            titleImageNewsView.addGestureRecognizer(tapGuesture)
            
        }
        self.layoutIfNeeded()
        self.titleHeadScrollView.setContentOffset(CGPointMake(screenBounds.size.width, 0), animated: false)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var screenBounds = UIScreen.mainScreen().bounds
        FLOG(scrollView.contentOffset.x)
        var pageIndex : Int = Int(scrollView.contentOffset.x /  scrollView.frame.size.width)
        headPageControl.currentPage = pageIndex - 1
        if pageIndex == 0 {
            self.titleHeadScrollView.setContentOffset(CGPointMake(screenBounds.size.width * CGFloat(titleImages.count), 0), animated: false)
            var pageIndex1 : Int = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            headPageControl.currentPage = pageIndex1 - 1
        }
        if pageIndex == titleImages.count + 1 {
            self.titleHeadScrollView.setContentOffset(CGPointMake(screenBounds.size.width, 0), animated: false)
            var pageIndex1 : Int = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            headPageControl.currentPage = pageIndex1 - 1
        }
    }
    
    
    
    func gotoArticleDetailView(guest : UIGestureRecognizer){
        FLOG("guest:::\(guest.view?.tag)")
        FLOG("titleImage::\(titleImages)")
        if self.titleImages.count == 1 {
            var index = (guest.view?.tag)! - 200
            NSNotificationCenter.defaultCenter().postNotificationName("gotoAriticleDetailViewController", object: nil,userInfo:["data":titleImages[0]])
        }else{
            var index = (guest.view?.tag)! - 201
            NSNotificationCenter.defaultCenter().postNotificationName("gotoAriticleDetailViewController", object: nil,userInfo:["data":titleImages[index]])
        }
        

    }

}
