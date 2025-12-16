//
//  Session.swift
//  liftempo
//
//  Created by Arthur Wong on 12/15/25.
//

import Foundation

struct Session: Identifiable {
    let id: UUID
    let date: Date
    let samples: [MotionSample]

    init(id: UUID = UUID(), date: Date = Date(), samples: [MotionSample] = []) {
        self.id = id
        self.date = date
        self.samples = samples
    }
}
