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

final class FQueryParamsTests: XCTestCase {

  func testQueryParamsEquals() {
    // Limit equals
    let limLast10 = FQueryParams.defaultInstance.limitToLast(10)
    let lim10 = FQueryParams.defaultInstance.limitTo(10)
    let limFirst10 = FQueryParams.defaultInstance.limitToFirst(10)
    let limLast11 = FQueryParams.defaultInstance.limitToLast(11)
    XCTAssertEqual(limLast10, lim10)
    XCTAssertEqual(limLast10.hashValue, lim10.hashValue)
    XCTAssertNotEqual(limLast10, limFirst10)
    XCTAssertNotEqual(limLast10, limLast11)

    // Index equals
    let byPriority = FQueryParams.defaultInstance.orderBy(.priority)
    let byPriority2 = FQueryParams.defaultInstance.orderBy(.priority)
    let byKey = FQueryParams.defaultInstance.orderBy(.key)
    XCTAssertEqual(byPriority, byPriority2)
    XCTAssertEqual(byPriority.hashValue, byPriority2.hashValue)
    XCTAssertNotEqual(byPriority, byKey)

    // startAt equals
    let start1 = FQueryParams.defaultInstance.startAt(FSnapshotUtilities.nodeFrom("value"))
    let start2 = FQueryParams.defaultInstance.startAt(FSnapshotUtilities.nodeFrom("value"),
                                                       childKey: nil)
    let start3 = FQueryParams.defaultInstance.startAt(FSnapshotUtilities.nodeFrom("value-2"))
    XCTAssertEqual(start1, start2)
    XCTAssertEqual(start1.hashValue, start2.hashValue)
    XCTAssertNotEqual(start1, start3)

    // startAt with childKey equals
    let startKey1 = FQueryParams.defaultInstance.startAt(.empty, childKey: "key")
    let startKey2 = FQueryParams.defaultInstance.startAt(.empty, childKey: "key")
    let startKey3 = FQueryParams.defaultInstance.startAt(.empty, childKey: "other-key")
    XCTAssertEqual(startKey1, startKey2)
    XCTAssertEqual(startKey1.hashValue, startKey2.hashValue)
    XCTAssertNotEqual(startKey1, startKey3)

    // endAt equals
    let end1 = FQueryParams.defaultInstance.endAt(FSnapshotUtilities.nodeFrom("value"))
    let end2 = FQueryParams.defaultInstance.endAt(FSnapshotUtilities.nodeFrom("value"),
                                                   childKey: nil)
    let end3 = FQueryParams.defaultInstance.endAt(FSnapshotUtilities.nodeFrom("value-2"))
    XCTAssertEqual(end1, end2)
    XCTAssertEqual(end1.hashValue, end2.hashValue)
    XCTAssertNotEqual(end1, end3)

    // endAt with childKey equals
    let endKey1 = FQueryParams.defaultInstance.endAt(.empty, childKey: "key")
    let endKey2 = FQueryParams.defaultInstance.endAt(.empty, childKey: "key")
    let endKey3 = FQueryParams.defaultInstance.endAt(.empty, childKey: "other-key")
    XCTAssertEqual(endKey1, endKey2)
    XCTAssertEqual(endKey1.hashValue, endKey2.hashValue)
    XCTAssertNotEqual(endKey1, endKey3)

    // Limit/startAt equals
    let limitStart1 = FQueryParams.defaultInstance
      .limitToFirst(10)
      .startAt(FSnapshotUtilities.nodeFrom("value"))
    let limitStart2 = FQueryParams.defaultInstance
      .limitTo(10)
      .startAt(FSnapshotUtilities.nodeFrom("value"))
    let limitStart3 = FQueryParams.defaultInstance
      .limitTo(10)
      .startAt(FSnapshotUtilities.nodeFrom("value-2"))
    XCTAssertEqual(limitStart1, limitStart2)
    XCTAssertEqual(limitStart1.hashValue, limitStart2.hashValue)
    XCTAssertNotEqual(limitStart1, limitStart3)
  }

  func testFromDictionaryEquals() {
    let params = FQueryParams.defaultInstance
      .limitToLast(10)
      .startAt(FSnapshotUtilities.nodeFrom("start-value"), childKey: "child-key-2")
      .endAt(FSnapshotUtilities.nodeFrom("end-value"), childKey: "child-key-2")
      .orderBy(.key)
    let roundTripped = FQueryParams.fromQueryObject(params.wireProtocolParams)
    XCTAssertEqual(params, roundTripped)
    XCTAssertEqual(params.hashValue, roundTripped.hashValue)
  }

  func testCanCreateAllIndexes() {
    let byKey = FQueryParams.defaultInstance.orderBy(.key)
    let byValue = FQueryParams.defaultInstance.orderBy(.value)
    let byPriority = FQueryParams.defaultInstance.orderBy(.priority)
    let byPath = FQueryParams.defaultInstance.orderBy(.path(FPath(with: "subkey")))

    XCTAssertEqual(byKey, FQueryParams.fromQueryObject(byKey.wireProtocolParams))
    XCTAssertEqual(byValue, FQueryParams.fromQueryObject(byValue.wireProtocolParams))
    XCTAssertEqual(byPriority, FQueryParams.fromQueryObject(byPriority.wireProtocolParams))
    XCTAssertEqual(byPath, FQueryParams.fromQueryObject(byPath.wireProtocolParams))

    XCTAssertEqual(byKey.hashValue,
                   FQueryParams.fromQueryObject(byKey.wireProtocolParams).hashValue)
    XCTAssertEqual(byValue.hashValue,
                   FQueryParams.fromQueryObject(byValue.wireProtocolParams).hashValue)
    XCTAssertEqual(byPriority.hashValue,
                   FQueryParams.fromQueryObject(byPriority.wireProtocolParams).hashValue)
    XCTAssertEqual(byPath.hashValue,
                   FQueryParams.fromQueryObject(byPath.wireProtocolParams).hashValue)
  }

  func testDifferentLimits() {
    let first10 = FQueryParams.defaultInstance.limitToFirst(10)
    let last10 = FQueryParams.defaultInstance.limitToLast(10)
    let lim10 = FQueryParams.defaultInstance.limitTo(10)

    XCTAssertEqual(first10, FQueryParams.fromQueryObject(first10.wireProtocolParams))
    XCTAssertEqual(last10, FQueryParams.fromQueryObject(last10.wireProtocolParams))
    XCTAssertEqual(lim10, FQueryParams.fromQueryObject(lim10.wireProtocolParams))
    // limitToLast and limitTo are equivalent
    XCTAssertEqual(last10, FQueryParams.fromQueryObject(lim10.wireProtocolParams))

    XCTAssertEqual(first10.hashValue,
                   FQueryParams.fromQueryObject(first10.wireProtocolParams).hashValue)
    XCTAssertEqual(last10.hashValue,
                   FQueryParams.fromQueryObject(last10.wireProtocolParams).hashValue)
    XCTAssertEqual(lim10.hashValue,
                   FQueryParams.fromQueryObject(lim10.wireProtocolParams).hashValue)
    XCTAssertEqual(last10.hashValue,
                   FQueryParams.fromQueryObject(lim10.wireProtocolParams).hashValue)
  }

  func testStartAtNullIsSerializable() {
    let params = FQueryParams.defaultInstance.startAt(.empty, childKey: "key")
    let parsed = FQueryParams.fromQueryObject(params.wireProtocolParams)
    XCTAssertEqual(parsed, params)
    XCTAssertTrue(parsed.hasStart)
  }

  func testEndAtNullIsSerializable() {
    let params = FQueryParams.defaultInstance.endAt(.empty, childKey: "key")
    let parsed = FQueryParams.fromQueryObject(params.wireProtocolParams)
    XCTAssertEqual(parsed, params)
    XCTAssertTrue(parsed.hasEnd)
  }
}
