//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 19/02/2022.
//

import Foundation

struct FWriteRecordImpl: Hashable, Equatable {
  let writeId: Int
  let path: FPath
  // TODO: Overwrite or merge are mutually exclusive
  // and as such they should be two cases of an enum
  let overwrite: FNode?
  let merge: FCompoundWrite?
  let visible: Bool
  init(path: FPath, overwrite: FNode, writeId: Int, visible: Bool) {
    self.path = path
    self.overwrite = overwrite
    self.merge = nil
    self.writeId = writeId
    self.visible = visible
  }

  init(path: FPath, merge: FCompoundWrite, writeId: Int) {
    self.path = path
    self.merge = merge
    self.overwrite = nil
    self.writeId = writeId
    self.visible = true
  }
  var isMerge: Bool {
    merge != nil
  }

  var isOverwrite: Bool {
    overwrite != nil
  }

  var debugDescription: String {
    if let overwrite = overwrite {
      return "FWriteRecord { writeId = \(writeId), path = \(path), overwrite = \(overwrite), visible = \(visible) }"
    } else {
      return "FWriteRecord { writeId = \(writeId), path = \(path), merge = \(merge!) }"
    }
  }
}

protocol Ski: Hashable {}


class FWriteRecord {
  let impl: FWriteRecordImpl

  init(path: FPath, overwrite: FNode, writeId: Int, visible: Bool) {
    self.impl = FWriteRecordImpl(path: path, overwrite: overwrite, writeId: writeId, visible: visible)
  }

  init(path: FPath, merge: FCompoundWrite, writeId: Int) {
    self.impl = .init(path: path, merge: merge, writeId: writeId)
  }

  var writeId: Int { impl.writeId }
  var visible: Bool { impl.visible }
  var path: FPath { impl.path }
  var isOverwrite: Bool { impl.isOverwrite }
  var isMerge: Bool { impl.isMerge }
  var overwrite: FNode? { impl.overwrite }
  var merge: FCompoundWrite? { impl.merge }
    var hash: Int { impl.hashValue }
    var debugDescription: String {
        impl.debugDescription
    }

    var description: String {
        impl.debugDescription
    }

    func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? FWriteRecord else { return false }
        return other.impl == self.impl
    }
}
