//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 28/10/2022.
//

import Foundation

#if os(iOS)

/**
   @brief The opaque session identifier for the current sign-in flow.
*/
var session: MultiFactorSession?

@objc public protocol AuthWrapper: NSObjectProtocol { }

//@objc(FIRMultiFactorResolver) public class MultiFactorResolver: NSObject {
//
//    /**
//       @brief The list of hints for the second factors needed to complete the sign-in for the current
//           session.
//    */
//    @objc public var hints: [MultiFactorInfo]
//
//    /**
//       @brief The Auth reference for the current FIRMultiResolver.
//    */
//    @objc public var auth: AuthWrapper
//
//
//    /** @fn resolveSignInWithAssertion:completion:
//        @brief A helper function to help users complete sign in with a second factor using an
//            FIRMultiFactorAssertion confirming the user successfully completed the second factor
//       challenge.
//        @param completion The block invoked when the request is complete, or fails.
//    */
//    @objc public func resolveSignIn(assertion: MultiFactorAssertion) async throws -> AuthDataResultWrapper {
//
//    }
//}

#endif
