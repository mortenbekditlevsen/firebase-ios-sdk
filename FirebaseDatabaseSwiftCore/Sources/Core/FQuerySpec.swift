//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 03/03/2022.
//

import Foundation

public struct FQuerySpec: Hashable {
    public let path: FPath
    public let params: FQueryParams
    public init(path: FPath, params: FQueryParams) {
        self.params = params
        self.path = path
    }

    public static func defaultQueryAtPath(_ path: FPath) -> FQuerySpec {
        FQuerySpec(path: path, params: .defaultInstance)
    }

    public var index: FIndex {
        params.index
    }
    public var isDefault: Bool {
        params.isDefault
    }
    public var loadsAllData: Bool {
        params.loadsAllData
    }

    public var description: String {
        "FQuerySpec (path: \(path), params: \(params)"
    }
}
