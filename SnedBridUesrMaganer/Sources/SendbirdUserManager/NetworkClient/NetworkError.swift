//
//  NetworkError.swift
//
//
//  Created by yes on 1/27/24.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case invalidHttpStatusCode(Int)
    case emptyData
    case serverErrorMessage(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "서버 응답이 HTTPURLResponse로 캐스팅되지 않았습니다."
        case .invalidHttpStatusCode: return "status코드가 200~299가 아닙니다."
        case .emptyData: return "data가 비어있습니다."
        case .serverErrorMessage(let message): return message
        }
    }
}
