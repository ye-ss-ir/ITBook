//
//  File.swift
//  
//
//  Created by yes on 1/25/24.
//

import Foundation

struct UserResponse: Codable {
    let userId: String
    let nickname: String
    let profileURL: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname
        case profileURL = "profile_url"
    }
}

struct UserListResponse: Codable {
    let users: [UserResponse]
}
