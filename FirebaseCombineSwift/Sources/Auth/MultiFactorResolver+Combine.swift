// Copyright 2020 Google LLC
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

#if canImport(Combine) && swift(>=5.0) && canImport(FirebaseAuth)
  import Foundation

  import Combine
  import FirebaseAuth

  @available(swift 5.0)
  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
  extension MultiFactorResolver {
    /// A helper function to help users complete sign in with a second factor using an
    /// `MultiFactorAssertion` confirming the user successfully completed the second factor
    ///
    /// - Parameter assertion: The base class for asserting ownership of a second factor.
    /// - Returns: A publisher that emits an `AuthDataResult` when the sign-in flow completed
    ///   successfully, or an error otherwise.
    public func resolveSignIn(with assertion: MultiFactorAssertion)
      -> Future<AuthDataResult, Error> {
      Future<AuthDataResult, Error> { promise in
        self.resolveSignIn(with: assertion) { authDataResult, error in
          if let error = error {
            promise(.failure(error))
          } else if let authDataResult = authDataResult {
            promise(.success(authDataResult))
          }
        }
      }
    }
  }
#endif
