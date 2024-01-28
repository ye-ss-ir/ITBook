//
//  RateLimiter.swift
//
//
//  Created by yes on 1/27/24.
//

import Foundation

enum RateLimiterError: LocalizedError {
    case tooManyRequests
    var errorDescription: String? {
        switch self {
        case .tooManyRequests: return "너무 많은 요청이 발생했습니다."
        }
    }
}

final class RateLimiter {
    typealias Rate = (limit: Int, second: TimeInterval)
    typealias TaskBlock = () -> Void
    var rateLimit: Rate
    var capacity: Int
    
    private let executionDispatchQueue: DispatchQueue
    
    private var taskQueue: [TaskBlock] = []
    private var isFull: Bool { taskQueue.count == capacity }
    private var lastUpdateTime = Date.distantPast
    
    init(label: String, rateLimit: Rate, capacity: Int) {
        self.rateLimit = rateLimit
        self.capacity = capacity
        self.executionDispatchQueue = DispatchQueue(label: "com.SendbirdUserManager.RateLimiter.\(label)")
    }
    
    func enqueueTask(_ task: @escaping TaskBlock) throws {
        var enqueueSuccess = false
        executionDispatchQueue.sync(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            guard !isFull else {
                return
            }
            
            taskQueue.append(task)
            enqueueSuccess = true
            processTask(task)
        }
        
        guard enqueueSuccess else {
            throw RateLimiterError.tooManyRequests
        }
    }
    
    private func dequeueTask(after interval: TimeInterval) {
        for _ in 0..<rateLimit.limit {
            executionDispatchQueue.asyncAfter(deadline: DispatchTime.now() + interval, flags: .barrier) { [weak self] in
                let task = self?.taskQueue.removeFirst()
                task?()
            }
        }
    }
    
    private func processTask(_ task: @escaping TaskBlock) {
        let currentTime = Date()
        let scheduledTime = lastUpdateTime.addingTimeInterval(rateLimit.second)
        if currentTime > scheduledTime {
            lastUpdateTime = currentTime
            dequeueTask(after: 0)
        } else {
            lastUpdateTime = scheduledTime
            let timeInterval = scheduledTime.timeIntervalSince(Date())
            dequeueTask(after: timeInterval)
        }
    }
}
