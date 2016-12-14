//
//  MSAPIConfiguration.swift
//  MSAPIService
//
//  Created by Tum on 11/29/16.
//  Copyright © 2016 Morestudio. All rights reserved.
//

import UIKit

public struct MSAConfiguration {
    
    public static var `default` = MSAConfiguration()
    
    public var baseURL: String = ""
    public var versionEnpoint: String = "/api/v1"
    public var errorDomain = "error"
}

extension MSAConfiguration {
    
    public var baseAPIString: String {
        assert(!baseURL.isEmpty)
        return baseURL + versionEnpoint
    }
    
    public var baseAPIURL: URL? {
        guard let url = URL(string: baseAPIString) else { assert(false); return nil }
        return url
    }
}
