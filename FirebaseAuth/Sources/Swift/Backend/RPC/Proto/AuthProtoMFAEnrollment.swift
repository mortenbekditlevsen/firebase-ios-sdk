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

import Foundation

 public class AuthProtoMFAEnrollment: AuthProto {
  public var phoneInfo: String?

  public var mfaEnrollmentID: String?

  public var displayName: String?

  public var enrolledAt: Date?

  public var dictionary: [String: Any]

  public required init(dictionary: [String: Any]) {
    self.dictionary = dictionary
    phoneInfo = dictionary["phoneInfo"] as? String
    mfaEnrollmentID = dictionary["mfaEnrollmentId"] as? String
    displayName = dictionary["displayName"] as? String
    if let enrolledAt = dictionary["enrolledAt"] as? String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      self.enrolledAt = dateFormatter.date(from: enrolledAt)
    }
  }
}
