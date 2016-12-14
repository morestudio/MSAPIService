//
//  MSAWorker.swift
//  MSAPIService
//
//  Created by Tum on 12/1/16.
//  Copyright © 2016 Morestudio. All rights reserved.
//

import ObjectMapper
import PromiseKit
import SwiftyJSON

import UIKit

public protocol MSAWorker {
    var request: MSARequest { get }
    init(endpoint: String, params: Parameterable?, method: Method, encoding: ParameterEncoding, headers: [String: String]?)
    init(request: MSARequest)
    
    func responseObject<T>(keypath: String?)-> Promise<T> where T: Mappable
    func responseArray<T>(keypath: String?)-> Promise<[T]> where T: Mappable
}

open class MSAPIWorker: MSAWorker {
   
    private(set) public var request: MSARequest
    
    public required init(endpoint: String, params: Parameterable?, method: Method, encoding: ParameterEncoding = .default, headers: [String: String]? = nil) {
        let url = MSAConfiguration.default.baseAPIString + endpoint
        self.request = MSAPIRequest(urlString: url, params: params, method: method, encoding: encoding, headers: headers)
    }
    
    public required init(request: MSARequest) {
        self.request = request
    }
    
    open func responseObject<T>(keypath: String? = nil)-> Promise<T> where T: Mappable {
        let pending = Promise<T>.pending()
        self.request.response { response in
            switch response {
            case .success(let json):
                do {
                    let object: T = try self.handleObjectSuccess(json: json, keypath: keypath)
                    pending.fulfill(object)
                } catch MSAError.objectFormatError {
                    pending.reject(MSAError.objectFormatError)
                } catch {
                    pending.reject(MSAError.unknow)
                }
            case .error(let error):
                pending.reject(error)
            }
        }
        
        return pending.promise
    }
    
    open func responseArray<T>(keypath: String? = nil)-> Promise<[T]> where T: Mappable {
        let pending = Promise<[T]>.pending()
        self.request.response { response in
            switch response {
            case .success(let json):
                do {
                    let object: [T] = try self.handleArraySuccess(json: json, keypath: keypath)
                    pending.fulfill(object)
                } catch MSAError.objectFormatError {
                    pending.reject(MSAError.objectFormatError)
                } catch {
                    pending.reject(MSAError.unknow)
                }
            case .error(let error):
                pending.reject(error)
            }
        }
        return pending.promise
    }
    
    private func handleResponse<T>() -> (T, Error)? {
        
        return nil
    }
}

extension MSAPIWorker {
    internal func handleArraySuccess<T>(json: JSON, keypath: String?)throws -> [T] where T: Mappable{
        let objectData = mapObject(json: json, keypath: keypath)
        let mapper = Mapper<T>()
        guard let object = mapper.mapArray(JSONObject: objectData) else {
            debugPrint("json objectFormatError:", json.rawValue)
            throw MSAError.objectFormatError
        }
        return object
    }
    
    internal func handleObjectSuccess<T>(json: JSON, keypath: String?)throws -> T where T: Mappable{
        let objectData = mapObject(json: json, keypath: keypath)
        let mapper = Mapper<T>()
        guard let object = mapper.map(JSONObject: objectData) else {
            debugPrint("json objectFormatError:", json.rawValue)
            throw MSAError.objectFormatError
        }
        return object
    }
    
    fileprivate func mapObject(json: JSON, keypath: String?) -> Any {
        let objectData: Any
        if let key = keypath, !key.isEmpty {
            objectData = json[key].rawValue
        } else {
            objectData = json.rawValue
        }
        return objectData
    }
}
