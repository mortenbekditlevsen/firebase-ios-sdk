//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 03/03/2022.
//

import Foundation

private struct QueryParams: Hashable, Equatable {
    static func == (lhs: QueryParams, rhs: QueryParams) -> Bool {
        lhs.limitSet == rhs.limitSet &&
        lhs.limit == rhs.limit &&
        lhs.isViewFromLeft == rhs.isViewFromLeft &&
        (lhs.indexStartValue?.isEqual(rhs.indexStartValue) ?? true) &&
        (rhs.indexStartValue?.isEqual(lhs.indexStartValue) ?? true) &&
        lhs.indexStartKey == rhs.indexStartKey &&
        (lhs.indexEndValue?.isEqual(rhs.indexEndValue) ?? true) &&
        (rhs.indexEndValue?.isEqual(lhs.indexEndValue) ?? true) &&
        lhs.indexEndKey == rhs.indexEndKey &&
        lhs.index.isEqual(rhs.index)
    }

    func hash(into hasher: inout Hasher) {
        limitSet.hash(into: &hasher)
        limit.hash(into: &hasher)
        isViewFromLeft.hash(into: &hasher)
        if let x = indexStartValue {
            x.hash.hash(into: &hasher)
        } else {
            "xyz".hash(into: &hasher)
        }
        indexStartKey.hash(into: &hasher)
        if let x = indexEndValue {
            x.hash.hash(into: &hasher)
        } else {
            "zyx".hash(into: &hasher)
        }
        index.hash.hash(into: &hasher)
    }

    var isViewFromLeft: Bool {
        if viewFrom != nil {
            // Not null, we can just check
            return viewFrom == kFQPViewFromLeft
        } else {
            // If start is set, it's view from left. Otherwise not.
            return hasStart
        }
    }

    var hasStart: Bool {
        indexStartValue != nil
    }

    var hasEnd: Bool {
        indexEndValue != nil
    }

    public var limitSet: Bool
    public var limit: Int
    public var viewFrom: String?
    public var indexStartValue: FNode?
    public var indexStartKey: String?
    public var indexEndValue: FNode?
    public var indexEndKey: String?
    public var index: FIndex

//
//    public static func fromQueryObject(_ dict: [String: Any]) -> FQueryParams {
//        guard dict.count > 0 else {
//            return .defaultInstance
//        }
//        if let val = dict[kFQPIndexStartValue] {
//            params.indexStartValue = FSnapshotUtilities.nodeFrom(val)
//            if let key = dict[kFQPIndexStartName] as? String {
//                params.indexStartKey = key
//            }
//        }
//        if let val = dict[kFQPIndexEndValue] {
//            params.indexEndValue = FSnapshotUtilities.nodeFrom(val)
//            if let key = dict[kFQPIndexEndName] as? String {
//                params.indexEndKey = key
//            }
//        }
//        if let vf = dict[kFQPViewFrom] as? String {
//            if vf != kFQPViewFromLeft && vf != kFQPViewFromRight {
//                fatalError("Unknown view from paramter: \(vf)")
//            }
//            params.viewFrom = vf
//        }
//        if let index = dict[kFQPIndex] as? String {
//            params.index = FIndexFactory.indexFromQueryDefinition(index)
//        }
//        return FQueryParams(params: params)
//    }

}

public struct FQueryParams: Hashable {

    private var params: QueryParams
    public var limitSet: Bool { params.limitSet }
    public var viewFrom: String? { params.viewFrom }
    public var index: FIndex { params.index }

    public var loadsAllData: Bool {
        !(hasStart || hasEnd || limitSet)
    }

    public var isDefault: Bool {
        loadsAllData && index.isEqual(FPriorityIndex.priorityIndex)
    }

    public var isValid: Bool {
        !(hasStart && hasEnd && limitSet && !hasAnchoredLimit)
    }

    /**
     * @return true if a limit has been set and has been explicitly anchored
     */
    public var hasAnchoredLimit: Bool {
        limitSet && viewFrom != nil
    }

    /**
     * Only valid if hasEnd is true.
     * @return The end key name for the range defined by these query parameters
     */
    public var indexEndKey: String {
        assert(hasEnd, "Only valid if end has been set")
        return params.indexEndKey ?? FUtilities.maxName
    }

    /**
     * Only valid if hasEnd is true.
     */
    public var indexEndValue: FNode {
        assert(hasEnd, "Only valid if end has been set")
        return params.indexEndValue!
    }

    /**
     * Only valid if hasStart is true
     */
    public var indexStartValue: FNode {
        assert(hasStart, "Only valid if start has been set")
        return params.indexStartValue!
    }

    /**
     * Only valid if hasStart is true.
     * @return The starting key name for the range defined by these query parameters
     */
    public var indexStartKey: String {
        assert(hasStart, "Only valid if start has been set")
        return params.indexStartKey ?? FUtilities.minName
    }

    public init() {
        self.params = QueryParams(limitSet: false,
                                  limit: 0,
                                  index: FPriorityIndex.priorityIndex)
    }

    /**
     * Only valid to call if limitSet returns true
     */
    public var limit: Int {
        assert(self.limitSet, "Only valid if limit has been set")
        return params.limit
    }

    public func limitTo(_ limit: Int) -> FQueryParams {
        var params = params
        params.limit = limit
        params.limitSet = true
        params.viewFrom = nil
        return FQueryParams(params: params)
    }


    public func limitToFirst(_ limit: Int) -> FQueryParams {
        var params = params
        params.limit = limit
        params.limitSet = true
        params.viewFrom = kFQPViewFromLeft
        return FQueryParams(params: params)
    }

    public func limitToLast(_ limit: Int) -> FQueryParams {
        var params = params
        params.limit = limit
        params.limitSet = true
        params.viewFrom = kFQPViewFromRight
        return FQueryParams(params: params)
    }

    public func startAt(_ indexValue: FNode, childKey: String?) -> FQueryParams {
        assert(indexValue.isLeafNode() || indexValue.isEmpty)
        var params = params
        params.indexStartValue = indexValue
        params.indexStartKey = childKey
        return FQueryParams(params: params)
    }

    public func startAt(_ indexValue: FNode) -> FQueryParams {
        startAt(indexValue, childKey: nil)
    }

    public func endAt(_ indexValue: FNode, childKey: String?) -> FQueryParams {
        assert(indexValue.isLeafNode() || indexValue.isEmpty)
        var params = params
        params.indexEndValue = indexValue
        params.indexEndKey = childKey
        return FQueryParams(params: params)
    }

    public func endAt(_ indexValue: FNode) -> FQueryParams {
        endAt(indexValue, childKey: nil)
    }

    public func orderBy(_ index: FIndex) -> FQueryParams {
        var params = params
        params.index = index
        return FQueryParams(params: params)
    }

    public static var defaultInstance: FQueryParams = FQueryParams()

    private init(params: QueryParams) {
        self.params = params
    }

    public static func fromQueryObject(_ dict: [String: Any]) -> FQueryParams {
        guard dict.count > 0 else {
            return .defaultInstance
        }
        var params = QueryParams(limitSet: false, limit: 0, index: FPriorityIndex.priorityIndex)
        if let val = dict[kFQPLimit] as? Int {
            params.limitSet = true
            params.limit = val
        }
        if let val = dict[kFQPIndexStartValue] {
            params.indexStartValue = FSnapshotUtilities.nodeFrom(val)
            if let key = dict[kFQPIndexStartName] as? String {
                params.indexStartKey = key
            }
        }
        if let val = dict[kFQPIndexEndValue] {
            params.indexEndValue = FSnapshotUtilities.nodeFrom(val)
            if let key = dict[kFQPIndexEndName] as? String {
                params.indexEndKey = key
            }
        }
        if let vf = dict[kFQPViewFrom] as? String {
            if vf != kFQPViewFromLeft && vf != kFQPViewFromRight {
                fatalError("Unknown view from paramter: \(vf)")
            }
            params.viewFrom = vf
        }
        if let index = dict[kFQPIndex] as? String {
            params.index = FIndexFactory.indexFromQueryDefinition(index)
        }
        return FQueryParams(params: params)
    }

    public var hasStart: Bool {
        params.hasStart
    }

    public var hasEnd: Bool {
        params.hasEnd
    }

    public var wireProtocolParams: [String: Any] {
        var dict: [String: Any] = [:]
        if let value = params.indexStartValue {
            dict[kFQPIndexStartValue] = value.val(forExport: true)
        }
        if let value = params.indexStartKey {
            dict[kFQPIndexStartName] = value
        }
        if let value = params.indexEndValue {
            dict[kFQPIndexEndValue] = value.val(forExport: true)
        }
        if let value = params.indexEndKey {
            dict[kFQPIndexEndName] = value
        }
        if params.limitSet {
            dict[kFQPLimit] = params.limit
            var vf = params.viewFrom
            if vf == nil {
                // limit() rather than limitToFirst or limitToLast was called.
                // This means that only one of startSet or endSet is true. Use them
                // to calculate which side of the view to anchor to. If neither is
                // set, Anchor to end
                if hasStart {
                    vf = kFQPViewFromLeft
                } else {
                    vf = kFQPViewFromRight
                }
            }
            dict[kFQPViewFrom] = vf
        }
        // For now, priority index is the default, so we only specify if it's some
        // other index.
        if !index.isEqual(FPriorityIndex.priorityIndex) {
            dict[kFQPIndex] = index.queryDefinition
        }

        return dict
    }

    public var description: String {
        // Ensure that description is always in same order, as it is (apparently) used
        // to generate keys - at least in test cases.
        let sortedParams = wireProtocolParams.map { ($0, $1) }.sorted(by: { $0.0 < $1.0 })
        return "[\(sortedParams.map { "\"\($0.0)\": \($0.1)" }.joined(separator: ", "))]"
    }

    public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? FQueryParams else { return false }
        return other.params == self.params
    }

    public var hash: Int {
        var hasher = Hasher()
        params.hash(into: &hasher)
        return hasher.finalize()
    }

    public var isViewFromLeft: Bool {
        params.isViewFromLeft
    }

    public var nodeFilter: FNodeFilter {
        if loadsAllData {
            return FIndexedFilter(index: index)
        } else if limitSet {
            return FLimitedFilter(queryParams: self)
        } else {
            return FRangedFilter(queryParams: self)
        }
    }
}
