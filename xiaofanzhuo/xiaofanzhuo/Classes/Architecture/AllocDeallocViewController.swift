//
//  AllocDeallocViewController.swift
//  xiaofanzhuo
//
//  Created by Fred on 2/8/15.
//  Copyright (c) 2015 songzm. All rights reserved.
//

import UIKit

class AllocDeallocViewController: UIViewController {
    
    deinit {
        FLOG("----------------释放类---------------- \(NSStringFromClass(self.dynamicType))")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        FLOG("----------------创建类---------------- \(NSStringFromClass(self.dynamicType))")
    }
    
    init(){
        super.init(nibName: nil, bundle: nil)
        FLOG("----------------创建类---------------- \(NSStringFromClass(self.dynamicType))")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        FLOG("----------------创建类---------------- \(NSStringFromClass(self.dynamicType))")
        fatalError("init(coder:) has not been implemented")
        
    }
}
