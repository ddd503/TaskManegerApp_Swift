//
//  Folder.swift
//  TaskManegerApp_Swift
//
//  Created by kawaharadai on 2018/01/18.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation
import RealmSwift

final class Folder: Object {
    @objc dynamic var folderId = 0
    @objc dynamic var updateDate = Date()
    @objc dynamic var folderName = ""
    // DB連携
    var tasks = List<Task>()
    
    override static func primaryKey() -> String? {
        return "folderId"
    }
    
    // フォルダIDによってソートする
    func checkTaskCount() -> String {
        return TaskListDao.selectObjectsSortedDateWithFolderId(folderId: folderId).count.description
    }
}

