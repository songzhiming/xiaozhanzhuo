//
//  ShowPhotoCollectionView.swift
//  xiaofanzhuo
//
//  Created by 陈鲲鹏 on 15/5/13.
//  Copyright (c) 2015年 songzm. All rights reserved.
//

import UIKit

protocol ShowPhotoCollectionViewDelegate:class{
    func imagesCollectionDidChange(imageUrls:[String])
}

class ShowPhotoCollectionView: UICollectionView {

    //变量
    var imageUrls:[String]!
    var upLoadQueue:[UIImage]!
    weak var showPhotoDelegate: ShowPhotoCollectionViewDelegate?
    
    //常量
    let max_count = 5
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configureViews()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureImageUrls(imageUrls:[String]){
        self.imageUrls = imageUrls
    }
    
    func configureViews(){
        imageUrls = [String]()
        upLoadQueue = [UIImage]()
        
        self.backgroundColor = UIColor.whiteColor()
        
        var flowLayout: UICollectionViewFlowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout

        flowLayout.itemSize = CGSizeMake(42,64)
        flowLayout.minimumInteritemSpacing = 15
        flowLayout.minimumLineSpacing = 6
        
        self.delegate = self
        self.dataSource = self
        self.registerNib(UINib(nibName: "ShowPhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ShowPhotoCollectionViewCell.cellId)
    }
}

//MARK:-UICollectionViewDataSource
extension ShowPhotoCollectionView:UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return imageUrls.count + 1 > max_count ? max_count : imageUrls.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        var cell = self.dequeueReusableCellWithReuseIdentifier(ShowPhotoCollectionViewCell.cellId, forIndexPath: indexPath) as! ShowPhotoCollectionViewCell
        if imageUrls.count + 1 <= max_count && indexPath.row == imageUrls.count {//添加按钮
            cell.configureShowPhotoCellWithImage(UIImage(named: "add_photo")!)
            cell.closeBtn.hidden = true
            cell.setAddButtonState()
            return cell
        }
        cell.configureShowPhotoCellWithUrl(imageUrls[indexPath.row])
        cell.setImageState()
        return cell
    }
}

//MARK:-UICollectionViewDelegate
extension ShowPhotoCollectionView:UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        if imageUrls.count + 1 <= max_count && indexPath.row == imageUrls.count {//添加按钮
            var actionSheet = UIActionSheet(
                title: nil,
                delegate: self,
                cancelButtonTitle: "取消",
                destructiveButtonTitle: nil,
                otherButtonTitles:"相册","拍照")
            actionSheet.actionSheetStyle = UIActionSheetStyle.BlackOpaque
            actionSheet.destructiveButtonIndex = -1
            actionSheet.showInView(self)
            return
        }
        
        //点击照片删除
//        collectionView.deleteItemsAtIndexPaths([indexPath])
        imageUrls.removeAtIndex(indexPath.row)
        self.reloadData()
        self.showPhotoDelegate?.imagesCollectionDidChange(self.imageUrls)
    }
}

//MARK:-UICollectionViewDelegate
extension ShowPhotoCollectionView:UIActionSheetDelegate{
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 0 {
        }else if buttonIndex == 1 {
            self.pickImageFromAlbum()
        }else if buttonIndex == 2 {
            self.pickImageFromCarera()
        }
    }
}

//MARK:-实例方法
extension ShowPhotoCollectionView{
    func pickImageFromAlbum(){
        var controller = AlbumTableViewController(nibName:"AlbumTableViewController",bundle:nil,maxCount:max_count-self.imageUrls.count)
        CommonTool.findNearsetViewController(self).navigationController?.pushViewController(controller, animated: true)
        controller.getImagesArray { (imageArray) -> Void in
            self.upLoadQueue.extend(imageArray)
            self.uploadImages()
        }
    }
    
    func pickImageFromCarera() {
        var imagePicker : UIImagePickerController
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        //            imagePicker.allowsEditing = true
        CommonTool.findNearsetViewController(self).presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func uploadImages(){
//        HYBProgressHUD.showSuccess("图片开始上传")
        var counter = 0
        var preVc = CommonTool.findNearsetViewController(self) as! BasicViewController
        preVc.addLoadingView()
        for image in upLoadQueue {
            HttpManager.uploadFileToServer(BASE_URL + UPLOAD_IMAGE , uploadImage: image,imageType:.Jpg)
                .responseJSON{(_, _, JSON, _) in
                    if let json = JSON as? [String:AnyObject] {
                        if (json["code"] as! Int) == 0 {
                            println("上传图片返回JSON\(json)")
                            self.imageUrls.append(json["imageUrl"] as! String)
                            if ++counter == self.upLoadQueue.count {
                                self.reloadData()
                                self.upLoadQueue.removeAll(keepCapacity: false)
                                self.showPhotoDelegate?.imagesCollectionDidChange(self.imageUrls)
                                preVc.removeLoadingView()
                                HYBProgressHUD.showSuccess("图片上传成功")
                            }
     
                        }else{
                            preVc.removeLoadingView()
                            HYBProgressHUD.showError(json["message"] as! String)
                            println("服务器返回数据错误,code!=0")
                        }
                    }else{
                        preVc.removeLoadingView()
                        HYBProgressHUD.showError("网络连接错误！")
                        println("网络连接错误！")
                    }
            }//httpmanager
        }//for
    }
}

//MARK:-UIImagePickerControllerDelegate
extension ShowPhotoCollectionView:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        var image = info["UIImagePickerControllerOriginalImage"] as! UIImage
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        picker.dismissViewControllerAnimated(true, completion: nil)
        upLoadQueue.append(image)
        uploadImages()
    }
}
