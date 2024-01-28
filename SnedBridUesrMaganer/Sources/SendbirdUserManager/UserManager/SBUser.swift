//
//  Models.swift
//  
//
//  Created by Sendbird
//

import Foundation

/// Sendbird의 User를 나타내는 객체입니다
public struct SBUser: Hashable {
    public init(userId: String, nickname: String? = nil, profileURL: String? = nil) {
        self.userId = userId
        self.nickname = nickname
        self.profileURL = profileURL
    }

    public var userId: String
    public var nickname: String?
    public var profileURL: String?
}
