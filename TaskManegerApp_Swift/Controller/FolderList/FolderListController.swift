//
//  FolderListController.swift
//  TaskManegerApp_Swift
//
//  Created by kawaharadai on 2018/01/18.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

class FolderListController: UIViewController {
    
    @IBOutlet weak var folderList: UITableView!
    @IBOutlet weak var toolBarButton: UIBarButtonItem!
    
    var provider = FolderListProvider()
    var folderListAlert: UIAlertController?
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadFolderList()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        setupToolbarButton(isEditing: editing)
        folderList.isEditing = editing
    }
    
    // MARK: - action
    
    @IBAction func didTapToolbarButton(_ sender: UIBarButtonItem) {
        if isEditing {
            createDeleteAllActionSheet()
        } else {
            createFolderAlert()
        }
    }
    
    // MARK: - private
    
    private func setup() {
        navigationItem.title = "フォルダ"
        navigationItem.rightBarButtonItem = editButtonItem
        setupToolbarButton(isEditing: isEditing)
        setupTableView()
    }
    
    private func setupTableView() {
        provider.delegate = self
        folderList.dataSource = provider
        folderList.delegate = self
        folderList.allowsSelectionDuringEditing = true
    }
    
    private func setupToolbarButton(isEditing: Bool) {
        if isEditing {
            toolBarButton.title = "全て削除"
        } else {
            toolBarButton.title = "新規フォルダ"
        }
    }
}

// MARK: - fileprivate
private extension FolderListController {
    
    func reloadFolderList() {
        let folderData = FolderListDao.selectObjects()
        provider.setFolderList(folderList: folderData)
        folderList.reloadData()
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
            
            FolderListDao.deleteAll()
            selfClass.reloadFolderList()
        }
        let cancelAction = UIAlertAction(title: "キャンセル",
                                         style: .cancel,
                                         handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func createFolderAlert(folderId: Int? = nil) {
        
        var folderName  = ""
        
        if
            let folderId = folderId,
            let findFolder = FolderListDao.selectID(folderId: folderId) {
            // 更新の場合、登録済みのフォルダ名をセット
            folderName = findFolder.folderName
        }
        
        var message = String()
        if folderId != nil {
            // 更新
            message = "このフォルダの新しい名前を入力してください。"
        } else {
            // 新規作成
            message = "このフォルダの名前を入力してください。"
        }
        
        folderListAlert = UIAlertController(title: folderName,
                                            message: message,
                                            preferredStyle: .alert)
        
        guard let alertController = self.folderListAlert else {
            return
        }
        
        alertController.addTextField { (textField) in
            
            textField.text = folderName
            textField.placeholder = message
            NotificationCenter.default.addObserver(self,
                                                   selector: .alertTextFieldTextDidChange,
                                                   name: .UITextFieldTextDidChange,
                                                   object: textField)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) {
            [weak self] (alertAction) in
            guard let selfClass = self else { return }
            selfClass.removeTextFieldObserver()
        }
        
        let saveAction = UIAlertAction(title: "保存", style: .default) {
            [weak self] (alertAction) in
            
            guard
                let selfClass = self,
                let folderName = self?.folderListAlert?.textFields?.first?.text else { return }
            
            if
                let folderId = folderId,
                let findResult = FolderListDao.selectID(folderId: folderId) {
                
                // 更新
                findResult.folderName = folderName
                FolderListDao.update(model: findResult)
            } else {
                // 新規作成
                let folder = Folder()
                folder.folderName = folderName
                FolderListDao.add(model: folder)
            }
            
            selfClass.removeTextFieldObserver()
            selfClass.reloadFolderList()
        }
        
        // 新規登録の場合はfalse, 更新の場合はtrue
        saveAction.isEnabled = (folderId != nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /// アラート内のtextFieldの文字入力通知を削除
    func removeTextFieldObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .UITextFieldTextDidChange,
                                                  object: folderListAlert?.textFields?.first)
    }
    
    /// アラート内のtextFieldの文字入力通知
    @objc func alertTextFieldTextDidChange(notification: NSNotification) {
        guard
            let textField = notification.object as? UITextField,
            let charactersCount = textField.text?.count else {
                return
        }
        folderListAlert?.actions.last?.isEnabled = charactersCount > 0
    }
}

// MARK: - fileprivate Selector
private extension Selector {
    static let alertTextFieldTextDidChange =
        #selector(FolderListController.alertTextFieldTextDidChange(notification:))
}

// MARK: - UITableViewDelegate
extension FolderListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedFolder = provider.selectFolder(index: indexPath)
        
        if isEditing {
            // フォルダ編集
            createFolderAlert(folderId: selectedFolder.folderId)
        } else {
            // タスクリストに遷移
            let taskListController = TaskListController.startUp(folder: selectedFolder)
            self.navigationController?.pushViewController(taskListController, animated: true)
        }
    }
}

// MARK: - FolderListProviderDelegate
extension FolderListController: FolderListProviderDelegate {
    func deleteFolder(folder: Folder) {
        // フォルタテーブルから対象のフォルダを削除する
        FolderListDao.delete(model: folder)
        TaskListDao.deleteByfolder(folderId: folder.folderId)
        reloadFolderList()
    }
}

