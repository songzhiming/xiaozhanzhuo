//
//  ImageSource.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/13.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import Foundation

class ImageSource :NSObject{
    var imageUrls   = [String](){   //完整的ImageUrl
        didSet{
            trasnslateUrlsToNames()
        }
    }
    var imageNames  = [String]()   //imageName,服务器返回的名字
    
    override init(){
        
    }
    
    init(urls:[String]){
        imageUrls = urls
    }
}

extension ImageSource{
    
    private func trasnslateUrlsToNames(){
        imageNames.removeAll(keepCapacity:true)
        for url in imageUrls{
            var nsImageUrl =  NSMutableString(string: url)
            var imageName = nsImageUrl.stringByReplacingOccurrencesOfString(BASE_URL + "upload/images/", withString: "")
            imageNames.append(imageName)
        }
    }
    
    func dataForShowImageCollectionView() -> [String]{
        return self.imageUrls
    }
    
    func translateNamesToJsonString() -> String {
        var jsonNamesArray = [[String:String]]()
        for name in imageNames{
            jsonNamesArray.append(["imageUrl":name])
        }
        return ApplicationContext.toJSONString(jsonNamesArray) as! String
    }
}