//
//  File 2.swift
//  
//
//  Created by Morten Bek Ditlevsen on 26/06/2022.
//

import Foundation

/**
    @brief Represents user data returned from an identity provider.
 */
@objc(FIRUserInfo) public protocol UserInfo: NSObjectProtocol {
    /** @property providerID
     @brief The provider identifier.
     */
    var providerID: String { get }

    /** @property uid
     @brief The provider's user ID for the user.
     */
    var uid: String { get }

    /** @property displayName
     @brief The name of the user.
     */
    var displayName: String? { get }

    /** @property photoURL
        @brief The URL of the user's profile photo.
     */
    var photoURL: URL? { get }

    /** @property email
        @brief The user's email address.
     */
    var email: String? { get }

    /** @property phoneNumber
        @brief A phone number associated with the user.
        @remarks This property is only available for users authenticated via phone number auth.
     */
    var phoneNumber: String? { get }
}
