#if os(iOS)
import SwiftUI

struct SessionDetailView: View {
    let session: Session

    var body: some View {
        List {
            Section("Session") {
                LabeledContent("Started", value: session.date.formatted(date: .abbreviated, time: .standard))
                LabeledContent("Samples", value: "\(session.features.sampleCount)")
                LabeledContent("Duration", value: format(session.features.duration))
                LabeledContent("Estimated Rate", value: "\(formatted(session.features.estimatedHz, decimals: 1)) Hz")
                LabeledContent("Classifier", value: session.features.predictionSummary.classifierSource)
                LabeledContent("Avg confidence", value: formatted(session.features.predictionSummary.averageConfidence, decimals: 2))
            }

            Section("Predictions") {
                LabeledContent("Eccentric", value: "\(session.features.predictionSummary.eccentricCount)")
                LabeledContent("Concentric", value: "\(session.features.predictionSummary.concentricCount)")
                LabeledContent("Unknown", value: "\(session.features.predictionSummary.unknownCount)")
            }

            Section("Signal Summary") {
                LabeledContent("Accel mean", value: formatted(session.features.accelerationMagnitudeMean, decimals: 4))
                LabeledContent("Accel std dev", value: formatted(session.features.accelerationMagnitudeStdDev, decimals: 4))
                LabeledContent("Accel peak", value: formatted(session.features.accelerationPeak, decimals: 4))
                LabeledContent("Gyro mean", value: formatted(session.features.rotationMagnitudeMean, decimals: 4))
                LabeledContent("Gyro std dev", value: formatted(session.features.rotationMagnitudeStdDev, decimals: 4))
                LabeledContent("Gyro peak", value: formatted(session.features.rotationPeak, decimals: 4))
            }

            Section("Feature Windows") {
                if session.features.windows.isEmpty {
                    Text("Not enough samples to generate windows yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(session.features.windows) { window in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Window \(window.index + 1)")
                                .font(.headline)
                            Text("\(format(window.endTime - window.startTime)) span")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Text(window.prediction.label.rawValue.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(predictionColor(window.prediction.label).opacity(0.18))
                                    .clipShape(Capsule())
                                Text("conf \(formatted(window.prediction.confidence, decimals: 2))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text("Accel mean \(formatted(window.accelerationMagnitudeMean, decimals: 4))  std \(formatted(window.accelerationMagnitudeStdDev, decimals: 4))")
                                .font(.caption)
                            Text("Gyro mean \(formatted(window.rotationMagnitudeMean, decimals: 4))  std \(formatted(window.rotationMagnitudeStdDev, decimals: 4))")
                                .font(.caption)
                            Text("Dominant axes: accel \(window.dominantAccelerationAxis), gyro \(window.dominantRotationAxis)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Vector: \(window.featureVector.values.map { formatted($0, decimals: 3) }.joined(separator: ", "))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section("Raw Samples Preview") {
                ForEach(Array(session.samples.prefix(20))) { sample in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sample.timestamp.formatted(.number.precision(.fractionLength(3))))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("acc (\(formatted(sample.accX, decimals: 3)), \(formatted(sample.accY, decimals: 3)), \(formatted(sample.accZ, decimals: 3)))")
                            .font(.caption2)
                        Text("gyro (\(formatted(sample.rotX, decimals: 3)), \(formatted(sample.rotY, decimals: 3)), \(formatted(sample.rotZ, decimals: 3)))")
                            .font(.caption2)
                    }
                }
            }
        }
        .navigationTitle("Set Data")
    }

    private func format(_ interval: TimeInterval) -> String {
        "\(formatted(interval, decimals: 2))s"
    }

    private func formatted(_ value: Double, decimals: Int) -> String {
        String(format: "%.\(decimals)f", value)
    }

    private func predictionColor(_ label: PhaseLabel) -> Color {
        switch label {
        case .eccentric:
            return .blue
        case .concentric:
            return .green
        case .unknown:
            return .gray
        }
    }
}
#endif
