//
//  HttpManager.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15-1-15.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

enum ImageType : String {
    case Jpg = "jpg"
    case Png = "png"
}

let Current_Version = "1.1"

class HttpManager: NSObject {
    class var sharedInstance :Manager {
        
        struct Singleton {
            static let instance = Manager(configuration:config)
            static var config : NSURLSessionConfiguration {
                var defaultHeaders = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
                //设置header
                defaultHeaders["headerdata"] = "{\"deviceType\":\"ios\",\"currentVersion\":\"\(Current_Version)\"}"
                let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
                configuration.HTTPAdditionalHeaders = defaultHeaders
                //                configuration.requestCachePolicy = WlanReachability.isConnectedToNetwork() ? .ReloadIgnoringLocalAndRemoteCacheData : .ReturnCacheDataElseLoad
                configuration.timeoutIntervalForRequest = 5
                return configuration
            }
        }
        return Singleton.instance
    }
    
    
    
    class func postDatatoServer(method: Method, _ URLString: URLStringConvertible, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL) -> Request {
            var defaultHeaders = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
           //设置header
            defaultHeaders["headerdata"] = "{\"deviceType\":\"ios\",\"currentVersion\":\"\(Current_Version)\"}"
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.HTTPAdditionalHeaders = defaultHeaders
          //设置连接超时
            configuration.timeoutIntervalForRequest = 5
            let manager = Manager(configuration: configuration)
        
        FLOG(URLString)
        FLOG(parameters)
        
        /***********************用缓存整个postDatatoServer改成如下(未测试)********************
        let cachePolicy: NSURLRequestCachePolicy = WlanReachability.isConnectedToNetwork() ? .ReloadIgnoringLocalCacheData : .ReturnCacheDataElseLoad
        var request = NSMutableURLRequest(URL: NSURL(string: "\(URLString)")!, cachePolicy: cachePolicy, timeoutInterval: 10)
        request.addValue("{\"deviceType\":\"ios\",\"currentVersion\":\"1.0\"}", forHTTPHeaderField: "headerdata")
        request.HTTPMethod = method.rawValue
        var alamoRequest = Manager.sharedInstance.request(encoding.encode(request, parameters: parameters).0)
       *************************************************************************/
        
//        var request: NSMutableURLRequest!
//        if Reachability.isConnectedToNetwork() {
//            request = NSMutableURLRequest(URL: NSURL(string: URLString)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 2.0)

        
        
//        var request: NSMutableURLRequest!
//        if WlanReachability.isConnectedToNetwork() {
////            request = NSMutableURLRequest(URL: NSURL(string: URLString)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
////            request = NSMutableURLRequest(URL: NSURL(string: URLString)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 2.0)

//        } else {
////            request = NSMutableURLRequest(URL: NSURL(string: URLString)!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 2.0)
//        }
        return manager.request(method,URLString,parameters: parameters,encoding: encoding)
    }
    
    class func uploadFileToServer(URLString: String,uploadImage:UIImage,imageType:ImageType=ImageType.Jpg) -> Request {

        var imageData : NSData!
        
        switch imageType {
        case .Jpg :
            imageData = UIImageJPEGRepresentation(uploadImage,0)
        case .Png :
            imageData = UIImagePNGRepresentation(uploadImage)
        }
        
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString)!)
        let boundaryConstant = "smalltable.witmob.com.boundary\(arc4random())"
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        let uploadData = NSMutableData()
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"ios.\(imageType.rawValue)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/\(imageType.rawValue)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        return Manager.sharedInstance.upload(ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, data: uploadData)
    }
    
    //发送Post请求
    class func sendHttpRequestPost(
        URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        success: ((json:[String:AnyObject])->Void)? = nil,
        failure: ((reason:[String:AnyObject]?)->Void)? = nil) {
            
        HttpManager.sendHttpRequest(.POST, URLString: URLString, parameters: parameters, success: success, failure: failure)
    }
    
    //发送http网络请求
    class func sendHttpRequest(
            method: Method,
         URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
           success: ((json:[String:AnyObject])->Void)? = nil,
           failure: ((reason:[String:AnyObject]?)->Void)? = nil) {
        
            var url = URLString.URLString
            var getRequestUrl = BASE_URL+url
            
            if let param = parameters {
                getRequestUrl += "?"
                for (key,value) in param {
                    getRequestUrl += key
                    getRequestUrl += "="
                    getRequestUrl += "\(value)"
                    getRequestUrl += "&"
                }
                getRequestUrl = getRequestUrl.substringToIndex(advance(getRequestUrl.startIndex, count(getRequestUrl)-1))
            }
                
            FLOG(BASE_URL+url)
            FLOG(parameters)
            FLOG(getRequestUrl+"&deviceType=ios&currentVersion=\(Current_Version)")

            HttpManager.sharedInstance.request(
                method,
                BASE_URL+url,
                parameters: parameters,
                encoding: .URL).responseJSON { (_, _, JSON, _) -> Void in
                    if let json = JSON as? [String:AnyObject] {
                        if (json["code"] as! Int) == 0 {
                            if let successClosure = success {
                                successClosure(json: json)
                            }
                        }else{
                            var code = json["code"] as! Int
                            var message = json["message"] as! String
                            var reason : [String:AnyObject] = ["code":"\(code)","message":message]
                            
                            //冻结或者被删除跳转首页
                            if code == 10002 || code == 10003 {
                                NSNotificationCenter.defaultCenter().postNotificationName("popToLogin", object: message)
                                return
                            }
                            
                            if let failureClosure = failure {
                                failureClosure(reason: reason)
                            }
                            HYBProgressHUD.showError(json["message"] as! String)
                        }
                    }else{
                        
                        if let failureClosure = failure {
                            failureClosure(reason: nil)
                        }
                        HYBProgressHUD.showError("网络连接错误！")
                    }
                }
    }
}
