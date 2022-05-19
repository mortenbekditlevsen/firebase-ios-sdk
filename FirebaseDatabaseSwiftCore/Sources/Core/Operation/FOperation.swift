//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 09/03/2022.
//

import Foundation

public enum FOperationType: Int {
    case overwrite = 0
    case merge = 1
    case ackUserWrite = 2
    case listenComplete = 3
}

public protocol FOperation {
    var source: FOperationSource { get }
    var type: FOperationType { get }
    var path: FPath { get }
    func operationForChild(_ childKey: String) -> FOperation?
}
