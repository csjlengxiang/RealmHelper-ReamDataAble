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
import RxSwift

public protocol RealmDataAble: HandyJSON {
    associatedtype realmDataType // : Object, BasicDataAble
    var realmData: realmDataType? { get }
}

public protocol BasicDataAble: class, HandyJSON {
    associatedtype basicDataType // : RealmDataAble  http://stackoverflow.com/questions/37253236/swift-protocol-with-associated-type-type-may-not-reference-itself-as-a-require
    var basicData: basicDataType? { get }
}

extension RealmDataAble where Self.realmDataType: BasicDataAble, Self.realmDataType: Object {
    
    public var realmData: realmDataType? {
        return realmDataType.deserialize(from: self.toJSONString()) // Object can be deserialize. but can not toJSONString when get from realm result. WTF
    }
    
    // 普通数据增删改查...待添加
    func addOrUpdate() {
        guard let realmData = self.realmData else {
            return
        }
        RealmHelper.addOrUpdate(object: realmData)
    }
    
    // 普通数据获取
    static func select(predicate: NSPredicate) -> Observable<[Self]> {
        let o: Observable<Results<Self.realmDataType>>  = RealmHelper.select(type: Self.realmDataType.self, predicate: predicate)
        
        return o.map({ (results) -> [Self] in
            
            var ret: [Self] = []
            for result in results {
                ret.append(result.basicData as! Self)
            }
            return ret
        })
    }
}

extension BasicDataAble where Self: Object, Self.basicDataType: RealmDataAble {
    public var basicData: basicDataType? {
        return basicDataType.deserialize(from: self.toDictionary()) // bug: self.toJSONString() will nil when get result from Result<T>, so use http://stackoverflow.com/questions/32023249/how-can-i-convert-a-realm-object-to-json-in-swift
    }
}

extension Object {
    func toDictionary() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValues(forKeys: properties)
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeys(dictionary)
        
        for prop in self.objectSchema.properties as [Property]! {
            // find lists
            if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [AnyObject]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    let object = nestedListObject._rlmArray[index] as AnyObject
                    objects.append(object.toDictionary())
                }
                mutabledic.setObject(objects, forKey: prop.name as NSCopying)
            }
        }
        return mutabledic
    }
}

public struct RealmHelper {
    
    public static func initRealm() {
        var config = Realm.Configuration()
        let realmName = "realmName"
        
        config.fileURL =  config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(realmName).realm")
        
        config.schemaVersion = 0;
        
        //        config.migrationBlock
        
        Realm.Configuration.defaultConfiguration = config
        
        print ("file url: \(config.fileURL!)")
    }
    
    public static func addOrUpdate<T: Object>(object: T) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(object, update: true)
        }
    }
    
    public static func select<T: Object>(type: T.Type, predicate: NSPredicate) -> Observable<Results<T>> {
        return Observable.create({ (observer) -> Disposable in
            let realm = try! Realm()
            let results = realm.objects(type).filter(predicate)
            observer.onNext(results)
            observer.onCompleted()
            return Disposables.create()
        })
    }
    
}







