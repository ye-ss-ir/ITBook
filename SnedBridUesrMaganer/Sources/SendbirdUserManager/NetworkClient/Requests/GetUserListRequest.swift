//
//  GetUserListRequest.swift
//
//
//  Created by yes on 1/25/24.
//

import Foundation

struct UserListParams: Encodable {
    let limit: String
    let nickname: String?
}

struct GetUserListRequest: Request {
    typealias Response = UserListResponse
    
    let path: String
    let method: HttpMethod
    let parameters: RequestParams?
    let headers: [String: String]?
    
    init(params: UserListParams) {
        self.path = "/v3/users"
        self.method = .get
        self.parameters = .query(params)
        self.headers = ["Accept": "application/json"]
    }
}
