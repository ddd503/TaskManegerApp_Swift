//
//  RealmHelper.swift
//  TaskManegerApp_Swift
//
//  Created by kawaharadai on 2018/01/18.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import RealmSwift

final class RealmDaoHelper <T: RealmSwift.Object> {
    
    let realm: Realm
    
    init() {
        do {
            realm = try Realm()
        } catch(let error) {
            print("initエラー：\(error)")
            fatalError("RealmDaoHelper initialize error.")
        }
    }
    
    // MARK: - 新規登録
    
    func newId() -> Int? {
        guard let key = T.primaryKey() else {
            //primaryKey未設定
            return nil
        }
        return (realm.objects(T.self).max(ofProperty: key) as Int? ?? 0) + 1
    }
    
    // MARK: - serect
    
    func findAll() -> Results<T> {
        return realm.objects(T.self)
    }
    
    // 一番最初のオブジェクトのみ
    func findFirst() -> T? {
        return findAll().first
    }
    
    // 任意の場所のオブジェクトを取得
    func findFirst(key: AnyObject) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: key)
    }
    
   // 一番最後のオブジェクトを取得
    func findLast() -> T? {
        return findAll().last
    }
    
    // MARK: - insert
    
    func add(d :T) {
        do {
            try realm.write {
                realm.add(d)
            }
        } catch let error as NSError {
            print("インサートエラー：\(error)")
        }
    }
    
    // MARK: - update
    
    func update(d: T, block:(() -> Void)? = nil) -> Bool {
        do {
            try realm.write {
                block?()
                realm.add(d, update: true)
            }
            return true
        } catch let error as NSError {
            print("アップデートエラー：\(error)")
        }
        return false
    }
    
    // MARK: - delete
    
    // 任意のオブジェクトを削除
    func delete(d: T) {
        do {
            try realm.write {
                realm.delete(d)
            }
        } catch let error as NSError {
            print("デリートエラー：\(error)")
        }
    }
    
    // 全削除
    func deleteAll() {
        let allObject = realm.objects(T.self)
        do {
            try realm.write {
                realm.delete(allObject)
            }
        } catch let error as NSError {
            print("オールデリートエラー：\(error)")
        }
    }
}
