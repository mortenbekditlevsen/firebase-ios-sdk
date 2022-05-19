//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 09/03/2022.
//

import Foundation

public class FSnapshotHolder {
    public var rootNode = FEmptyNode.emptyNode

    public init() {}

    public func getNode(_ path: FPath) -> FNode {
        rootNode.getChild(path)
    }

    public func updateSnapshot(_ path: FPath, withNewSnapshot newSnapshotNode: FNode) {
        self.rootNode = self.rootNode.updateChild(path, withNewChild: newSnapshotNode)
    }
}
