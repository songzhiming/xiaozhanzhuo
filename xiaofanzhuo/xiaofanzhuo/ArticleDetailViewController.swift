//
//  ArticleDetailViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-26.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class ArticleDetailViewController:  BasicViewController,UMSocialUIDelegate{

    @IBOutlet weak var webViewButtomConstraint: NSLayoutConstraint!
    @IBOutlet weak var replyCount: UILabel!
    @IBOutlet weak var ariticleDetailWebview: UIWebView!
    var currentDic : [String : AnyObject]!

    var theId = ""
    
    var articleDetail : [String :AnyObject]!
    var activityDetail : [String : AnyObject]!
//    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?,dic : [String : AnyObject]?=nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        FLOG("param :::\(dic)")
        self.currentDic = dic
        FLOG(self.currentDic)
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
        self.headView.titleLabel.text = "官方文章"
        var url = ""
        if  self.currentDic["data"] is NewsList {
            url = (self.currentDic["data"] as! NewsList).htmlUrl! + "&userId=" + ApplicationContext.getUserID()! + "&deviceType=ios&currentVersion=\(Current_Version)"
        }else{
            url = (self.currentDic["data"] as! TitleImage).htmlUrl! + "&userId=" + ApplicationContext.getUserID()! + "&deviceType=ios&currentVersion=\(Current_Version)"
        }
        
        FLOG("artical:\(url)")
        
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
        ariticleDetailWebview.stringByEvaluatingJavaScriptFromString(meta as String)
        NSNotificationCenter.defaultCenter().postNotificationName("remove.loading.view", object: nil)
        FLOG("webViewDidFinishLoad")
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError){
        NSNotificationCenter.defaultCenter().postNotificationName("remove.loading.view", object: nil)
        FLOG("didFailLoadWithError")
    }

    @IBAction func articleCommentBtnClick(sender: AnyObject) {
        var vc = ArticleCommentViewController(nibName: "BaseCommentViewController", bundle: nil,param: theId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
     @IBAction func shareArticle(sender: AnyObject){

        FLOG(self.articleDetail)
        FLOG(self.currentDic)
        var shareText : String!
        shareText = String()
        var shareImage : UIImage!
        shareImage = UIImage()
        var shareUrl = ""
        if self.currentDic["type"] as! String == "1" {//文章
            var htmlUrl = ""
            shareText = self.articleDetail["title"] as! String + "  " + "via@小饭桌" + "  " //+ "http://www.xfz.cn/web/vpage/index.html"
            if  self.currentDic["data"] is NewsList {
                FLOG((self.currentDic["data"] as! NewsList))
                htmlUrl = (self.currentDic["data"] as! NewsList).htmlUrl!
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
                htmlUrl = (self.currentDic["data"] as! TitleImage).htmlUrl!
                shareUrl = (self.currentDic["data"] as! TitleImage).shareUrl!
                if (self.currentDic["data"] as! TitleImage).imageUrl != nil {
                    var url : String = (self.currentDic["data"] as! TitleImage).imageUrl!
                    var shareImageURL = NSURL(string: url)
                    shareImage = UIImage(data: NSData(contentsOfURL: shareImageURL!)!)
                }else{
                    shareImage = UIImage(named: "failure")
                }
            }
//            shareText = shareText
            UMSocialData.defaultData().extConfig.wechatSessionData.url = shareUrl
            UMSocialData.defaultData().extConfig.wechatTimelineData.url = shareUrl
        }else{
            var htmlUrl = ""
            shareText = self.articleDetail["title"] as! String + "  " + "via@小饭桌" + "  " //+ "http://www.xfz.cn/web/vpage/index.html"
            if  self.currentDic["data"] is NewsList {
                htmlUrl = (self.currentDic["data"] as! NewsList).htmlUrl!
                shareUrl = (self.currentDic["data"] as! NewsList).shareUrl!
                FLOG((self.currentDic["data"] as! NewsList))
                if (self.currentDic["data"] as! NewsList).imageUrl != nil {
                    var url : String = (self.currentDic["data"] as! NewsList).imageUrl!
                    var shareImageURL = NSURL(string: url)
                    shareImage = UIImage(data: NSData(contentsOfURL: shareImageURL!)!)
                }else{
                    shareImage = UIImage(named: "failure")
                }
                
            }else{
                htmlUrl = (self.currentDic["data"] as! TitleImage).htmlUrl!
                shareUrl = (self.currentDic["data"] as! TitleImage).shareUrl!
                if (self.currentDic["data"] as! TitleImage).imageUrl != nil {
                    
                    var url : String = (self.currentDic["data"] as! TitleImage).imageUrl!
                    var shareImageURL = NSURL(string: url)
                    shareImage = UIImage(data: NSData(contentsOfURL: shareImageURL!)!)
                }else{
                    shareImage = UIImage(named: "failure")
                }
            }
//            shareText = shareText
            UMSocialData.defaultData().extConfig.wechatSessionData.url = shareUrl
            UMSocialData.defaultData().extConfig.wechatTimelineData.url = shareUrl
        }

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
            HYBProgressHUD.showSuccess("分享成功")
        }else{
            HYBProgressHUD.showError("分享失败")
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
        HttpManager.sendHttpRequestPost(GETARTICLEINFO, parameters:
            ["userId": ApplicationContext.getUserID()!,
            "id":id
            ],
            success: { (json) -> Void in
                
                FLOG("干货json:\(json)")
                self.articleDetail = json as [String :AnyObject]
                var count = self.articleDetail["replyCount"] as! Int
                self.replyCount.text = "(\(count))"
                if self.currentDic["type"] as! String == "1" {
                    self.headView.titleLabel.text = "官方文章"
                }
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }

    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        println(request.URL!.absoluteString?.hasPrefix("local"))
        if (request.URL!.absoluteString!.hasPrefix("local")){
            
            println(request.URL!.absoluteString)
            FLOG("theRequest:\(request)")
            
            println((request.URL!.absoluteString! as NSString).substringFromIndex(24))
 
            var dic = ["index":"0","labelId":(request.URL!.absoluteString! as NSString).substringFromIndex(24)]

            var labelArticleViewController : LabelArticleViewController = LabelArticleViewController(nibName: "LabelArticleViewController", bundle: nil,param: dic)
            self.navigationController?.pushViewController(labelArticleViewController, animated: true)
            return false
        }
        return true
    }
    
    

}
