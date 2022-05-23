//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 12/03/2022.
//

import Foundation

class FListenComplete: FOperation {
    var source: FOperationSource
    var path: FPath
    var type: FOperationType
    init(source: FOperationSource, path: FPath) {
        assert(!source.fromUser,
                 "Can't have a listen complete from a user source")
        self.source = source
        self.path = path
        self.type = .listenComplete
    }

    func operationForChild(_ childKey: String) -> FOperation? {
        if path.isEmpty {
            return FListenComplete(source: source, path: .empty)
        } else {
            return FListenComplete(source: source, path: path.popFront())
        }
    }
    var description: String {
        "FListenComplete { path=\(path), source=\(source) }"
    }
}
