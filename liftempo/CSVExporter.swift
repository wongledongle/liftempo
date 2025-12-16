//
//  CSVExporter.swift
//  liftempo
//
//  Created by Arthur Wong on 12/15/25.
//


import Foundation

struct CSVExporter {

    static func sessionsToCSV(_ sessions: [Session]) -> String {
        var lines: [String] = []

        // Header
        lines.append("session_id,session_date,sample_index,timestamp,rotX,rotY,rotZ,accX,accY,accZ")

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        for session in sessions {
            let sessionId = session.id.uuidString
            let sessionDateString = dateFormatter.string(from: session.date)

            for (index, sample) in session.samples.enumerated() {
                let row = [
                    sessionId,
                    sessionDateString,
                    String(index),
                    String(sample.timestamp),
                    String(sample.rotX),
                    String(sample.rotY),
                    String(sample.rotZ),
                    String(sample.accX),
                    String(sample.accY),
                    String(sample.accZ)
                ]

                // Join with commas; no quotes needed since all are simple values
                lines.append(row.joined(separator: ","))
            }
        }

        return lines.joined(separator: "\n")
    }
}
