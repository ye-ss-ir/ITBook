//
//  UpdateUserRequest.swift
//
//
//  Created by yes on 1/25/24.
//

import Foundation

/// User를 update할때 사용되는 parameter입니다.
/// - Parameters:
///   - userId: 업데이트할 User의 ID
///   - nickname: 새로운 nickname
///   - profileURL: 새로운 image url
public struct UserUpdateParams: Encodable {
    public let userId: String
    public let nickname: String?
    public let profileURL: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname
        case profileURL = "profile_url"
    }
    
    public init(userId: String, nickname: String?, profileURL: String?) {
        self.userId = userId
        self.nickname = nickname
        self.profileURL = profileURL
    }
}

struct UpdateUserRequest: Request {
    typealias Response = UserResponse
    
    let path: String
    let method: HttpMethod
    let parameters: RequestParams?
    let headers: [String: String]?
    
    init(params: UserUpdateParams) {
        self.path = "/v3/users/\(params.userId)"
        self.method = .put
        self.parameters = .body(params)
        self.headers = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
