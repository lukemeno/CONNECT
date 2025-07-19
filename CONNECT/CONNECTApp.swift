//
//  CONNECTApp.swift
//  CONNECT
//
//  Created by Luke on 19.07.25.
//

import SwiftUI
import SwiftData

@main
struct CONNECTApp: App {
    let dependencyContainer = DependencyContainer()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Moment.self,
            Comment.self,
            Reaction.self,
            FriendRequest.self,
            Community.self,
            Event.self,
            Location.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(dependencyContainer)
                .environmentObject(dependencyContainer.authenticationManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
