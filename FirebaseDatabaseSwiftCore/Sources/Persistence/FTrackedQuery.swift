//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 03/03/2022.
//

import Foundation

public struct FTrackedQuery: Hashable {
    public let queryId: Int
    public let query: FQuerySpec
    public let lastUse: TimeInterval
    public let isComplete: Bool
    public let isActive: Bool

    public init(id queryId: Int, query: FQuerySpec, lastUse: TimeInterval, isActive: Bool, isComplete: Bool) {
        self.queryId = queryId
        self.query = query
        self.lastUse = lastUse
        self.isActive = isActive
        self.isComplete = isComplete
    }

    public init(id queryId: Int, query: FQuerySpec, lastUse: TimeInterval, isActive: Bool) {
        self.queryId = queryId
        self.query = query
        self.lastUse = lastUse
        self.isActive = isActive
        self.isComplete = false
    }

    public func updateLastUse(_ lastUse: TimeInterval) -> FTrackedQuery {
        .init(id: queryId, query: query, lastUse: lastUse, isActive: isActive, isComplete: isComplete)
    }

    public func setComplete() -> FTrackedQuery {
        .init(id: queryId, query: query, lastUse: lastUse, isActive: isActive, isComplete: true)
    }

    public func setActiveState(_ isActive: Bool) -> FTrackedQuery {
        .init(id: queryId, query: query, lastUse: lastUse, isActive: isActive, isComplete: true)
    }
}
