//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 19/02/2022.
//

import Foundation


public class FCacheNode {
  public var isFullyInitialized: Bool
  public var isFiltered: Bool
  public var indexedNode: FIndexedNode
    public var indexedNodeObjC: FIndexedNodeObjC {
        .init(wrapped: indexedNode)
    }
  public var node: FNode {
    indexedNode.node
  }
  public init(indexedNode: FIndexedNode, isFullyInitialized: Bool, isFiltered: Bool) {
    self.indexedNode = indexedNode
    self.isFiltered = isFiltered
    self.isFullyInitialized = isFullyInitialized
  }

  public func isComplete(forPath path: FPath) -> Bool {
    if let childKey = path.getFront() {
      return isComplete(forChild: childKey)
    } else { // path is empty
      return isFullyInitialized && !isFiltered
    }
  }

  public func isComplete(forChild childKey: String) -> Bool {
    (isFullyInitialized && !isFiltered) || node.hasChild(childKey)
  }
}
