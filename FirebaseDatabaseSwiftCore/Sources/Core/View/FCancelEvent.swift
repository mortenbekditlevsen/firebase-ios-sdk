//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 09/03/2022.
//

import Foundation


public class FCancelEvent: FEvent {
    public var eventRegistration: FEventRegistration
    public var error: Error
    public var path: FPath

    public init(eventRegistration: FEventRegistration, error: Error, path: FPath) {
        self.eventRegistration = eventRegistration
        self.error = error
        self.path = path
    }

    public func fireEventOnQueue(_ queue: DispatchQueue) {
        eventRegistration.fireEvent(self, queue: queue)
    }
    public var isCancelEvent: Bool { true }
    public var description: String {
        "\(path): cancel"
    }
}
