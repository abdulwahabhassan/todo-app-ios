//
//  RealmCategory.swift
//  Todoey
//
//  Created by Hassan Abdulwahab on 04/01/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCategory: Object { //create data object that subclasses realm Object which will allows us to be able to persist data in realm
    //dynamic keyword is a declaration modifier that informs the runtime environment to use the dynamic dispatch instead of the standard static dispatch to declare this propery so that its value can be monitored and when its values changes at runtime, realm will be able to dynamically update the change in the database. This keyword comes from object c api hence, we must mark the keywrod with @objc
    @objc dynamic var name: String = ""
    let todos = List<RealmTodo>() //create a realm list that holds data type of RealmTodo //this defines a forwards relationship between RealmCategory and RealmTodo. Each RealmCategory can have many RealmTodo
    
}
