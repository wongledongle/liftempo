//
//  ContentView.swift
//  liftempo
//
//  Created by Arthur Wong on 12/15/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionStore: SessionStore

    var body: some View {
        NavigationStack {
            VStack {
                if sessionStore.sessions.isEmpty {
                    Text("No sets yet")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List(sessionStore.sessions) { session in
                        HStack {
                            Text("Set at")
                            Spacer()
                            Text(session.date.formatted(date: .omitted, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Debug / manual add button for now
                Button("Add dummy session") {
                    sessionStore.addSession()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Tempo Sets")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionStore())
}
