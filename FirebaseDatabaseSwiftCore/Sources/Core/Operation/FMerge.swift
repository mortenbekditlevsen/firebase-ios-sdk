//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 09/03/2022.
//

import Foundation

public class FMerge: FOperation {
    public var source: FOperationSource
    public var type: FOperationType
    public var path: FPath
    public var children: FCompoundWrite

    public init(source: FOperationSource, path: FPath, children: FCompoundWrite) {
        self.source = source
        self.type = .merge
        self.path = path
        self.children = children
    }

    public func operationForChild(_ childKey: String) -> FOperation? {
        if path.isEmpty {
            let childTree = children.childCompoundWriteAtPath(FPath(with: childKey))
            if childTree.isEmpty {
                return nil
            } else if let rootWrite = childTree.rootWrite {
                // We have a snapshot for the child in question. This becomes an
                // overwrite of the child.
                return FOverwrite(source: source, path: .empty, snap: rootWrite)
            } else {
                // This is a merge at a deeper level
                return FMerge(source: source, path: .empty, children: childTree)
            }
        } else {
            assert(path.getFront() == childKey,
                "Can't get a merge for a child not on the path of the operation")
            return FMerge(source: source, path: path.popFront(), children: children)
        }
    }

    public var description: String {
        "FMerge { path=\(path), source=\(source) children=\(children)}"
    }
}
