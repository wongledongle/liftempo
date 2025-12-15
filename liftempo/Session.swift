//
//  Session.swift
//  liftempo
//
//  Created by Arthur Wong on 12/15/25.
//


import Foundation

struct Session: Identifiable, Hashable {
    let id: UUID
    let date: Date

    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}
