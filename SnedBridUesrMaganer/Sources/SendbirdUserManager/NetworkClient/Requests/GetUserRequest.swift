//
//  GetUserRequest.swift
//
//
//  Created by yes on 1/25/24.
//

import Foundation

struct GetUserRequest: Request {
    typealias Response = UserResponse
    
    let path: String
    let method: HttpMethod
    let parameters: RequestParams?
    let headers: [String: String]?
    
    init(userId: String) {
        self.path = "/v3/users/\(userId)"
        self.method = .get
        self.parameters = nil
        self.headers = ["Accept": "application/json"]
    }
}
