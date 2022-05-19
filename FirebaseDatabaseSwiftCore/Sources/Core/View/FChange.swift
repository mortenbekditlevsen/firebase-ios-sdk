//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 27/02/2022.
//

import Foundation

public class FChange {
    public let type: DataEventType
    public let indexedNode: FIndexedNode
    public let childKey: String?
    public let prevKey: String?
    public let oldIndexedNode: FIndexedNode?
    public var indexedNodeObjC: FIndexedNodeObjC {
        .init(wrapped: indexedNode)
    }

    init(type: DataEventType, indexedNode: FIndexedNode) {
        self.type = type
        self.indexedNode = indexedNode
        self.childKey = nil
        self.oldIndexedNode = nil
        self.prevKey = nil
    }

    init(type: DataEventType, indexedNode: FIndexedNode, childKey: String?) {
        self.type = type
        self.indexedNode = indexedNode
        self.childKey = childKey
        self.oldIndexedNode = nil
        self.prevKey = nil
    }

    init(type: DataEventType, indexedNode: FIndexedNode, childKey: String?, oldIndexedNode: FIndexedNode?) {
        self.type = type
        self.indexedNode = indexedNode
        self.childKey = childKey
        self.oldIndexedNode = oldIndexedNode
        self.prevKey = nil
    }

    private init(type: DataEventType, indexedNode: FIndexedNode, childKey: String?, oldIndexedNode: FIndexedNode?, prevKey: String?) {
        self.type = type
        self.indexedNode = indexedNode
        self.childKey = childKey
        self.oldIndexedNode = oldIndexedNode
        self.prevKey = prevKey
    }

    public func change(prevKey: String?) -> FChange {
        FChange(type: type,
                indexedNode: indexedNode,
                childKey: childKey,
                oldIndexedNode: oldIndexedNode,
                prevKey: prevKey)
    }

    public var description: String {
        "event: \(type.rawValue), data: \(indexedNode.node.val())"
    }
    
    public var debugDescription: String {
        "event: \(type.rawValue), data: \(indexedNode.node.val())"
    }
}

/*


 */
