//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 20/06/2023.
//

import Foundation
import FirebaseDatabaseSwiftCore
import FirebaseAuth
//import Observation
//
//// TODO: Override decoder, override db
//
////@Observable
//class Live<Model: Decodable> {
//    subscript<T>(dynamicMember keyPath: KeyPath<Model, T>) -> T? {
//        model?[keyPath: keyPath]
//    }
//
//    var model: Model? = nil
//    var handle: DatabaseHandle? = nil
//    var path: String? = nil
//    init(path: String) {
//        self.path = path
//        let database = Database.database()
//        handle =  database.reference().child(path).observeEventType(.value) { [weak self] snap in
//            guard let self else {
//                return
//            }
//            guard let decoded = try? snap.data(as: Model.self) else {
//                self.model = nil
//                return
//            }
//            print("UPDATING \(decoded)")
//            self.model = decoded
//        }
//    }
//    deinit {
//        if let handle, let path {
//            let database = Database.database()
//            database.reference()
//                .child(path)
//                .removeObserverWithHandle(handle)
//        }
//    }
//}
//
//
//public protocol CollectionPathProtocol {
//    associatedtype Element
//}
//public typealias CollectionPath<T> = DbPath.Path<DbPath.Collection<T>>
//public typealias Path<T> = DbPath.Path<T>
//extension DbPath.Collection: CollectionPathProtocol {
//    public typealias Element = Entity
//}
//
//public enum DbPath {
//    public struct Collection<Entity> {}
//
//    public struct Path<Element> {
//
//        private var components: [String]
//
//        private func append<T>(
//            _ args: [String]
//        ) -> Path<T> {
//            Path<T>(
//                components + args
//            )
//        }
//
//        private func append<T>(
//            _ arg: String
//        ) -> Path<T> {
//            Path<T>(
//                components + [arg]
//            )
//        }
//
//        private init(
//            _ components: [String]
//        ) {
//            self.components = components
//        }
//
//        var rendered: String {
//            components.joined(separator: "/")
//        }
//    }
//}
//extension Path where Element: CollectionPathProtocol {
//    public func child(_ key: String) -> Path<Element.Element> {
//        append([key])
//    }
//}
//
//public extension DbPath {
//    enum Root {}
//}
//
//extension Path where Element == DbPath.Root {
//    public init() {
//        self.components = []
//    }
//
//    public var chatroomIndex: CollectionPath<ChatRoom> {
//        append("chatroom_index")
//    }
//}


#if canImport(Observation)
// TODO: Override decoder, override db

@available(macOS 14.0, *)
class RTDBLive<Model: Decodable>: Live<Model> {
    var handle: DatabaseHandle? = nil
    var path: String? = nil
    let database: Database
    init(path: String, database: Database) {
        self.path = path
        self.database = Database.database()
        super.init()
        handle = database.reference().child(path).observeEventType(.value) { [weak self] snap in
            guard let self else {
                return
            }
            guard let decoded = try? snap.data(as: Model.self) else {
                self.model = nil
                return
            }
            print("UPDATING \(decoded)")
            self.model = decoded
        }
    }
    deinit {
        if let handle, let path {
            database.reference()
                .child(path)
                .removeObserverWithHandle(handle)
        }
    }
}
#endif

extension Path where Element == DbPath.Root {
    public var chatroomIndex: CollectionPath<ChatRoom> {
        _append("chatroom_index")
    }
}

extension Database {
    #if canImport(Observation)
    @available(macOS 14.0, *)
    func liveValue<T: Decodable>(at path: Path<T>) -> Live<T> {
        RTDBLive(path: path.rendered, database: self)
    }

    @available(macOS 14.0, *)
    func liveValue<T: Decodable>(at path: CollectionPath<T>) -> Live<[String: T]> {
        RTDBLive(path: path.rendered, database: self)
    }
    #endif

    func `get`<T: Decodable>(at path: Path<T>, buffered: Bool = false) async throws -> T {
        let ref = reference().child(path.rendered)
        if buffered {
            return try await ref.observeSingle(as: T.self)
        } else {
            return try await ref.get(as: T.self)
        }
    }

    func `get`<T: Decodable>(at path: CollectionPath<T>, buffered: Bool = false) async throws -> [String: T] {
        let ref = reference().child(path.rendered)
        if buffered {
            return try await ref.observeSingle(as: [String: T].self)
        } else {
            return try await ref.get(as: [String: T].self)
        }
    }
}

//var live: Live<[String: ChatRoom]>?

@MainActor
 func main() async {
        FirebaseApp.configure(options: FirebaseApp.Options(databaseURL: "https://firestoretests-44fc8.firebaseio.com",  projectID: "firestoretests-44fc8", googleAppID: "1:649012064016:ios:b4dcc2e22b3b90ea", apiKey: "AIzaSyC9NV44W_Takzurg41lo7nxXpUr3vugI88", clientID: "649012064016-pdglutubaeg3rik5feojtq29lk5trf2a.apps.googleusercontent.com"))
        
        // With the current hackish setup, we need to initialize Auth
        // before Database. :-)
        Database.setLoggingEnabled(true)
        let auth = Auth.auth()
     try? auth.signOut()
        if let currentUser = auth.currentUser {
            print("Current user UID: \(currentUser.uid)")
        } else {
            do {
                let result = try await auth.signIn(
                    withEmail: "bek@termestrup.dk",
                    password: "hamster"
                )
                print("UID: \(result.user.uid)")
            } catch {
                print("ERROR", error)
            }
        }
        //    Path().chatroomIndex.child("a")
        //    try? auth.signOut()
        //    auth.currentUser?.uid
        let database = Database.database()
        database.isPersistenceEnabled = false
        
        //live = database.liveValue(at: Path().chatroomIndex)
        
            database.reference().child("chatroom_index/a").observeSingleEventOfType(.value) { snapshot in
                print(snapshot.value)
            }
        //    database.reference().child("chatroom_index/a").observeEventType(.value) { snap in
        //        print(snap.value)
        //
        //    }
    }

public struct ChatRoom: Codable {
    public var name: String
    public var description: String
}

Task {
    await main()
}
RunLoop.main.run()
