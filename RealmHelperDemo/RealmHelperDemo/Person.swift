//
//  Person.swift
//  RealmHelperDemo
//
//  Created by sijiechen3 on 2017/5/10.
//  Copyright © 2017年 sijiechen3. All rights reserved.
//

import RealmSwift

class PersonModel: Object, BasicDataAble {
    typealias basicDataType = Person

    dynamic var key = "key"
    dynamic var name = "csj"
    dynamic var age = 2
    
    override static func primaryKey() -> String? {
        return "key"
    }
}

struct Person: RealmDataAble {
    typealias realmDataType = PersonModel
    
    var key = "key"
    var name = "csj"
    var age = 2
}

