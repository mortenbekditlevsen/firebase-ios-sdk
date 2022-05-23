//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 09/03/2022.
//

import Foundation

class FOperationSource {
    public let fromUser: Bool
    public let fromServer: Bool
    public let isTagged: Bool
    public let queryParams: FQueryParams?
    init(fromUser isFromUser: Bool, fromServer isFromServer: Bool, queryParams: FQueryParams?, tagged isTagged: Bool) {
        self.isTagged = isTagged
        self.fromUser = isFromUser
        self.fromServer = isFromServer
        self.queryParams = queryParams
    }

    public static var userInstance: FOperationSource = .init(fromUser: true,
                                                                   fromServer: false,
                                                                   queryParams: nil,
                                                                   tagged: false)

    public static var serverInstance: FOperationSource = .init(fromUser: false,
                                                                   fromServer: true,
                                                                   queryParams: nil,
                                                                   tagged: false)

    static func forServerTaggedQuery(_ params: FQueryParams) -> FOperationSource {
        .init(fromUser: false, fromServer: true, queryParams: params, tagged: true)
    }

    var description: String {
        "FOperationSource { fromUser=\(fromUser), fromServer=\(fromServer), queryParams=\(String(describing: queryParams)), tagged=\(isTagged) }"
    }
}
