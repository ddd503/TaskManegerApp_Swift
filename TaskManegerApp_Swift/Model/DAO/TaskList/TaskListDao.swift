//
//  TaskListDao.swift
//  TaskManegerApp_Swift
//
//  Created by kawaharadai on 2018/01/18.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation
import RealmSwift

final class TaskListDao {
    
    static let taskListDaoHelper = RealmDaoHelper<Task>()
    static let folderListDaoHelper = RealmDaoHelper<Folder>()
    
    // select（Taskモデルに格納して返す）
    
    // 1件取得
    static func selectID(taskId: Int) -> Task? {
        guard let object = taskListDaoHelper.findFirst(key: taskId as AnyObject) else {
            return nil
        }
        return Task(value: object)
    }
    
    // 全件取得
    static func selectObjectsSortedDateWithFolderId(folderId: Int) ->[Task] {
        let objects =  taskListDaoHelper.findAll().filter("folderId = \(folderId.description)").sorted(byKeyPath: "updateDate", ascending: false)
        return objects.map { Task(value: $0) }
    }
    
    // insert
    // オブジェクト追加
    static func add(model: Task) {
        
        let newObject = Task()
        
        if let newId = taskListDaoHelper.newId() {
            newObject.taskId = newId
        }
        newObject.updateDate = model.updateDate
        newObject.taskName = model.taskName
        newObject.folderId = model.folderId
        
        taskListDaoHelper.add(d: newObject)
    }
    
    // update
    static func update(model: Task) {
        
        guard let updateTask = taskListDaoHelper.findFirst(key: model.taskId as AnyObject) else {
            return
        }
        
        guard let updateFolder = taskListDaoHelper.findFirst(key: model.folderId as AnyObject) else {
            return
        }
        
        
        do {
            taskListDaoHelper.realm.beginWrite()
            updateTask.taskName = model.taskName
            updateTask.updateDate = Date()
            updateTask.folderId = model.folderId
            try taskListDaoHelper.realm.commitWrite()
        } catch let error {
            if taskListDaoHelper.realm.isInWriteTransaction {
                taskListDaoHelper.realm.cancelWrite()
            }
            print(error)
        }
        
        do {
            folderListDaoHelper.realm.beginWrite()
            updateFolder.updateDate = model.updateDate
            try folderListDaoHelper.realm.commitWrite()
        } catch let error {
            if folderListDaoHelper.realm.isInWriteTransaction {
                folderListDaoHelper.realm.cancelWrite()
            }
            print(error)
        }
    }
    
    // delete
    static func delete(model: Task) {
        guard let deleteObject = taskListDaoHelper.findFirst(key: model.taskId as AnyObject) else {
            return
        }
        
        taskListDaoHelper.delete(d: deleteObject)
    }
    
    // delete by folder delete
    static func deleteByfolder(folderId: Int) {
        let objects =  taskListDaoHelper.findAll().filter("folderId = \(folderId.description)").sorted(byKeyPath: "updateDate", ascending: false)
        
        for task in objects {
            delete(model: task)
        }
    }
    
    // all delete
    static func deleteAll() {
        taskListDaoHelper.deleteAll()
    }
}
