//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 09/03/2022.
//

import Foundation

public class FViewCache {
    public let cachedEventSnap: FCacheNode
    public var completeEventSnap: FNode? {
        cachedEventSnap.isFullyInitialized ? cachedEventSnap.node : nil
    }

    public let cachedServerSnap: FCacheNode
    public var completeServerSnap: FNode? {
        cachedServerSnap.isFullyInitialized
                   ? cachedServerSnap.node
                   : nil
    }

    public init(eventCache: FCacheNode, serverCache: FCacheNode) {
        self.cachedEventSnap = eventCache
        self.cachedServerSnap = serverCache
    }
    public func updateEventSnap(_ eventSnap: FIndexedNode, isComplete: Bool, isFiltered: Bool) -> FViewCache {
        let updatedEventCache = FCacheNode(indexedNode: eventSnap,
                                           isFullyInitialized: isComplete,
                                           isFiltered: isFiltered)
        return FViewCache(eventCache: updatedEventCache,
                          serverCache: cachedServerSnap)

    }
    public func updateServerSnap(_ serverSnap: FIndexedNode, isComplete: Bool, isFiltered: Bool) -> FViewCache {
        let updatedServerCache = FCacheNode(indexedNode: serverSnap,
                                            isFullyInitialized: isComplete,
                                            isFiltered: isFiltered)
        return FViewCache(eventCache: cachedEventSnap,
                          serverCache: updatedServerCache)

    }
}
