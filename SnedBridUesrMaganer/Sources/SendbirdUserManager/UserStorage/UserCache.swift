//
//  UserCache.swift
//
//
//  Created by yes on 1/24/24.
//

import Foundation
import CoreData

private class SBUserObject {
    let sbUser: SBUser
    init(sbUser: SBUser) {
        self.sbUser = sbUser
    }
}

final class UserCache {
    private let cache = NSCache<NSString, SBUserObject>()
    private let keyManager = SafeKeyManager()

    func setObject(_ user: SBUser, forKey key: String) {
        cache.setObject(SBUserObject(sbUser: user), forKey: key as NSString)
        keyManager.addKey(key)
    }
    
    func object(forKey key: String) -> SBUser? {
        cache.object(forKey: key as NSString)?.sbUser
    }
    
    func allObjects() -> [SBUser] {
        var objects: [SBUser] = []
        for key in keyManager.allKeys() {
            if let object = object(forKey: key) {
                objects.append(object)
            } else {
                keyManager.remove(key)
            }
        }
        
        return objects
    }
    
    func removeAllObjects() {
        cache.removeAllObjects()
        keyManager.removeAll()
    }
}

private class SafeKeyManager {
    private let setAccessQueue = DispatchQueue(label: "com.SendbirdUserManager.SBUserCache.SafeKeyManager", attributes: .concurrent)
    private var threadSafeSet = Set<String>()

    func addKey(_ key: String) {
        let _ = setAccessQueue.sync(flags: .barrier) {
            threadSafeSet.insert(key)
        }
    }

    func remove(_ key: String) {
        let _ = setAccessQueue.sync(flags: .barrier) {
            threadSafeSet.remove(key)
        }
    }
    
    func removeAll() {
        threadSafeSet.removeAll()
    }
    
    func allKeys() -> Set<String> {
        threadSafeSet
    }
}


