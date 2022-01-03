//
//  Item.swift
//  Todoey
//
//  Created by Hassan Abdulwahab on 02/01/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation

struct Item: Codable {
    //struct Item must adopt the Codable(encapsulate Encodable and Decodable) protocol otherwise we wouldn't be able to encode (and decode) it with the PropertyListEncoder when we need to persist the data locally by saving to (or retrieving from) a plist in the data file path
    let title: String
    var done: Bool = false
    
    mutating func toggleCheck() {
        done = !done
    }
}
