//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 20/06/2023.
//

import Foundation
import FirebaseDatabaseSwiftCore
import FirebaseAuth

func main() async {
    FirebaseApp.configure(options: FirebaseApp.Options(databaseURL: "https://firestoretests-44fc8.firebaseio.com",  projectID: "firestoretests-44fc8", googleAppID: "1:649012064016:ios:b4dcc2e22b3b90ea", apiKey: "AIzaSyC9NV44W_Takzurg41lo7nxXpUr3vugI88", clientID: "649012064016-pdglutubaeg3rik5feojtq29lk5trf2a.apps.googleusercontent.com"))

    // With the current hackish setup, we need to initialize Auth
    // before Database. :-)
    Database.setLoggingEnabled(true)
    let auth = Auth.auth()
    if let result = try? await auth.signIn(withEmail: "bek@termestrup.dk", password: "hamster") {
        print("UID: \(result.user.uid)")
    }

//    try? auth.signOut()
    let database = Database.database()
    database.isPersistenceEnabled = false
//    database.reference().child("chatroom_index/a").observeSingleEventOfType(.value) { snapshot in
//        print(snapshot.value)
//    }
    database.reference().child("chatroom_index/a").observeEventType(.value) { snap in
        print(snap.value)

    }
}

struct ChatRoom: Codable {
    var name: String
    var description: String
}

Task {
    await main()
}
RunLoop.main.run()
