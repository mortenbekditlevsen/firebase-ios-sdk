// Copyright 2021 Google LLC
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

// Swift replaces the ObjC constants with language-level equivalents.
private let minPushChar = String(MIN_PUSH_CHAR)  // " " (space / 0x20)
private let maxPushChar = String(MAX_PUSH_CHAR)  // "z"

final class FNextPushIdTests: XCTestCase {

  func testSuccessorSpecialValues() {
    let maxIntegerKeySuccessor = FNextPushId.successor("\(Int32.max)")
    XCTAssertEqual(maxIntegerKeySuccessor, minPushChar,
                   "successor(Int32.max) == MIN_PUSH_CHAR")

    let maxKey = String(repeating: maxPushChar, count: MAX_KEY_LEN)
    let maxKeySuccessor = FNextPushId.successor(maxKey)
    XCTAssertEqual(maxKeySuccessor, FUtilities.maxName,
                   "successor(maxKey) == MAX_NAME")
  }

  func testSuccessorBasic() {
    let actual1 = FNextPushId.successor("abc")
    let expected1 = "abc" + minPushChar
    XCTAssertEqual(expected1, actual1, "successor(abc) == abc + MIN_PUSH_CHAR")

    let longKey = "abc" + String(repeating: maxPushChar, count: MAX_KEY_LEN - 3)
    let actual2 = FNextPushId.successor(longKey)
    XCTAssertEqual("abd", actual2,
                   "successor(abc + MAX_PUSH_CHAR * (MAX_KEY_LEN-3)) == abd")

    let actual3 = FNextPushId.successor("abc" + minPushChar)
    let expected3 = "abc" + minPushChar + minPushChar
    XCTAssertEqual(expected3, actual3, "successor(abc + MIN_PUSH_CHAR) == abc + MIN_PUSH_CHAR + MIN_PUSH_CHAR")
  }

  func testPredecessorSpecialValues() {
    let actual1 = FNextPushId.predecessor(minPushChar)
    let expected1 = "\(Int32.max)"
    XCTAssertEqual(expected1, actual1, "predecessor(MIN_PUSH_CHAR) == Int32.max")

    let actual2 = FNextPushId.predecessor("\(Int32.min)")
    XCTAssertEqual(FUtilities.minName, actual2, "predecessor(Int32.min) == MIN_NAME")
  }

  func testPredecessorBasic() {
    let actual1 = FNextPushId.predecessor("abc")
    let expected1 = "abb" + String(repeating: maxPushChar, count: MAX_KEY_LEN - 3)
    XCTAssertEqual(expected1, actual1,
                   "predecessor(abc) = abb + MAX_PUSH_CHAR * (MAX_KEY_LEN-3)")

    let actual2 = FNextPushId.predecessor("abc" + minPushChar)
    XCTAssertEqual("abc", actual2, "predecessor(abc + MIN_PUSH_CHAR) == abc")
  }

  func testPredecessorUnicode() {
    // predecessor("\u{E000}") = "\u{10FFFF}" + MAX_PUSH_CHAR * (MAX_KEY_LEN - 2)
    let actual1 = FNextPushId.predecessor("\u{E000}")
    let expected1 = "\u{10FFFF}" + String(repeating: maxPushChar, count: MAX_KEY_LEN - 2)
    XCTAssertEqual(expected1, actual1, "predecessor(\\u{E000})")

    // predecessor("\u{10000}") = "\u{D7FF}" + MAX_PUSH_CHAR * (MAX_KEY_LEN - 2)
    let actual2 = FNextPushId.predecessor("\u{10000}")
    let expected2 = "\u{D7FF}" + String(repeating: maxPushChar, count: MAX_KEY_LEN - 2)
    XCTAssertEqual(expected2, actual2, "predecessor(\\u{10000})")

    // predecessor("\u{0080}") = "\u{007E}" + MAX_PUSH_CHAR * (MAX_KEY_LEN - 2)
    let actual3 = FNextPushId.predecessor("\u{0080}")
    let expected3 = "\u{007E}" + String(repeating: maxPushChar, count: MAX_KEY_LEN - 2)
    XCTAssertEqual(expected3, actual3, "predecessor(\\u{0080})")
  }

  func testPredecessorOrdering() {
    // Start after space (0x20) to avoid integer interpretation.
    for codePoint: UInt32 in 0x21 ..< 0xD800 {
      guard let scalar = Unicode.Scalar(codePoint) else { continue }
      let key = String(scalar)
      guard FValidation.isValidKey(key) else { continue }
      let predecessor = FNextPushId.predecessor(key)
      XCTAssertEqual(FUtilities.compareKey(key, predecessor), .orderedDescending,
                     "key '\(key)' (U+\(String(codePoint, radix: 16))) must be > its predecessor")
    }
    for codePoint: UInt32 in 0xE000 ... 0xFFFF {
      guard let scalar = Unicode.Scalar(codePoint) else { continue }
      let key = String(scalar)
      let predecessor = FNextPushId.predecessor(key)
      XCTAssertEqual(FUtilities.compareKey(key, predecessor), .orderedDescending,
                     "key '\(key)' (U+\(String(codePoint, radix: 16))) must be > its predecessor")
    }
    // Supplementary code points (> U+FFFF) — Swift handles these natively.
    for codePoint: UInt32 in 0x10000 ... 0x10FFFF {
      guard let scalar = Unicode.Scalar(codePoint) else { continue }
      let key = String(scalar)
      let predecessor = FNextPushId.predecessor(key)
      XCTAssertEqual(FUtilities.compareKey(key, predecessor), .orderedDescending,
                     "supplementary code point U+\(String(codePoint, radix: 16)) must be > its predecessor")
    }
  }

  func testSuccessorOrdering() {
    for codePoint: UInt32 in 0x21 ..< 0xD800 {
      guard let scalar = Unicode.Scalar(codePoint) else { continue }
      let key = String(scalar)
      guard FValidation.isValidKey(key) else { continue }
      let successor = FNextPushId.successor(key)
      XCTAssertEqual(FUtilities.compareKey(key, successor), .orderedAscending,
                     "key '\(key)' (U+\(String(codePoint, radix: 16))) must be < its successor")
    }
    for codePoint: UInt32 in 0xE000 ... 0xFFFF {
      guard let scalar = Unicode.Scalar(codePoint) else { continue }
      let key = String(scalar)
      let successor = FNextPushId.successor(key)
      XCTAssertEqual(FUtilities.compareKey(key, successor), .orderedAscending,
                     "key '\(key)' (U+\(String(codePoint, radix: 16))) must be < its successor")
    }
    // Supplementary code points (> U+FFFF)
    for codePoint: UInt32 in 0x10000 ... 0x10FFFF {
      guard let scalar = Unicode.Scalar(codePoint) else { continue }
      let key = String(scalar)
      let successor = FNextPushId.successor(key)
      XCTAssertEqual(FUtilities.compareKey(key, successor), .orderedAscending,
                     "supplementary code point U+\(String(codePoint, radix: 16)) must be < its successor")
    }
  }
}
