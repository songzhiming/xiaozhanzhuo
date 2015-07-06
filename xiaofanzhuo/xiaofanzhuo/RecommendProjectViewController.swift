//
//  RecommendProjectViewController.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-1-16.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class RecommendProjectViewController: BasicViewController,UIAlertViewDelegate,UITextViewDelegate {

    
    var keyboardShowstate : Bool = false
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var projectIntroTextView: HolderTextView!
    @IBOutlet weak var contactWatTextField: UITextField!
    @IBOutlet weak var projectPeopleTextField: UITextField!
    @IBOutlet weak var projectNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        headView.changeLeftButton()
        headView.changeTitle("推荐项目")
        headView.logoImage.hidden = true
        headView.searchButton.hidden = true
        headView.generateCodeButton.hidden = true
        
        projectIntroTextView.placeHolder = "必填,文字请尽量简约，不要超过300字"
        projectIntroTextView.maxLength = 300
        projectIntroTextView.textColor = UIColor.blackColor()
        projectIntroTextView.delegate = self
        
        //键盘收起，和出来
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    


    @IBAction func submitProject(sender: UIButton) {
        self.RecommendProject()
    }
    
    //键盘出来
    func keyboardWillShow(){
        if UIScreen.mainScreen().bounds.size.height == 568 {
            if keyboardShowstate ==  true {
                return
            }
            UIView.animateWithDuration(
                0.3,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.view.frame = CGRectMake(self.view.frame.origin.x, -70, self.view.frame.size.width, self.view.frame.size.height)
                }) { (Bool) -> Void in
                    
            }
            keyboardShowstate = true
        
        }

    
    }
    //键盘隐藏
    func keyboardWillHide(){
        if UIScreen.mainScreen().bounds.size.height == 568 {
            UIView.animateWithDuration(
                0.3,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height)
                }) { (Bool) -> Void in
                    
            }
            keyboardShowstate = false
            
        }
    }
    

    
    
    //推荐项目
    func RecommendProject(){
        var params : [String :String] = ["userId":ApplicationContext.getUserID()!,
                      "projectName":projectNameTextField.text,
                      "projectPeople":projectPeopleTextField.text,
                      "contactWay":contactWatTextField.text,
                      "projectIntro":projectIntroTextView.text]
        self.addLoadingView()
        HttpManager.sendHttpRequestPost(RECOMMEND_PROJECT, parameters: params,
            success: { (json) -> Void in
                self.removeLoadingView()
                UIAlertView(title: "恭喜您，已经提交成功", message: "后续会主动与您联系，请耐心等待!", delegate: self, cancelButtonTitle: "确定").show()
                
                self.navigationController?.popViewControllerAnimated(true)
            },
            failure:{ (reason) -> Void in
                self.removeLoadingView()
                FLOG("失败原因:\(reason)")
        })
    }

    @IBAction func closeKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    
    
    func textViewDidChange(textView: UITextView){
        if textView.text.isEmpty {
            projectIntroTextView.placeHolderView.hidden = false
        }else{
            projectIntroTextView.placeHolderView.hidden = true
        }
        
        var toBeString = textView.text as NSString
        if (toBeString.length >= 300) {
            textView.text = toBeString.substringToIndex(300)
        }
        var string = textView.text as NSString
        var number : Int = 300 - string.length
        numberLabel.text = "还可以输入" + String(number) + "字"
    }
    
    
    
}
