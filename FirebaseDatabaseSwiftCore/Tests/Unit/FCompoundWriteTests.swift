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

final class FCompoundWriteTests: XCTestCase {

  private var leafNode: FNode { FSnapshotUtilities.nodeFrom("leaf-node") }
  private var priorityNode: FNode { FSnapshotUtilities.nodeFrom("prio") }
  private var baseNode: FNode {
    FSnapshotUtilities.nodeFrom(["child-1": "value-1", "child-2": "value-2"])
  }

  /// Asserts that applying `compoundWrite` to `node` equals `node.updatePriority(priority)`.
  /// If `node` is empty the result must also be empty.
  private func assertApplied(_ compoundWrite: FCompoundWrite,
                              equalsNode node: FNode,
                              withPriority priority: FNode,
                              file: StaticString = #file, line: UInt = #line) {
    let updated = compoundWrite.applyToNode(node)
    if node.isEmpty {
      XCTAssertEqual(FNode.empty, updated, file: file, line: line)
    } else {
      XCTAssertEqual(node.updatePriority(priority), updated, file: file, line: line)
    }
  }

  func testEmptyMergeIsEmpty() {
    XCTAssertTrue(FCompoundWrite.emptyWrite.isEmpty)
  }

  func testCompoundWriteWithPriorityUpdateIsNotEmpty() {
    let cw = FCompoundWrite.emptyWrite.addWrite(priorityNode, atKey: ".priority")
    XCTAssertFalse(cw.isEmpty)
  }

  func testCompoundWriteWithUpdateIsNotEmpty() {
    let cw = FCompoundWrite.emptyWrite.addWrite(leafNode, atPath: FPath(with: "foo/bar"))
    XCTAssertFalse(cw.isEmpty)
  }

  func testCompoundWriteWithRootUpdateIsNotEmpty() {
    let cw = FCompoundWrite.emptyWrite.addWrite(leafNode, atPath: .empty)
    XCTAssertFalse(cw.isEmpty)
  }

  func testCompoundWriteWithEmptyRootUpdateIsNotEmpty() {
    let cw = FCompoundWrite.emptyWrite.addWrite(.empty, atPath: .empty)
    XCTAssertFalse(cw.isEmpty)
  }

  func testCompoundWriteWithRootPriorityUpdateAndChildMergeIsNotEmpty() {
    let cw = FCompoundWrite.emptyWrite
      .addWrite(priorityNode, atKey: ".priority")
      .childCompoundWriteAtPath(FPath(with: ".priority"))
    XCTAssertFalse(cw.isEmpty)
  }

  func testAppliesLeafOverwrite() {
    let cw = FCompoundWrite.emptyWrite.addWrite(leafNode, atPath: .empty)
    XCTAssertEqual(cw.applyToNode(.empty), leafNode)
  }

  func testAppliesChildrenOverwrite() {
    let childNode = FNode.empty.updateImmediateChild("child", withNewChild: leafNode)
    let cw = FCompoundWrite.emptyWrite.addWrite(childNode, atPath: .empty)
    XCTAssertEqual(cw.applyToNode(.empty), childNode)
  }

  func testAddsChildNode() {
    let expected = FNode.empty.updateImmediateChild("child", withNewChild: leafNode)
    let cw = FCompoundWrite.emptyWrite.addWrite(leafNode, atKey: "child")
    XCTAssertEqual(cw.applyToNode(.empty), expected)
  }

  func testAddsDeepChildNode() {
    let path = FPath(with: "deep/deep/node")
    let expected = FNode.empty.updateChild(path, withNewChild: leafNode)
    let cw = FCompoundWrite.emptyWrite.addWrite(leafNode, atPath: path)
    XCTAssertEqual(cw.applyToNode(.empty), expected)
  }

  func testOverwritesExistingChild() {
    let path = FPath(with: "child-1")
    let cw = FCompoundWrite.emptyWrite.addWrite(leafNode, atPath: path)
    let updated = cw.applyToNode(baseNode)
    let expected = baseNode.updateImmediateChild(path.getFront()!, withNewChild: leafNode)
    XCTAssertEqual(updated, expected)
  }

  func testChildMergeWithEmptyPathIsSameMerge() {
    let update = FSnapshotUtilities.nodeFrom(["foo": "foo-value", "bar": "bar-value"])
    let cw = FCompoundWrite.emptyWrite.addWrite(update, atPath: .empty)
    XCTAssertEqual(cw.childCompoundWriteAtPath(.empty), cw)
  }

  func testRootUpdateRemovesRootPriority() {
    let update = FSnapshotUtilities.nodeFrom("foo")
    let cw = FCompoundWrite.emptyWrite
      .addWrite(priorityNode, atPath: FPath(with: ".priority"))
      .addWrite(update, atPath: .empty)
    XCTAssertEqual(cw.applyToNode(.empty), update)
  }

  func testDeepUpdateRemovesPriorityThere() {
    let update = FSnapshotUtilities.nodeFrom("bar")
    let cw = FCompoundWrite.emptyWrite
      .addWrite(priorityNode, atPath: FPath(with: "foo/.priority"))
      .addWrite(update, atPath: FPath(with: "foo"))
    let expected = FSnapshotUtilities.nodeFrom(["foo": "bar"])
    XCTAssertEqual(cw.applyToNode(.empty), expected)
  }

  func testAddingUpdatesAtPathWorks() {
    let updates = FCompoundWrite.compoundWrite(
      valueDictionary: ["foo": "foo-value", "bar": "bar-value"])
    let cw = FCompoundWrite.emptyWrite
      .addCompoundWrite(updates, atPath: FPath(with: "child-1"))
    let expected = baseNode.updateImmediateChild(
      "child-1",
      withNewChild: FSnapshotUtilities.nodeFrom(["foo": "foo-value", "bar": "bar-value"]))
    XCTAssertEqual(cw.applyToNode(baseNode), expected)
  }

  func testAddingUpdatesAtRootWorks() {
    let updates = FCompoundWrite.compoundWrite(
      valueDictionary: ["child-1": "new-value-1", "child-2": NSNull(), "child-3": "value-3"])
    let cw = FCompoundWrite.emptyWrite.addCompoundWrite(updates, atPath: .empty)
    let expected = FSnapshotUtilities.nodeFrom(["child-1": "new-value-1", "child-3": "value-3"])
    XCTAssertEqual(cw.applyToNode(baseNode), expected)
  }

  func testChildMergeOfRootPriorityWorks() {
    let cw = FCompoundWrite.emptyWrite
      .addWrite(priorityNode, atPath: FPath(with: ".priority"))
      .childCompoundWriteAtPath(FPath(with: ".priority"))
    XCTAssertEqual(cw.applyToNode(.empty), priorityNode)
  }

  func testCompleteChildrenOnlyReturnsCompleteOverwrites() {
    let cw = FCompoundWrite.emptyWrite.addWrite(leafNode, atPath: FPath(with: "child-1"))
    let complete = cw.completeChildren
    XCTAssertEqual(complete.count, 1)
    XCTAssertEqual(complete.first?.name, "child-1")
    XCTAssertEqual(complete.first?.node, leafNode)
  }

  func testCompleteChildrenOnlyReturnsEmptyOverwrites() {
    let cw = FCompoundWrite.emptyWrite.addWrite(.empty, atPath: FPath(with: "child-1"))
    let complete = cw.completeChildren
    XCTAssertEqual(complete.count, 1)
    XCTAssertEqual(complete.first?.name, "child-1")
    XCTAssertEqual(complete.first?.node, .empty)
  }

  func testCompleteChildrenDoesntReturnDeepOverwrites() {
    let cw = FCompoundWrite.emptyWrite.addWrite(leafNode, atPath: FPath(with: "child-1/deep/path"))
    XCTAssertTrue(cw.completeChildren.isEmpty)
  }

  func testCompleteChildrenReturnAllCompleteChildrenButNoIncomplete() {
    let cw = FCompoundWrite.emptyWrite
      .addWrite(leafNode, atPath: FPath(with: "child-1/deep/path"))
      .addWrite(leafNode, atPath: FPath(with: "child-2"))
      .addWrite(.empty, atPath: FPath(with: "child-3"))
    var actual: [String: FNode] = [:]
    for namedNode in cw.completeChildren {
      actual[namedNode.name] = namedNode.node
    }
    XCTAssertEqual(actual["child-2"], leafNode)
    XCTAssertEqual(actual["child-3"], .empty)
    XCTAssertNil(actual["child-1"])
  }

  func testCompleteChildrenReturnAllChildrenForRootSet() {
    let cw = FCompoundWrite.emptyWrite.addWrite(baseNode, atPath: .empty)
    var actual: [String: FNode] = [:]
    for namedNode in cw.completeChildren {
      actual[namedNode.name] = namedNode.node
    }
    XCTAssertEqual(actual["child-1"], FSnapshotUtilities.nodeFrom("value-1"))
    XCTAssertEqual(actual["child-2"], FSnapshotUtilities.nodeFrom("value-2"))
  }

  func testEmptyMergeHasNoShadowingWrite() {
    XCTAssertFalse(FCompoundWrite.emptyWrite.hasCompleteWriteAtPath(.empty))
  }

  func testCompoundWriteWithEmptyRootHasShadowingWrite() {
    let cw = FCompoundWrite.emptyWrite.addWrite(.empty, atPath: .empty)
    XCTAssertTrue(cw.hasCompleteWriteAtPath(.empty))
    XCTAssertTrue(cw.hasCompleteWriteAtPath(FPath(with: "child")))
  }

  func testCompoundWriteWithRootHasShadowingWrite() {
    let cw = FCompoundWrite.emptyWrite.addWrite(leafNode, atPath: .empty)
    XCTAssertTrue(cw.hasCompleteWriteAtPath(.empty))
    XCTAssertTrue(cw.hasCompleteWriteAtPath(FPath(with: "child")))
  }

  func testCompoundWriteWithDeepUpdateHasShadowingWrite() {
    let cw = FCompoundWrite.emptyWrite.addWrite(leafNode, atPath: FPath(with: "deep/update"))
    XCTAssertFalse(cw.hasCompleteWriteAtPath(.empty))
    XCTAssertFalse(cw.hasCompleteWriteAtPath(FPath(with: "deep")))
    XCTAssertTrue(cw.hasCompleteWriteAtPath(FPath(with: "deep/update")))
  }

  func testCompoundWriteWithPriorityUpdateHasShadowingWrite() {
    let cw = FCompoundWrite.emptyWrite.addWrite(priorityNode, atPath: FPath(with: ".priority"))
    XCTAssertFalse(cw.hasCompleteWriteAtPath(.empty))
    XCTAssertTrue(cw.hasCompleteWriteAtPath(FPath(with: ".priority")))
  }

  func testUpdatesCanBeRemoved() {
    let update = FSnapshotUtilities.nodeFrom(["foo": "foo-value", "bar": "bar-value"])
    let cw = FCompoundWrite.emptyWrite
      .addWrite(update, atPath: FPath(with: "child-1"))
      .removeWriteAtPath(FPath(with: "child-1"))
    XCTAssertEqual(cw.applyToNode(baseNode), baseNode)
  }

  func testDeepRemovesHasNoEffectOnOverlayingSet() {
    let update1 = FSnapshotUtilities.nodeFrom(["foo": "foo-value", "bar": "bar-value"])
    let update2 = FSnapshotUtilities.nodeFrom("baz-value")
    let update3 = FSnapshotUtilities.nodeFrom("new-foo-value")
    let cw = FCompoundWrite.emptyWrite
      .addWrite(update1, atPath: FPath(with: "child-1"))
      .addWrite(update2, atPath: FPath(with: "child-1/baz"))
      .addWrite(update3, atPath: FPath(with: "child-1/foo"))
      .removeWriteAtPath(FPath(with: "child-1/foo"))
    let expected = baseNode.updateImmediateChild(
      "child-1",
      withNewChild: FSnapshotUtilities.nodeFrom(
        ["foo": "new-foo-value", "bar": "bar-value", "baz": "baz-value"]))
    XCTAssertEqual(cw.applyToNode(baseNode), expected)
  }

  func testRemoveAtPathWithoutSetIsWithoutEffect() {
    let update1 = FSnapshotUtilities.nodeFrom(["foo": "foo-value", "bar": "bar-value"])
    let update2 = FSnapshotUtilities.nodeFrom("baz-value")
    let update3 = FSnapshotUtilities.nodeFrom("new-foo-value")
    let cw = FCompoundWrite.emptyWrite
      .addWrite(update1, atPath: FPath(with: "child-1"))
      .addWrite(update2, atPath: FPath(with: "child-1/baz"))
      .addWrite(update3, atPath: FPath(with: "child-1/foo"))
      .removeWriteAtPath(FPath(with: "child-2"))
    let expected = baseNode.updateImmediateChild(
      "child-1",
      withNewChild: FSnapshotUtilities.nodeFrom(
        ["foo": "new-foo-value", "bar": "bar-value", "baz": "baz-value"]))
    XCTAssertEqual(cw.applyToNode(baseNode), expected)
  }

  func testCanRemovePriority() {
    let cw = FCompoundWrite.emptyWrite
      .addWrite(priorityNode, atPath: FPath(with: ".priority"))
      .removeWriteAtPath(FPath(with: ".priority"))
    assertApplied(cw, equalsNode: leafNode, withPriority: .empty)
  }

  func testRemovingOnlyAffectsRemovedPath() {
    let updates = FCompoundWrite.compoundWrite(
      valueDictionary: ["child-1": "new-value-1", "child-2": NSNull(), "child-3": "value-3"])
    let cw = FCompoundWrite.emptyWrite
      .addCompoundWrite(updates, atPath: .empty)
      .removeWriteAtPath(FPath(with: "child-2"))
    let expected = FSnapshotUtilities.nodeFrom(
      ["child-1": "new-value-1", "child-2": "value-2", "child-3": "value-3"])
    XCTAssertEqual(cw.applyToNode(baseNode), expected)
  }

  func testRemoveRemovesAllDeeperSets() {
    let update2 = FSnapshotUtilities.nodeFrom("baz-value")
    let update3 = FSnapshotUtilities.nodeFrom("new-foo-value")
    let cw = FCompoundWrite.emptyWrite
      .addWrite(update2, atPath: FPath(with: "child-1/baz"))
      .addWrite(update3, atPath: FPath(with: "child-1/foo"))
      .removeWriteAtPath(FPath(with: "child-1"))
    XCTAssertEqual(cw.applyToNode(baseNode), baseNode)
  }

  func testRemoveAtRootAlsoRemovesPriority() {
    let nodeWithPriority = FNode.leaf("foo", priority: priorityNode)
    let cw = FCompoundWrite.emptyWrite
      .addWrite(nodeWithPriority, atPath: .empty)
      .removeWriteAtPath(.empty)
    assertApplied(cw, equalsNode: FSnapshotUtilities.nodeFrom("value"), withPriority: .empty)
  }

  func testUpdatingPriorityDoesntOverwriteLeafNode() {
    let cw = FCompoundWrite.emptyWrite
      .addWrite(leafNode, atPath: .empty)
      .addWrite(priorityNode, atPath: FPath(with: "child/.priority"))
    XCTAssertEqual(cw.applyToNode(.empty), leafNode)
  }

  func testUpdatingEmptyChildNodeDoesntOverwriteLeafNode() {
    let cw = FCompoundWrite.emptyWrite
      .addWrite(leafNode, atPath: .empty)
      .addWrite(.empty, atPath: FPath(with: "child"))
    XCTAssertEqual(cw.applyToNode(.empty), leafNode)
  }
}
