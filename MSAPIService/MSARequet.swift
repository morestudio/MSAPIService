//
//  MSAPIRequet.swift
//  MSAPIService
//
//  Created by Tum on 11/29/16.
//  Copyright © 2016 Morestudio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper

public enum Method: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

public enum ParameterEncoding {
    case `default`
    case json
}

public enum MSAJSONResponse {
    case success(json: JSON)
    case error(Error)
}


public protocol MSARequest {
    var urlString   : String { get }
    var params      : Parameterable? { get }
    var method      : Method { get }
    var encoding    : ParameterEncoding { get }
    var headers     : [String: String]? { get }
    
    init(urlString: String, params: Parameterable?, method: Method, encoding: ParameterEncoding, headers: [String: String]?)
    
    func request() -> DataRequest
    func response(_ completion: ((MSAJSONResponse) -> Void)?)
    
    func handleJSON(_ json: JSON) -> MSAJSONResponse
    func handleError(_ json: JSON) -> Error
}

// MARK: - Helper
extension MSARequest {
    
    public func request() -> DataRequest {
        let request = SessionManager.default.request(
            urlString,
            method: toHTTPMethod(method),
            parameters: params?.toParameters(),
            encoding: toParameterEncoding(encoding),
            headers: headers
        )
        
        request.validate(statusCode: 200...300)
        return request
    }
    
    internal func toHTTPMethod(_ method: Method) -> HTTPMethod {
        guard let httpMethod = HTTPMethod(rawValue: method.rawValue) else { assert(false); return .get }
        return httpMethod
    }
    
    internal func toParameterEncoding(_ encoding: ParameterEncoding) -> Alamofire.ParameterEncoding{
        switch encoding {
        case .default: return URLEncoding.default
        case .json: return JSONEncoding.default
        }
    }
}

public struct MSAPIRequest: MSARequest {

    private(set) public var urlString   : String
    private(set) public var params      : Parameterable?
    private(set) public var method      : Method
    private(set) public var encoding    : ParameterEncoding
    private(set) public var headers     : [String: String]?
    
    public init(urlString: String, params: Parameterable?, method: Method, encoding: ParameterEncoding = .default, headers: [String: String]? = nil) {
        self.urlString  = urlString
        self.params     = params
        self.method     = method
        self.encoding   = encoding
        self.headers    = headers
    }
    
    public func response(_ completion: ((MSAJSONResponse) -> Void)?) {
        let request = self.request()
        request.responseJSON { (response) in
            if let error = response.result.error {
                debugPrint("request", response.request?.url?.absoluteString ?? "request not found\nerror:", error)
                completion?(.error(error)); return
            }
            guard let data = response.data else {
                completion?(.error(MSAError.noResponse)); return
            }
            
            let json = JSON(data: data)
            let response = self.handleJSON(json)
            completion?(response)
        }
    }
    
    public func handleJSON(_ json: JSON) -> MSAJSONResponse {
        guard let status = json["status"].string else {
            debugPrint("error json format: \nraw json:",json)
            assert(false); return .error(MSAError.jsonFormatError)
        }
        
        switch status {
        case "success":
            return .success(json: json)
        case "error":
            return .error(handleError(json))
        default:
            assert(false)
            return .error(MSAError.jsonFormatError)
        }
    }
    
    public func handleError(_ json: JSON) -> Error {
        guard let errorData = json["error"].dictionary else {
                debugPrint("error json format: \nraw json:", json)
                assert(false); return MSAError.jsonFormatError
        }
        
        if let debugMessage = errorData["debugMessage"]?.string { debugPrint("error from server", debugMessage) }
        
        let mapper = Mapper<MSAPIError>()
        guard let error = mapper.map(JSONObject: json["error"].rawValue) else {
            debugPrint("error json format: \nraw json", json)
            assert(false)
            return MSAError.unknow
        }
        return error
    }
}
