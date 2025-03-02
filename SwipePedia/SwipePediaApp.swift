//
//  SwipePediaApp.swift
//  SwipePedia
//
//  Created by Serkan Dogantekin on 16.02.2025.
//

import SwiftUI
import FirebaseCore

@main
struct SwipePediaApp: App {
    init() {
        FirebaseManager.shared.configure()
        // Log app open event
        FirebaseManager.shared.logAppOpen()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
