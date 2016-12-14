//
//  MSAError.swift
//  MSAPIService
//
//  Created by Tum on 11/29/16.
//  Copyright © 2016 Morestudio. All rights reserved.
//

import UIKit
import ObjectMapper

public enum MSAError: Error {
    case unknow
    case noResponse
    case jsonFormatError
    case objectFormatError
}

extension NSError {
    convenience public init(domain: String, code: Int, errorMessage: String) {
        self.init(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: errorMessage])
    }
}


public struct MSAPIError: Mappable {
    private(set) var code: Int
    private(set) var title: String
    private(set) var message: String
    private(set) var debugMessage: String?
    
    public init?(map: Map) {
        code           = NSNotFound
        title          = ""
        message        = ""
        debugMessage   = nil
    }
    
    public mutating func mapping(map: Map) {
        code           <- map["code"]
        title          <- map["title"]
        message        <- map["message"]
        debugMessage   <- map["debug_message"]
    }
}

extension MSAPIError {
    public func toNSError() -> NSError {
        return NSError(domain: MSAConfiguration.default.errorDomain, code: code, errorMessage: message)
    }
    
    public var localizedDescription: String {
        return message
    }
}

extension MSAPIError: Error {}
