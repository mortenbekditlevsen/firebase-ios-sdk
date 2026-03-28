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

/// Convenience: create a node from a raw value.
private func node(_ val: Any?) -> FNode {
  FSnapshotUtilities.nodeFrom(val)
}

/// Convenience: create a node from a value with a priority.
private func node(_ val: Any?, priority: Any?) -> FNode {
  FSnapshotUtilities.nodeFrom(val, priority: priority)
}

final class FNodeTests: XCTestCase {

  func testLeafNodeEqualsHashCode() {
    let falseNode = node(false)
    let trueNode = node(true)
    let stringOneNode = node("one")
    let stringTwoNode = node("two")
    let zeroNode = node(0)
    let oneNode = node(1)
    let emptyNode1 = node(nil)
    let emptyNode2 = node(NSNull())

    XCTAssertEqual(falseNode, node(false))
    XCTAssertEqual(falseNode.hashValue, node(false).hashValue)
    XCTAssertEqual(trueNode, node(true))
    XCTAssertEqual(trueNode.hashValue, node(true).hashValue)
    XCTAssertNotEqual(falseNode, trueNode)
    XCTAssertNotEqual(falseNode, oneNode)
    XCTAssertNotEqual(falseNode, stringOneNode)
    XCTAssertNotEqual(falseNode, emptyNode1)

    XCTAssertEqual(stringOneNode, node("one"))
    XCTAssertEqual(stringOneNode.hashValue, node("one").hashValue)
    XCTAssertNotEqual(stringOneNode, stringTwoNode)
    XCTAssertNotEqual(stringOneNode, emptyNode1)
    XCTAssertNotEqual(stringOneNode, oneNode)
    XCTAssertNotEqual(stringOneNode, trueNode)

    XCTAssertEqual(zeroNode, node(0))
    XCTAssertEqual(zeroNode.hashValue, node(0).hashValue)
    XCTAssertNotEqual(zeroNode, oneNode)
    XCTAssertNotEqual(zeroNode, emptyNode1)
    XCTAssertNotEqual(zeroNode, falseNode)

    XCTAssertEqual(emptyNode1, emptyNode2)
    XCTAssertEqual(emptyNode1.hashValue, emptyNode2.hashValue)
  }

  func testLeafNodePrioritiesEqualsHashCode() {
    let oneOne = node(1, priority: 1)
    let stringOne = node("value", priority: 1)
    let oneString = node(1, priority: "value")
    let stringString = node("value", priority: "value")

    XCTAssertEqual(oneOne, node(1, priority: 1))
    XCTAssertEqual(oneOne.hashValue, node(1, priority: 1).hashValue)
    XCTAssertNotEqual(oneOne, stringOne)
    XCTAssertNotEqual(oneOne, oneString)
    XCTAssertNotEqual(oneOne, stringString)

    XCTAssertEqual(stringOne, node("value", priority: 1))
    XCTAssertEqual(stringOne.hashValue, node("value", priority: 1).hashValue)
    XCTAssertNotEqual(stringOne, oneOne)
    XCTAssertNotEqual(stringOne, oneString)
    XCTAssertNotEqual(stringOne, stringString)

    XCTAssertEqual(oneString, node(1, priority: "value"))
    XCTAssertEqual(oneString.hashValue, node(1, priority: "value").hashValue)
    XCTAssertNotEqual(oneString, stringOne)
    XCTAssertNotEqual(oneString, oneOne)
    XCTAssertNotEqual(oneString, stringString)

    XCTAssertEqual(stringString, node("value", priority: "value"))
    XCTAssertEqual(stringString.hashValue, node("value", priority: "value").hashValue)
    XCTAssertNotEqual(stringString, stringOne)
    XCTAssertNotEqual(stringString, oneString)
    XCTAssertNotEqual(stringString, oneOne)
  }

  func testChildrenNodeEqualsHashCode() {
    let nodeOne = node(["one": 1, "two": 2, ".priority": "prio"])
    var nodeTwo = FNode.empty
      .updateImmediateChild("one", withNewChild: node(1))
    nodeTwo = nodeTwo.updateImmediateChild("two", withNewChild: node(2))
    nodeTwo = nodeTwo.updatePriority(node("prio"))

    XCTAssertEqual(nodeOne, nodeTwo)
    XCTAssertEqual(nodeOne.hashValue, nodeTwo.hashValue)
    XCTAssertNotEqual(nodeOne.updatePriority(.empty), nodeOne)
    XCTAssertNotEqual(
      nodeOne.updateImmediateChild("one", withNewChild: .empty),
      nodeOne
    )
    XCTAssertNotEqual(
      nodeOne.updateImmediateChild("one", withNewChild: node(2)),
      nodeOne
    )
  }

  func testLeadingZerosWorkCorrectly() {
    let data: [String: Any] = ["1": 1, "01": 2, "001": 3, "0001": 4]
    let n = node(data)
    XCTAssertEqual(n.getImmediateChild("1").val(), 1)
    XCTAssertEqual(n.getImmediateChild("01").val(), 2)
    XCTAssertEqual(n.getImmediateChild("001").val(), 3)
    XCTAssertEqual(n.getImmediateChild("0001").val(), 4)
  }

  func testLeadingZerosArePreservedInValue() {
    let data: [String: Any] = ["1": 1, "01": 2, "001": 3, "0001": 4]
    let n = node(data)
    // val() returns an AnyHashable dictionary; verify the keys are preserved
    if let dict = n.val() as? [String: Any] {
      XCTAssertEqual(dict["1"] as? Int, 1)
      XCTAssertEqual(dict["01"] as? Int, 2)
      XCTAssertEqual(dict["001"] as? Int, 3)
      XCTAssertEqual(dict["0001"] as? Int, 4)
    } else {
      XCTFail("Expected dictionary from val()")
    }
  }

  func testEmptyNodeEqualsEmptyChildrenNode() {
    XCTAssertEqual(FNode.empty, FNode.children([:]))
    XCTAssertEqual(FNode.children([:]), FNode.empty)
    XCTAssertEqual(FNode.children([:]).hashValue, FNode.empty.hashValue)
  }

  func testUpdatingEmptyChildrenDoesntOverwriteLeafNode() {
    let leafNode = FNode.leaf("value")
    XCTAssertEqual(leafNode, leafNode.updateChild(FPath(with: ".priority"),
                                                   withNewChild: .empty))
    XCTAssertEqual(leafNode, leafNode.updateChild(FPath(with: "child"),
                                                   withNewChild: .empty))
    XCTAssertEqual(leafNode, leafNode.updateChild(FPath(with: "child/.priority"),
                                                   withNewChild: .empty))
    XCTAssertEqual(leafNode, leafNode.updateImmediateChild("child", withNewChild: .empty))
    XCTAssertEqual(leafNode, leafNode.updateImmediateChild(".priority", withNewChild: .empty))
  }

  func testUpdatingPrioritiesOnEmptyNodesIsANoOp() {
    let priority = node("prio")

    XCTAssertTrue(FNode.empty.updatePriority(priority).getPriority().isEmpty)
    XCTAssertTrue(FNode.empty
      .updateChild(FPath(with: ".priority"), withNewChild: priority)
      .getPriority().isEmpty)
    XCTAssertTrue(FNode.empty
      .updateImmediateChild(".priority", withNewChild: priority)
      .getPriority().isEmpty)

    // Add a child, then remove it — result should be empty again
    let valueNode = node("value")
    let childPath = FPath(with: "child")
    let reemptied = FNode.empty
      .updateChild(childPath, withNewChild: valueNode)
      .updateChild(childPath, withNewChild: .empty)

    XCTAssertTrue(reemptied.updatePriority(priority).getPriority().isEmpty)
    XCTAssertTrue(reemptied
      .updateChild(FPath(with: ".priority"), withNewChild: priority)
      .getPriority().isEmpty)
    XCTAssertTrue(reemptied
      .updateImmediateChild(".priority", withNewChild: priority)
      .getPriority().isEmpty)
  }

  func testDeletingLastChildFromChildrenNodeRemovesPriority() {
    let priority = node("prio")
    let valueNode = node("value")
    let childPath = FPath(with: "child")
    let withPriority = FNode.empty
      .updateChild(childPath, withNewChild: valueNode)
      .updatePriority(priority)
    XCTAssertEqual(priority, withPriority.getPriority())
    let deletedChild = withPriority.updateChild(childPath, withNewChild: .empty)
    XCTAssertTrue(deletedChild.getPriority().isEmpty)
  }

  func testFromNodeReturnsEmptyNodesWithoutPriority() {
    let empty1 = node([".priority": "prio"])
    XCTAssertTrue(empty1.getPriority().isEmpty)

    let empty2 = node(["dummy": NSNull(), ".priority": "prio"])
    XCTAssertTrue(empty2.getPriority().isEmpty)
  }
}
