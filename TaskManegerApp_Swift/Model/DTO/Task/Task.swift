//
//  Task.swift
//  TaskManegerApp_Swift
//
//  Created by kawaharadai on 2018/01/18.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation
import RealmSwift

final class Task: Object {
    
    @objc dynamic var taskId = 0
    @objc dynamic var folderId = 0
    @objc dynamic var updateDate = Date()
    @objc dynamic var taskName = ""
    
    override static func primaryKey() -> String? {
        return "taskId"
    }
}
