//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 27/09/2022.
//

import Foundation

/** @class FIRVerifyAssertionResponse
    @brief Represents the response from the emailLinkSignin endpoint.
 */
@objc(FIREmailLinkSignInResponse) public class EmailLinkSignInResponse: NSObject, AuthRPCResponse {

    /** @property IDToken
     @brief The ID token in the email link sign-in response.
     */
    @objc public var IDToken: String?

    /** @property email
     @brief The email returned by the IdP.
     */
    @objc public var email: String?

    /** @property refreshToken
     @brief The refreshToken returned by the server.
     */
    @objc public var refreshToken: String?

    /** @property approximateExpirationDate
     @brief The approximate expiration date of the access token.
     */
    @objc public var approximateExpirationDate: Date?

    /** @property isNewUser
     @brief Flag indicating that the user signing in is a new user and not a returning user.
     */
    @objc public var isNewUser: Bool = false

    public func setFields(dictionary: [String: Any]) throws {
        self.email = dictionary["email"] as? String
        self.IDToken = dictionary["idToken"] as? String
        self.isNewUser = dictionary["isNewUser"] as? Bool ?? false
        self.refreshToken = dictionary["refreshToken"] as? String

        self.approximateExpirationDate = (dictionary["expiresIn"] as? String).flatMap({ Date(timeIntervalSinceNow: ($0 as NSString).doubleValue)
        })
    }
}
