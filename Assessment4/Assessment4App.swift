//
//  Assessment4App.swift
//  Assessment4
//
//  Created by netblen on 10-02-2026.
//

import SwiftUI

@main
struct Assessment4App: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            let context = persistenceController.container.viewContext
            ContentView()
                .environment(\.managedObjectContext, context)
      
                .environmentObject(LibraryHolder(context))
        }
    }
}
