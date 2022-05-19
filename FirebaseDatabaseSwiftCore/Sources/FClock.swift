//
//  FClock.swift
//  FClock
//
//  Created by Morten Bek Ditlevsen on 09/09/2021.
//

import Foundation

public protocol FClock {
    var currentTime: TimeInterval { get }
}

public class FSystemClock: FClock {
    public static var clock: FSystemClock = FSystemClock()
    public var currentTime: TimeInterval {
        Date().timeIntervalSince1970
    }
}

public class FOffsetClock: FClock {
    private let clock: FClock
    private let offset: TimeInterval
    public init(clock: FClock, offset: TimeInterval) {
        self.clock = clock
        self.offset = offset
    }
    public var currentTime: TimeInterval {
        clock.currentTime + offset
    }
}
