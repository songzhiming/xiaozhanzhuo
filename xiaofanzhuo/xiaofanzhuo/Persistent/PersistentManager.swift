//
//  PersistentManager.swift
//  FMDB_Demo
//
//  Created by 陈鲲鹏 on 15/4/21.
//  Copyright (c) 2015年 陈鲲鹏. All rights reserved.
//

import Foundation

/*  草稿保存步骤,用服务器返回的id（应用内唯一，如话题的id，评论的id，组队的id）作为主键和草稿唯一标识 by:kunpeng

**  1. 建立一个stateId(String=""),保存id：stateId = comment.id!;建立一个isPublish(Bool=false)标识是否已经发布

**  2. 获取草稿并显示到控件上：
    if let dic = PersistentManager.getValueById(stateId){
        contentText.text = dic["describe"]
    }

**  3.如果请求发送成功，删除草稿：
    PersistentManager.deleteById(stateId)

**  4.如果草稿没发送，退出页面需要保留草稿：
    deinit {
        if !isPublish{
            PersistentManager.setValueById(stateId, describe: contentText.text)
        }
    }
*/

//对第三方库（fmdb）的一个封装类，用于适配小饭桌项目，对项目提供统一接口
class PersistentManager {
    
    //供内部使用的一个单例
    private static let sharedInstance: FMDatabase = {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let path = documentsFolder.stringByAppendingPathComponent("xfz.sqlite")
        
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(path) {
            let db = FMDatabase(path: path)
            if !db.open() {
                return db
            }
            db.executeStatements("CREATE TABLE 'xfz' ( 'id' varchar(40) primary key , 'title' varchar(50) , 'describe' varchar(5010) ) ")
            db.close()
            return db
        }
        return FMDatabase(path: path)
        
    }()

    //根据id获取值
    class func getValueById(id:String)->[String:String]?{
        
        let db = PersistentManager.sharedInstance
        if !db.open() {
            return nil
        }
        
        var returnID = ""
        var returnTitle = ""
        var returnDescribe = ""
        
        //select操作
        var sql = "select * from xfz where id = ?"
        var rs = db.executeQuery(sql, withArgumentsInArray: [id])
        while rs.next() {
            returnID = rs.stringForColumn("id")
            returnTitle = rs.stringForColumn("title")
            returnDescribe = rs.stringForColumn("describe")
//            println("id = \(returnID); title = \(returnTitle); describe = \(returnDescribe)")
        }
        db.close()
        
        return ["id":returnID,"title":returnTitle,"describe":returnDescribe]
    }
    
    class func setValueById(id:String,describe:String,title:String=""){
        let db = PersistentManager.sharedInstance
        if !db.open() {
            return
        }
        
        var sql = "select * from xfz where id = ?"
        var rs = db.executeQuery(sql, withArgumentsInArray: [id])
        
        if rs.next(){//如果存在记录，则更新
            db.executeUpdate("update xfz set title = ?,describe = ? where id = ?", withArgumentsInArray: [title, describe,id])
        }else{//如果不存在记录，则插入
            db.executeUpdate("insert into xfz (id, title, describe) values (?, ?, ?)", withArgumentsInArray: [id, title, describe])
        }
        
        //update操作
        
        db.close()
        
        return
    }
    
    //根据id删除行
    class func deleteById(id:String){
        let db = PersistentManager.sharedInstance
        if !db.open() {
            return
        }
        
        db.executeUpdate("delete from xfz where id = ?", withArgumentsInArray: [id])
        db.close()
    }
    
    //清除全部数据
    class func cleanAll(){
        
        let db = PersistentManager.sharedInstance
        if !db.open() {
            return
        }
        db.executeUpdate("delete from xfz",withArgumentsInArray:nil)
        db.close()
    }
    
    class func showAll(){
        let db = PersistentManager.sharedInstance
        if !db.open() {
            return
        }
        
        var returnID = ""
        var returnTitle = ""
        var returnDescribe = ""
        
        //select操作
        var sql = "select * from xfz"
        var rs = db.executeQuery(sql, withArgumentsInArray: nil)
        while rs.next() {
            returnID = rs.stringForColumn("id")
            returnTitle = rs.stringForColumn("title")
            returnDescribe = rs.stringForColumn("describe")
            println("id = \(returnID); title = \(returnTitle); describe = \(returnDescribe)")
        }
        db.close()
    }
    
}
