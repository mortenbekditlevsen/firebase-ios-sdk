// Copyright 2017 Google LLC
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

import XCTest
@testable import FirebaseDatabaseSwiftCore

final class FRepoInfoTests: XCTestCase {

  func testGetConnectionURL() {
    let info = FRepoInfo(host: "test-namespace.example.com", isSecure: false,
                         withNamespace: "tests")
    XCTAssertEqual(info.connectionURL,
                   "ws://test-namespace.example.com/.ws?v=5&ns=tests")
  }

  func testGetConnectionURLWithLastSession() {
    let info = FRepoInfo(host: "tests-namespace.example.com", isSecure: false,
                         withNamespace: "tests")
    XCTAssertEqual(info.connectionURL(lastSessionID: "testsession"),
                   "ws://tests-namespace.example.com/.ws?v=5&ns=tests&ls=testsession")
  }

  func testSecureURL() {
    let info = FRepoInfo(host: "myproject.firebaseio.com", isSecure: true,
                         withNamespace: "myproject")
    XCTAssertTrue(info.connectionURL.hasPrefix("wss://"))
  }
}
