//
//  NewsImageCollectionViewCell.swift
//  SpainAppProto
//
//  Created by dp on 14/12/2.
//  Copyright (c) 2014年 Marshal Wu. All rights reserved.
//

import UIKit

class NewsImageCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate, UIActionSheetDelegate,UIGestureRecognizerDelegate {

    var imageScrollView: UIScrollView! = UIScrollView()
    
    var imageView: UIImageView = UIImageView()
    var image: UIImage!
    var saveActionSheet: UIActionSheet!
    

        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
        
        imageScrollView.directionalLockEnabled = true
        imageScrollView.delegate = self
        imageScrollView.maximumZoomScale = 1.5
        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.showsVerticalScrollIndicator = false
        imageScrollView.decelerationRate = UIScrollViewDecelerationRateFast
        self.contentView.addSubview(imageScrollView)
        

        
        

        //双击手势
        var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "onDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delegate = self
        imageScrollView.addGestureRecognizer(doubleTapRecognizer)
        
        //单击手势
        var singleTapRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onSingleTap:")
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.delegate = self
        imageScrollView.addGestureRecognizer(singleTapRecognizer)
        
        
        // 关键在这一行，如果双击确定偵測失败才會触发单击
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.userInteractionEnabled = true
        var longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "onLongPress:")
        imageView.addGestureRecognizer(longPressRecognizer)

    }
    //单点关闭view
    func onSingleTap(recognizer: UITapGestureRecognizer) {
//        CommonTool.findNearsetViewController(self).removeFromParentViewController()
//        CommonTool.findNearsetViewController(self).view.removeFromSuperview()
//        CommonTool.findNearsetViewController(self).navigationController?.popViewControllerAnimated(false)
        CommonTool.findNearsetViewController(self).view.removeFromSuperview()
        CommonTool.findNearsetViewController(self).removeFromParentViewController()
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        println(touch.view)
        println(touch.tapCount)
        return true
    }
    
    
    
    func onDoubleTap(recognizer: UITapGestureRecognizer) {
        println(recognizer.numberOfTapsRequired)
        if imageScrollView.zoomScale == 1.0 {
            imageScrollView.setZoomScale(1.5, animated: true)
        } else {
            imageScrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    func onLongPress(recognizer: UILongPressGestureRecognizer) {
        if self.saveActionSheet==nil {
            saveActionSheet = UIActionSheet(title: "保存到图片到相册?", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "确定")
            saveActionSheet.showInView(self)
        } else if !self.saveActionSheet.visible {
            saveActionSheet.showInView(self)
        }
        
        if saveActionSheet.superview != nil {  
            var tapRecognizer = UITapGestureRecognizer(target: self, action: "onTap:")
            tapRecognizer.numberOfTapsRequired = 1
            tapRecognizer.numberOfTouchesRequired = 1
            saveActionSheet.superview!.addGestureRecognizer(tapRecognizer)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 { // Save
            
            UIImageWriteToSavedPhotosAlbum(self.image, self, "image:didFinishSavingWithError:contextInfo:", nil)
//            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil)
//            UIGraphicsEndImageContext()
        } else { // Cancel
            
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()>) {

//        HYBProgressHUD.showSuccess("\(error == nil)")
//        dispatch_async(dispatch_get_main_queue(), {
//        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageScrollView.setZoomScale(1.0, animated: false)
    }
    
    func onTap(recognizer: UITapGestureRecognizer) {
        if self.saveActionSheet != nil && self.saveActionSheet.visible {
            self.saveActionSheet.dismissWithClickedButtonIndex(1, animated: true)
        }
    }

    func loadData(imageURL: String) {
        imageScrollView.frame = self.bounds

        imageScrollView.contentSize = CGSizeZero
        imageScrollView.contentOffset = CGPointZero
        if imageScrollView.subviews.count > 0 {
            imageScrollView.setZoomScale(1.0, animated: false)
            for view in imageScrollView.subviews {
                view.removeFromSuperview()
            }
        }

        imageScrollView.addSubview(imageView)

        imageView.frame = self.bounds
//        imageView.sd_setImageWithURL(NSURL(string: imageURL))
//        imageview.sd
        imageView.sd_setImageWithURL(NSURL(string: imageURL)) { (image, error, _, _) -> Void in
            if imageURL == "" {
                self.imageView.image = UIImage(named:"avatarDefaultImage")
            }
            self.image = image
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
