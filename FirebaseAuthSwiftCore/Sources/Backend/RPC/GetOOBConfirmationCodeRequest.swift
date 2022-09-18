//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 02/07/2022.
//

import Foundation

enum GetOOBConfirmationCodeRequestType: Int {
    /** @var FIRGetOOBConfirmationCodeRequestTypePasswordReset
        @brief Requests a password reset code.
     */
    case passwordReset

    /** @var FIRGetOOBConfirmationCodeRequestTypeVerifyEmail
        @brief Requests an email verification code.
     */
    case verifyEmail

    /** @var FIRGetOOBConfirmationCodeRequestTypeEmailLink
        @brief Requests an email sign-in link.
     */
    case emailLink

    /** @var FIRGetOOBConfirmationCodeRequestTypeVerifyBeforeUpdateEmail
        @brief Requests an verify before update email.
     */
    case verifyBeforeUpdateEmail
}

@objc(FIRGetOOBConfirmationCodeRequest) public class GetOOBConfirmationCodeRequest: IdentityToolkitRequest, AuthRPCRequest {
    /** @property requestType
        @brief The types of OOB Confirmation Code to request.
     */
    let requestType: GetOOBConfirmationCodeRequestType

    /** @property email
        @brief The email of the user.
        @remarks For password reset.
     */
    var email: String?

    /** @property updatedEmail
        @brief The new email to be updated.
        @remarks For verifyBeforeUpdateEmail.
     */
    var updatedEmail: String?

    /** @property accessToken
        @brief The STS Access Token of the authenticated user.
        @remarks For email change.
     */
    var accessToken: String?

    /** @property continueURL
        @brief This URL represents the state/Continue URL in the form of a universal link.
     */
    var continueURL: String?

    /** @property iOSBundleID
        @brief The iOS bundle Identifier, if available.
     */
    var iOSBundleID: String?

    /** @property androidPackageName
        @brief The Android package name, if available.
     */
    var androidPackageName: String?

    /** @property androidMinimumVersion
        @brief The minimum Android version supported, if available.
     */
    var androidMinimumVersion: String?

    /** @property androidInstallIfNotAvailable
        @brief Indicates whether or not the Android app should be installed if not already available.
     */
    var androidInstallApp: Bool

    /** @property handleCodeInApp
        @brief Indicates whether the action code link will open the app directly or after being
            redirected from a Firebase owned web widget.
     */
    var handleCodeInApp: Bool

    /** @property dynamicLinkDomain
        @brief The Firebase Dynamic Link domain used for out of band code flow.
     */
    var dynamicLinkDomain: String?

}
