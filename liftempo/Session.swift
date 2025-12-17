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
    let features: SessionFeatures

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        samples: [MotionSample] = [],
        features: SessionFeatures? = nil
    ) {
        self.id = id
        self.date = date
        self.samples = samples
        self.features = features ?? FeatureExtractor.extract(from: samples)
    }
}
