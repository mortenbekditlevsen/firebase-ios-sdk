//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 22/06/2023.
//

import Foundation

#if canImport(Observation)
import Observation

@available(macOS 14.0, *)
@Observable
class Live<Model: Decodable>: Observable {
    subscript<T>(dynamicMember keyPath: KeyPath<Model, T>) -> T? {
        model?[keyPath: keyPath]
    }

    var model: Model? = nil
}
#endif

public protocol CollectionPathProtocol {
    associatedtype Element
}
public typealias CollectionPath<T> = DbPath.Path<DbPath.Collection<T>>
public typealias Path<T> = DbPath.Path<T>
extension DbPath.Collection: CollectionPathProtocol {
    public typealias Element = Entity
}

public enum DbPath {
    public struct Collection<Entity> {}

    public struct Path<Element> {

        private var components: [String]

        public func _append<T>(
            _ args: [String]
        ) -> Path<T> {
            Path<T>(
                components + args
            )
        }

        public func _append<T>(
            _ arg: String
        ) -> Path<T> {
            Path<T>(
                components + [arg]
            )
        }

        private init(
            _ components: [String]
        ) {
            self.components = components
        }

        var rendered: String {
            components.joined(separator: "/")
        }
    }
}
extension Path where Element: CollectionPathProtocol {
    public func child(_ key: String) -> Path<Element.Element> {
        _append(key)
    }
}

public extension DbPath {
    enum Root {}
}

extension Path where Element == DbPath.Root {
    public init() {
        self.components = []
    }
}
