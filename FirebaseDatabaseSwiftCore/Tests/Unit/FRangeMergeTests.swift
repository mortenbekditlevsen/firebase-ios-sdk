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

/// Convenience: build a node from any value (mirrors the ObjC NODE() macro).
private func node(_ val: Any?) -> FNode { FSnapshotUtilities.nodeFrom(val) }

final class FRangeMergeTests: XCTestCase {

  func testSmokeTest() {
    let base = node([
      "bar": "bar-value",
      "foo": ["a": ["deep-a-1": 1, "deep-a-2": 2], "b": "b", "c": "c", "d": "d"],
      "quu": "quu-value",
    ])
    let updates = node([
      "foo": ["a": ["deep-a-2": "new-a-2", "deep-a-3": 3], "b-2": "new-b", "c": "new-c"]
    ])
    let merge = FRangeMerge(start: FPath(with: "foo/a/deep-a-1"),
                            end: FPath(with: "foo/c"),
                            updates: updates)
    let expected = node([
      "bar": "bar-value",
      "foo": [
        "a": ["deep-a-1": 1, "deep-a-2": "new-a-2", "deep-a-3": 3],
        "b-2": "new-b",
        "c": "new-c",
        "d": "d",
      ],
      "quu": "quu-value",
    ])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testStartIsExclusive() {
    let base = node(["bar": "bar-value", "foo": "foo-value", "quu": "quu-value"])
    let updates = node(["foo": "new-foo-value"])
    let merge = FRangeMerge(start: FPath(with: "bar"), end: FPath(with: "foo"), updates: updates)
    let expected = node(["bar": "bar-value", "foo": "new-foo-value", "quu": "quu-value"])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testStartIsExclusiveButIncludesChildren() {
    let base = node(["bar": "bar-value", "foo": "foo-value", "quu": "quu-value"])
    let updates = node(["bar": ["bar-child": "bar-child-value"], "foo": "new-foo-value"])
    let merge = FRangeMerge(start: FPath(with: "bar"), end: FPath(with: "foo"), updates: updates)
    let expected = node([
      "bar": ["bar-child": "bar-child-value"],
      "foo": "new-foo-value",
      "quu": "quu-value",
    ])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testEndIsInclusive() {
    let base = node(["bar": "bar-value", "foo": "foo-value", "quu": "quu-value"])
    let updates = node(["baz": "baz-value"])
    // foo should be deleted (end is inclusive)
    let merge = FRangeMerge(start: FPath(with: "bar"), end: FPath(with: "foo"), updates: updates)
    let expected = node(["bar": "bar-value", "baz": "baz-value", "quu": "quu-value"])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testEndIsInclusiveButExcludesChildren() {
    let base = node(["bar": "bar-value", "foo": ["foo-child": "foo-child-value"], "quu": "quu-value"])
    let updates = node(["baz": "baz-value"])
    let merge = FRangeMerge(start: FPath(with: "bar"), end: FPath(with: "foo"), updates: updates)
    let expected = node([
      "bar": "bar-value",
      "baz": "baz-value",
      "foo": ["foo-child": "foo-child-value"],
      "quu": "quu-value",
    ])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testCanUpdateLeafNode() {
    let base = node("leaf-value")
    let updates = node(["bar": "bar-value"])
    let merge = FRangeMerge(start: nil, end: FPath(with: "foo"), updates: updates)
    let expected = node(["bar": "bar-value"])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testCanReplaceLeafNodeWithLeafNode() {
    let base = node("leaf-value")
    let updates = node("new-leaf-value")
    let merge = FRangeMerge(start: nil, end: FPath(with: ""), updates: updates)
    let expected = node("new-leaf-value")
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testLeafsAreUpdatedWhenRangesIncludeDeeperPath() {
    let base = node(["foo": ["bar": "bar-value"]])
    let updates = node(["foo": ["bar": "new-bar-value"]])
    let merge = FRangeMerge(start: FPath(with: "foo"),
                            end: FPath(with: "foo/bar/deep"),
                            updates: updates)
    let expected = node(["foo": ["bar": "new-bar-value"]])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testLeafsAreNotUpdatedWhenRangesIncludeDeeperPaths() {
    let base = node(["foo": ["bar": "bar-value"]])
    let updates = node(["foo": ["bar": "new-bar-value"]])
    let merge = FRangeMerge(start: FPath(with: "foo/bar"),
                            end: FPath(with: "foo/bar/deep"),
                            updates: updates)
    let expected = node(["foo": ["bar": "bar-value"]])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testUpdatingEntireRangeUpdatesEverything() {
    let base = FNode.empty
    let updates = node(["foo": "foo-value", "bar": ["child": "bar-child-value"]])
    let merge = FRangeMerge(start: nil, end: nil, updates: updates)
    let expected = node(["foo": "foo-value", "bar": ["child": "bar-child-value"]])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testUpdatingRangeWithUnboundedLeftPostWorks() {
    let base = node(["bar": "bar-value", "foo": "foo-value"])
    let updates = node(["bar": "new-bar"])
    let merge = FRangeMerge(start: nil, end: FPath(with: "bar"), updates: updates)
    let expected = node(["bar": "new-bar", "foo": "foo-value"])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testUpdatingRangeWithRightPostChildOfLeftPostWorks() {
    let base = node(["foo": ["a": "a", "b": ["1": "1", "2": "2"], "c": "c"]])
    let updates = node(["foo": ["a": "new-a", "b": ["1": "new-1"]]])
    let merge = FRangeMerge(start: FPath(with: "foo"),
                            end: FPath(with: "foo/b/1"),
                            updates: updates)
    let expected = node(["foo": ["a": "new-a", "b": ["1": "new-1", "2": "2"], "c": "c"]])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testUpdatingRangeWithRightPostChildOfLeftPostWorksWithIntegerKeys() {
    let base = node(["foo": ["a": "a", "b": ["1": "1", "2": "2", "10": "10"], "c": "c"]])
    let updates = node(["foo": ["a": "new-a", "b": ["1": "new-1"]]])
    let merge = FRangeMerge(start: FPath(with: "foo"),
                            end: FPath(with: "foo/b/2"),
                            updates: updates)
    let expected = node(["foo": ["a": "new-a", "b": ["1": "new-1", "10": "10"], "c": "c"]])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testUpdatingLeafIncludesPriority() {
    let base = node(["bar": "bar-value", "foo": "foo-value", "quu": "quu-value"])
    let updates = node(["foo": [".value": "new-foo", ".priority": "prio"]])
    let merge = FRangeMerge(start: FPath(with: "bar"), end: FPath(with: "foo"), updates: updates)
    let expected = node([
      "bar": "bar-value",
      "foo": [".value": "new-foo", ".priority": "prio"],
      "quu": "quu-value",
    ])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testUpdatingPriorityInChildrenNodeWorks() {
    let base = node(["bar": "bar-value", "foo": "foo-value"])
    let updates = node(["bar": "new-bar", ".priority": "prio"])
    let merge = FRangeMerge(start: nil, end: FPath(with: "bar"), updates: updates)
    let expected = node(["bar": "new-bar", "foo": "foo-value", ".priority": "prio"])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testUpdatingPriorityOnInitiallyEmptyNodeDoesNotBreak() {
    let base = node([:])
    let updates = node([".priority": "prio", "foo": "foo-value"])
    let merge = FRangeMerge(start: nil, end: FPath(with: "foo"), updates: updates)
    let expected = node(["foo": "foo-value", ".priority": "prio"])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testPriorityIsDeletedWhenIncludedInChildrenRange() {
    let base = node(["bar": "bar-value", "foo": "foo-value", ".priority": "prio"])
    let updates = node(["bar": "new-bar"])
    // deletes priority (open start includes it)
    let merge = FRangeMerge(start: nil, end: FPath(with: "bar"), updates: updates)
    let expected = node(["bar": "new-bar", "foo": "foo-value"])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testPriorityIsIncludedInOpenStart() {
    let base = node(["foo": ["bar": "bar-value"]])
    let updates = node([".priority": "prio", "baz": "baz"])
    let merge = FRangeMerge(start: nil, end: FPath(with: "foo/bar"), updates: updates)
    let expected = node(["baz": "baz", ".priority": "prio"])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }

  func testPriorityIsIncludedInOpenEnd() {
    let base = node("leaf-node")
    let updates = node([".priority": "prio", "foo": "bar"])
    let merge = FRangeMerge(start: FPath(with: "/"), end: nil, updates: updates)
    let expected = node(["foo": "bar", ".priority": "prio"])
    XCTAssertEqual(merge.applyToNode(base), expected)
  }
}
