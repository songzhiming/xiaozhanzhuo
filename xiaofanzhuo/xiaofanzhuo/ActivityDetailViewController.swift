//
//  ActivityDetailViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-3-10.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class ActivityDetailViewController: BasicViewController,UMSocialUIDelegate{

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var replyCount: UILabel!
//    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var ariticleDetailWebview: UIWebView!
    var currentDic : [String : AnyObject]!
    var theId = ""
    
    var articleDetail : [String :AnyObject]!
    var activityDetail : [String : AnyObject]!
    //
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?,dic : [String : AnyObject]?=nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.currentDic = dic
        var id = ""
        if  self.currentDic["data"] is NewsList {
            id = (self.currentDic["data"] as! NewsList).id!
        }else{
            id = (self.currentDic["data"] as! TitleImage).id!
        }
        theId = id
        //以下通知已经废弃，若又改用右上角按钮分享就去掉注释，并在viewDidiLoad中写上headView.shareButton.hidden = false
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shareArticle", name: "share.Article", object: nil)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.getArticleDetail()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articleDetail = [String : AnyObject]()
        headView.recommendButton.hidden = true
        headView.backButton.hidden = false
        headView.logoImage.hidden = true
        headView.titleLabel.hidden = false
        headView.searchButton.hidden = true
//        headView.shareButton.hidden = false
        self.headView.titleLabel.text = "活动"
        
        signUpButton.layer.cornerRadius = 37
        signUpButton.layer.masksToBounds = true
        
        var url = ""
        if  self.currentDic["data"] is NewsList {
            url = (self.currentDic["data"] as! NewsList).htmlUrl! + "&userId=" + ApplicationContext.getUserID()! + "&deviceType=ios&currentVersion=\(Current_Version)"
        }else{
            url = (self.currentDic["data"] as! TitleImage).htmlUrl! + "&userId=" + ApplicationContext.getUserID()! + "&deviceType=ios&currentVersion=\(Current_Version)"
        }
        
        
        var cachePolicy : NSURLRequestCachePolicy = WlanReachability.isConnectedToNetwork() ? .ReloadIgnoringLocalAndRemoteCacheData : .ReturnCacheDataElseLoad
        var urlRequest = NSURLRequest(URL: NSURL(string:url)!, cachePolicy: cachePolicy, timeoutInterval: 5)
        
        ariticleDetailWebview.loadRequest(urlRequest)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    
    
    func webViewDidStartLoad(webView: UIWebView){
        self.addLoadingView()
        FLOG("webViewDidStartLoad")
    }
    func webViewDidFinishLoad(webView: UIWebView){
        var meta = NSString(format: "document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", UIScreen.mainScreen().bounds.size.width-10)
        
        
        println(UIScreen.mainScreen().bounds.size.width-10)
        ariticleDetailWebview.stringByEvaluatingJavaScriptFromString(meta as String)
        NSNotificationCenter.defaultCenter().postNotificationName("remove.loading.view", object: nil)
        FLOG("webViewDidFinishLoad")
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError){
        NSNotificationCenter.defaultCenter().postNotificationName("remove.loading.view", object: nil)
        FLOG("didFailLoadWithError")
    }
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        println(request.URL!.absoluteString?.hasPrefix("local"))
        if (request.URL!.absoluteString!.hasPrefix("local")){
            println(request.URL!.absoluteString)
            
            
            println((request.URL!.absoluteString! as NSString).substringFromIndex(24))
            
            var dic = ["index":"1","labelId":(request.URL!.absoluteString! as NSString).substringFromIndex(24)]
            
            var labelArticleViewController : LabelArticleViewController = LabelArticleViewController(nibName: "LabelArticleViewController", bundle: nil,param: dic)
            self.navigationController?.pushViewController(labelArticleViewController, animated: true)
            return false
        }
        return true
    }


    
    
    func signUpActivity(){
        var id : String
        if  self.currentDic["data"] is NewsList {
            id = (self.currentDic["data"] as! NewsList).id!
        }else{
            id = (self.currentDic["data"] as! TitleImage).id!
        }
        
        HttpManager.sendHttpRequestPost(SIGNUP, parameters:
            ["userId":ApplicationContext.getUserID()!,
                "id":id],
            success: { (json) -> Void in
                
                FLOG("报名json:\(json)")
//                self.signUpButton.enabled = false
                self.setSignUpButtonFasleState()
                self.signUpButton.setTitle("已报名", forState: UIControlState.Disabled)
                UIAlertView(title: "报名已经提交", message: "报名成功后,会有工作人员与您联络", delegate: nil, cancelButtonTitle: "确定").show()
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
    
    func setSignUpButtonFasleState(){
        self.signUpButton.enabled = false
        self.signUpButton.backgroundColor = UIColor.lightGrayColor()
    }
    
    func signUp(sender: UIButton) {
        self.signUpActivity()
    }
    
    
    @IBAction func onclickSignUpButton(sender: AnyObject) {
        self.signUpActivity()
    }

    @IBAction func commentBtnClick(sender: AnyObject) {
        var vc = ActivityCommentViewController(nibName: "BaseCommentViewController", bundle: nil,param: theId)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func shareArticle(sender: AnyObject) {
//        UMSocialData.defaultData().extConfig.wechatSessionData.url = "http://www.xfz.cn/web/vpage/index.html"
//        UMSocialData.defaultData().extConfig.wechatTimelineData.url = "http://www.xfz.cn/web/vpage/index.html"
        FLOG(self.articleDetail)
        FLOG("currentDic:\(self.currentDic)")
        var shareText : String!
        shareText = String()
        var shareImage : UIImage!
        shareImage = UIImage()
        var shareUrl = ""
        if self.currentDic["type"] as! String == "1" {//文章
            shareText = self.articleDetail["title"] as! String + "  " + "via@小饭桌" + "  "
//                + "http://www.xfz.cn/web/vpage/index.html"
            if  self.currentDic["data"] is NewsList {
                FLOG((self.currentDic["data"] as! NewsList))
                shareUrl = (self.currentDic["data"] as! NewsList).shareUrl!
                if (self.currentDic["data"] as! NewsList).imageUrl != nil {
                    var url : String = (self.currentDic["data"] as! NewsList).imageUrl!
                    var shareImageURL = NSURL(string: url)
                    shareImage = UIImage(data: NSData(contentsOfURL: shareImageURL!)!)
                }else{
                    shareImage = UIImage(named: "failure")
                }
                
            }else{
                println(self.currentDic["data"])
                shareUrl = (self.currentDic["data"] as! NewsList).shareUrl!
                if (self.currentDic["data"] as! TitleImage).imageUrl != nil {
                    var url : String = (self.currentDic["data"] as! TitleImage).imageUrl!
                    var shareImageURL = NSURL(string: url)
                    shareImage = UIImage(data: NSData(contentsOfURL: shareImageURL!)!)
                }else{
                    shareImage = UIImage(named: "failure")
                }
            }
            UMSocialData.defaultData().extConfig.wechatSessionData.url = shareUrl
            UMSocialData.defaultData().extConfig.wechatTimelineData.url = shareUrl
        }else{
            shareText = self.activityDetail["title"] as! String + "  " + "via@小饭桌" + "  "
//                + "http://www.xfz.cn/web/vpage/index.html"
            if  self.currentDic["data"] is NewsList {
                FLOG((self.currentDic["data"] as! NewsList))
//                (self.currentDic["data"] as NewsList).discription()
//                shareUrl = (self.currentDic["data"] as NewsList).shareUrl!
                shareUrl = activityDetail["shareUrl"] as! String
                if (self.currentDic["data"] as! NewsList).imageUrl != nil {
                    var url : String = (self.currentDic["data"] as! NewsList).imageUrl!
                    println("url::::\(url)")
                    var shareImageURL = NSURL(string: url)
                    shareImage = UIImage(data: NSData(contentsOfURL: shareImageURL!)!)
                }else{
                    shareImage = UIImage(named: "failure")
                }
                
            }else{
                shareUrl = activityDetail["shareUrl"] as! String
                if (self.currentDic["data"] as! TitleImage).imageUrl != nil {
                    var url : String = (self.currentDic["data"] as! TitleImage).imageUrl!
                    println("url::::\(url)")
                    var shareImageURL = NSURL(string: url)
                    shareImage = UIImage(data: NSData(contentsOfURL: shareImageURL!)!)
                }else{
                    shareImage = UIImage(named: "failure")
                }
            }
            UMSocialData.defaultData().extConfig.wechatSessionData.url = shareUrl
            UMSocialData.defaultData().extConfig.wechatTimelineData.url = shareUrl
        }
        FLOG("shareText:\(shareText)")
        FLOG("shareImage:\(shareImage)")
        UMSocialSnsService.presentSnsIconSheetView(
            self,
            appKey: "54d06833fd98c59e540009c8",
            shareText: shareText,
            shareImage: shareImage,
            shareToSnsNames: [UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline],
            delegate: self)
    }
    
    
    func didFinishGetUMSocialDataInViewController(response: UMSocialResponseEntity!) {
        if response.responseCode.value == UMSResponseCodeSuccess.value {
            UIAlertView(title: "提示", message: "分享成功", delegate: nil, cancelButtonTitle: "好的,知道了").show()
        }else{
            UIAlertView(title: "提示", message: "分享失败", delegate: nil, cancelButtonTitle: "好的,知道了").show()
        }
    }
    
    
    //获取文章详情
    func getArticleDetail(){
        var id : String!
        id = String()
        if  self.currentDic["data"] is NewsList {
            id = (self.currentDic["data"] as! NewsList).id
        }else{
            id = (self.currentDic["data"] as! TitleImage).id
        }
        theId = id
        HttpManager.sendHttpRequestPost(GETACTIVITYINFO, parameters:
            ["userId": ApplicationContext.getUserID()!,
            "id":id
            ],
            success: { (json) -> Void in
                
                FLOG("活动详情页面返回数据json:\(json)")
                self.activityDetail = json as [String :AnyObject]
                println("activityDetail;;;;;\(self.activityDetail)")
                var count = self.activityDetail["replyCount"] as! Int
                self.replyCount.text = "(\(count))"
                if (self.activityDetail["isEnd"] as! Bool) == true {//已截止
                    self.setSignUpButtonFasleState()
                    self.signUpButton.setTitle("已截止", forState: UIControlState.Disabled)

                }else{
                    if (self.activityDetail["isApply"] as! Bool) == true {
                        self.setSignUpButtonFasleState()
                        self.signUpButton.setTitle("已报名", forState: UIControlState.Disabled)
                    }else{
                        self.signUpButton.enabled = true
                        self.signUpButton.setTitle("报名", forState: UIControlState.Normal)
                    }
                }

            },
            failure:{ (reason) -> Void in
                self.signUpButton.enabled = false
                self.signUpButton.setTitle("已截止", forState: UIControlState.Disabled)
                FLOG("失败原因:\(reason)")
        })

    }
}
