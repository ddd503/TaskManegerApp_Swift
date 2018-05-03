//
//  TaskListProvider.swift
//  TaskManegerApp_Swift
//
//  Created by kawaharadai on 2018/01/18.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation
import UIKit

protocol TaskListProviderDelegate: class {
    func deleteTask(task: Task)
}

class TaskListProvider: NSObject {
    
    weak var delegate: TaskListProviderDelegate?
    
    fileprivate var taskList = [Task]()
    
    func setTaskList(taskList: [Task]) {
        self.taskList = taskList
    }
    
    func selectTask(index: IndexPath) -> Task {
        return self.taskList[index.row]
    }
}

// MARK: - UITableViewDataSource Methods
extension TaskListProvider: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        cell.taskNameLabel.text = taskList[indexPath.row].taskName
        cell.updateTaskTimeLabel.text = taskList[indexPath.row].updateDate.dateStyle()
        
        return cell
    }
    
    // 削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let deleteTask = self.taskList[indexPath.row]
            delegate?.deleteTask(task: deleteTask)
        }
    }
}
