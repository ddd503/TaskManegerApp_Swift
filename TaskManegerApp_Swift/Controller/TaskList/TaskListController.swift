
//
//  TaskListController.swift
//  TaskManegerApp_Swift
//
//  Created by kawaharadai on 2018/01/18.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

class TaskListController: UIViewController {
    
    @IBOutlet weak var taskList: UITableView!
    @IBOutlet weak var toolBarButton: UIBarButtonItem!
    
    fileprivate let provider = TaskListProvider()
    fileprivate var taskListAlert: UIAlertController?
    
    var folder = Folder()
    
    // MARK : - factory
    
    class func startUp(folder: Folder) -> TaskListController {
        
        guard let taskListController = UIStoryboard(name: "TaskList", bundle: nil)
            .instantiateInitialViewController() as? TaskListController else {
                fatalError("TaskListViewController is nil.")
        }
        taskListController.folder = folder
        
        return taskListController
    }
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTaskList()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        setupToolbarButton(isEditing: editing)
        taskList.isEditing = editing
    }
    
    // MARK: - action
    
    @IBAction func didTapToolbarButton(_ sender: UIBarButtonItem) {
        if isEditing {
            createDeleteAllActionSheet()
        } else {
            createTaskAlert()
        }
    }
    
    // MARK: - private
    
    private func setup() {
        navigationItem.title = folder.folderName
        navigationItem.rightBarButtonItem = editButtonItem
        setupToolbarButton(isEditing: isEditing)
        setupTableView()
    }
    
    private func setupTableView() {
        provider.delegate = self
        taskList.dataSource = provider
        taskList.delegate = self
        taskList.allowsSelectionDuringEditing = true
    }
    
    private func setupToolbarButton(isEditing: Bool) {
        if isEditing {
            toolBarButton.title = "すべて削除"
        } else {
            toolBarButton.title = "タスク追加"
        }
    }
}

// MARK: - fileprivate
private extension TaskListController {
    
    /// タスク一覧取得
    func reloadTaskList() {
        
        let tasks = TaskListDao.selectObjectsSortedDateWithFolderId(folderId: folder.folderId)
        provider.setTaskList(taskList: tasks)
        taskList.reloadData()
    }
    
    /// すべて削除ボタン押下時のアクションシート
    func createDeleteAllActionSheet() {
        
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "削除", style: .destructive) { [weak self] (action) in
            
            guard let selfClass = self else {
                return
            }
            TaskListDao.deleteAll()
            selfClass.reloadTaskList()
        }
        let cancelAction = UIAlertAction(title: "キャンセル",
                                         style: .cancel,
                                         handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// フォルダ登録/編集アラート
    func createTaskAlert(taskId: Int? = nil) {
        
        var taskName  = ""
        
        if
            let taskId = taskId,
            let findResult = TaskListDao.selectID(taskId: taskId) {
            // 更新の場合、既存タスク名をセット
            taskName = findResult.taskName
        }
        
        var message = String()
        if taskId != nil {
            message = "このタスクの新しい名前を入力してください。"
        } else {
            message = "このタスクの名前を入力してください。"
        }
        
        taskListAlert = UIAlertController(title: taskName,
                                          message: message,
                                          preferredStyle: .alert)
        
        guard let alertController = self.taskListAlert else {
            return
        }
        
        alertController.addTextField { (textField) in
            
            textField.text = taskName
            textField.placeholder = message
            NotificationCenter.default.addObserver(self,
                                                   selector: .alertTextFieldTextDidChange,
                                                   name: .UITextFieldTextDidChange,
                                                   object: textField)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)  {
            [weak self] (alertAction) in
            guard let selfClass = self else {
                return
                
            }
            selfClass.removeTextFieldObserver()
        }
        
        let saveAction = UIAlertAction(title: "保存", style: .default) {
            [weak self] (alertAction) in
            
            guard
                let selfClass = self,
                let taskName = alertController.textFields?.first?.text else {
                    return
            }
            
            if let taskId = taskId,
                let findResult = TaskListDao.selectID(taskId: taskId) {
                // 更新
                findResult.taskName = taskName
                TaskListDao.update(model: findResult)
            } else {
                // 新規登録
                let task = Task()
                task.folderId = selfClass.folder.folderId
                task.taskName = taskName
                TaskListDao.add(model: task)
            }
            
            selfClass.removeTextFieldObserver()
            selfClass.reloadTaskList()
        }
        
        // 新規登録の場合はfalse, 更新の場合はtrue
        saveAction.isEnabled = (taskId != nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func removeTextFieldObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .UITextFieldTextDidChange,
                                                  object: taskListAlert?.textFields?.first)
    }
    
    /// アラート内の文字入力通知
    @objc func alertTextFieldTextDidChange(notification: NSNotification) {
        guard
            let textField = notification.object as? UITextField,
            let charactersCount = textField.text?.count else {
                return
        }
        taskListAlert?.actions.last?.isEnabled = charactersCount > 0
    }
}

// MARK: - fileprivate Selector
private extension Selector {
    static let alertTextFieldTextDidChange =
        #selector(TaskListController.alertTextFieldTextDidChange(notification:))
}

// MARK: - UITableViewDelegate
extension TaskListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTask = provider.selectTask(index: indexPath)
        
        if isEditing {
            // 登録済みタスク編集
            createTaskAlert(taskId: selectedTask.taskId)
        }
    }
}

// MARK: - TaskListProviderDelegate
extension TaskListController: TaskListProviderDelegate {
    func deleteTask(task: Task) {
        TaskListDao.delete(model: task)
        reloadTaskList()
    }
}

