//
//  MSProduct.swift
//  MSAPIService
//
//  Created by Tum on 12/2/16.
//  Copyright © 2016 Morestudio. All rights reserved.
//

import UIKit
import ObjectMapper

struct Product: Mappable {
    var id: Int = NSNotFound
    var name: String = ""
    var imageURL = ""
    var shortDetail = ""
    var detail = ""
    var price = 0.0
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.name <- map["name"]
        self.imageURL <- map["img_url"]
        self.shortDetail <- map["short_desc"]
        self.detail <- map["description"]
        self.price <- map["price"]
    }
}
