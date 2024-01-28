//
//  SendbirdUserManagerTests.swift
//  SendbirdUserManagerTests
//
//  Created by Sendbird
//

import XCTest
@testable import SendbirdUserManager

final class UserManagerTests: UserManagerBaseTests {
    override func userManagerType() -> SBUserManager.Type! {
        SendbirdUserManager.self
    }
}

final class UserStorageTests: UserStorageBaseTests {
    override func userStorageType() -> SBUserStorage.Type! {
        SenbirdUserStorage.self
    }
    
}

final class NetworkClientTests: NetworkClientBaseTests {
    override func networkClientType() -> SBNetworkClient.Type! {
        SendbirdNetworkClient.self
    }
}
