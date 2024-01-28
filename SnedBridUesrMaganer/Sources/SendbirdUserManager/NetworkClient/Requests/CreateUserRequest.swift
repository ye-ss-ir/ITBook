//
//  CreateUserRequest.swift
//
//
//  Created by yes on 1/25/24.
//

import Foundation

/// User를 생성할때 사용되는 parameter입니다.
/// - Parameters:
///   - userId: 생성될 user id
///   - nickname: 해당 user의 nickname
///   - profileURL: 해당 user의 profile로 사용될 image url
public struct UserCreationParams: Encodable {
    public let userId: String
    public let nickname: String
    public let profileURL: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname
        case profileURL = "profile_url"
    }
    
    public init(userId: String, nickname: String, profileURL: String) {
        self.userId = userId
        self.nickname = nickname
        self.profileURL = profileURL
    }
}

struct CreateUserRequest: Request {
    typealias Response = UserResponse
    
    let path: String
    let method: HttpMethod
    let parameters: RequestParams?
    let headers: [String: String]?
    
    init(params: UserCreationParams) {
        self.path = "/v3/users"
        self.method = .post
        self.parameters = .body(params)
        self.headers = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}

