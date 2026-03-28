//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 20/06/2023.
//

import Foundation

// Dummy protocol since I don't have heartbeatlogger working yet
public protocol FIRHeartbeatLoggerProtocol: Sendable {

}

// Dummy protocol since I don't have AppCheck working yet
public protocol AppCheckInterop: Sendable {
    func getToken(forcingRefresh: Bool) async throws -> String

}

public class FirebaseApp: Equatable {
    public static func == (lhs: FirebaseApp, rhs: FirebaseApp) -> Bool {
        lhs.name == rhs.name && lhs.options == rhs.options
    }

    public struct Options: Equatable {
        public init(databaseURL: String? = nil, projectID: String? = nil, googleAppID: String, apiKey: String?, clientID: String?) {
            self.databaseURL = databaseURL
            self.projectID = projectID
            self.googleAppID = googleAppID
            self.apiKey = apiKey
            self.clientID = clientID
        }

        public var databaseURL: String?
        public var projectID: String?
        public var googleAppID: String
        public var apiKey: String?
        public var clientID: String?
    }
    public var auth: AuthInterop?
    public var name: String
    public var options: Options
    public init(options: Options, name: String) {
        self.options = options
        self.name = name
    }
    public var heartbeatLogger: FIRHeartbeatLoggerProtocol?
    public static var isDefaultAppConfigured: Bool { defaultApp != nil }
    public static func configure(name: String? = nil, options: Options) {
        defaultApp = FirebaseApp(options: options, name: name ?? "[DEFAULT]")
    }
    public static private(set) var defaultApp: FirebaseApp?
}

@MainActor
public protocol AuthInterop: AnyObject {
    func getToken(forcingRefresh forceRefresh: Bool) async throws -> String?
    func getUserID() -> String?
}
