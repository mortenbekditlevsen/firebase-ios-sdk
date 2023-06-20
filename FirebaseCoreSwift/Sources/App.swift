//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 20/06/2023.
//

import Foundation

// Dummy protocol since I don't have heartbeatlogger working yet
public protocol FIRHeartbeatLoggerProtocol {

}

// Dummy protocol since I don't have AppCheck working yet
public protocol AppCheckInterop {
    func getToken(forcingRefresh: Bool, callback: (Result<String, Error>) -> Void)

}

public class FirebaseApp {
    public var options: FirebaseAppOptions = .init()
    public var name: String = ""
    private static var shared: FirebaseApp = .init()
    public static func app() -> FirebaseApp? { shared }
    public var heartbeatLogger: FIRHeartbeatLoggerProtocol? = nil
}

public class FirebaseAppOptions {
    public var apiKey: String? = ""
    public var name: String? = ""
    public var clientID: String? = ""
    public var googleAppID: String = ""
}

public protocol AuthInterop {
    func getToken(forcingRefresh forceRefresh: Bool,
                         completion callback: @escaping (String?, Error?) -> Void)

    func getUserID() -> String?
}
