//
//  liftempoApp.swift
//  liftempo
//
//  Created by Arthur Wong on 12/15/25.
//

import SwiftUI

@main
struct liftempoApp: App {
    @StateObject private var sessionStore = SessionStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
                .onAppear {
                    PhoneConnectivity.shared.configure(with: sessionStore)
                }
        }
    }
}

