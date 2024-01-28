//
//  NetworkClientBaseTests.swift
//
//
//  Created by kakaoent on 1/28/24.
//

import XCTest
@testable import SendbirdUserManager

open class NetworkClientBaseTests: XCTestCase {
    open func networkClientType() -> SBNetworkClient.Type! {
        nil
    }
    
    let applicationId = "70CF63EC-9E52-432A-AB6A-4AA3FD585FF3"   // Note: add an application ID
    let apiToken = "6bfe3fdb2e96a0e9187e7d4a7b183fc2239c622f"        // Note: add an API Token
    
    func testSetup() {
        let networkClient = networkClientType().init()
        let params = UserCreationParams(userId: UUID().uuidString, nickname: UUID().uuidString, profileURL: "")
        let userCreationRequest = CreateUserRequest(params: params)
        
        let expectation = self.expectation(description: "Wait for result")
        networkClient.request(request: userCreationRequest) { result in
            switch result {
            case .success:
                XCTFail("failure expected. setup 먼저 해야함!")
            case .failure(let error):
                print(error.localizedDescription)
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testRequest() {
        let networkClient = networkClientType().init()
        networkClient.setup(applicationId: applicationId, apiToken: apiToken)
        
        let params = UserCreationParams(userId: UUID().uuidString, nickname: UUID().uuidString, profileURL: "")
        let userCreationRequest = CreateUserRequest(params: params)
        
        let expectation = self.expectation(description: "Wait for result")
        networkClient.request(request: userCreationRequest) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testThreadSafety() {
        let networkClient = networkClientType().init()
        networkClient.setup(applicationId: applicationId, apiToken: apiToken)
        
        let expectation = expectation(description: "Wait for all requests done")
        expectation.expectedFulfillmentCount = 1000
        
        for _ in 0..<expectation.expectedFulfillmentCount {
            DispatchQueue.global().async {
                let params = UserCreationParams(userId: UUID().uuidString, nickname: UUID().uuidString, profileURL: "")
                let userCreationRequest = CreateUserRequest(params: params)
                
                networkClient.request(request: userCreationRequest) { result in
                    switch result {
                    case .success:
                        print("success \(Date())")
                    case .failure(let error):
                        print("failure \(error)")
                    }
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 30.0)
        XCTAssert(true, "👏👏 app is alive 👏👏")
    }
}
