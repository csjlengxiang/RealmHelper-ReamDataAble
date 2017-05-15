//
//  ViewController.swift
//  RealmHelperDemo
//
//  Created by sijiechen3 on 2017/5/9.
//  Copyright © 2017年 sijiechen3. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.testPerson()
    }

    
    func testPerson() {
        
        RealmHelper.initRealm()
        
        let personModel = PersonModel()
        
        
        personModel.key = "my key2"
        personModel.name = "lx"
        personModel.age = 16

        let realm = try! Realm()
        
        try! realm.write {
            realm.add(personModel, update: true)
        }
        
        
        print (personModel.toJSONString())
//
//        let p2 = PersonModel.deserialize(from: personModel.toJSONString())
//        
//        print (p2?.toJSONString())

        var person = Person(key: "my key", name: "csj", age: 18)
        
        person.addOrUpdate()
        
        person = Person(key: "my key1", name: "csj", age: 18)
        
        person.addOrUpdate()
        
        DispatchQueue.global().async {
            Person.select(predicate: NSPredicate(format: "name == %@", "csj")).subscribe(onNext: { (persons) in
                print (persons)
            })
        }
    }

}















