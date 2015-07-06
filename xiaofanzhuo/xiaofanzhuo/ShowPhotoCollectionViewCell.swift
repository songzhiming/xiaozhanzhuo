//
//  ShowPhotoCollectionViewCell.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/13.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

class ShowPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var closeBtn: UIImageView!
    
    class var cellId: String {
        return "ShowPhotoCollectionViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

extension ShowPhotoCollectionViewCell{
    
    func configureShowPhotoCellWithUrl(imageUrl:String){
        image.sd_setImageWithURL(NSURL(string:imageUrl), placeholderImage: UIImage(named:"avater"))
    }
    func configureShowPhotoCellWithImage(imageData:UIImage){
        image.image = imageData
    }
    func setAddButtonState(){
        closeBtn.hidden = true
    }
    func setImageState(){
        closeBtn.hidden = false
    }
}