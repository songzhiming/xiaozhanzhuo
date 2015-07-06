//
//  GenerateCodeViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-16.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class GenerateCodeViewController: BasicViewController {

    @IBOutlet weak var firstNumberLabel: UILabel!
    @IBOutlet weak var secondNumberLabel: UILabel!
    @IBOutlet weak var threeNumberLabel: UILabel!
    @IBOutlet weak var fourNumberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noticLabel: UILabel!
    
    var labelGroup : [UILabel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        headView.changeLeftButton()
        headView.changeTitle("推荐新学员")
        headView.logoImage.hidden = true
        headView.generateCodeButton.hidden = true
        headView.searchButton.hidden = true
        
        labelGroup = [UILabel]()
        labelGroup.append(firstNumberLabel)
        labelGroup.append(secondNumberLabel)
        labelGroup.append(threeNumberLabel)
        labelGroup.append(fourNumberLabel)
        
        FLOG("PARAM:\(self.param)")
        
        if let info = self.param as? [String:String] {
            if info["tag"] == "show"{//如果是产看复制邀请码
                for i in 0..<4 {

                    labelGroup[i].text = (info["data"] as NSString!).substringWithRange(NSMakeRange(i,1))
                }
                titleLabel.text = "使用推荐码"
                noticLabel.hidden = true    
            }else if info["tag"] == "generate"{//如果是产生邀请码
                 self.generateRecommendCode()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //添加下划线
    func addUnderLine(str:String)->NSAttributedString{
        var content = NSMutableAttributedString(string: str)
        var contentRange = NSRange(location: 0,length: content.length)
        content.addAttribute(NSUnderlineColorAttributeName, value: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue), range: contentRange)
        return content
    }

    
    
    
    func generateRecommendCode(){
        var params : [String :String] = ["userId":ApplicationContext.getUserID()!]
        HttpManager.sendHttpRequestPost(GENERATERECOMMENDCODE, parameters: params,
            success: { (json) -> Void in
                
                FLOG("生成推荐码:\(json)")
                self.firstNumberLabel.text = (json["recomCode"] as! NSString).substringWithRange(NSMakeRange(0,1))
                self.secondNumberLabel.text = (json["recomCode"] as! NSString).substringWithRange(NSMakeRange(1,1))
                self.threeNumberLabel.text = (json["recomCode"] as! NSString).substringWithRange(NSMakeRange(2,1))
                self.fourNumberLabel.text = (json["recomCode"] as! NSString).substringWithRange(NSMakeRange(3,1))
            },
            failure:{ (reason) -> Void in
                FLOG("失败原因:\(reason)")
        })
    }
    @IBAction func copyNumberAction(sender: AnyObject) {
        var pboard = UIPasteboard.generalPasteboard()
        pboard.string = firstNumberLabel.text! + secondNumberLabel.text! + threeNumberLabel.text! + fourNumberLabel.text!
        UIAlertView(title: "提示", message: "复制成功", delegate: nil, cancelButtonTitle: "好的知道了").show()
    }


}
