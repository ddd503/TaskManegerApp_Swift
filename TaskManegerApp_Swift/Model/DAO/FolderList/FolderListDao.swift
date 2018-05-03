//
//  FolderListDao.swift
//  TaskManegerApp_Swift
//
//  Created by kawaharadai on 2018/01/18.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation
import RealmSwift

final class FolderListDao {
    
    static let daoHelper = RealmDaoHelper<Folder>()
    
    // select（Folderモデルに格納して返す）
    
    // 1件取得
    static func selectID(folderId: Int) -> Folder? {
        guard let object = daoHelper.findFirst(key: folderId as AnyObject) else {
            return nil
        }
        return Folder(value: object)
    }
    
    // 全件取得
    static func selectObjects() -> [Folder] {
        let objects =  daoHelper.findAll().sorted(byKeyPath: "updateDate", ascending: false)
        return objects.map { Folder(value: $0) }
    }
    
    // insert
    // オブジェクト追加
    static func add(model: Folder) {
        
        let newObject = Folder()
        
        if let newId = daoHelper.newId() {
            newObject.folderId = newId
        }
        newObject.updateDate = model.updateDate
        newObject.folderName = model.folderName
        newObject.tasks = model.tasks
        
        daoHelper.add(d: newObject)
    }
    
    // update
    static func update(model: Folder) {
        
        guard let updateFolder = daoHelper.findFirst(key: model.folderId as AnyObject) else {
            return
        }
        
        do {
             // 更新作業開始
            daoHelper.realm.beginWrite()
            updateFolder.folderId = model.folderId
            updateFolder.folderName = model.folderName
            updateFolder.tasks = model.tasks
            try daoHelper.realm.commitWrite()
            return
        } catch let error {
            print(error)
        }
    }
    
    // delete
    static func delete(model: Folder) {
        guard let deleteObject = daoHelper.findFirst(key: model.folderId as AnyObject) else {
            return
        }
        
        daoHelper.delete(d: deleteObject)
    }
    
    // all delete
    static func deleteAll() {
        daoHelper.deleteAll()
    }
}
