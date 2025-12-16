//
//  MotionSample.swift
//  liftempo
//
//  Created by Arthur Wong on 12/15/25.
//


import Foundation

struct MotionSample: Identifiable, Codable {
    let id = UUID()
    let timestamp: TimeInterval  // seconds since 1970
    let rotX: Double
    let rotY: Double
    let rotZ: Double
    let accX: Double
    let accY: Double
    let accZ: Double
}
