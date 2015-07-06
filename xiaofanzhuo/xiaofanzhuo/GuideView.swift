//
//  GuideView.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/4/22.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class GuideView: UIView {
    
    var imageViewArray : [UIImageView]!
    var pageControl : UIPageControl!
    var scrollView : UIScrollView!
    var scrollFinishCallBack : ( () -> Void )?
    
    init(frame: CGRect,scrollFinishCallBack: ( () -> Void )?=nil) {
        super.init(frame:frame)
        
        //用于完成滑动的回调
        self.scrollFinishCallBack = scrollFinishCallBack
        
        //初始化scrollview
        scrollView = UIScrollView(frame: CGRectMake(0, 0 , frame.width, frame.height))
        self.addSubview(scrollView)
        
        //初始化引导画廊
        imageViewArray = [UIImageView]()
        for i in 0..<5 {
            imageViewArray.append(UIImageView(frame: CGRectMake(frame.width*CGFloat(i),0, frame.width, frame.height)))
            scrollView.addSubview(imageViewArray[i])
        }
        imageViewArray[0].image = UIImage(named: "default_new1")
        imageViewArray[1].image = UIImage(named: "default_new2")
        imageViewArray[2].image = UIImage(named: "default_new3")
        imageViewArray[3].image = UIImage(named: "default_new4")
        imageViewArray[4].image = UIImage(named: "default_new5")
        scrollView.contentSize = CGSizeMake(frame.width*6, 0)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self

        
        //初始化页号指示器
        pageControl = UIPageControl(frame: CGRectMake(0, frame.height-40, frame.width, 20))
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        self.addSubview(pageControl)
        
        self.backgroundColor = UIColor.blackColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GuideView : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView){
        scrollView.contentOffset.y = 0
        var pageWidth = scrollView.frame.size.width
        pageControl.currentPage = Int( floor( (scrollView.contentOffset.x - pageWidth / 2)  / pageWidth ) + 1)
        
        //划到最左边,不让继续划
        if scrollView.contentOffset.x < 0 {
            scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
        }
        
        //如果翻到最后一页继续往下翻，则渐变消失
        if scrollView.contentOffset.x >= self.frame.width * 4 {
            var offset = scrollView.contentOffset.x - self.frame.width * 4
            self.alpha = (1 - offset/self.frame.width)
            
            //滑到最右边,就从父view中移除
            if scrollView.contentOffset.x >= self.frame.width * 5 {
                self.removeFromSuperview()
                self.scrollFinishCallBack?()
                
            }
        }
        
    }
}
