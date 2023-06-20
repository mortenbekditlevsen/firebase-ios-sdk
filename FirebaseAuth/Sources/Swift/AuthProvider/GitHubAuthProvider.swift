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

/**
 @brief Utility class for constructing GitHub Sign In credentials.
 */
@available(iOS 13, tvOS 13, macOS 10.15, macCatalyst 13, watchOS 7, *)
 open class GitHubAuthProvider {
  public static let id = "github.com"

  /**
      @brief Creates an `AuthCredential` for a GitHub sign in.

      @param token The GitHub OAuth access token.
      @return An AuthCredential containing the GitHub credentials.
   */
  public class func credential(withToken token: String) -> AuthCredential {
    return GitHubAuthCredential(withToken: token)
  }

  @available(*, unavailable)
   public init() {
    fatalError("This class is not meant to be initialized.")
  }
}

@available(iOS 13, tvOS 13, macOS 10.15, macCatalyst 13, watchOS 7, *)
class GitHubAuthCredential: AuthCredential, Codable {
  let token: String

  init(withToken token: String) {
    self.token = token
    super.init(provider: GitHubAuthProvider.id)
  }

  override func prepare(_ request: VerifyAssertionRequest) {
    request.providerAccessToken = token
  }

    enum CodingKeys: CodingKey {
        case token
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.token, forKey: .token)
    }


    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.token = try container.decode(String.self, forKey: .token)

        super.init(provider: GitHubAuthProvider.id)

    }
}
