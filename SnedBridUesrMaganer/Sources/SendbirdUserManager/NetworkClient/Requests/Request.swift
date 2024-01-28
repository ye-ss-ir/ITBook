//
//  Request.swift
//
//
//  Created by Sendbird
//

import Foundation

enum URLRequestConversionError: Error {
    case urlCreationFail
    case parametersEncodingFail
}

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum RequestParams {
    case query(_ params: Encodable)
    case body(_ params: Encodable)
}

public protocol Request {
    associatedtype Response: Decodable
    var path: String { get }
    var method: HttpMethod { get }
    var parameters: RequestParams? { get }
    var headers: [String: String]? { get }
}

extension Request {
    func asURLRequest(withApplicationId applicationId: String, apiToken: String) throws -> URLRequest {
        let baseURL = "https://api-\(applicationId).sendbird.com"
        let urlString = baseURL + path
        var urlComponents = URLComponents(string: urlString)
        
        if case let .query(params) = parameters,
           let queryDict = try encodeToDictionary(params) as? [String: String?] {
            let queryItems = queryDict.map { URLQueryItem(name: $0.key, value: $0.value) }
            urlComponents?.queryItems = queryItems
        }
        
        guard let url = urlComponents?.url else {
            throw URLRequestConversionError.urlCreationFail
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(apiToken, forHTTPHeaderField: "Api-Token")
        headers?.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        if case let .body(params) = parameters {
            let bodyDict = try encodeToDictionary(params)
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict)
        }
        
        return urlRequest
    }
    
    func encodeToDictionary(_ paramsObject: Encodable) throws -> [String: Any?] {
        let data = try JSONEncoder().encode(paramsObject)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        guard let dictionary = jsonObject as? [String: Any?] else {
            throw URLRequestConversionError.parametersEncodingFail
        }
        return dictionary
    }
}


