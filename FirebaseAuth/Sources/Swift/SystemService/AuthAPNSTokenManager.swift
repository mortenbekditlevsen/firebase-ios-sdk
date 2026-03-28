// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if os(iOS) 
  import Foundation
  import UIKit

  // TODO: This may be needed for extension detecting support
  // @_implementationOnly //import FirebaseCoreExtension

//  #if SWIFT_PACKAGE
//    @_implementationOnly import GoogleUtilities_Environment
//  #else
//    @_implementationOnly import GoogleUtilities
//  #endif // SWIFT_PACKAGE

  public protocol AuthAPNSTokenApplication {
    func registerForRemoteNotifications()
  }

  extension UIApplication: AuthAPNSTokenApplication {}

  // TODO: remove objc public here and below after Sample ported.
  /** @class AuthAPNSToken
      @brief A data structure for an APNs token.
   */
  @available(iOS 13, tvOS 13, macOS 10.15, macCatalyst 13, watchOS 7, *)
   public class AuthAPNSTokenManager {
    /** @property timeout
        @brief The timeout for registering for remote notification.
        @remarks Only tests should access this property.
     */
    var timeout: TimeInterval = 5

    /** @fn initWithApplication:
        @brief Initializes the instance.
        @param application The @c UIApplication to request the token from.
        @return The initialized instance.
     */
    init(withApplication application: AuthAPNSTokenApplication) {
      self.application = application
    }

    /** @fn getTokenWithCallback:
        @brief Attempts to get the APNs token.
        @param callback The block to be called either immediately or in future, either when a token
            becomes available, or when timeout occurs, whichever happens earlier.
     */
    public func getToken(callback: @escaping (AuthAPNSToken?, Error?) -> Void) {
      if failFastForTesting {
        let error = NSError(domain: "dummy domain", code: AuthErrorCode.missingAppToken.rawValue)
        callback(nil, error)
        return
      }
      if let token = tokenStore {
        callback(token, nil)
        return
      }
      if pendingCallbacks.count > 0 {
        pendingCallbacks.append(callback)
        return
      }
      pendingCallbacks = [callback]

      DispatchQueue.main.async {
        self.application.registerForRemoteNotifications()
      }
      let applicableCallbacks = pendingCallbacks
      let deadline = DispatchTime.now() + timeout
      kAuthGlobalWorkQueue.asyncAfter(deadline: deadline) {
        // Only cancel if the pending callbacks remain the same, i.e., not triggered yet.
        if applicableCallbacks.count == self.pendingCallbacks.count {
          self.callback(withToken: nil, error: nil)
        }
      }
    }

    /** @property token
        @brief The APNs token, if one is available.
        @remarks Setting a token with AuthAPNSTokenTypeUnknown will automatically converts it to
            a token with the automatically detected type.
     */
    public var token: AuthAPNSToken? {
      get {
        return tokenStore
      }
      set(setToken) {
        guard let setToken else {
          tokenStore = nil
          return
        }
        var newToken = setToken
        if setToken.type == AuthAPNSTokenType.unknown {
          let detectedTokenType = isProductionApp() ? AuthAPNSTokenType.prod : AuthAPNSTokenType
            .sandbox
          newToken = AuthAPNSToken(withData: setToken.data, type: detectedTokenType)
        }
        tokenStore = newToken
        callback(withToken: newToken, error: nil)
      }
    }

    // Should only be written to in tests
    var tokenStore: AuthAPNSToken?

    /** @fn cancelWithError:
        @brief Cancels any pending `getTokenWithCallback:` request.
        @param error The error to return.
     */
    func cancel(withError error: Error) {
      callback(withToken: nil, error: error)
    }

    var failFastForTesting: Bool = false

    // `application` is a var to enable unit test faking.
    var application: AuthAPNSTokenApplication
    private var pendingCallbacks: [(AuthAPNSToken?, Error?) -> Void] = []

    private func callback(withToken token: AuthAPNSToken?, error: Error?) {
      let pendingCallbacks = self.pendingCallbacks
      self.pendingCallbacks = []
      for callback in pendingCallbacks {
        callback(token, error)
      }
    }

    private func isProductionApp() -> Bool {
      let defaultAppTypeProd = true

      #if targetEnvironment(simulator)
      AuthLog.logInfo(code: "I-AUT000006", message: "Assuming prod APNs token type on simulator.")
      return defaultAppTypeProd
      #endif

      // Apps distributed via TestFlight use the Production APNs certificates.
      if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
        return defaultAppTypeProd
      }

      // Check for embedded provisioning profile to detect development builds.
      let path = Bundle.main.bundlePath + "/embedded.mobileprovision"
      guard FileManager.default.fileExists(atPath: path) else {
        AuthLog.logInfo(code: "I-AUT000007", message: "\(path) does not exist")
        return defaultAppTypeProd
      }
      do {
        let profileData = try Data(contentsOf: URL(fileURLWithPath: path))

        // The "embedded.mobileprovision" is DER-encoded and may contain null bytes
        // (0x00) or non-ASCII bytes (>127) that break string parsing. Replace them
        // with '.' so the XML plist section can be extracted as a UTF-8 string.
        let sanitized = profileData.map { ($0 == 0 || $0 > 127) ? UInt8(46) : $0 }
        guard let embeddedProfile = String(bytes: sanitized, encoding: .utf8) else {
          AuthLog.logInfo(code: "I-AUT000008",
                          message: "Failed to convert embedded mobileprovision to String")
          return defaultAppTypeProd
        }

        // Locate the plist section embedded in the provisioning profile.
        guard let plistStart = embeddedProfile.range(of: "<plist"),
              let plistEnd = embeddedProfile.range(
                of: "</plist>",
                range: plistStart.upperBound ..< embeddedProfile.endIndex
              )
        else {
          AuthLog.logInfo(code: "I-AUT000009",
                          message: "Couldn't locate plist in embedded mobileprovision")
          return defaultAppTypeProd
        }
        let plistString = String(embeddedProfile[plistStart.lowerBound ..< plistEnd.upperBound])

        guard let plistData = plistString.data(using: .utf8),
              let plistMap = try? PropertyListSerialization.propertyList(
                from: plistData, options: [], format: nil
              ) as? [String: Any]
        else {
          AuthLog.logInfo(code: "I-AUT000010",
                          message: "Error converting embedded mobileprovision plist to dictionary")
          return defaultAppTypeProd
        }

        guard let entitlements = plistMap["Entitlements"] as? [String: Any],
              let apsEnvironment = entitlements["aps-environment"] as? String
        else {
          AuthLog.logInfo(code: "I-AUT000013",
                          message: "No aps-environment set. If testing on a device APNs is not " +
                            "correctly configured. Please recheck your provisioning profiles.")
          return defaultAppTypeProd
        }

        AuthLog.logInfo(code: "I-AUT000012", message: "APNs environment in profile: \(apsEnvironment)")
        return apsEnvironment != "development"
      } catch {
        AuthLog.logInfo(code: "I-AUT000008",
                        message: "Error while reading embedded mobileprovision: \(error)")
        return defaultAppTypeProd
      }
    }
  }
#endif
