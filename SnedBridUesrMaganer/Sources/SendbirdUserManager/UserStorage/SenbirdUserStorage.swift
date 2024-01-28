//
//  SenbirdUserStorage.swift
//
//
//  Created by yes on 1/22/24.
//

import Foundation

final class SenbirdUserStorage: SBUserStorage {
    private let userCache = UserCache()
    
    required init() {}
    
    func upsertUser(_ user: SBUser) {
        userCache.setObject(user, forKey: user.userId)
    }
    
    func getUsers() -> [SBUser] {
        userCache.allObjects()
    }
    
    func getUsers(for nickname: String) -> [SBUser] {
        userCache.allObjects().filter { $0.nickname == nickname }
    }
    
    func getUser(for userId: String) -> (SBUser)? {
        userCache.object(forKey: userId)
    }
    
    func removeAllUsers() {
        userCache.removeAllObjects()
    }
}

