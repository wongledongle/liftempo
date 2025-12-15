//
//  SessionStore.swift
//  liftempo
//
//  Created by Arthur Wong on 12/15/25.
//


import Foundation
import Combine

class SessionStore: ObservableObject {
    @Published var sessions: [Session] = []

    func addSession(date: Date = Date()) {
        let newSession = Session(date: date)
        sessions.insert(newSession, at: 0) // newest first
    }
}
