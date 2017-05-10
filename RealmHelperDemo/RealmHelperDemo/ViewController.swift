//
//  ViewController.swift
//  RealmHelperDemo
//
//  Created by sijiechen3 on 2017/5/9.
//  Copyright © 2017年 sijiechen3. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.testPerson()
    }

    
    func testPerson() {
        
        RealmHelper.initRealm()
        
        var person = Person(key: "my key", name: "csj", age: 18)
        
        person.addOrUpdate()
        
        person = Person(key: "my key1", name: "csj", age: 18)
        
        person.addOrUpdate()
        
        
        Person.select(predicate: NSPredicate(format: "name == %@", "csj")) { (result) in
            print (result)
        }
        
        
        
    }

}

