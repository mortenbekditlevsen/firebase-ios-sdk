//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 28/10/2022.
//

import Foundation

#if os(iOS)
private let kUIDCodingKey = "uid"

private let kDisplayNameCodingKey = "displayName"

private let kEnrollmentDateCodingKey = "enrollmentDate"

private let kFactorIDCodingKey = "factorID"

@objc(FIRMultiFactorSession) public class MultiFactorSession: NSObject {

    // XXX TODO SHOULD BE INTERNAL
    @objc public var IDToken: String?

    // XXX TODO SHOULD BE INTERNAL
    @objc public var MFAPendingCredential: String?

    // XXX TODO SHOULD BE INTERNAL
    @objc public var multiFactorInfo: MultiFactorInfo?

    @objc public static var sessionForCurrentUser: MultiFactorSession {
        /// XXX TODO: Fix WHEN ALL IS CONVERTED
//        let currentUser = Auth.auth().currentUser
//        let idToken = currentUser.rawAccessToken
        let idToken: String? = nil
        return .init(IDToken: idToken)
    }

    @objc public init(IDToken: String?) {
        self.IDToken = IDToken
    }
}

#endif
