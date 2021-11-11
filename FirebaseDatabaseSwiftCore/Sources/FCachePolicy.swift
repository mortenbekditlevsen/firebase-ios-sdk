//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 10/11/2021.
//

import Foundation

public protocol FCachePolicy: NSObjectProtocol {
  func shouldPruneCacheWithSize(_ cacheSize: Int, numberOfTrackedQueries: Int) -> Bool
  func shouldCheckCacheSize(_ serverUpdatesSinceLastCheck: Int) -> Bool
  func percentOfQueriesToPruneAtOnce() -> Double
  func maxNumberOfQueriesToKeep() -> Int
}

private let kFMaxNumberOfPrunableQueriesToKeep = 1000
private let kFServerUpdatesBetweenCacheSizeChecks = 1000
private let kFPercentOfQueriesToPruneAtOnce: Double = 0.2

public class FLRUCachePolicy: NSObject, FCachePolicy {
  private let maxSize: Int
  public init(maxSize: Int) {
    self.maxSize = maxSize
  }
  func shouldPruneCacheWithSize(_ cacheSize: Int, numberOfTrackedQueries: Int) -> Bool {
    cacheSize > self.maxSize ||
    numTrackedQueries > kFMaxNumberOfPrunableQueriesToKeep
  }
  func shouldCheckCacheSize(_ serverUpdatesSinceLastCheck: Int) -> Bool {
    serverUpdatesSinceLastCheck > kFServerUpdatesBetweenCacheSizeChecks
  }
  func percentOfQueriesToPruneAtOnce() -> Double {
    kFPercentOfQueriesToPruneAtOnce
  }
  func maxNumberOfQueriesToKeep() -> Int {
    kFMaxNumberOfPrunableQueriesToKeep
  }
}

public class FNoCachePolicy: NSObject, FCachePolicy {
  static var noCachePolicy: FNoCachePolicy = FNoCachePolicy()

  func shouldPruneCacheWithSize(_ cacheSize: Int, numberOfTrackedQueries: Int) -> Bool {
    false
  }
  func shouldCheckCacheSize(_ serverUpdatesSinceLastCheck: Int) -> Bool {
    false
  }
  func percentOfQueriesToPruneAtOnce() -> Double {
    0
  }
  func maxNumberOfQueriesToKeep() -> Int {
    Int.max
  }
}
