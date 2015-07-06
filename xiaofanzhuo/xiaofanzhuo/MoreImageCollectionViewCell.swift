//
//  MoreImageCollectionViewCell.swift
//  xiaofanzhuo
//
//  Created by 宋志明 on 15-3-11.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class MoreImageCollectionViewCell: UICollectionViewCell {

    var indexNumber : Int = Int()
    @IBOutlet weak var moreImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func onlickDeleteButton(sender: AnyObject) {
//        (CommonTool.findNearsetViewController(self.superview) as AddDescriptionViewController).selectedImageData.removeAtIndex(indexNumber)
//        (CommonTool.findNearsetViewController(self) as AddDescriptionViewController).selectedImageArray.removeAtIndex(indexNumber)
//        (CommonTool.findNearsetViewController(self) as AddDescriptionViewController).selectedImageName.removeAtIndex(indexNumber)
//        (CommonTool.findNearsetViewController(self) as AddDescriptionViewController).imageCollectionView.reloadData()

        if CommonTool.findNearsetViewController(self) is AddDescriptionViewController {
            (CommonTool.findNearsetViewController(self) as! AddDescriptionViewController).selectedImageArray.removeAtIndex(indexNumber)
            (CommonTool.findNearsetViewController(self) as! AddDescriptionViewController).selectedImageName.removeAtIndex(indexNumber)
            (CommonTool.findNearsetViewController(self) as! AddDescriptionViewController).imageCollectionView.reloadData()
        }else{//另外一个新增的单独编辑发言的页面
            (CommonTool.findNearsetViewController(self) as! EditReplyViewController).selectedImageArray.removeAtIndex(indexNumber)
            (CommonTool.findNearsetViewController(self) as! EditReplyViewController).selectedImageName.removeAtIndex(indexNumber)
            (CommonTool.findNearsetViewController(self) as! EditReplyViewController).imageCollectionView.reloadData()
        }
    }
    
    
    
    func loadData(data:String,index:Int){
        indexNumber = index
//        moreImageView.image = data
        moreImageView.sd_setImageWithURL(NSURL(string:data))


    }

}
