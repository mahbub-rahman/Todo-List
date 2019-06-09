//
//  Category.swift
//  Todo-List
//
//  Created by mahbub rahman on 8/6/19.
//  Copyright © 2019 mahbub rahman. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name:String = ""
    @objc dynamic var color:String = ""
    let items = List<Item>()
}
