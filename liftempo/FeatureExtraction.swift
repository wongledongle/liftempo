#if os(iOS)
import Foundation

struct SessionFeatures {
    let sampleCount: Int
    let duration: TimeInterval
    let estimatedHz: Double
    let accelerationMagnitudeMean: Double
    let accelerationMagnitudeStdDev: Double
    let rotationMagnitudeMean: Double
    let rotationMagnitudeStdDev: Double
    let accelerationPeak: Double
    let rotationPeak: Double
    let windows: [FeatureWindow]
    let predictionSummary: PredictionSummary

    static let empty = SessionFeatures(
        sampleCount: 0,
        duration: 0,
        estimatedHz: 0,
        accelerationMagnitudeMean: 0,
        accelerationMagnitudeStdDev: 0,
        rotationMagnitudeMean: 0,
        rotationMagnitudeStdDev: 0,
        accelerationPeak: 0,
        rotationPeak: 0,
        windows: [],
        predictionSummary: .empty
    )
}

struct FeatureWindow: Identifiable {
    let id = UUID()
    let index: Int
    let startTime: TimeInterval
    let endTime: TimeInterval
    let accelerationMagnitudeMean: Double
    let accelerationMagnitudeStdDev: Double
    let rotationMagnitudeMean: Double
    let rotationMagnitudeStdDev: Double
    let dominantAccelerationAxis: String
    let dominantRotationAxis: String
    let featureVector: PhaseFeatureVector
    let prediction: PhasePrediction
}

struct PhaseFeatureVector {
    let meanAccMagnitude: Double
    let stdAccMagnitude: Double
    let meanRotMagnitude: Double
    let stdRotMagnitude: Double
    let meanAccX: Double
    let meanAccY: Double
    let meanAccZ: Double
    let meanRotX: Double
    let meanRotY: Double
    let meanRotZ: Double
    let windowDuration: Double
    let deltaAccZ: Double

    var values: [Double] {
        [
            meanAccMagnitude,
            stdAccMagnitude,
            meanRotMagnitude,
            stdRotMagnitude,
            meanAccX,
            meanAccY,
            meanAccZ,
            meanRotX,
            meanRotY,
            meanRotZ,
            windowDuration,
            deltaAccZ
        ]
    }
}

struct PredictionSummary {
    let classifierSource: String
    let eccentricCount: Int
    let concentricCount: Int
    let unknownCount: Int
    let averageConfidence: Double

    static let empty = PredictionSummary(
        classifierSource: "none",
        eccentricCount: 0,
        concentricCount: 0,
        unknownCount: 0,
        averageConfidence: 0
    )
}

enum FeatureExtractor {
    static func extract(from samples: [MotionSample], windowSize: Int = 25) -> SessionFeatures {
        guard samples.count > 1 else {
            return .empty
        }

        let sortedSamples = samples.sorted { $0.timestamp < $1.timestamp }
        let duration = sortedSamples.last!.timestamp - sortedSamples.first!.timestamp
        let estimatedHz = duration > 0 ? Double(sortedSamples.count - 1) / duration : 0

        let accelerationMagnitudes = sortedSamples.map { magnitude(x: $0.accX, y: $0.accY, z: $0.accZ) }
        let rotationMagnitudes = sortedSamples.map { magnitude(x: $0.rotX, y: $0.rotY, z: $0.rotZ) }

        let windows = makeWindows(from: sortedSamples, size: windowSize)
        let predictionSummary = summarizePredictions(windows)

        return SessionFeatures(
            sampleCount: sortedSamples.count,
            duration: duration,
            estimatedHz: estimatedHz,
            accelerationMagnitudeMean: mean(accelerationMagnitudes),
            accelerationMagnitudeStdDev: stdDev(accelerationMagnitudes),
            rotationMagnitudeMean: mean(rotationMagnitudes),
            rotationMagnitudeStdDev: stdDev(rotationMagnitudes),
            accelerationPeak: accelerationMagnitudes.max() ?? 0,
            rotationPeak: rotationMagnitudes.max() ?? 0,
            windows: windows,
            predictionSummary: predictionSummary
        )
    }

    private static func makeWindows(from samples: [MotionSample], size: Int) -> [FeatureWindow] {
        guard samples.count >= size else { return [] }

        var windows: [FeatureWindow] = []
        var startIndex = 0
        var windowIndex = 0
        let classifier = PhaseClassifier.shared

        while startIndex + size <= samples.count {
            let slice = Array(samples[startIndex..<(startIndex + size)])
            let accX = slice.map(\.accX)
            let accY = slice.map(\.accY)
            let accZ = slice.map(\.accZ)
            let rotX = slice.map(\.rotX)
            let rotY = slice.map(\.rotY)
            let rotZ = slice.map(\.rotZ)

            let accelerationMagnitudes = slice.map { magnitude(x: $0.accX, y: $0.accY, z: $0.accZ) }
            let rotationMagnitudes = slice.map { magnitude(x: $0.rotX, y: $0.rotY, z: $0.rotZ) }

            let vector = PhaseFeatureVector(
                meanAccMagnitude: mean(accelerationMagnitudes),
                stdAccMagnitude: stdDev(accelerationMagnitudes),
                meanRotMagnitude: mean(rotationMagnitudes),
                stdRotMagnitude: stdDev(rotationMagnitudes),
                meanAccX: mean(accX),
                meanAccY: mean(accY),
                meanAccZ: mean(accZ),
                meanRotX: mean(rotX),
                meanRotY: mean(rotY),
                meanRotZ: mean(rotZ),
                windowDuration: slice.last!.timestamp - slice.first!.timestamp,
                deltaAccZ: (slice.last?.accZ ?? 0) - (slice.first?.accZ ?? 0)
            )

            windows.append(
                FeatureWindow(
                    index: windowIndex,
                    startTime: slice.first!.timestamp,
                    endTime: slice.last!.timestamp,
                    accelerationMagnitudeMean: vector.meanAccMagnitude,
                    accelerationMagnitudeStdDev: vector.stdAccMagnitude,
                    rotationMagnitudeMean: vector.meanRotMagnitude,
                    rotationMagnitudeStdDev: vector.stdRotMagnitude,
                    dominantAccelerationAxis: dominantAxis(x: accX, y: accY, z: accZ),
                    dominantRotationAxis: dominantAxis(x: rotX, y: rotY, z: rotZ),
                    featureVector: vector,
                    prediction: classifier.predict(vector: vector)
                )
            )

            windowIndex += 1
            startIndex += size
        }

        return windows
    }

    private static func summarizePredictions(_ windows: [FeatureWindow]) -> PredictionSummary {
        guard !windows.isEmpty else { return .empty }

        let source = windows.first?.prediction.source ?? "none"
        let eccentric = windows.filter { $0.prediction.label == .eccentric }.count
        let concentric = windows.filter { $0.prediction.label == .concentric }.count
        let unknown = windows.filter { $0.prediction.label == .unknown }.count
        let averageConfidence = windows.map(\.prediction.confidence).reduce(0, +) / Double(windows.count)

        return PredictionSummary(
            classifierSource: source,
            eccentricCount: eccentric,
            concentricCount: concentric,
            unknownCount: unknown,
            averageConfidence: averageConfidence
        )
    }

    private static func dominantAxis(x: [Double], y: [Double], z: [Double]) -> String {
        let xScore = x.map(abs).reduce(0, +)
        let yScore = y.map(abs).reduce(0, +)
        let zScore = z.map(abs).reduce(0, +)

        if xScore >= yScore, xScore >= zScore { return "X" }
        if yScore >= xScore, yScore >= zScore { return "Y" }
        return "Z"
    }

    private static func magnitude(x: Double, y: Double, z: Double) -> Double {
        sqrt((x * x) + (y * y) + (z * z))
    }

    private static func mean(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private static func stdDev(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let avg = mean(values)
        let variance = values.reduce(0) { partial, value in
            partial + pow(value - avg, 2)
        } / Double(values.count)
        return sqrt(variance)
    }
}
#endif
