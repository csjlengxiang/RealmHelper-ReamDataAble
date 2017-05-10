//
//  RealmHelper.swift
//  testUseHandyJsonAndObjectMapper
//
//  Created by sijiechen3 on 2017/5/9.
//  Copyright © 2017年 csj. All rights reserved.
//

import Foundation
import HandyJSON
import RealmSwift

protocol RealmDataAble: HandyJSON {
    associatedtype realmDataType
    var realmData: realmDataType? { get }
}

protocol BasicDataAble: class, HandyJSON {
    associatedtype basicDataType
    var basicData: basicDataType? { get }
}

extension RealmDataAble where Self.realmDataType: BasicDataAble, Self.realmDataType: Object {
    
    var realmData: realmDataType? {
        return realmDataType.deserialize(from: self.toJSONString())
    }
    
    // 普通数据增删改查...待添加
    func addOrUpdate() {
        guard let realmData = self.realmData else {
            return
        }
        RealmHelper.addOrUpdate(object: realmData)
    }
    
    func add() {
        guard let realmData = self.realmData else {
            return
        }
        RealmHelper.add(object: realmData)
    }
    
    // 普通数据获取
    static func select(predicate: NSPredicate, clouse: @escaping ([Self]) -> Void) {
        
        let newClouse: (Results<Self.realmDataType>) -> Void = { results in
            var ret: [Self] = []
            for result in results {
                ret.append(result.basicData as! Self)
            }
            clouse(ret)
        }
        RealmHelper.select(type: Self.realmDataType.self, predicate: predicate, clouse: newClouse)
    }
}

extension BasicDataAble where Self: Object, Self.basicDataType: RealmDataAble {
    var basicData: basicDataType? {
        return basicDataType.deserialize(from: self.toJSONString())
    }
}


public struct RealmHelper {
    
    public static var mainRealm: Realm!
    
    public static func initRealm() {
        var config = Realm.Configuration()
        let realmName = "realmName"
        
        config.fileURL =  config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(realmName).realm")
        
        config.schemaVersion = 0;
        
        //        config.migrationBlock
        
        Realm.Configuration.defaultConfiguration = config
        
        RealmHelper.mainRealm = try! Realm()
        
        print ("file url: \(config.fileURL!)")
    }
    
    public static func doWriteHandler(clouse: @escaping () -> Void) {
        DispatchQueue.main.async {
            try! mainRealm.write {
                clouse()
            }
        }
    }
    
    public static func add<T: Object>(object: T) {
        RealmHelper.doWriteHandler {
            mainRealm.add(object)
        }
    }
    
    public static func addOrUpdate<T: Object>(object: T) {
        RealmHelper.doWriteHandler {
            mainRealm.add(object, update: true)
        }
    }
    
    public static func addOrUpdate<T: Object>(objects: [T]) {
        RealmHelper.doWriteHandler {
            mainRealm.add(objects, update: true)
        }
    }
    
    public static func select<T: Object>(type: T.Type, predicate: NSPredicate, clouse: @escaping (Results<T>) -> Void) -> Void {
        DispatchQueue.main.async {
            let results = mainRealm.objects(type).filter(predicate)
            clouse(results)
        }
    }
}

















