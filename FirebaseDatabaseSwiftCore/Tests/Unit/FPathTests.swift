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

final class FPathTests: XCTestCase {

  func testContains() {
    XCTAssertTrue(FPath(with: "/").contains(FPath(with: "/a/b/c")))
    XCTAssertTrue(FPath(with: "/a").contains(FPath(with: "/a/b/c")))
    XCTAssertTrue(FPath(with: "/a/b").contains(FPath(with: "/a/b/c")))
    XCTAssertTrue(FPath(with: "/a/b/c").contains(FPath(with: "/a/b/c")))

    XCTAssertFalse(FPath(with: "/a/b/c").contains(FPath(with: "/a/b")))
    XCTAssertFalse(FPath(with: "/a/b/c").contains(FPath(with: "/a")))
    XCTAssertFalse(FPath(with: "/a/b/c").contains(FPath(with: "/")))

    let pieces = ["a", "b", "c"]
    let pathFromPieceNum1 = FPath(pieces: pieces, andPieceNum: 1) // represents "b/c"

    XCTAssertTrue(pathFromPieceNum1.contains(FPath(with: "/b/c")))
    XCTAssertTrue(pathFromPieceNum1.contains(FPath(with: "/b/c/d")))

    XCTAssertFalse(FPath(with: "/a/b/c").contains(FPath(with: "/b/c")))
    XCTAssertFalse(FPath(with: "/a/b/c").contains(FPath(with: "/a/c/b")))

    XCTAssertFalse(pathFromPieceNum1.contains(FPath(with: "/a/b/c")))
    XCTAssertTrue(pathFromPieceNum1.contains(FPath(with: "/b/c")))
    XCTAssertTrue(pathFromPieceNum1.contains(FPath(with: "/b/c/d")))
  }

  func testPopFront() {
    XCTAssertEqual(FPath(with: "/a/b/c").popFront(), FPath(with: "/b/c"))
    XCTAssertEqual(FPath(with: "/a/b/c").popFront().popFront(), FPath(with: "/c"))
    XCTAssertEqual(FPath(with: "/a/b/c").popFront().popFront().popFront(), FPath.empty)
    // Popping past empty is a no-op
    XCTAssertEqual(FPath(with: "/a/b/c").popFront().popFront().popFront().popFront(), FPath.empty)
  }

  func testParent() {
    XCTAssertEqual(FPath(with: "/a/b/c").parent(), FPath(with: "/a/b"))
    XCTAssertEqual(FPath(with: "/a/b/c").parent()?.parent(), FPath(with: "/a"))
    XCTAssertEqual(FPath(with: "/a/b/c").parent()?.parent()?.parent(), FPath.empty)
    XCTAssertNil(FPath(with: "/a/b/c").parent()?.parent()?.parent()?.parent())
  }

  func testWireFormat() {
    XCTAssertEqual(FPath.empty.wireFormat(), "/")
    XCTAssertEqual(FPath(with: "/a/b//c/").wireFormat(), "a/b/c")
    XCTAssertEqual(FPath(with: "/a/b//c/").popFront().wireFormat(), "b/c")
  }

  func testComparison() {
    let pathsInOrder = [
      "1", "2", "10", "a", "a/1", "a/2", "a/10", "a/a", "a/aa", "a/b", "a/b/c", "b", "b/a",
    ]
    for i in pathsInOrder.indices {
      let path1 = FPath(with: pathsInOrder[i])
      for j in (i + 1) ..< pathsInOrder.count {
        let path2 = FPath(with: pathsInOrder[j])
        XCTAssertEqual(path1.compare(path2), .orderedAscending,
                       "\(pathsInOrder[i]) should be less than \(pathsInOrder[j])")
        XCTAssertEqual(path2.compare(path1), .orderedDescending,
                       "\(pathsInOrder[j]) should be greater than \(pathsInOrder[i])")
      }
      XCTAssertEqual(path1.compare(path1), .orderedSame)
    }
  }
}
