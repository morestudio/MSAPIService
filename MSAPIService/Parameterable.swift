//
//  Parameterable.swift
//  MSAPIService
//
//  Created by Tum on 12/13/16.
//  Copyright © 2016 Morestudio. All rights reserved.
//

import UIKit

public protocol Parameterable {
    func toParameters() -> [String: Any]
}

extension Dictionary: Parameterable {
    public func toParameters() -> [String : Any] {
        var params: [String: Any] = [:]
        for (key, value) in self {
            params["\(key)"] = value
        }
        return params
    }
}


