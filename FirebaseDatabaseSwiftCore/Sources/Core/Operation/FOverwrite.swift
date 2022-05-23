//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 09/03/2022.
//

import Foundation

class FOverwrite: FOperation {
    var source: FOperationSource
    var type: FOperationType
    var path: FPath
    public let snap: FNode

    init(source: FOperationSource, path: FPath, snap: FNode) {
        self.source = source
        self.type = .overwrite
        self.path = path
        self.snap = snap
    }
    func operationForChild(_ childKey: String) -> FOperation? {
        if path.isEmpty {
            return FOverwrite(source: source, path: .empty, snap: snap.getImmediateChild(childKey))
        } else {
            return FOverwrite(source: source, path: path.popFront(), snap: snap)
        }
    }

    var description: String {
        "FOverwrite { path=\(path), source=\(source), snapshot=\(snap) }"
    }
}
