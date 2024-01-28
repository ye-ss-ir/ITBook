//
//  SBNetworkClient.swift
//
//
//  Created by yes on 1/25/24.
//

import Foundation

public protocol SBNetworkClient {
    init()
    func setup(applicationId: String, apiToken: String)
    /// 리퀘스트를 요청하고 리퀘스트에 대한 응답을 받아서 전달합니다
    func request<R: Request>(
        request: R,
        completionHandler: @escaping (Result<R.Response, Error>) -> Void
    )
}
