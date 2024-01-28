//
//  SendbirdNetworkClient.swift
//
//
//  Created by yes on 1/22/24.
//

import Foundation

enum SendbirdNetworkClientError: LocalizedError {
    case setupRequired
    var errorDescription: String? {
        switch self {
        case .setupRequired: return "setup(applicationId:apiToken:)으로 필수 데이터를 설정해주세요."
        }
    }
}


final class SendbirdNetworkClient: SBNetworkClient {
    private var applicationId: String?
    private var apiToken: String?
    private let globalRateLimiter = RateLimiter(label: "SendbirdNetworkClient", rateLimit: (limit: 1, second: 1), capacity: 10)
    
    required init() {}
    
    func setup(applicationId: String, apiToken: String) {
        self.applicationId = applicationId
        self.apiToken = apiToken
    }
    
    // 해당 리퀘스트를 요청하고 리퀘스트에 대한 응답을 받아서 전달합니다
    func request<R>(request: R, completionHandler: @escaping (Result<R.Response, Error>) -> Void) where R : Request {
        do {
            guard let applicationId = applicationId,
                  let apiToken = apiToken else {
                throw SendbirdNetworkClientError.setupRequired
            }
            
            let urlRequest = try request.asURLRequest(withApplicationId: applicationId, apiToken: apiToken)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
                guard let self = self else { return }
                do {
                    let responseObject: R.Response = try getErrorHandledResponseObject(data, response, error)
                    completionHandler(.success(responseObject))
                } catch {
                    completionHandler(.failure(error))
                }
            }
            
            try globalRateLimiter.enqueueTask {
                dataTask.resume()
            }
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    private func getErrorHandledResponseObject<T: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) throws -> T {
        if let error = error {
            throw error
        }
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(response.statusCode) else {
            throw NetworkError.invalidHttpStatusCode(response.statusCode)
        }
        guard let data = data else {
            throw NetworkError.emptyData
        }
        
        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data),
           errorResponse.error {
            throw NetworkError.serverErrorMessage(errorResponse.message)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
