//
//  LoginViewControllerNew.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/3/9.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class LoginViewControllerNew: BasicViewController {

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    //变量
    var imageViewIndex = 0
    var imageIndex = 0
    var imageArray = [UIImage]()
    var imageViewArray = [UIImageView]()
    var downLoadImageArray = [UIImage]()
    var scrollFinished = false
    var initFlag = true
    var downLoadCount = 0
    var imageCount = 0
    private var isToAnimate : Bool = false
    private var isAnimating : Bool = false
    
    var guideView : GuideView!
    
    //常量
    let IMAGE_COUNT = 5
    let IMAGEVIEW_COUNT = 2
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headView.hidden = true
        
        /*****
        var imageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        imageView.image = UIImage(named: "default_new")
        var frontPageData = NSUserDefaults.standardUserDefaults().objectForKey("frontPage") as? NSData
        if let data = frontPageData {
            var image = UIImage(data: data)
            imageView.image = image
        }
        
        HttpManager.sendHttpRequestPost(GET_FRONT_PAGE, parameters: ["type":"client"],
            success: { (json) -> Void in
                
            FLOG("鸡汤json:\(json)")
            var frontPage = json["frontPage"] as! [String:AnyObject]
            var imageUrl = frontPage["imageUrl"] as! String
            SDWebImageDownloader.sharedDownloader().downloadImageWithURL(NSURL(string: imageUrl), options: SDWebImageDownloaderOptions.LowPriority, progress: {(receivedSize, expectedSize) -> Void in

                }) {(image, data, error, finished) -> Void in
                    if image !=  nil && finished {
                        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "frontPage")
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                }
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })

        self.view.insertSubview(imageView, atIndex: 0)
        ******/
        
        //设置2个ImageVie用于轮播
        for i in 0..<2 {
            imageViewArray.append(UIImageView(frame: UIScreen.mainScreen().bounds))
            self.view.insertSubview(imageViewArray[i], atIndex: 0)
        }
        //给image设置5张默认图
        for i in 0..<5 {
            imageArray.append(UIImage(named: "default_animate\(i+1)")!)
        }

        //从UserDefault中读取看看是否有key为frontPage数组，如果有，则把前面的几张换成frontPage数组前面几张
        var frontPageData = NSUserDefaults.standardUserDefaults().objectForKey("frontPage") as? NSData
        if let data = frontPageData,let frontPageArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [UIImage]  {
            for i in 0..<frontPageArray.count {
                if i > imageArray.count - 1 { //如果超过数组容量就追加,
                    imageArray.append(frontPageArray[i])
                }else{  //没有超过就替换掉前面的
                    imageArray[i] = frontPageArray[i]
                }
            }
        }
        //设置第一张图
        imageViewArray[0].image = imageArray[0]
        //获取鸡汤图片地址
        HttpManager.sendHttpRequestPost(GET_FRONT_PAGE, parameters: ["type":"client"],
            success: { (json) -> Void in
                
                FLOG("鸡汤json:\(json)")
                var frontPage = json["frontPage"] as! [[String:AnyObject]]
                self.imageCount = frontPage.count
                
                for i in 0..<frontPage.count {
                    var imageUrl = frontPage[i]["imageUrl"] as! String
                    //对每一张图进行下载
                    SDWebImageDownloader.sharedDownloader().downloadImageWithURL(NSURL(string: imageUrl), options: SDWebImageDownloaderOptions.LowPriority, progress: {(receivedSize, expectedSize) -> Void in
                        
                        }) {(image, data, error, finished) -> Void in
                            if image !=  nil && finished {
                                self.downLoadCount++
                                self.downLoadImageArray.append(image)
                                FLOG("下载张数:\(self.downLoadCount)")
                                if self.downLoadCount == self.imageCount {
                                    //如果下载完成，则把下载的图片数组放到userDefault中，把数组archive成为NSData再放进去（最保险做法），取出来的时候再UnArchive
                                    NSUserDefaults.standardUserDefaults().setValue(NSKeyedArchiver.archivedDataWithRootObject(self.downLoadImageArray), forKey: "frontPage")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    
                                }
                            }
                    }
                    
                }//for
                
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
        
        //初始化引导页
        var isGuideShown: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("isGuideShown")
        if isGuideShown == nil {
            initFlag = false//如果执行过一次引导，就不让viewDidLayoutSubViews进行对guideView的访问
            //添加引导页
            guideView = GuideView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)){
            }
            self.view.insertSubview(guideView, atIndex: 0)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isGuideShown")
        NSUserDefaults.standardUserDefaults().synchronize()
        //startAnimation
        
//        UIGraphicsBeginImageContext(UIScreen.mainScreen().bounds.size);
//        UIImage(named: "default_new")?.drawInRect(UIScreen.mainScreen().bounds)
//        var image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext();
//        self.view.backgroundColor = UIColor(patternImage: image)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated )
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        
        self.startAnimation()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !initFlag {
            self.view.bringSubviewToFront(guideView)
            initFlag = true
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}

//MARK: -实例方法
extension LoginViewControllerNew {
    func stopAnimation(){
        self.isToAnimate = false
    }
    
    func startAnimation(){
        
        self.isToAnimate = true
        
        //对2个ImageView的复用，分别取下一张图片，和当前图片
        var nowImageViewIndex = imageViewIndex % imageViewArray.count
        var nextImageViewIndex = ++imageViewIndex % imageViewArray.count
    
        var nextImageIndex = ++imageIndex % imageArray.count
    
        var imageView = imageViewArray[nowImageViewIndex]
        var nextImageView = imageViewArray[nextImageViewIndex]
        
        nextImageView.image = imageArray[nextImageIndex]
        
        UIView.animateWithDuration(3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            imageView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            self.view.layoutIfNeeded()
        }) { (Bool) -> Void in
            
            UIView.animateWithDuration(3, delay: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in

                nextImageView.alpha = 1
                imageView.alpha = 0
                
                self.view.layoutIfNeeded()
                }) { (Bool) -> Void in
                    imageView.transform = CGAffineTransformIdentity
                    if self.isToAnimate {
                        self.startAnimation()
                    }
                    
            }
        }//UIView
    }
}
//MARK: -按钮点击
extension LoginViewControllerNew {
    
    //登录
    @IBAction func loginBtnClick(sender: AnyObject) {
        var signInViewController = SignInViewController(nibName: "SignInViewController", bundle: nil)
        self.navigationController?.pushViewController(signInViewController, animated: true)
    }
    
    //注册
    @IBAction func registerBtnClick(sender: AnyObject) {
        var registerViewController = RegisterViewController(nibName: "RegisterViewController", bundle: nil,param:["state":"regist_new_user","data":""])
        self.navigationController?.pushViewController(registerViewController, animated: true)
    }
}

