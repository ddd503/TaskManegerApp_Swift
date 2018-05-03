//
//  FolderListProvider.swift
//  TaskManegerApp_Swift
//
//  Created by kawaharadai on 2018/01/18.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation
import UIKit

protocol FolderListProviderDelegate: class {
    func deleteFolder(folder: Folder)
}

class FolderListProvider: NSObject {
    
    weak var delegate: FolderListProviderDelegate?

    fileprivate var folderList = [Folder]()
    
    func setFolderList(folderList: [Folder]) {
        self.folderList = folderList
    }
    
    func selectFolder(index: IndexPath) -> Folder {
        return self.folderList[index.row]
    }
}

// MARK: - UITableViewDataSource Methods
extension FolderListProvider: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! FolderCell
        
        cell.folderNameLabel.text = folderList[indexPath.row].folderName
        cell.taskCountLabel.text = folderList[indexPath.row].checkTaskCount()
        
        return cell
    }
    
    // 削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
           let deleteFolder = self.folderList[indexPath.row]
            delegate?.deleteFolder(folder: deleteFolder)
        }
    }
}

