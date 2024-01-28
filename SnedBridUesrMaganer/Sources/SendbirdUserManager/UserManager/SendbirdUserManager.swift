//
//  SendbirdUserManager.swift
//
//
//  Created by yes on 1/22/24.
//

import Foundation

enum SendbirdUserManagerError: LocalizedError {
    case emptyNickname
    case userCreationLimitExceeded(Int)
    case usersCreationPartialFailed([UserCreationParams])

    var errorDescription: String? {
        switch self {
        case .emptyNickname: return "닉네임이 빈 문자열입니다."
        case .userCreationLimitExceeded(let count): return "한 번에 생성할 수 있는 사용자의 수는 최대 \(count)명입니다."
        case .usersCreationPartialFailed: return "일부 사용자의 생성이 실패했습니다."
        }
    }
}

final class SendbirdUserManager: SBUserManager {
    var networkClient: SBNetworkClient
    var userStorage: SBUserStorage
    
    required init() {
        self.networkClient = SendbirdNetworkClient()
        self.userStorage = SenbirdUserStorage()
    }
    
    func initApplication(applicationId: String, apiToken: String) {
        if prevApplicationId != applicationId {
            clearUserStorage()
            saveApplicationId(applicationId)
        }
        
        networkClient.setup(applicationId: applicationId, apiToken: apiToken)
    }
    
    func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        // 생성 요청이 성공한 뒤에 캐시에 추가되어야 합니다
        let request = CreateUserRequest(params: params)
        networkClient.request(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                let user = SBUser(userId: response.userId, nickname: response.nickname, profileURL: response.profileURL)
                self?.userStorage.upsertUser(user)
                completionHandler?(.success(user))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        let maxNumberOfRequest = 10
        
        // Partial local rate limit: 초당 1명의 user를 생성해야합니다.
        let localRateLimiter = RateLimiter(label: "CreateUsers", rateLimit: (limit: 1, second: 1), capacity: maxNumberOfRequest)
        
        // 해당 함수를 한 번 호출하여 생성할 수 있는 사용자의 최대 수는 10명으로 제한해야 합니다
        guard params.count <= maxNumberOfRequest else {
            completionHandler?(.failure(SendbirdUserManagerError.userCreationLimitExceeded(maxNumberOfRequest)))
            return
        }
        
        var createdUsers: [SBUser] = []
        var failedUsers: [UserCreationParams] = []
        
        let dispatchGroup = DispatchGroup()
        
        params.forEach { param in
            dispatchGroup.enter()
            do {
                try localRateLimiter.enqueueTask { [weak self] in
                    guard let self = self else { return }
                    createUser(params: param) { result in
                        switch result {
                        case .success(let user):
                            createdUsers.append(user)
                        case .failure:
                            failedUsers.append(param)
                        }
                        dispatchGroup.leave()
                    }
                }
            } catch {
                failedUsers.append(param)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.wait()
        
        // 부분적 성공은 실패 처리를 해야하고, 성공한 유저와 성공하지 않은 유저를 구분해주어야 합니다
        guard failedUsers.isEmpty else {
            completionHandler?(.failure(SendbirdUserManagerError.usersCreationPartialFailed(failedUsers)))
            return
        }
        completionHandler?(.success(createdUsers))
    }
    
    func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
        let request = UpdateUserRequest(params: params)
        networkClient.request(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                let user = SBUser(userId: response.userId, nickname: response.nickname, profileURL: response.profileURL)
                self?.userStorage.upsertUser(user)
                completionHandler?(.success(user))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
        // 캐시에 해당 User가 있으면 캐시된 User를 반환합니다
        if let user = userStorage.getUser(for: userId) {
            completionHandler?(.success(user))
            return
        }
    
        // 캐시에 해당 User가 없으면 /GET API 호출하고 캐시에 저장합니다
        let request = GetUserRequest(userId: userId)
        networkClient.request(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                let user = SBUser(userId: response.userId, nickname: response.nickname, profileURL: response.profileURL)
                self?.userStorage.upsertUser(user)
                completionHandler?(.success(user))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        // check for a specific error related to the invalid nickname
        let filteredNickname = nicknameMatches.filter { !$0.isWhitespace }
        guard !filteredNickname.isEmpty else {
            completionHandler?(.failure(SendbirdUserManagerError.emptyNickname))
            return
        }
        
        // limit 100 고정
        let params = UserListParams(limit: "100", nickname: nicknameMatches)
        let request = GetUserListRequest(params: params)
        networkClient.request(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                let users = response.users.map {
                    SBUser(userId: $0.userId, nickname: $0.nickname, profileURL: $0.profileURL)
                }
                users.forEach { self?.userStorage.upsertUser($0) }
                completionHandler?(.success(users))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
}

extension SendbirdUserManager {
    private var userDefaults: UserDefaults { .standard }
    private var appIdKey: String { "SBApplicationId" }
    private var apiTokenKey: String { "SBApiToken" }
    private var prevApplicationId: String? { userDefaults.value(forKey: appIdKey) as? String }
    
    private func saveApplicationId(_ applicationId: String) {
        userDefaults.setValue(applicationId, forKey: appIdKey)
    }
    
    private func clearUserStorage() {
        userStorage.removeAllUsers()
    }
}
